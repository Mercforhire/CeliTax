//
// Notifications.h
// CeliTax
//
// Created by Leon Chen on 2015-06-07.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notifications : NSObject

    extern NSString *const kReceiptItemsTableReceiptPressedNotification;

    extern NSString *const kReceiptDatabaseChangedNotification;

    extern NSString *const kAppLanguageChangedNotification;

@end