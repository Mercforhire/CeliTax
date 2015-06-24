//
//  UserData.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UserData.h"

#define kKeyCatagoriesKey       @"Catagories"
#define kKeyRecordsKey          @"Records"
#define kKeyReceiptsKey         @"Receipts"
#define kKeyTaxYearsKey         @"TaxYears"

@implementation UserData

- (id) init
{
    self = [super init];
    
    self.catagories = [[NSMutableArray alloc] init];
    self.records = [[NSMutableArray alloc] init];
    self.receipts = [[NSMutableArray alloc] init];
    self.taxYears = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.catagories     forKey:kKeyCatagoriesKey];
    [coder encodeObject:self.records        forKey:kKeyRecordsKey];
    [coder encodeObject:self.receipts       forKey:kKeyReceiptsKey];
    [coder encodeObject:self.taxYears       forKey:kKeyTaxYearsKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    NSArray *catagories = [coder decodeObjectForKey:kKeyCatagoriesKey];
    self.catagories = [[NSMutableArray alloc] initWithArray:catagories copyItems:NO];
    
    NSArray *records = [coder decodeObjectForKey:kKeyRecordsKey];
    self.records = [[NSMutableArray alloc] initWithArray:records copyItems:NO];
    
    NSArray *receipts = [coder decodeObjectForKey:kKeyReceiptsKey];
    self.receipts = [[NSMutableArray alloc] initWithArray:receipts copyItems:NO];
    
    NSArray *taxYears = [coder decodeObjectForKey:kKeyTaxYearsKey];
    self.taxYears = [[NSMutableArray alloc] initWithArray:taxYears copyItems:NO];
    
    return self;
}

@end
