//
//  UserData.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

//wrapper object containing all of an user's data
@interface UserData : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *itemCatagories;

@property (nonatomic, strong) NSMutableArray *catagoryRecords;

@property (nonatomic, strong) NSMutableArray *receipts;

@end
