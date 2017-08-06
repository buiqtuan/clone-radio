//
//  NowPlayingVC.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/4/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import GoogleMobileAds

class NowPlayingVC: UIViewController, UINavigationControllerDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var likeIcon: UIBarButtonItem!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var playButtonIcon: UIButton!
    @IBOutlet weak var volumeSilder: UIView!
    
    
    var incomingChannel: Channel!
    var isThumbnailRorating = false
    var incomingAVPlayer: AVPlayer!
    var volumeView: MPVolumeView!
    var mediaControlCenter: MPNowPlayingInfoCenter!
    var subInterstitial: GADInterstitial!
    let _ad = UIApplication.shared.delegate as! AppDelegate
    var _context: AnyObject! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        self.thumbnail.layer.cornerRadius = 110
        self.thumbnail.clipsToBounds = true
        
        UtilClass.setImageFromUrl(urlStr: incomingChannel.pic!, thumbnail: self.thumbnail)
        
        channelName.text = incomingChannel.name
        
        if self.incomingAVPlayer.isPlaying {
            playButtonIcon.setImage(UIImage(named: "ic_pause_36pt_3x.png"), for: .normal)
        } else {
            playButtonIcon.setImage(UIImage(named: "ic_play_arrow_black_36dp.png"), for: .normal)
        }
        
        
        //configure slider -- NEED TO TEST ON REAL DEVICE
        volumeSilder.backgroundColor = UIColor.clear
        self.volumeView = MPVolumeView(frame: self.volumeSilder.bounds)
        self.volumeView.frame.origin = volumeSilder.bounds.origin;
        self.volumeView.center = CGPoint(x: self.volumeSilder.frame.size.width/2,
                                         y: self.volumeSilder.frame.size.height/2)
        self.volumeView.showsRouteButton = false
        self.volumeSilder.addSubview(self.volumeView)
        
        //Start circling the view when AVPlayer is fully loaded
        incomingAVPlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        
        if self.incomingAVPlayer.isPlaying && self.incomingChannel.link == UserDefaults.standard.string(forKey: KEY_CURRENT_PLAYED_LINK) {
            self.thumbnail.startRotating(duration: 8, clockwise: true)
        }
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.thumbnail.stopRotating()
            self.isThumbnailRorating = false
            self.incomingAVPlayer.pause()
            self.playButtonIcon.setImage(UIImage(named: "ic_play_arrow_black_36dp.png" ), for: .normal)
            return MPRemoteCommandHandlerStatus.success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.thumbnail.startRotating(duration: 8, clockwise: true)
            self.isThumbnailRorating = true
            self.incomingAVPlayer.play()
            self.playButtonIcon.setImage(UIImage(named: "ic_pause_36pt_3x.png" ), for: .normal)
            return MPRemoteCommandHandlerStatus.success
        }
        
        _context = self._ad.persistentContainer.viewContext
        
        if incomingChannel.isFavorite {
            likeIcon.image = UIImage(named: "ic_star_36pt.png")
        } else {
            likeIcon.image = UIImage(named: "ic_star_border_black_36dp_1x.png")
        }
        
        UserDefaults.standard.synchronize()
        
        //Add ads
        subInterstitial = GADInterstitial(adUnitID: INTER_ADS_NOWPLAYING_ID)
        subInterstitial.delegate = self
        subInterstitial.load(GADRequest())
    }
    
    @objc
    override func observeValue(forKeyPath keyPath: String?, of object: Any!, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if incomingAVPlayer.status == AVPlayerStatus.readyToPlay {
                self.thumbnail.startRotating(duration: 8, clockwise: true)
                isThumbnailRorating = true
                UserDefaults.standard.set(self.incomingChannel.link, forKey: KEY_CURRENT_PLAYED_LINK)
            }
        }
        self.incomingAVPlayer.removeObserver(self, forKeyPath: "status")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        self.subInterstitial = GADInterstitial(adUnitID: INTER_ADS_NOWPLAYING_ID)
        subInterstitial.delegate = self
        subInterstitial.load(GADRequest())
        return subInterstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.subInterstitial = createAndLoadInterstitial()
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if !isThumbnailRorating {
            self.thumbnail.startRotating(duration: 8, clockwise: true)
            isThumbnailRorating = true
            incomingAVPlayer.play()
            playButtonIcon.setImage(UIImage(named: "ic_pause_36pt_3x.png" ), for: .normal)
        } else {
            self.thumbnail.stopRotating()
            isThumbnailRorating = false
            incomingAVPlayer.pause()
            playButtonIcon.setImage(UIImage(named: "ic_play_arrow_black_36dp.png" ), for: .normal)
        }
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        //play: 100 - pause: 101
        if let type = event?.subtype.rawValue {
            switch type {
            case 100:
                self.incomingAVPlayer.play()
                self.playButtonIcon.setImage(UIImage(named: "ic_pause_36pt_3x.png" ), for: .normal)
                self.thumbnail.startRotating(duration: 8, clockwise: true)
                break
            case 101:
                self.incomingAVPlayer.pause()
                self.playButtonIcon.setImage(UIImage(named: "ic_play_arrow_black_36dp.png" ), for: .normal)
                self.thumbnail.stopRotating()
                break
            default:
                break
            }
        }
    }

    @IBAction func likeButton(_ sender: Any) {
        if incomingChannel.isFavorite {
            incomingChannel.isFavorite = false
            likeIcon.image = UIImage(named: "ic_star_border_black_36dp_1x.png")
        } else {
            incomingChannel.isFavorite = true
            likeIcon.image = UIImage(named: "ic_star_36pt.png")
        }
        self._ad.saveContext()
        //show ads
        if self.subInterstitial.isReady {
            self.subInterstitial.present(fromRootViewController: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.synchronize()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
