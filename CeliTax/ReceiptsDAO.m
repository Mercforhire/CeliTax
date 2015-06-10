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

- (BOOL) addReceiptWithFilenames: (NSArray *) filenames
{
    if (!filenames)
    {
        return NO;
    }

    Receipt *newReceipt = [Receipt new];
    newReceipt.identifer = [Utils generateUniqueID];
    newReceipt.fileNames = [filenames mutableCopy];
    newReceipt.dateCreated = [NSDate date];

    [[self.userDataDAO getReceipts] addObject: newReceipt];

    return [self.userDataDAO saveUserData];
}

- (BOOL) addReceipt: (Receipt *) receiptToAdd
{
    if (!receiptToAdd)
    {
        return NO;
    }

    [[self.userDataDAO getReceipts] addObject: receiptToAdd];

    return [self.userDataDAO saveUserData];
}

- (NSArray *) loadReceipts
{
    return [self.userDataDAO getReceipts];
}

- (NSArray *) loadNewestNthReceipts: (NSInteger) nTh inYear: (NSInteger) year
{
    NSArray *allReceipts = [self.userDataDAO getReceipts];

    // filter only receipts from the chosen year
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ) fromDate: [NSDate date]];

    // create a start date with these components
    [components setMonth: 1];
    [components setDay: 1]; // reset the other components
    [components setYear: year]; // reset the other components

    NSDate *startDate = [calendar dateFromComponents: components];

    // create a end date with these components
    [components setMonth: 1];
    [components setDay: 1]; // reset the other components
    [components setYear: year + 1]; // reset the other components

    NSDate *endDate = [calendar dateFromComponents: components];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"((dateCreated >= %@) AND (dateCreated < %@)) || (dateCreated = nil)", startDate, endDate];
    NSArray *allReceiptsInChosen = [allReceipts filteredArrayUsingPredicate: predicate];

    NSArray *sortedAllReceipts = [allReceiptsInChosen sortedArrayUsingComparator: ^NSComparisonResult (Receipt *a, Receipt *b) {
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

- (NSArray *)loadReceiptsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSArray *allReceipts = [self.userDataDAO getReceipts];
    
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
    NSPredicate *findReceipt = [NSPredicate predicateWithFormat: @"identifer == %@", receiptID];
    NSArray *receipt = [[self.userDataDAO getReceipts] filteredArrayUsingPredicate: findReceipt];

    return [receipt firstObject];
}

@end