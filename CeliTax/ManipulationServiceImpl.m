//
// ManipulationServiceImpl.m
// CeliTax
//
// Created by Leon Chen on 2015-05-05.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ManipulationServiceImpl.h"
#import "CatagoriesDAO.h"
#import "ReceiptsDAO.h"
#import "RecordsDAO.h"
#import "Catagory.h"
#import "Record.h"
#import "TaxYearsDAO.h"

@implementation ManipulationServiceImpl

- (BOOL) addCatagoryForName: (NSString *) catagoryName forColor: (UIColor *) catagoryColor
{
    if (!catagoryName || !catagoryColor)
    {
        return NO;
    }

    if ([self.catagoriesDAO addCatagoryForName: catagoryName andColor: catagoryColor andNationalAverageCost: 0])
    {
        return YES;
    }

    return NO;
}

- (BOOL) modifyCatagoryForCatagoryID: (NSString *) catagoryID newName: (NSString *) catagoryName newColor: (UIColor *) catagoryColor
{
    if ([self.catagoriesDAO modifyCatagory: catagoryID forName: catagoryName andColor: catagoryColor])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) deleteCatagoryForCatagoryID: (NSString *) catagoryID
{
    if ([self.catagoriesDAO deleteCatagory: catagoryID])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) transferCatagoryFromCatagoryID: (NSString *) fromCatagoryID toCatagoryID: (NSString *) toCatagoryID
{
    NSArray *fromRecords = [self.recordsDAO loadRecordsforCatagory: fromCatagoryID];

    if (!fromRecords)
    {
        // nothing to transfer
        return YES;
    }

    Catagory *toItemCatagory = [self.catagoriesDAO loadCatagory: toCatagoryID];

    if (!toItemCatagory)
    {
        return NO;
    }

    NSMutableArray *modifiedRecordsToAdd = [NSMutableArray new];

    for (Record *record in fromRecords)
    {
        record.catagoryID = [toCatagoryID copy];

        [modifiedRecordsToAdd addObject: record];
    }

    if ([self.recordsDAO addRecords: modifiedRecordsToAdd])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *) addRecordForCatagoryID: (NSString *) catagoryID forReceiptID: (NSString *) receiptID forQuantity: (NSInteger) quantity forAmount: (float) amount
{
    Catagory *toItemCatagory = [self.catagoriesDAO loadCatagory: catagoryID];

    if (!toItemCatagory)
    {
        return nil;
    }

    NSString *newestRecordID = [self.recordsDAO addRecordForCatagoryID: catagoryID andReceiptID: receiptID forQuantity: quantity forAmount: amount];

    if (newestRecordID)
    {
        return newestRecordID;
    }
    
    return nil;
}

- (BOOL) deleteRecord: (NSString *) recordID
{
    NSArray *arrayWithSingleNumber = [NSArray arrayWithObject: recordID];

    if ([self.recordsDAO deleteRecordsForRecordIDs: arrayWithSingleNumber])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) modifyRecord: (Record *) record
{
    if ([self.recordsDAO modifyRecord: record])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *) addReceiptForFilenames: (NSArray *) filenames
                           andTaxYear: (NSInteger) taxYear
{
    if ( !filenames )
    {
        return nil;
    }
    
    NSString *newReceiptID = [self.receiptsDAO addReceiptWithFilenames: filenames inTaxYear:taxYear];
    if ( newReceiptID )
    {
        return ( newReceiptID );
    }
    
    return nil;
}

- (BOOL) modifyReceipt:(Receipt *)receipt
{
    if (!receipt)
    {
        return NO;
    }
    
    return [self.receiptsDAO modifyReceipt:receipt];
}

- (BOOL) deleteReceiptAndAllItsRecords: (NSString *) receiptID
{
    if (!receiptID)
    {
        return NO;
    }

    NSArray *recordsForThisReceipt = [self.recordsDAO loadRecordsforReceipt: receiptID];

    NSMutableArray *arrayOfReceiptIDs = [NSMutableArray new];

    for (Record *recordToDelete in recordsForThisReceipt)
    {
        [arrayOfReceiptIDs addObject: recordToDelete.localID];
    }

    if ([self.recordsDAO deleteRecordsForRecordIDs: arrayOfReceiptIDs])
    {
        if ([self.receiptsDAO deleteReceipt: receiptID])
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) addTaxYear: (NSInteger) taxYear
{
    return [self.taxYearsDAO addTaxYear:taxYear];
}

@end