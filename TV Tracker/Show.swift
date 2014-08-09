//
//  Show.swift
//  TV Tracker
//
//  Created by Atharv Vaish on 7/29/14.
//  Copyright (c) 2014 Atharv Vaish. All rights reserved.
//

import Foundation
import CoreData

class Show: NSManagedObject {

    @NSManaged var airDay: NSNumber
    @NSManaged var airTime: NSNumber
    @NSManaged var banner: NSData
    @NSManaged var certification: String
    @NSManaged var country: String
    @NSManaged var fanart: NSData
    @NSManaged var genre: String
    @NSManaged var id: String
    @NSManaged var imdb: String
    @NSManaged var lastSynced: NSDate
    @NSManaged var lastUpdated: NSDate
    @NSManaged var network: String
    @NSManaged var overview: String
    @NSManaged var poster: NSData
    @NSManaged var runtime: NSNumber
    @NSManaged var status: String
    @NSManaged var title: String
    @NSManaged var tvdb: String
    @NSManaged var tvrage: String
    @NSManaged var year: NSNumber
    @NSManaged var episodes: NSSet

}
