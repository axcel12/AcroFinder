//
//  acroSearch.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

var acroSearched: acroSearch = acroSearch()

class acroSearch: NSString {
    var acronyms = [acronym]()
    
    struct acronym{
        var name = "Un-Named"
    }
    
    func addAcronym(name: String){
        acronyms.insert(acronym(name:name), atIndex: 0)
    }
}