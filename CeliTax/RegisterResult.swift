//
//  RegisterResult.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-10-30.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class RegisterResult : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    var success : Bool = false
    var message : String = ""
}