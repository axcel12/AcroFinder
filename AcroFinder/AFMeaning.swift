//
//  AFMeaning.swift
//  AcroFinder
//
//  Created by Michael Ramos on 8/24/15.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import Foundation

let kMeaningNameKey = "name"
let kMeaningRelevanceKey = "relevance"
let kMeaningHitsKey = "hits"

class AFMeaning:NSObject, NSCoding {
    var name:String
    var relevance:Int
    var hits:Int
    
    init(name:String, relevance:Int, hits:Int) {
        self.name = name
        self.relevance = relevance
        self.hits = hits
    }
    
    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey(kMeaningNameKey) as! String
        self.relevance  = aDecoder.decodeIntegerForKey(kMeaningRelevanceKey)
        self.hits = aDecoder.decodeIntegerForKey(kMeaningHitsKey)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: kMeaningNameKey)
        aCoder.encodeInteger(self.relevance, forKey: kMeaningRelevanceKey)
        aCoder.encodeInteger(self.hits, forKey: kMeaningHitsKey)
    }
}