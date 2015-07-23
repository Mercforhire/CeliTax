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

- (BOOL) addCatagoryForName: (NSString *) catagoryName forColor: (UIColor *) catagoryColor save: (BOOL)save
{
    if (!catagoryName || !catagoryColor)
    {
        return NO;
    }

    if ([self.catagoriesDAO addCatagoryForName: catagoryName andColor: catagoryColor andNationalAverageCost: 0 save:save])
    {
        return YES;
    }

    return NO;
}

- (BOOL) modifyCatagoryForCatagoryID: (NSString *) catagoryID newName: (NSString *) catagoryName newColor: (UIColor *) catagoryColor save: (BOOL)save
{
    if ([self.catagoriesDAO modifyCatagory: catagoryID forName: catagoryName andColor: catagoryColor save:save])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) deleteCatagoryForCatagoryID: (NSString *) catagoryID save: (BOOL)save
{
    if ([self.catagoriesDAO deleteCatagory: catagoryID save:save])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) transferCatagoryFromCatagoryID: (NSString *) fromCatagoryID toCatagoryID: (NSString *) toCatagoryID save: (BOOL)save
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
        record.dataAction = DataActionInsert;

        [modifiedRecordsToAdd addObject: record];
    }

    if ([self.recordsDAO addRecords: modifiedRecordsToAdd save:save])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *) addRecordForCatagoryID: (NSString *) catagoryID forReceiptID: (NSString *) receiptID forQuantity: (NSInteger) quantity forAmount: (float) amount save: (BOOL)save
{
    Catagory *toItemCatagory = [self.catagoriesDAO loadCatagory: catagoryID];

    if (!toItemCatagory)
    {
        return nil;
    }

    NSString *newestRecordID = [self.recordsDAO addRecordForCatagoryID: catagoryID andReceiptID: receiptID forQuantity: quantity forAmount: amount save:save];

    if (newestRecordID)
    {
        return newestRecordID;
    }
    
    return nil;
}

- (BOOL) deleteRecord: (NSString *) recordID save:(BOOL)save
{
    NSArray *arrayWithSingleNumber = [NSArray arrayWithObject: recordID];

    if ([self.recordsDAO deleteRecordsForRecordIDs: arrayWithSingleNumber save:save])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) modifyRecord: (Record *) record save:(BOOL)save
{
    if ([self.recordsDAO modifyRecord: record save:save])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *) addReceiptForFilenames: (NSArray *) filenames
                           andTaxYear: (NSInteger) taxYear
                                 save: (BOOL)save
{
    if ( !filenames )
    {
        return nil;
    }
    
    NSString *newReceiptID = [self.receiptsDAO addReceiptWithFilenames: filenames inTaxYear:taxYear save:save];
    if ( newReceiptID )
    {
        return ( newReceiptID );
    }
    
    return nil;
}

- (BOOL) modifyReceipt:(Receipt *)receipt save: (BOOL)save
{
    if (!receipt)
    {
        return NO;
    }
    
    return [self.receiptsDAO modifyReceipt:receipt save:save];
}

- (BOOL) deleteReceiptAndAllItsRecords: (NSString *) receiptID save: (BOOL)save
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

    if ([self.recordsDAO deleteRecordsForRecordIDs: arrayOfReceiptIDs save:save])
    {
        if ([self.receiptsDAO deleteReceipt: receiptID save:save])
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) addTaxYear: (NSInteger) taxYear save: (BOOL)save
{
    return [self.taxYearsDAO addTaxYear:taxYear save:save];
}

@end