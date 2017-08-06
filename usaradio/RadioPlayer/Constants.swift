//
//  Constants.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/11/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import Foundation

let CountriesList = ["Algeria","China","Dominica","France","Germany"
    ,"Malaysia","Sweden","Thailand","Argentina","Australia","Austria","Bangladesh","Russia","Senegal","Serbia","Singapore","Spain","Venezuela"
    ,"Belgium","Haiti","Honduras","Hungary","India","Mexico","New Zealand","Portugal"
    ,"Bolivia","Czech","Denmark","Ecuador","Egypt","England","Finland","Greece"
    ,"Brazil","Bulgaria","Canada","Chile","Colombia","Croatia"
    ,"United States"]

let ALGERIA_URL = "https://storage.googleapis.com/channelsdata/algieriaan.txt"
let CHINA_URL = "https://storage.googleapis.com/channelsdata/anchina.txt"
let DOMINICAN_URL = "https://storage.googleapis.com/channelsdata/andominican.txt"
let FRANCE_URL = "https://storage.googleapis.com/channelsdata/anfrance.txt"
let GERMANY_URL = "https://storage.googleapis.com/channelsdata/angermany.txt"
let MALAYSIA_URL = "https://storage.googleapis.com/channelsdata/anmalaysia.txt"
let SWEDEN_URL = "https://storage.googleapis.com/channelsdata/answeden.txt"
let THAILAND_URL = "https://storage.googleapis.com/channelsdata/answeden.txt"
let USA_URL = "https://storage.googleapis.com/channelsdata/anusa.txt"
let ARGENTINA_URL = "https://storage.googleapis.com/channelsdata/argentinaan.txt"
let AUSTRALIA_URL = "https://storage.googleapis.com/channelsdata/australiaan.txt"
let AUSTRIA_URL = "https://storage.googleapis.com/channelsdata/austria.txt"
let BANGLADESH_URL = "https://storage.googleapis.com/channelsdata/bangladeshan.txt"
let BELGIUM_URL = "https://storage.googleapis.com/channelsdata/belgiuman.txt"
let BOLIVIA_URL = "https://storage.googleapis.com/channelsdata/bolivia.txt"
let BRAZIL_URL = "https://storage.googleapis.com/channelsdata/brazilan.txt"
let BULGARIA_URL = "https://storage.googleapis.com/channelsdata/bulgaria.txt"
let CANADA_URL = "https://storage.googleapis.com/channelsdata/canada.txt"
let CHILE_URL = "https://storage.googleapis.com/channelsdata/chile.txt"
let COLOMBIA_URL = "https://storage.googleapis.com/channelsdata/colombiaan.txt"
let CROATIA_URL = "https://storage.googleapis.com/channelsdata/croatia.txt"
let CZECH_URL = "https://storage.googleapis.com/channelsdata/czechan.txt"
let DENMARK_URL = "https://storage.googleapis.com/channelsdata/denmarkan.txt"
let ECUADOR_URL = "https://storage.googleapis.com/channelsdata/ecuador.txt"
let EGYPT_URL = "https://storage.googleapis.com/channelsdata/egyptan.txt"
let ENGLAND_URL = "https://storage.googleapis.com/channelsdata/english.txt"
let FINLAND_URL = "https://storage.googleapis.com/channelsdata/finlandan.txt"
let GREECE_URL = "https://storage.googleapis.com/channelsdata/greecean.txt"
let HAITI_URL = "https://storage.googleapis.com/channelsdata/haiti.txt"
let HONDURAS_URL = "https://storage.googleapis.com/channelsdata/honduras.txt"
let HUNGARY_URL = "https://storage.googleapis.com/channelsdata/hungaryan.txt"
let INDIA_URL = "https://storage.googleapis.com/channelsdata/indiaan.txt"
let MEXICO_URL = "https://storage.googleapis.com/channelsdata/mexicoan.txt"
let NEWZEALAND_URL = "https://storage.googleapis.com/channelsdata/newzealand.txt"
let PORTUGAL_URL = "https://storage.googleapis.com/channelsdata/portugalan.txt"
let RUSSIA_URL = "https://storage.googleapis.com/channelsdata/russiaan.txt"
let SENEGAL_URL = "https://storage.googleapis.com/channelsdata/senegal.txt"
let SERBIA_URL = "https://storage.googleapis.com/channelsdata/serbiaan.txt"
let SINGAPORE_URL = "https://storage.googleapis.com/channelsdata/singaporean.txt"
let SPAIN_URL = "https://storage.googleapis.com/channelsdata/spain.txt"
let VENEZUELA_URL = "https://storage.googleapis.com/channelsdata/venezuelaan.txt"

let MOST_POPULAR_URL = "https://storage.googleapis.com/channelsdata/mostpopular.txt"

let KEY_CURRENT_STATE = "CURRENT_STATE"
let KEY_PICKED_COUNTRY = "PICKED_COUNTRY"
let KEY_CURRENT_PLAYED_LINK = "KEY_CURRENT_PLAYED_LINK"
let ANIMATION_ROTATE_KEY = "ANIMATION_ROTATE_KEY"
let KEY_MOST_POPULAR = "KEY_MOST_POPULAR"

let DEFAULT_STREAM_LINK = "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1_mf_p"

//Production
let INTER_ADS_ID = "ca-app-pub-9562198892708304/1512771111"
let BANNER_ADS_ID = "ca-app-pub-9562198892708304/1340901794"
let INTER_ADS_NOWPLAYING_ID = "ca-app-pub-9562198892708304/2224029624"

//Test
let BANNER_TEST_ID = "ca-app-pub-3940256099942544/6300978111"
let INTER_TEST_ID = "ca-app-pub-3940256099942544/1033173712"



typealias DownloadComplete = () -> ()
