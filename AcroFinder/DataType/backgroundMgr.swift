//
//  backgroundMgr.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

var acroBack: backgroundMgr = backgroundMgr()

class backgroundMgr: NSString {
    var colors = [color]()
    
    struct color{
        var colorNavigator: UInt32 = 0x254B95
        var colorViewController: UInt32 = 0xFFFFFF
        var colorLabel: UInt32 = 0x00CFA6
        var colorSettings: UInt32 = 0xF1F1F7
        var backKey:NSIndexPath? = nil
        var colorWhite: UInt32 = 0xFFFFFF
    }
    
    func changeColor(colorNavigator: UInt32, colorViewController: UInt32, colorLabel: UInt32, colorSettings: UInt32, backKey: NSIndexPath, colorWhite: UInt32){
        colors.insert(color(colorNavigator:colorNavigator, colorViewController:colorViewController, colorLabel:colorLabel, colorSettings:colorSettings, backKey:backKey, colorWhite:colorWhite), atIndex: 0)
    }
}