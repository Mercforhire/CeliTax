//
//  CatagoryRecord.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject <NSCoding>

@property (nonatomic, copy) NSString    *identifer;
@property (nonatomic, strong) NSDate    *dateCreated;

@property (nonatomic, copy) NSString    *catagoryID; //must match an ItemCatagory
@property (nonatomic, copy) NSString    *catagoryName;

@property (nonatomic, copy) NSString    *receiptID; //must match an Receipt

@property float                         amount;
@property NSInteger                     quantity;

@end
