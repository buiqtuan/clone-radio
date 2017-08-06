	//
//  ItemCell.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/14/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    var _channel:Channel!
    
    func configureCell(channel: Channel) {
        self._channel = channel
        UtilClass.setImageFromUrl(urlStr: channel.pic!, thumbnail: self.thumbnail)
        channelName.text = channel.name
        if _channel.isFavorite {
            likeBtn.setImage(UIImage(named: "ic_star_black_36dp.png" ), for: .normal)
        } else {
            likeBtn.setImage(UIImage(named: "ic_star_border_black_36dp.png" ), for: .normal)
        }
    }
    
    @IBAction func likePressed(_ sender: Any) {
        if (likeBtn.currentImage?.isEqual(UIImage(named: "ic_star_border_black_36dp.png")))! {
            likeBtn.setImage(UIImage(named: "ic_star_black_36dp.png" ), for: .normal)
            self._channel.isFavorite = true
            ad.saveContext()
        } else {
            likeBtn.setImage(UIImage(named: "ic_star_border_black_36dp.png" ), for: .normal)
            self._channel.isFavorite = false
            ad.saveContext()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        channelName.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
