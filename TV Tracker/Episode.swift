//
//  Episode.swift
//  TV Tracker
//
//  Created by Atharv Vaish on 7/29/14.
//  Copyright (c) 2014 Atharv Vaish. All rights reserved.
//

import Foundation
import CoreData

class Episode: NSManagedObject {

    @NSManaged var airTime: NSDate
    @NSManaged var image: NSData
    @NSManaged var number: NSNumber
    @NSManaged var overview: String
    @NSManaged var season: NSNumber
    @NSManaged var title: String
    @NSManaged var watched: NSNumber
    @NSManaged var show: Show

}
