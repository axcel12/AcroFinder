//
//  AFAcronym.swift
//  AcroFinder
//
//  Created by Michael Ramos on 8/24/15.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import Foundation

let kAcronymID = "id"
let kAcronymRevKey = "rev"
let kAcronymKey = "acronym"
let kAcronymMeaningsKey = "meanings"

class AFAcronym:NSObject, NSCoding {
    var id:String
    var rev:String
    var acronym:String
    var meanings:[AFMeaning]
    
    init(id:String, rev:String, acronym:String, meanings:[AFMeaning]) {
        self.id = id
        self.rev = rev
        self.acronym = acronym
        self.meanings = meanings
        super.init()
        sortMeanings()
    }
    
    func sortMeanings() {
        meanings.sort({$0.relevance>$1.relevance})
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey(kAcronymID) as! String
        self.rev = aDecoder.decodeObjectForKey(kAcronymRevKey) as! String
        self.acronym = aDecoder.decodeObjectForKey(kAcronymKey) as! String
        self.meanings = aDecoder.decodeObjectForKey(kAcronymMeaningsKey) as! [AFMeaning]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: kAcronymID)
        aCoder.encodeObject(self.rev, forKey: kAcronymRevKey)
        aCoder.encodeObject(self.acronym, forKey: kAcronymKey)
        aCoder.encodeObject(self.meanings, forKey: kAcronymMeaningsKey)
    }
}