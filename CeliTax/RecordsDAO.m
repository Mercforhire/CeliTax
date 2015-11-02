//
//  RecordsDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "RecordsDAO.h"
#import "Utils.h"

#import "CeliTax-Swift.h"

@implementation RecordsDAO

-(NSArray *)loadRecords
{
    NSPredicate *loadRecords = [NSPredicate predicateWithFormat: @"dataAction != %ld", DataActionStatusDataActionDelete];
    NSArray *records = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: loadRecords];
    
    return records;
}

-(NSArray *)loadRecordsforCatagory:(NSString *)catagoryID
{
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    NSArray *records = [[self loadRecords] filteredArrayUsingPredicate: findRecords];
    
    return records;
}

-(NSArray *)loadRecordsforReceipt:(NSString *)receiptID
{
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"receiptID == %@", receiptID];
    NSArray *records = [[self loadRecords] filteredArrayUsingPredicate: findRecords];
    
    return records;
}

-(Record *)loadRecord:(NSString *)recordID
{
    NSPredicate *findRecord = [NSPredicate predicateWithFormat: @"localID == %@", recordID];
    NSArray *record = [[self loadRecords] filteredArrayUsingPredicate: findRecord];
    
    return record.firstObject;
}

-(NSString *)addRecordForCatagory: (ItemCategory *) category
                       andReceipt: (Receipt *) receipt
                      forQuantity: (NSInteger) quantity
                           orUnit: (NSInteger) unitType
                        forAmount: (float) amount
                             save: (BOOL)save
{
    if (category)
    {
        Record *newRecord = [Record new];
        
        newRecord.localID = [Utils generateUniqueID];
        newRecord.catagoryID = [category.localID copy];
        newRecord.receiptID = [receipt.localID copy];
        newRecord.quantity = quantity;
        newRecord.unitType = unitType;
        newRecord.amount = amount;
        newRecord.dataAction = DataActionStatusDataActionInsert;
        
        //set it back to userData and save it
        [[self.userDataDAO getRecords] addObject:newRecord];
        
        NSString *newRecordID = newRecord.localID;
        
        if (save)
        {
            if ([self.userDataDAO saveUserData])
            {
                return newRecordID;
            }
        }
        else
        {
            return newRecordID;
        }
    }
    //else we should not be adding a record to a userData that doesn't have any set catagories
    
    return nil;
}

-(NSString *)addRecordForCatagoryID: (NSString *) catagoryID
                       andReceiptID: (NSString *) receiptID
                        forQuantity: (NSInteger) quantity
                             orUnit: (NSInteger) unitType
                          forAmount: (float) amount
                               save: (BOOL)save
{
    ItemCategory *category = [self.catagoriesDAO loadCatagory:catagoryID];
    
    if (category)
    {
        Record *newRecord = [Record new];
        
        newRecord.localID = [Utils generateUniqueID];
        newRecord.catagoryID = [catagoryID copy];
        newRecord.receiptID = [receiptID copy];
        newRecord.quantity = quantity;
        newRecord.unitType = unitType;
        newRecord.amount = amount;
        newRecord.dataAction = DataActionStatusDataActionInsert;
        
        //set it back to userData and save it
        [[self.userDataDAO getRecords] addObject:newRecord];
        
        NSString *newRecordID = newRecord.localID;
        
        if (save)
        {
            if ([self.userDataDAO saveUserData])
            {
                return newRecordID;
            }
        }
        else
        {
            return newRecordID;
        }
    }
    //else we should not be adding a record to a userData that doesn't have any set catagories
    
    return nil;
}

-(BOOL)addRecords:(NSArray *)records save: (BOOL)save
{
    [[self.userDataDAO getRecords] addObjectsFromArray:records];
    
    if (save)
    {
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return YES;
    }
}

-(BOOL)modifyRecord:(Record *)record save: (BOOL)save
{
    Record *recordToModify = [self loadRecord:record.localID];
    
    if (recordToModify)
    {
        recordToModify.quantity = record.quantity;
        recordToModify.amount = record.amount;
        recordToModify.unitType = record.unitType;
        recordToModify.catagoryID = [record.catagoryID copy];
        recordToModify.receiptID = [record.receiptID copy];
        
        if (recordToModify.dataAction != DataActionStatusDataActionInsert)
        {
            recordToModify.dataAction = DataActionStatusDataActionUpdate;
        }
        
        if (save)
        {
            return [self.userDataDAO saveUserData];
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

-(BOOL)deleteRecordsForRecordIDs:(NSArray *)recordIDs save: (BOOL)save
{
    if ( !recordIDs || !recordIDs.count )
    {
        return YES;
    }
    
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"localID in %@", recordIDs];
    NSArray *recordsToDelete = [[self loadRecords] filteredArrayUsingPredicate: findRecords];
    
    if ( !recordsToDelete || !recordsToDelete.count )
    {
        return NO;
    }
    
    for (Record *recordToDelete in recordsToDelete)
    {
        recordToDelete.dataAction = DataActionStatusDataActionDelete;
    }
    
    if (save)
    {
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return YES;
    }
}

-(BOOL)mergeWith:(NSArray *)records save:(BOOL)save
{
    NSMutableArray *localRecords = [NSMutableArray arrayWithArray:[self loadRecords]];
    
    for (Record *record in records)
    {
        //find any existing Record with same id as this new one
        NSPredicate *findRecord = [NSPredicate predicateWithFormat: @"localID == %@", record.localID];
        NSArray *existingRecord = [localRecords filteredArrayUsingPredicate: findRecord];
        
        if (existingRecord.count)
        {
            Record *existing = existingRecord.firstObject;
            
            [existing copyDataFromRecord:record];
            
            [localRecords removeObject:existing];
        }
        else
        {
            [[self.userDataDAO getRecords] addObject:record];
        }
    }
    
    //For any local Record that the server doesn't have and isn't marked DataActionInsert,
    //we need to set these to DataActionInsert again so that can be uploaded to the server next time
    for (Record *record in localRecords)
    {
        if (record.dataAction != DataActionStatusDataActionInsert)
        {
            record.dataAction = DataActionStatusDataActionInsert;
        }
    }
    
    
    if (save)
    {
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return YES;
    }
}

- (NSArray *) fetchRecordsOfCatagory: (NSString *) catagoryID inReceipt: (NSString *) receiptID
{
    NSArray *allRecordsForReceipt = [self loadRecordsforReceipt: receiptID];
    
    NSPredicate *findRecordsWithGivenCatagoryID = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    
    NSArray *recordsWithGivenCatagoryID = [allRecordsForReceipt filteredArrayUsingPredicate: findRecordsWithGivenCatagoryID];
    
    return recordsWithGivenCatagoryID;
}

- (NSArray *) fetchRecordsOfCatagory: (NSString *) catagoryID ofUnitType:(UnitTypes) unitType inReceipt: (NSString *) receiptID
{
    NSArray *allRecordsForReceipt = [self loadRecordsforReceipt: receiptID];
    
    NSPredicate *findRecordsWithGivenCatagoryIDAndUnitType = [NSPredicate predicateWithFormat: @"catagoryID == %@ AND unitType == %ld", catagoryID, unitType];
    
    NSArray *recordsWithGivenCatagoryIDAndUnitType = [allRecordsForReceipt filteredArrayUsingPredicate: findRecordsWithGivenCatagoryIDAndUnitType];
    
    return recordsWithGivenCatagoryIDAndUnitType;
}

@end
