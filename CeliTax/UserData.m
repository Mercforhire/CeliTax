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
#define kKeyLastUploadHash  @"LastUploadHash"

@implementation UserData

- (instancetype) init
{
    if (self = [super init])
    {
        self.catagories = [[NSMutableArray alloc] init];
        self.records = [[NSMutableArray alloc] init];
        self.receipts = [[NSMutableArray alloc] init];
        self.taxYears = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.catagories             forKey:kKeyCatagories];
    [coder encodeObject:self.records                forKey:kKeyRecords];
    [coder encodeObject:self.receipts               forKey:kKeyReceipts];
    [coder encodeObject:self.taxYears               forKey:kKeyTaxYears];
    [coder encodeObject:self.lastUploadedDate       forKey:kKeyLastUploadedDate];
    [coder encodeObject:self.lastUploadHash         forKey:kKeyLastUploadHash];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [self init])
    {
        NSArray *catagories = [coder decodeObjectForKey:kKeyCatagories];
        self.catagories = [[NSMutableArray alloc] initWithArray:catagories copyItems:NO];
        
        NSArray *records = [coder decodeObjectForKey:kKeyRecords];
        self.records = [[NSMutableArray alloc] initWithArray:records copyItems:NO];
        
        NSArray *receipts = [coder decodeObjectForKey:kKeyReceipts];
        self.receipts = [[NSMutableArray alloc] initWithArray:receipts copyItems:NO];
        
        NSArray *taxYears = [coder decodeObjectForKey:kKeyTaxYears];
        self.taxYears = [[NSMutableArray alloc] initWithArray:taxYears copyItems:NO];
        
        self.lastUploadedDate = [coder decodeObjectForKey:kKeyLastUploadedDate];
        
        self.lastUploadHash = [coder decodeObjectForKey:kKeyLastUploadHash];
    }
    
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
    
    json[kKeyCatagories] = catagoriesJSONs;
    
    
    NSMutableArray *recordsJSONs = [NSMutableArray new];
    
    for (Record *record in self.records)
    {
        if (record.dataAction != DataActionNone)
        {
            //convert record to JSON and add to recordsJSONs
            [recordsJSONs addObject:[record toJson]];
        }
    }
    
    json[kKeyRecords] = recordsJSONs;
    
    
    NSMutableArray *receiptsJSONs = [NSMutableArray new];
    
    for (Receipt *receipt in self.receipts)
    {
        if (receipt.dataAction != DataActionNone)
        {
            //convert receipt to JSON and add to receiptsJSONs
            [receiptsJSONs addObject:[receipt toJson]];
        }
    }
    
    json[kKeyReceipts] = receiptsJSONs;
    
    
    NSMutableArray *taxYearsJSONs = [NSMutableArray new];
    
    for (TaxYear *taxYear in self.taxYears)
    {
        if (taxYear.dataAction != DataActionNone)
        {
            //convert receipt to JSON and add to receiptsJSONs
            [taxYearsJSONs addObject:[taxYear toJson]];
        }
    }
    
    json[kKeyTaxYears] = taxYearsJSONs;
    
    return json;
}

- (void) resetAllDataActionsAndClearOutDeletedOnes
{
    NSMutableArray *catagoriesToDelete = [NSMutableArray new];
    
    for (Catagory *catagory in self.catagories)
    {
        if (catagory.dataAction == DataActionDelete)
        {
            [catagoriesToDelete addObject:catagory];
        }
        else
        {
            catagory.dataAction = DataActionNone;
        }
    }
    
    [self.catagories removeObjectsInArray:catagoriesToDelete];
    
    
    NSMutableArray *recordsToDelete = [NSMutableArray new];
    
    for (Record *record in self.records)
    {
        if (record.dataAction == DataActionDelete)
        {
            [recordsToDelete addObject:record];
        }
        else
        {
            record.dataAction = DataActionNone;
        }
    }
    
    [self.records removeObjectsInArray:recordsToDelete];
    
    
    NSMutableArray *receiptsToDelete = [NSMutableArray new];
    
    for (Receipt *receipt in self.receipts)
    {
        if (receipt.dataAction == DataActionDelete)
        {
            [receiptsToDelete addObject:receipt];
        }
        else
        {
            receipt.dataAction = DataActionNone;
        }
    }
    
    [self.receipts removeObjectsInArray:receiptsToDelete];
    
    
    NSMutableArray *taxYearsToDelete = [NSMutableArray new];
    
    for (TaxYear *taxYear in self.taxYears)
    {
        if (taxYear.dataAction == DataActionDelete)
        {
            [taxYearsToDelete addObject:taxYear];
        }
        else
        {
            taxYear.dataAction = DataActionNone;
        }
    }
    
    [self.taxYears removeObjectsInArray:taxYearsToDelete];
}

@end
