//
//  Channel+CoreDataProperties.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/13/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

    @NSManaged public var frequency: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var link: String?
    @NSManaged public var name: String?
    @NSManaged public var number: Int16
    @NSManaged public var pic: String?
    @NSManaged public var country: String?
    @NSManaged public var toCountry: NSManagedObject?

}
