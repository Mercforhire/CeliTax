//
// ReceiptsDAO.m
// CeliTax
//
// Created by Leon Chen on 2015-05-22.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptsDAO.h"
#import "Receipt.h"
#import "Utils.h"

@implementation ReceiptsDAO

- (NSString *) addReceiptWithFilenames: (NSArray *) filenames inTaxYear:(NSInteger)taxYear save:(BOOL) save
{
    if (!filenames)
    {
        return nil;
    }

    Receipt *newReceipt = [Receipt new];
    newReceipt.localID = [Utils generateUniqueID];
    newReceipt.fileNames = [filenames mutableCopy];
    newReceipt.dateCreated = [NSDate date];
    newReceipt.taxYear = taxYear;
    newReceipt.dataAction = DataActionInsert;

    [[self.userDataDAO getReceipts] addObject: newReceipt];
    
    if (save)
    {
        if ( [self.userDataDAO saveUserData] )
        {
            return newReceipt.localID;
        }
    }
    else
    {
        return newReceipt.localID;
    }
    
    return nil;
}

- (BOOL) addReceipt: (Receipt *) receiptToAdd save:(BOOL) save
{
    if (!receiptToAdd)
    {
        return NO;
    }

    [[self.userDataDAO getReceipts] addObject: receiptToAdd];

    if (save)
    {
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return YES;
    }
}

/*
 @return NSArray of Receipts, nil if user not found or has no receipts
 */
- (NSArray *) loadAllReceipts
{
    NSPredicate *loadReceipts = [NSPredicate predicateWithFormat: @"dataAction != %ld", DataActionDelete];
    NSArray *receipts = [[self.userDataDAO getReceipts] filteredArrayUsingPredicate: loadReceipts];
    
    return receipts;
}

- (NSArray *) loadReceiptsFromTaxYear:(NSInteger)taxYear;
{
    NSPredicate *filterReceipts = [NSPredicate predicateWithFormat: @"taxYear == %ld", taxYear];
    NSArray *receipts = [[self loadAllReceipts] filteredArrayUsingPredicate: filterReceipts];
    
    return receipts;
}

- (NSArray *) loadNewestNthReceipts: (NSInteger) nTh inTaxYear: (NSInteger) taxYear
{
    NSArray *allReceipts = [self loadReceiptsFromTaxYear:taxYear];

    NSArray *sortedAllReceipts = [allReceipts sortedArrayUsingComparator: ^NSComparisonResult (Receipt *a, Receipt *b) {
        NSDate *first = a.dateCreated;
        NSDate *second = b.dateCreated;
        return [second compare: first];
    }];

    NSMutableArray *newestNThReceipts = [NSMutableArray arrayWithCapacity: nTh];

    NSEnumerator *enumerator = [sortedAllReceipts objectEnumerator];

    for (id element in enumerator)
    {
        if (newestNThReceipts.count == nTh)
        {
            break;
        }

        [newestNThReceipts addObject: element];
    }

    return newestNThReceipts;
}

- (NSArray *)loadReceiptsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate inTaxYear:(NSInteger)taxYear
{
    NSArray *allReceipts = [self loadReceiptsFromTaxYear:taxYear];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"((dateCreated >= %@) AND (dateCreated <= %@)) || (dateCreated = nil)", fromDate, toDate];
    NSArray *allReceiptsInChosen = [allReceipts filteredArrayUsingPredicate: predicate];
    
    NSArray *sortedAllReceipts = [allReceiptsInChosen sortedArrayUsingComparator: ^NSComparisonResult (Receipt *a, Receipt *b) {
        NSDate *first = a.dateCreated;
        NSDate *second = b.dateCreated;
        return [second compare: first];
    }];
    
    return sortedAllReceipts;
}

- (Receipt *) loadReceipt: (NSString *) receiptID
{
    NSPredicate *findReceipt = [NSPredicate predicateWithFormat: @"localID == %@", receiptID];
    NSArray *receipt = [[self loadAllReceipts] filteredArrayUsingPredicate: findReceipt];

    return [receipt firstObject];
}

- (BOOL)modifyReceipt: (Receipt *)receipt save:(BOOL) save
{
    Receipt *receiptToModify = [self loadReceipt:receipt.localID];
    
    if (receiptToModify)
    {
        receiptToModify.fileNames = [receipt.fileNames mutableCopy];
        receiptToModify.taxYear = receipt.taxYear;
        
        if (receiptToModify.dataAction != DataActionInsert)
        {
            receiptToModify.dataAction = DataActionUpdate;
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

- (BOOL) deleteReceipt: (NSString *) receiptID save:(BOOL) save
{
    Receipt *receiptToDelete = [self loadReceipt:receiptID];
    
    if (receiptToDelete)
    {
        receiptToDelete.dataAction = DataActionDelete;
        
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

-(BOOL)mergeWith:(NSArray *)receipts save:(BOOL)save
{
    NSMutableArray *localReceipts = [NSMutableArray arrayWithArray:[self loadAllReceipts]];
    
    for (Receipt *receipt in receipts)
    {
        //find any existing Receipt with same id as this new one
        NSPredicate *findReceipt = [NSPredicate predicateWithFormat: @"localID == %@", receipt.localID];
        NSArray *existingReceipt = [localReceipts filteredArrayUsingPredicate: findReceipt];
        
        if (existingReceipt.count)
        {
            Receipt *existing = [existingReceipt firstObject];
            
            [existing copyDataFromReceipt:receipt];
            
            [localReceipts removeObject:existing];
        }
        else
        {
            [self addReceipt:receipt save:NO];
        }
    }
    
    //For any local Receipt that the server doesn't have and isn't marked DataActionInsert,
    //we need to set these to DataActionInsert again so that can be uploaded to the server next time
    for (Receipt *receipt in localReceipts)
    {
        if (receipt.dataAction != DataActionInsert)
        {
            receipt.dataAction = DataActionInsert;
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