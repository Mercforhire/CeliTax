//
//  CatagoryRecord.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject <NSCoding, NSCopying>

@property (nonatomic) NSInteger         serverID;

@property (nonatomic, copy) NSString    *localID;

@property (nonatomic, strong) NSDate    *dateCreated;

@property (nonatomic, copy) NSString    *catagoryID; //must match an ItemCatagory's localID

@property (nonatomic, copy) NSString    *receiptID; //must match an Receipt's localID

@property float                         amount;
@property NSInteger                     quantity;

@property (nonatomic, assign) NSInteger dataAction;

-(float)calculateTotal;

- (NSDictionary *) toJson;

@end
