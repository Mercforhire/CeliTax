//
//  TutorialStep.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-10-30.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class TutorialStep : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    var highlightedItemRect : CGRect = CGRectMake(0, 0, 0, 0)
    var text : String = ""
    var leftButtonTitle : String = ""
    var rightButtonTitle : String = ""
    var pointsUp : Bool = false
}