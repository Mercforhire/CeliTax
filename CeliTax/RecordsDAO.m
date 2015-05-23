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

@implementation RecordsDAO

-(NSArray *)loadRecords
{
    return [self.userDataDAO getRecords];
}

-(NSArray *)loadRecordsforCatagory:(NSInteger)catagoryID
{
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"catagoryID == %ld", (long)catagoryID];
    NSArray *records = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    return records;
}

-(NSArray *)loadRecordsforReceipt:(NSInteger)receiptID
{
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"receiptID == %ld", (long)receiptID];
    NSArray *records = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    return records;
}

-(BOOL)addRecordForCatagoryID:(NSInteger)catagoryID forReceiptID:(NSInteger)receiptID
                  forQuantity:(NSInteger)quantity forAmount:(NSInteger)amount
{
    Catagory *catagory = [self.catagoriesDAO loadCatagory:catagoryID];
    
    if (catagory)
    {
        Record *newRecord = [Record new];
        
        newRecord.identifer = [self.userDataDAO getRecords].count;
        newRecord.dateCreated = [NSDate date];
        newRecord.catagoryID = catagoryID;
        newRecord.catagoryName = catagory.name;
        newRecord.receiptID = receiptID;
        newRecord.quantity = quantity;
        newRecord.amount = amount;
        
        //set it back to userData and save it
        [[self.userDataDAO getRecords] addObject:newRecord];
        
        return [self.userDataDAO saveUserData];
    }
    //else we should not be adding a record to a userData that doesn't have any set catagories
    
    return NO;
}

-(BOOL)addRecords:(NSArray *)records
{
    [[self.userDataDAO getRecords] addObjectsFromArray:records];
    
    return [self.userDataDAO saveUserData];
}

-(BOOL)deleteCatagoryAndRecordsForRecordIDs:(NSArray *)recordIDs
{
    if ( !recordIDs )
    {
        return NO;
    }
    
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"identifer in %@", recordIDs];
    NSArray *recordsToDelete = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    [[self.userDataDAO getRecords] removeObjectsInArray:recordsToDelete];
    
    return [self.userDataDAO saveUserData];
}

@end
