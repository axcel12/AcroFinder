//
//  AFHistory.swift
//  AcroFinder
//
//  Created by Axcel Duarte on 8/29/15.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

var historyAcronym: AFHistory = AFHistory()

class AFHistory: NSObject {
    var histories = [AFAcronym]()
    
    func addAcronym(acronym: AFAcronym){
        histories.insert(acronym, atIndex: 0)
    }
}

/*
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
*/