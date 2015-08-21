//
//  acroPopular.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import Foundation

class acroPopular{
    var acroName = ""
    var acroMeaning = ""
    
    init(acroName: String, acroMeaning: String){
        self.acroName = acroName
        self.acroMeaning = acroMeaning
    }
}


/*import UIKit

var acroMostPopular: acroPop = acroPop()

class acroPop: NSString {
    var mostPopular = [popular]()

    struct popular{
        var acroName = ""
        var acroMeaning = ""
    }

    func addAcronym(name: String, meaning: String){
        mostPopular.insert(popular(acroName: name, acroMeaning: meaning), atIndex: 0)
    }
}*/
