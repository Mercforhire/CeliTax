//
// DataServiceImpl.m
// CeliTax
//
// Created by Leon Chen on 2015-05-02.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "DataServiceImpl.h"
#import "Catagory.h"
#import "Record.h"
#import "CatagoriesDAO.h"
#import "ReceiptsDAO.h"
#import "RecordsDAO.h"
#import "TaxYearsDAO.h"
#import "Receipt.h"
#import "Utils.h"


@interface DataServiceImpl ()

@end

@implementation DataServiceImpl

- (NSArray *) fetchCatagories
{
    NSArray *catagories = [self.catagoriesDAO loadCatagories];

    return (catagories);
}

- (Catagory *) fetchCatagory: (NSString *) catagoryID;
{
    Catagory *catagory = [self.catagoriesDAO loadCatagory: catagoryID];

    if (catagory)
    {
        return (catagory);
    }

    return nil;
}

- (NSArray *) fetchAllRecords
{
    NSArray *records = [self.recordsDAO loadRecords];

    if (records && records.count)
    {
        return (records);
    }
    
    return nil;
}

- (NSArray *) fetchRecordsForCatagoryID: (NSString *) catagoryID
                         inTaxYear: (NSInteger) taxYear
{
    NSArray *recordsFromAllTime = [self.recordsDAO loadRecordsforCatagory: catagoryID];

    NSMutableArray *recordsInTaxYear = [NSMutableArray new];
    
    for (Record *record in recordsFromAllTime)
    {
        Receipt *receipt = [self fetchReceiptForReceiptID:record.receiptID];
        
        if (receipt)
        {
            if (receipt.taxYear == taxYear)
            {
                [recordsInTaxYear addObject:record];
            }
        }
    }
    
    return (recordsInTaxYear);
}

- (NSArray *) fetchRecordsForReceiptID: (NSString *) receiptID
{
    NSArray *records = [self.recordsDAO loadRecordsforReceipt: receiptID];

    if (records)
    {
        return (records);
    }
    return nil;
}

- (Record *) fetchRecordForID: (NSString *) recordID
{
    Record *record = [self.recordsDAO loadRecord: recordID];

    if (record)
    {
        return(record);
    }

    return nil;
}

- (NSArray *) fetchReceiptsInTaxYear: (NSInteger) taxYear
{
    NSArray *receipts = [self.receiptsDAO loadReceiptsFromTaxYear:taxYear];

    if (receipts && receipts.count)
    {
        return(receipts);
    }

    return nil;
}

- (NSArray *) fetchNewestReceiptInfo: (NSInteger) nThNewest
                              inYear: (NSInteger) year
{
    NSMutableArray *receiptInfos = [NSMutableArray new];

    NSArray *receipts = [self.receiptsDAO loadNewestNthReceipts:nThNewest inTaxYear:year];

    for (Receipt *receipt in receipts)
    {
        NSMutableDictionary *receiptInfo = [NSMutableDictionary new];

        [receiptInfo setObject: receipt.localID forKeyedSubscript: kReceiptIDKey];
        [receiptInfo setObject: receipt.dateCreated forKeyedSubscript: kUploadTimeKey];

        float totalAmountForReceipt = 0.0f;

        // get all catagories for this receipt
        NSArray *records = [self.recordsDAO loadRecordsforReceipt: receipt.localID];
        
        receiptInfo[kNumberOfRecordsKey] = [NSNumber numberWithInteger:records.count];

        for (Record *record in records)
        {
            totalAmountForReceipt = totalAmountForReceipt + [record calculateTotal];
        }

        receiptInfo[kTotalAmountKey] = @(totalAmountForReceipt);

        [receiptInfos addObject: receiptInfo];
    }

    return(receiptInfos);
}

- (NSArray *) fetchReceiptInfoFromDate: (NSDate *) fromDate
                                toDate: (NSDate *) toDate
                             inTaxYear: (NSInteger) taxYear
{
    NSMutableArray *receiptInfos = [NSMutableArray new];
    
    NSArray *allReceipts = [self.receiptsDAO loadReceiptsFromTaxYear:taxYear];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"((dateCreated >= %@) AND (dateCreated < %@)) || (dateCreated = nil)", fromDate, toDate];
    NSArray *receiptsInGivenTimeFrame = [allReceipts filteredArrayUsingPredicate: predicate];
    
    NSArray *sortedReceipts = [receiptsInGivenTimeFrame sortedArrayUsingComparator: ^NSComparisonResult (Receipt *a, Receipt *b) {
        NSDate *first = a.dateCreated;
        NSDate *second = b.dateCreated;
        return [second compare: first];
    }];
    
    for (Receipt *receipt in sortedReceipts)
    {
        NSMutableDictionary *receiptInfo = [NSMutableDictionary new];
        
        [receiptInfo setObject: receipt.localID forKeyedSubscript: kReceiptIDKey];
        [receiptInfo setObject: receipt.dateCreated forKeyedSubscript: kUploadTimeKey];
        
        float totalAmountForReceipt = 0.0f;
        
        // get all catagories for this receipt
        NSArray *records = [self.recordsDAO loadRecordsforReceipt: receipt.localID];
        
        receiptInfo[kNumberOfRecordsKey] = [NSNumber numberWithInteger:records.count];
        
        for (Record *record in records)
        {
            totalAmountForReceipt = totalAmountForReceipt + [record calculateTotal];
        }
        
        receiptInfo[kTotalAmountKey] = @(totalAmountForReceipt);
        
        [receiptInfos addObject: receiptInfo];
    }
    
    return (receiptInfos);
}

