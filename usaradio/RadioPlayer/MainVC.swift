//
//  ViewController.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/4/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import AVFoundation
import MediaPlayer
import GoogleMobileAds

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, GADBannerViewDelegate, GADInterstitialDelegate {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var nowPlayingTitle: UIButton! //need to be replaced
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var settingButton: UIBarButtonItem!
    @IBOutlet weak var uiBannerView: UIView!
    

    @IBOutlet weak var nowPlayingThumbnail: UIImageView!
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var nowPlayingBtn: UIButton!
    
    
    let searchBarView = UISearchBar()
    
    var channelsArray = Array<Any>()
    var fetchController: NSFetchedResultsController<Channel>!
    var oldLeftBarButton: UIBarButtonItem!
    var avPlayer: AVPlayer! = nil
    var currentLink: String! = ""
    var searchedChannels:[Channel] = []
    var searchActive: Bool!
    var mediaControlCenter: MPNowPlayingInfoCenter!
    var nowPlayingItem: Channel!
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.loadingIndicator.isHidden = true
        if UserDefaults.standard.object(forKey: KEY_CURRENT_STATE) == nil {
            self.tableView.isHidden = true
            UserDefaults.standard.set("United States", forKey: KEY_PICKED_COUNTRY)
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            UtilClass.downloadJsonData(url: USA_URL, completed: {
                UtilClass.saveChannelToCoreData()
                self.loadingIndicator.isHidden = true
                UserDefaults.standard.set(true, forKey: KEY_CURRENT_STATE)
                self.fetchChannelsFromCoreData()
                self.tableView.reloadData()
                self.tableView.isHidden = false
            })
        }

        let imgName = "\(UserDefaults.standard.string(forKey: KEY_PICKED_COUNTRY)?.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "") ?? "noImg").png"
        self.settingButton.image = UIImage(named: imgName)?.withRenderingMode(.alwaysOriginal)

        //add search button
        searchBarView.delegate = self
        searchBarView.searchBarStyle = UISearchBarStyle.minimal
        
        oldLeftBarButton = navigationItem.leftBarButtonItem
        
        self.searchActive = false
        
        UserDefaults.standard.synchronize()
        
        nowPlayingBtn.layer.cornerRadius = 22
        nowPlayingThumbnail.layer.cornerRadius = 22
        nowPlayingThumbnail.layer.masksToBounds = true
        
        nowPlayingTitle.text = "No Channel Playing"
        nowPlayingBtn.setImage(UIImage(named: "play_blue_icon.png" ), for: .normal)
        
        let tapOnNowPlayingTitle = UITapGestureRecognizer(target: self, action: #selector(MainVC.onNowPlayingTitleTap))
        nowPlayingTitle.isUserInteractionEnabled = true
        nowPlayingTitle.addGestureRecognizer(tapOnNowPlayingTitle)
        
        //Adding bannder ads
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.delegate = self
        self.uiBannerView.addSubview(bannerView)
        bannerView.adUnitID = BANNER_ADS_ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        //Adding interstitial ads
        interstitial = GADInterstitial(adUnitID: INTER_ADS_ID)
        self.interstitial.delegate = self
        interstitial.load(GADRequest())
    }
    
    func onNowPlayingTitleTap() {
        if self.avPlayer != nil {
            if self.interstitial.isReady {
                self.interstitial.present(fromRootViewController: self)
            }
            performSegue(withIdentifier: "NowPlaying", sender: self.nowPlayingItem)
        } else {
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchChannelsFromCoreData()
        if self.avPlayer != nil {
            nowPlayingTitle.text = "\(self.nowPlayingItem.name ?? "Undefied")"
            nowPlayingBtn.setImage(UIImage(named: "play_blue_icon.png" ), for: .normal)
            UtilClass.setImageFromUrl(urlStr: self.nowPlayingItem.pic!, thumbnail: self.nowPlayingThumbnail)
            if self.avPlayer.isPlaying {
                nowPlayingBtn.setImage(UIImage(named: "pause_blue_icon.png" ), for: .normal)
                nowPlayingThumbnail.startRotating(duration: 8, clockwise: true)
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func playingBtnPressed(_ sender: Any) {
        if self.avPlayer != nil {
            if self.avPlayer.isPlaying {
                nowPlayingBtn.setImage(UIImage(named: "play_blue_icon.png" ), for: .normal)
                nowPlayingThumbnail.stopRotating()
                self.avPlayer.pause()
            } else {
                nowPlayingBtn.setImage(UIImage(named: "pause_blue_icon.png" ), for: .normal)
                nowPlayingThumbnail.startRotating(duration: 8, clockwise: true)
                self.avPlayer.play()
            }
        }
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.synchronize()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if (searchBar.text?.isEmpty)! {
            self.searchActive = false
        } else {
            self.searchActive = true
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchActive = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if (searchBar.text?.isEmpty)! {
            self.searchActive = false
            self.tableView.reloadData()
        } else {
            self.searchActive = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedChannels = (fetchController.fetchedObjects?.filter({ (channel) -> Bool in
            let tmp: String = channel.name!
            if tmp.lowercased().range(of: searchText.lowercased()) != nil {
                return true
            }
            return false
        }))!
        
        if searchedChannels.count > 0 {
            self.searchActive = true
        }
        
        if searchText == "" || self.searchedChannels.count == 0 {
            self.searchActive = false
        }
        self.tableView.reloadData()
    }
    
    @IBAction func openSearchBar(_ sender: Any) {
        if self.navigationItem.titleView == searchBarView {
            hideSearchBar()
        } else {
            showSearchBar()
        }
    }
    
    @IBAction func moveToChangingCountryVC(_ sender: Any) {
        if self.avPlayer != nil {
            self.avPlayer.pause()
        }
    }
    
    func showSearchBar() {
        searchBarView.alpha = 0
        searchBarView.sizeToFit()
        searchBarView.placeholder = "Search Channel ..."
        self.navigationItem.titleView = searchBarView
        self.navigationItem.setLeftBarButton(nil, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBarView.alpha = 1
        }, completion: { finished in
            self.searchBarView.becomeFirstResponder()
        })
        //show ads
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    func hideSearchBar() {
        navigationItem.setLeftBarButton(oldLeftBarButton, animated: true)
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationItem.titleView = nil
        }, completion: { finished in
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    //reload ads
    func createAndLoadInterstitial() -> GADInterstitial {
        self.interstitial = GADInterstitial(adUnitID: INTER_ADS_ID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstitial = createAndLoadInterstitial()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive {
            return searchedChannels.count
        } else {
            if (self.searchBarView.text?.isEmpty)! {
                if let sections = self.fetchController.sections {
                    let sectionInfo = sections[section]
                    return sectionInfo.numberOfObjects
                }
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: (indexPath))!
        selectedCell.contentView.backgroundColor = UIColor.blue
        
        self.nowPlayingItem = Channel()
        var count = 0
        
        if self.searchActive {
            nowPlayingItem = self.searchedChannels[indexPath.row]
            count = searchedChannels.count
        } else {
            nowPlayingItem = (fetchController.fetchedObjects?[indexPath.row])!
            count = (self.fetchController.fetchedObjects?.count)!
        }
        
        if count > 0 {
            let url = URL(string: nowPlayingItem.link!)
            if nowPlayingItem.link != UserDefaults.standard.string(forKey: KEY_CURRENT_PLAYED_LINK) || avPlayer == nil {
                if self.avPlayer != nil {
                    avPlayer.replaceCurrentItem(with: nil)
                }
                let avPlayerItem = AVPlayerItem(url: url!)
                avPlayer = AVPlayer(playerItem: avPlayerItem)
                mediaControlCenter = MPNowPlayingInfoCenter.default()
                let thumbnailImgView = UIImageView()
                UtilClass.setImageFromUrl(urlStr: nowPlayingItem.pic!, thumbnail: thumbnailImgView)
                //set up image for artwork
                let thumbnailImg = thumbnailImgView.image ?? UIImage(named: "ic_radio_48pt_3x.png")
                let artwork = MPMediaItemArtwork.init(boundsSize: (thumbnailImg?.size)!, requestHandler: { (size) -> UIImage in
                    return thumbnailImg!
                })
                mediaControlCenter.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: nowPlayingItem.name ?? "",
                    MPMediaItemPropertyArtist: nowPlayingItem.country ?? "",
                    MPMediaItemPropertyArtwork: artwork
                ]
                do {
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch _ {
                    return print("error")
                }
                avPlayer.play()
                
            }
            
            performSegue(withIdentifier: "NowPlaying", sender: self.nowPlayingItem)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NowPlaying" {
            if let destination = segue.destination as? NowPlayingVC {
                if let item = sender as? Channel {
                    //pass data to NowPlayingVC
                    destination.incomingChannel = item
                    destination.incomingAVPlayer = self.avPlayer
                    destination.mediaControlCenter = self.mediaControlCenter
                }
            }
        }
        
        //
        if segue.identifier == "moveToChangingCountryVC" {
            if self.avPlayer != nil {
                self.avPlayer.pause()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = self.fetchController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func configureCell(cell: ItemCell, indexPath: NSIndexPath) {
        var item:Channel = Channel()
        if self.searchActive {
            item = self.searchedChannels[indexPath.row]
        } else {
            item = self.fetchController.object(at: indexPath as IndexPath)
        }
        cell.configureCell(channel: item)
    }
    
    func fetchChannelsFromCoreData() {
        //All
        let fetchRequestAll: NSFetchRequest<Channel> = Channel.fetchRequest()
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequestAll.sortDescriptors = [nameSort]
        
        //Fav
        let fetchRequestFav: NSFetchRequest<Channel> = Channel.fetchRequest()
        let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(booleanLiteral: true))
        fetchRequestFav.predicate = predicate
        fetchRequestFav.sortDescriptors = [nameSort]
        
        //News
        let fetchRequestNews: NSFetchRequest<Channel> = Channel.fetchRequest()
        let predicateNews = NSPredicate(format: "frequency == %@", NSString(stringLiteral: "News"))
        fetchRequestNews.predicate = predicateNews
        fetchRequestNews.sortDescriptors = [nameSort]
        
        //Music + other
        let fetchRequestMusic: NSFetchRequest<Channel> = Channel.fetchRequest()
        let predicateMusic = NSPredicate(format: "frequency != %@", NSString(stringLiteral: "News"))
        fetchRequestMusic.predicate = predicateMusic
        fetchRequestMusic.sortDescriptors = [nameSort]
        
        if segment.selectedSegmentIndex == 0 {
            self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequestAll, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        } else if segment.selectedSegmentIndex == 1 {
            self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequestNews, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        } else if segment.selectedSegmentIndex == 2 {
            self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequestMusic, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        } else if segment.selectedSegmentIndex == 3 {
            self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequestFav, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        }
        
        do {
            try self.fetchController.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
    }
    
    @IBAction func onSegmentChange(_ sender: Any) {
        searchBarView.text = ""
        searchActive = false
        fetchChannelsFromCoreData()
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = newIndexPath {
                let cell = tableView.cellForRow(at: indexPath) as! ItemCell
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
