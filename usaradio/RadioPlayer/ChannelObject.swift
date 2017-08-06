//
//  ChannelObject.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/12/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import Foundation

public class ChannelObject {
    private var _logo: String!
    private var _name: String!
    private var _url: String!
    private var _category: String!
    
    var category: String {
        set {_category = newValue}
        get {return _category}
    }
    
    var name: String {
        set {_name = newValue}
        get {return _name}
    }
    
    var url: String {
        set {_url = newValue}
        get {return _url}
    }
    
    var logo: String {
        set {_logo = newValue}
        get {return _logo}
    }
}