- (Receipt *) fetchReceiptForReceiptID: (NSString *) receiptID
{
    Receipt *receipt = [self.receiptsDAO loadReceipt: receiptID];

    if (receipt)
    {
        return(receipt);
    }

    return nil;
}

- (NSArray *) fetchCatagoryInfoFromDate: (NSDate *) fromDate
                                 toDate: (NSDate *) toDate
                              inTaxYear: (NSInteger) taxYear
                            forCatagory: (NSString *) catagoryID
                            forUnitType: (NSInteger) unitType
{
    NSMutableArray *catagoryInfos = [NSMutableArray new];

    NSArray *allReceiptsFromTheDateRange = [self.receiptsDAO loadReceiptsFrom: fromDate toDate: toDate inTaxYear:taxYear];

    // filter out the receipts that contains Records of catagory: catagoryID
    for (Receipt *receipt in allReceiptsFromTheDateRange)
    {
        NSArray *recordsWithGivenCatagoryID = [receipt fetchRecordsOfCatagory: catagoryID usingRecordsDAO: self.recordsDAO];

        if (recordsWithGivenCatagoryID && recordsWithGivenCatagoryID.count)
        {
            NSInteger totalQty = 0;
            float totalAmount = 0.0f;

            // calculate totalQty and totalAmount
            for (Record *record in recordsWithGivenCatagoryID)
            {
                if (record.unitType != unitType)
                {
                    continue;
                }
                
                totalQty = totalQty + record.quantity;
                totalAmount = totalAmount + [record calculateTotal];
            }

            NSMutableDictionary *catagoryInfo = [NSMutableDictionary new];

            catagoryInfo[kReceiptIDKey] = receipt.localID;
            catagoryInfo[kReceiptTimeKey] = receipt.dateCreated;
            catagoryInfo[kTotalQtyKey] = @(totalQty);
            catagoryInfo[kTotalAmountKey] = @(totalAmount);

            [catagoryInfos addObject: catagoryInfo];
        }
    }

    return(catagoryInfos);
}

- (NSArray *) fetchLatestNthCatagoryInfosforCatagory: (NSString *) catagoryID
                                         andUnitType: (NSInteger) unitType
                                              forNth: (NSInteger) nTh
                                           inTaxYear: (NSInteger) taxYear
{
    NSMutableArray *catagoryInfos = [NSMutableArray new];

    NSArray *allReceipts = [self.receiptsDAO loadReceiptsFromTaxYear:taxYear];

    NSArray *sortedAllReceipts = [allReceipts sortedArrayUsingComparator: ^NSComparisonResult (Receipt *a, Receipt *b) {
        NSDate *first = a.dateCreated;
        NSDate *second = b.dateCreated;
        return [second compare: first];
    }];

    int counter = 0;

    // filter out the receipts that contains Records of catagory: catagoryID
    for (Receipt *receipt in sortedAllReceipts)
    {
        if (counter >= nTh && nTh != -1)
        {
            break;
        }

        NSArray *recordsWithGivenCatagoryID = [receipt fetchRecordsOfCatagory: catagoryID ofUnitType:unitType usingRecordsDAO:self.recordsDAO];

        if (recordsWithGivenCatagoryID && recordsWithGivenCatagoryID.count)
        {
            NSInteger totalQty = 0;
            float totalAmount = 0.0f;

            // calculate totalQty and totalAmount
            for (Record *record in recordsWithGivenCatagoryID)
            {
                if (record.unitType != unitType)
                {
                    continue;
                }
                
                totalQty = totalQty + record.quantity;
                totalAmount = totalAmount + [record calculateTotal];
            }

            NSMutableDictionary *catagoryInfo = [NSMutableDictionary new];

            catagoryInfo[kReceiptIDKey] = receipt.localID;
            catagoryInfo[kReceiptTimeKey] = receipt.dateCreated;
            catagoryInfo[kTotalQtyKey] = @(totalQty);
            catagoryInfo[kTotalAmountKey] = @(totalAmount);

            [catagoryInfos addObject: catagoryInfo];

            counter++;
        }
    }

    return(catagoryInfos);
}

- (NSArray *) fetchTaxYears
{
    NSArray *unsortedTaxYears = [self.taxYearsDAO loadAllTaxYears];
    
    NSArray *sortedYears = [unsortedTaxYears sortedArrayUsingComparator: ^NSComparisonResult (NSNumber *a, NSNumber *b) {
        return [b compare: a];
    }];
    
    return sortedYears;
}

@end