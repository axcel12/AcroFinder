//
//  acroFavorites.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

var acroFav: acroFavorites = acroFavorites()

class acroFavorites: NSString {
    var favorites = [favorite]()

    struct favorite{
        var name = "Un-Named"
    }

    func addAcronym(name: String){
        favorites.insert(favorite(name:name), atIndex: 0)
    }
}
