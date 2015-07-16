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
{
    if (catagory)
    {
        Record *newRecord = [Record new];
        
        newRecord.localID = [Utils generateUniqueID];
        newRecord.dateCreated = [NSDate date];
        newRecord.catagoryID = [catagory.localID copy];
        newRecord.receiptID = [receipt.localID copy];
        newRecord.quantity = quantity;
        newRecord.amount = amount;
        newRecord.dataAction = DataActionInsert;
        
        //set it back to userData and save it
        [[self.userDataDAO getRecords] addObject:newRecord];
        
        NSString *newRecordID = newRecord.localID;
        
        if ([self.userDataDAO saveUserData])
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
{
    Catagory *catagory = [self.catagoriesDAO loadCatagory:catagoryID];
    
    if (catagory)
    {
        Record *newRecord = [Record new];
        
        newRecord.localID = [Utils generateUniqueID];
        newRecord.dateCreated = [NSDate date];
        newRecord.catagoryID = [catagoryID copy];
        newRecord.receiptID = [receiptID copy];
        newRecord.quantity = quantity;
        newRecord.amount = amount;
        newRecord.dataAction = DataActionInsert;
        
        //set it back to userData and save it
        [[self.userDataDAO getRecords] addObject:newRecord];
        
        NSString *newRecordID = newRecord.localID;
        
        if ([self.userDataDAO saveUserData])
        {
            return newRecordID;
        }
    }
    //else we should not be adding a record to a userData that doesn't have any set catagories
    
    return nil;
}

-(BOOL)addRecords:(NSArray *)records
{
    [[self.userDataDAO getRecords] addObjectsFromArray:records];
    
    return [self.userDataDAO saveUserData];
}

-(BOOL)modifyRecord:(Record *)record
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
        
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return NO;
    }
}

-(BOOL)deleteRecordsForRecordIDs:(NSArray *)recordIDs
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
        if (!recordToDelete.serverID)
        {
            //recordToDelete is not on server, delete it right away
            [[self.userDataDAO getRecords] removeObject:recordToDelete];
        }
        else
        {
            //recordToDelete is on server, have to set its DataAction to delete
            recordToDelete.dataAction = DataActionDelete;
        }
    }
    
    return [self.userDataDAO saveUserData];
}

@end
