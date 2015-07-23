//
//  RecordsDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "RecordsDAO.h"
#import "Catagory.h"
#import "Record.h"
#import "Receipt.h"
#import "Utils.h"

@implementation RecordsDAO

-(NSArray *)loadRecords
{
    NSPredicate *loadRecords = [NSPredicate predicateWithFormat: @"dataAction != %ld", DataActionDelete];
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
    
    return [record firstObject];
}

-(NSString *)addRecordForCatagory: (Catagory *) catagory
                       andReceipt: (Receipt *) receipt
                      forQuantity: (NSInteger) quantity
                        forAmount: (float) amount
                             save: (BOOL)save
{
    if (catagory)
    {
        Record *newRecord = [Record new];
        
        newRecord.localID = [Utils generateUniqueID];
        newRecord.catagoryID = [catagory.localID copy];
        newRecord.receiptID = [receipt.localID copy];
        newRecord.quantity = quantity;
        newRecord.amount = amount;
        newRecord.dataAction = DataActionInsert;
        
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
                          forAmount: (float) amount
                               save: (BOOL)save
{
    Catagory *catagory = [self.catagoriesDAO loadCatagory:catagoryID];
    
    if (catagory)
    {
        Record *newRecord = [Record new];
        
        newRecord.localID = [Utils generateUniqueID];
        newRecord.catagoryID = [catagoryID copy];
        newRecord.receiptID = [receiptID copy];
        newRecord.quantity = quantity;
        newRecord.amount = amount;
        newRecord.dataAction = DataActionInsert;
        
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
        recordToModify.catagoryID = [record.catagoryID copy];
        recordToModify.receiptID = [record.receiptID copy];
        
        if (recordToModify.dataAction != DataActionInsert)
        {
            recordToModify.dataAction = DataActionUpdate;
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
        recordToDelete.dataAction = DataActionDelete;
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
        NSPredicate *findRecord = [NSPredicate predicateWithFormat: @"localID == %ld", record.localID];
        NSArray *existingRecord = [localRecords filteredArrayUsingPredicate: findRecord];
        
        if (existingRecord.count)
        {
            Record *existing = [existingRecord firstObject];
            
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
        if (record.dataAction != DataActionInsert)
        {
            record.dataAction = DataActionInsert;
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

@end
