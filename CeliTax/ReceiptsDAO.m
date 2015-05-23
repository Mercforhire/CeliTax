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

-(NSInteger)getNextReceiptID
{
    return [self.userDataDAO getReceipts].count;
}

-(BOOL)addReceiptWithFilenames:(NSArray *)filenames
{
    if ( !filenames )
    {
        return NO;
    }
    
    Receipt *newReceipt = [Receipt new];
    newReceipt.identifer = [self getNextReceiptID];
    newReceipt.fileNames = [filenames mutableCopy];
    newReceipt.dateCreated = [NSDate date];
    
    [[self.userDataDAO getReceipts] addObject:newReceipt];
    
    return [self.userDataDAO saveUserData];
}

-(NSArray *)loadReceipts
{
    return [self.userDataDAO getReceipts];
}

-(Receipt *)loadReceipt:(NSInteger)receiptID
{
    NSPredicate *findReceipt = [NSPredicate predicateWithFormat: @"identifer == %ld", (long)receiptID];
    NSArray *receipt = [[self.userDataDAO getReceipts] filteredArrayUsingPredicate: findReceipt];
    
    return [receipt firstObject];
}

@end
