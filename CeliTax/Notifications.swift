//
//  Notifications.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-01.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class Notifications : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    static let kReceiptItemsTableReceiptPressedNotification : String = "ReceiptItemsTableReceiptPressedNotification"
    
    static let kReceiptDatabaseChangedNotification : String = "ReceiptDatabaseChangedNotification"
    
    static let kAppLanguageChangedNotification : String = "AppLanguageChangedNotification"
    
    static let kSideBarOpenedNotification : String = "SideBarOpenedNotification"
}