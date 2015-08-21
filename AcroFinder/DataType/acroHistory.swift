//
//  acroHistory.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

var acroHist: acroHistory = acroHistory()

class acroHistory: NSString {
    var histories = [history]()
    
    struct history{
        var name = "Un-Named"
    }
    
    func addAcronym(name: String){
        histories.insert(history(name:name), atIndex: 0)
    }
}