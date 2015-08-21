//
//  AcronymItem.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

@objc public class AcronymItem: NSObject, CDTDataObject {
    
    var acronym : NSString = ""
    var meaning : NSString = ""
    var key : NSNumber = 0
    var hits : NSNumber = 0
    
    //Required by the IMFDataObject protocol
    public var metadata:CDTDataObjectMetadata?
}