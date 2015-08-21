//
//  acroFlag.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

var acroFlags: acroFlag = acroFlag()

class acroFlag: NSString {
    var flags = [flag]()
    
    struct flag{
        var value = "false"
    }
    
    func addFlag(value: String){
        flags.insert(flag(value:value), atIndex: 0)
    }
    
    func removeFlag(){
        flags.removeAll(keepCapacity: true)
    }
}