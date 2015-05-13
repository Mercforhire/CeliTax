//
//  CatagoryRecord.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatagoryRecord : NSObject <NSCoding>

@property NSInteger                     identifer;
@property (nonatomic, strong) NSDate    *dateCreated;

@property NSInteger                     itemCatagoryID; //must match an ItemCatagory
@property (nonatomic, copy) NSString    *itemCatagoryName;

@property NSInteger                     receiptID; //must match an Receipt

@property float                         amount;
@property NSInteger                     quantity;

@end
