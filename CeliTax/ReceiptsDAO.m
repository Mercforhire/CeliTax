//
//  ReceiptsDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptsDAO.h"
#import "Receipt.h"

@implementation ReceiptsDAO

-(BOOL)addReceiptWithFilenames:(NSArray *)filenames
{
    if ( !filenames )
    {
        return NO;
    }
    
    Receipt *newReceipt = [Receipt new];
    newReceipt.identifer = [[NSUUID UUID] UUIDString];
    newReceipt.fileNames = [filenames mutableCopy];
    newReceipt.dateCreated = [NSDate date];
    
    [[self.userDataDAO getReceipts] addObject:newReceipt];
    
    return [self.userDataDAO saveUserData];
}

-(NSArray *)loadReceipts
{
    return [self.userDataDAO getReceipts];
}

-(NSArray *)loadLast5Receipts
{
    NSArray *allReceipts = [self.userDataDAO getReceipts];
    NSArray *newest5Receipts;
    
    if (allReceipts.count >= 5)
    {
        NSRange range = NSMakeRange(allReceipts.count - 1 - 4, allReceipts.count - 1); //56789
        
        newest5Receipts = [allReceipts subarrayWithRange:range];
    }
    else
    {
        newest5Receipts = allReceipts;
    }
    
    return newest5Receipts;
}

-(Receipt *)loadReceipt:(NSString *)receiptID
{
    NSPredicate *findReceipt = [NSPredicate predicateWithFormat: @"identifer == %@", receiptID];
    NSArray *receipt = [[self.userDataDAO getReceipts] filteredArrayUsingPredicate: findReceipt];
    
    return [receipt firstObject];
}

@end
