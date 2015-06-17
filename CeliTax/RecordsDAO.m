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
    return [self.userDataDAO getRecords];
}

-(NSArray *)loadRecordsforCatagory:(NSString *)catagoryID
{
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    NSArray *records = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    return records;
}

-(NSArray *)loadRecordsforReceipt:(NSString *)receiptID
{
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"receiptID == %@", receiptID];
    NSArray *records = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    return records;
}

-(Record *)loadRecord:(NSString *)recordID
{
    NSPredicate *findRecord = [NSPredicate predicateWithFormat: @"identifer == %@", recordID];
    NSArray *record = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecord];
    
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
        
        newRecord.identifer = [Utils generateUniqueID];
        newRecord.dateCreated = [NSDate date];
        newRecord.catagoryID = [catagory.identifer copy];
        newRecord.catagoryName = [catagory.name copy];
        newRecord.receiptID = [receipt.identifer copy];
        newRecord.quantity = quantity;
        newRecord.amount = amount;
        
        //set it back to userData and save it
        [[self.userDataDAO getRecords] addObject:newRecord];
        
        NSString *newRecordID = newRecord.identifer;
        
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
        
        newRecord.identifer = [Utils generateUniqueID];
        newRecord.dateCreated = [NSDate date];
        newRecord.catagoryID = [catagoryID copy];
        newRecord.catagoryName = [catagory.name copy];
        newRecord.receiptID = [receiptID copy];
        newRecord.quantity = quantity;
        newRecord.amount = amount;
        
        //set it back to userData and save it
        [[self.userDataDAO getRecords] addObject:newRecord];
        
        NSString *newRecordID = newRecord.identifer;
        
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
    Record *recordToModify = [self loadRecord:record.identifer];
    
    if (recordToModify)
    {
        recordToModify.quantity = record.quantity;
        recordToModify.amount = record.amount;
        recordToModify.catagoryID = [record.catagoryID copy];
        recordToModify.catagoryName = [record.catagoryName copy];
        recordToModify.receiptID = [record.receiptID copy];
        
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
    
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"identifer in %@", recordIDs];
    NSArray *recordsToDelete = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    if ( !recordsToDelete || !recordsToDelete.count )
    {
        return NO;
    }
    
    [[self.userDataDAO getRecords] removeObjectsInArray:recordsToDelete];
    
    return [self.userDataDAO saveUserData];
}

@end
