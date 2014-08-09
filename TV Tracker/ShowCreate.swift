//
//  ShowCreate.swift
//  TV Tracker
//
//  Created by Atharv Vaish on 7/25/14.
//  Copyright (c) 2014 Atharv Vaish. All rights reserved.
//

import Foundation
import CoreData

extension Show {
    class func showWithTraktData(traktData: NSDictionary, context: NSManagedObjectContext) -> Show? {
        let request = NSFetchRequest(entityName: "Show")
        let title = traktData["title"] as String
        let error: NSErrorPointer = nil
        var show: Show? = nil
        
        request.predicate = NSPredicate(format: "title = \(title)")
        let matches = context.executeFetchRequest(request, error: error)
        
        if (error || matches.count > 1) {
            println("There was an error")
            // handle error?
        } else if matches.count == 1 {
            // check whether object needs to be updated
        } else {
            show = NSEntityDescription.insertNewObjectForEntityForName("Show",
                                               inManagedObjectContext: context) as? Show
            if var newShow = show {
                newShow.banner = NSData(contentsOfURL:
                    NSURL(string: (traktData["images"] as [String: String])["banner"]))
                newShow.certification = traktData["certification"] as String
                newShow.country = traktData["country"] as String
                newShow.fanart = NSData(contentsOfURL:
                    NSURL(string: (traktData["images"] as [String: String])["fanart"]))
                newShow.imdb = traktData["imdb_id"] as String
                
                newShow.year = traktData["year"] as Int
                newShow.tvrage = traktData["tvrage_id"] as String
                newShow.tvdb = traktData["tvdb_id"] as String
                newShow.title = title
                newShow.status = traktData["status"] as String
                newShow.runtime = traktData["runtime"] as Int
                newShow.poster = NSData(contentsOfURL:
                    NSURL(string: (traktData["images"] as [String: String])["poster"]))
                newShow.overview = traktData["overview"] as String
                
            }
        }
        
        return show
    }
}