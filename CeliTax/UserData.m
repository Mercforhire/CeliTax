//
//  UserData.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UserData.h"

#define kKeyItemCatagoriesKey       @"ItemCatagories"
#define kKeyCatagoryRecordsKey      @"CatagoryRecords"
#define kKeyReceiptsKey             @"Receipts"

@implementation UserData

- (id) init
{
    self = [super init];
    
    self.itemCatagories = [[NSMutableArray alloc] init];
    self.catagoryRecords = [[NSMutableArray alloc] init];
    self.receipts = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.itemCatagories     forKey:kKeyItemCatagoriesKey];
    [coder encodeObject:self.catagoryRecords    forKey:kKeyCatagoryRecordsKey];
    [coder encodeObject:self.receipts           forKey:kKeyReceiptsKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    NSArray *itemCatagories = [coder decodeObjectForKey:kKeyItemCatagoriesKey];
    self.itemCatagories = [[NSMutableArray alloc] initWithArray:itemCatagories copyItems:NO];
    
    NSArray *catagoryRecords = [coder decodeObjectForKey:kKeyCatagoryRecordsKey];
    self.catagoryRecords = [[NSMutableArray alloc] initWithArray:catagoryRecords copyItems:NO];
    
    NSArray *receipts = [coder decodeObjectForKey:kKeyReceiptsKey];
    self.receipts = [[NSMutableArray alloc] initWithArray:receipts copyItems:NO];
    
    return self;
}

@end
