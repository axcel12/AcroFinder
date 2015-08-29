//
//  AFHistory.swift
//  AcroFinder
//
//  Created by Axcel Duarte on 8/29/15.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

var acroHistory: AFHistory = AFHistory()

class AFHistory: NSObject {
    var histories = [AFAcronym]()
    
    func addAcronym(acronym: AFAcronym){
        histories.insert(acronym, atIndex: 0)
    }
}