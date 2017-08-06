//
//  UtilClass.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/16/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreData

public class UtilClass {
    
    static var channelsArray = [ChannelObject]()
    
    static func setImageFromUrl(urlStr: String, thumbnail: UIImageView) {
        if urlStr.isEmpty {
            thumbnail.image = UIImage(named: "ic_radio_48pt_3x.png")
            return
        }
        
        guard let url = URL(string: urlStr) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Fail fetching image!", error!)
                thumbnail.image = UIImage(named: "ic_radio_48pt_3x.png")
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Not a proper HTTPURLResponse or statusCode")
                thumbnail.image = UIImage(named: "ic_radio_48pt_3x.png")
                return
            }
            
            DispatchQueue.main.async {
                thumbnail.image = UIImage(data: data!)
            }
            }.resume()
    }
    
    //Download JSON data
    static func downloadJsonData(url: String,completed: @escaping DownloadComplete) {
        channelsArray.removeAll()
        //Alamonfire Download
        let currentRadioURL = URL(string: url)!
        
        Alamofire.request(currentRadioURL, method: .get, parameters: ["":""], encoding: URLEncoding.default, headers: nil).responseJSON { response in
            let result = response.result.value as? Array<Any>
            
            
            for r in result! {
                let channel = ChannelObject()
                
                if let dict = r as? Dictionary<String, AnyObject> {
                    if let name = dict["name"] as? String {
                        channel.name = name
                    } else {
                        channel.name = ""
                    }
                    
                    if let url = dict["url"] as? String {
                        channel.url = url
                    } else {
                        channel.url = ""
                    }
                    
                    if let logo = dict["logo"] as? String {
                        channel.logo = logo
                    } else {
                        channel.logo = ""
                    }
                    
                    if let category = dict["category"] as? String {
                        channel.category = category
                    } else {
                        channel.category = ""
                    }
                }
                self.channelsArray.append(channel)
            }
            completed()
        }
    }
    
    static func countryURL(name: String) -> String {
        switch name {
        case "Algeria":
            return ALGERIA_URL
        case "China":
            return CHINA_URL
        case "Dominica":
            return DOMINICAN_URL
        case "France":
            return FRANCE_URL
        case "Germany":
            return GERMANY_URL
        case "Malaysia":
            return MALAYSIA_URL
        case "Sweden":
            return SWEDEN_URL
        case "Thailand":
            return THAILAND_URL
        case "Argentina":
            return ARGENTINA_URL
        case "Australia":
            return AUSTRALIA_URL
        case "Austria":
            return AUSTRIA_URL
        case "Bangladesh":
            return BANGLADESH_URL
        case "Russia":
            return RUSSIA_URL
        case "Senegal":
            return SENEGAL_URL
        case "Serbia":
            return SERBIA_URL
        case "Singapore":
            return SINGAPORE_URL
        case "Spain":
            return SPAIN_URL
        case "Belgium":
            return BELGIUM_URL
        case "Haiti":
            return HAITI_URL
        case "Honduras":
            return HONDURAS_URL
        case "Hungary":
            return HUNGARY_URL
        case "India":
            return INDIA_URL
        case "Mexico":
            return MEXICO_URL
        case "New Zealand":
            return NEWZEALAND_URL
        case "Portugal":
            return PORTUGAL_URL
        case "Bolivia":
            return BOLIVIA_URL
        case "Czech":
            return CZECH_URL
        case "Denmark":
            return DENMARK_URL
        case "Ecuador":
            return ECUADOR_URL
        case "Egypt":
            return EGYPT_URL
        case "England":
            return ENGLAND_URL
        case "Finland":
            return FINLAND_URL
        case "Greece":
            return GREECE_URL
        case "Brazil":
            return BRAZIL_URL
        case "Bulgaria":
            return BULGARIA_URL
        case "Canada":
            return CANADA_URL
        case "Chile":
            return CHILE_URL
        case "Colombia":
            return COLOMBIA_URL
        case "Croatia":
            return CROATIA_URL
        case "United States":
            return USA_URL
        case "Venezuela":
            return VENEZUELA_URL
        default:
            return ""
        }
    }
    
    static func saveChannelToCoreData() {
        for case let c in self.channelsArray {
            let channel = Channel(context: context)
            
            channel.country = UserDefaults.standard.string(forKey: KEY_PICKED_COUNTRY)
            if c.url != "null" && !c.url.isEmpty{
                channel.link = c.url
            } else {
                channel.link = DEFAULT_STREAM_LINK
            }
            if !c.name.isEmpty && c.name != "null" {
                channel.name = c.name
            } else {
                channel.name = "Undefined"
            }
            if c.logo != "null" && !c.logo.isEmpty {
                channel.pic = c.logo
            } else {
                channel.pic = ""
            }
            channel.frequency = c.category
            channel.isFavorite = false
            let i = self.channelsArray.index(where: { (item) -> Bool in
                item.url == c.url
            })
            channel.number = Int16(i!)
            
            ad.saveContext()
        }
    }

}
