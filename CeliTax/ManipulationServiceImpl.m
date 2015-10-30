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
#import "Notifications.h"
#import "TaxYearsDAO.h"

@implementation ManipulationServiceImpl

- (BOOL) addCatagoryForName: (NSString *) catagoryName forColor: (UIColor *) catagoryColor save: (BOOL)save
{
    if (!catagoryName || !catagoryColor)
    {
        return NO;
    }

    if ([self.catagoriesDAO addCatagoryForName: catagoryName andColor: catagoryColor save:save])
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

    for (Record *record in fromRecords)
    {
        if (record == fromRecords.lastObject)
        {
            [self.recordsDAO addRecordForCatagoryID:toItemCatagory.localID andReceiptID:record.receiptID forQuantity:record.quantity orUnit:record.unitType forAmount:record.amount save: YES];
        }
        else
        {
            [self.recordsDAO addRecordForCatagoryID:toItemCatagory.localID andReceiptID:record.receiptID forQuantity:record.quantity orUnit:record.unitType forAmount:record.amount save: NO];
        }
    }

    return YES;
}

-(BOOL)addOrUpdateNationalAverageCostForCatagoryID: (NSString *) catagoryID andUnitType:(NSInteger)unitType amount:(float)amount save: (BOOL)save
{
    Catagory *catagoryToModify = [self.catagoriesDAO loadCatagory: catagoryID];
    
    if (!catagoryToModify)
    {
        return NO;
    }
    
    if ([self.catagoriesDAO addOrUpdateNationalAverageCostForCatagoryID: catagoryID andUnitType:unitType amount:amount save: save])
    {
        return YES;
    }
    
    return NO;
}

-(BOOL)deleteNationalAverageCostForCatagoryID: (NSString *) catagoryID andUnitType:(NSInteger)unitType save: (BOOL)save
{
    Catagory *catagoryToModify = [self.catagoriesDAO loadCatagory: catagoryID];
    
    if (!catagoryToModify)
    {
        return NO;
    }
    
    if ([self.catagoriesDAO deleteNationalAverageCostForCatagoryID: catagoryID andUnitType: unitType save: save])
    {
        return YES;
    }
    
    return NO;
}

-(NSString *)addRecordForCatagoryID: (NSString *) catagoryID
                       andReceiptID: (NSString *) receiptID
                        forQuantity: (NSInteger) quantity
                             orUnit: (NSInteger) unitType
                          forAmount: (float) amount
                               save: (BOOL)save
{
    Catagory *toItemCatagory = [self.catagoriesDAO loadCatagory: catagoryID];

    if (!toItemCatagory)
    {
        return nil;
    }

    NSString *newestRecordID = [self.recordsDAO addRecordForCatagoryID: catagoryID
                                                          andReceiptID: receiptID
                                                           forQuantity: quantity
                                                                orUnit:unitType
                                                             forAmount: amount
                                                                  save:save];
    if (newestRecordID)
    {
        return newestRecordID;
    }
    
    return nil;
}

- (BOOL) deleteRecord: (NSString *) recordID save:(BOOL)save
{
    NSArray *arrayWithSingleNumber = @[recordID];

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
        // send a kReceiptDatabaseChangedNotification notification when a Receipt is added or deleted
        [[NSNotificationCenter defaultCenter] postNotification: [NSNotification notificationWithName:kReceiptDatabaseChangedNotification object:nil]];
        
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
            // send a kReceiptDatabaseChangedNotification notification when a Receipt is added or deleted
            [[NSNotificationCenter defaultCenter] postNotification: [NSNotification notificationWithName:kReceiptDatabaseChangedNotification object:nil]];
            
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