//
//  AFAcronym.swift
//  AcroFinder
//
//  Created by Michael Ramos on 8/24/15.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import Foundation

class ASAcronym:NSObject {
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
}