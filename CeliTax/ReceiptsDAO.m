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

- (NSString *) addReceiptWithFilenames: (NSArray *) filenames inTaxYear:(NSInteger)taxYear
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

    [[self.userDataDAO getReceipts] addObject: newReceipt];

    if ( [self.userDataDAO saveUserData] )
    {
        return newReceipt.localID;
    }
    
    return nil;
}

//used by debug purposes only
- (BOOL) addReceipt: (Receipt *) receiptToAdd
{
    if (!receiptToAdd)
    {
        return NO;
    }

    [[self.userDataDAO getReceipts] addObject: receiptToAdd];

    return [self.userDataDAO saveUserData];
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

- (BOOL)modifyReceipt: (Receipt *)receipt
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
        
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return NO;
    }
}

- (BOOL) deleteReceipt: (NSString *) receiptID
{
    Receipt *receiptToDelete = [self loadReceipt:receiptID];
    
    if (receiptToDelete)
    {
        if (!receiptToDelete.serverID)
        {
            [[self.userDataDAO getReceipts] removeObject: receiptToDelete];
        }
        else
        {
            receiptToDelete.dataAction = DataActionDelete;
        }
        
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return NO;
    }
}
@end