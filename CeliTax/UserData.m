//
//  UserData.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UserData.h"
#import "Catagory.h"
#import "Record.h"
#import "Receipt.h"
#import "UserDataDAO.h"
#import "TaxYear.h"

#define kKeyCatagories       @"Catagories"
#define kKeyRecords          @"Records"
#define kKeyReceipts         @"Receipts"
#define kKeyTaxYears         @"TaxYears"
#define kKeyLastUploadedDate @"LastUploadedDate"

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
    [coder encodeObject:self.catagories             forKey:kKeyCatagories];
    [coder encodeObject:self.records                forKey:kKeyRecords];
    [coder encodeObject:self.receipts               forKey:kKeyReceipts];
    [coder encodeObject:self.taxYears               forKey:kKeyTaxYears];
    [coder encodeObject:self.lastUploadedDate       forKey:kKeyLastUploadedDate];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    NSArray *catagories = [coder decodeObjectForKey:kKeyCatagories];
    self.catagories = [[NSMutableArray alloc] initWithArray:catagories copyItems:NO];
    
    NSArray *records = [coder decodeObjectForKey:kKeyRecords];
    self.records = [[NSMutableArray alloc] initWithArray:records copyItems:NO];
    
    NSArray *receipts = [coder decodeObjectForKey:kKeyReceipts];
    self.receipts = [[NSMutableArray alloc] initWithArray:receipts copyItems:NO];
    
    NSArray *taxYears = [coder decodeObjectForKey:kKeyTaxYears];
    self.taxYears = [[NSMutableArray alloc] initWithArray:taxYears copyItems:NO];
    
    self.lastUploadedDate = [coder decodeObjectForKey:kKeyLastUploadedDate];
    
    return self;
}

- (NSDictionary *) generateJSONToUploadToServer
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    NSMutableArray *catagoriesJSONs = [NSMutableArray new];
    
    for (Catagory *catagory in self.catagories)
    {
        if (catagory.dataAction != DataActionNone)
        {
            //convert catagory to JSON and add to catagoriesJSONs
            [catagoriesJSONs addObject:[catagory toJson]];
        }
    }
    
    [json setObject:catagoriesJSONs forKey:kKeyCatagories];
    
    
    NSMutableArray *recordsJSONs = [NSMutableArray new];
    
    for (Record *record in self.records)
    {
        if (record.dataAction != DataActionNone)
        {
            //convert record to JSON and add to recordsJSONs
            [recordsJSONs addObject:[record toJson]];
        }
    }
    
    [json setObject:recordsJSONs forKey:kKeyRecords];
    
    
    NSMutableArray *receiptsJSONs = [NSMutableArray new];
    
    for (Receipt *receipt in self.receipts)
    {
        if (receipt.dataAction != DataActionNone)
        {
            //convert receipt to JSON and add to receiptsJSONs
            [receiptsJSONs addObject:[receipt toJson]];
        }
    }
    
    [json setObject:receiptsJSONs forKey:kKeyReceipts];
    
    
    NSMutableArray *taxYearsJSONs = [NSMutableArray new];
    
    for (TaxYear *taxYear in self.taxYears)
    {
        if (taxYear.dataAction != DataActionNone)
        {
            //convert receipt to JSON and add to receiptsJSONs
            [taxYearsJSONs addObject:[NSNumber numberWithInteger:taxYear.taxYear]];
        }
    }
    
    [json setObject:taxYearsJSONs forKey:kKeyTaxYears];
    
    return json;
}

- (void) setAllDataToDateActionNone
{
    for (Catagory *catagory in self.catagories)
    {
        catagory.dataAction = DataActionNone;
    }
    
    for (Record *record in self.records)
    {
        record.dataAction = DataActionNone;
    }
    
    for (Receipt *receipt in self.receipts)
    {
        receipt.dataAction = DataActionNone;
    }
    
    for (TaxYear *taxYear in self.taxYears)
    {
        taxYear.dataAction = DataActionNone;
    }
}

@end
