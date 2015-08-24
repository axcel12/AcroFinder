//
//  AFMeaning.swift
//  AcroFinder
//
//  Created by Michael Ramos on 8/24/15.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import Foundation

class AFMeaning:NSObject {
    var name:String
    var relevance:Int
    var hits:Int
    
    init(name:String, relevance:Int, hits:Int) {
        self.name = name
        self.relevance = relevance
        self.hits = hits
    }
}