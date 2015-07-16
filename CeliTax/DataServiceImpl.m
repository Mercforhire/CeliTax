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

- (void) loadDemoData
{
    if (![self.taxYearsDAO loadAllTaxYears].count)
    {
        [self.taxYearsDAO addTaxYear:2013];
        [self.taxYearsDAO addTaxYear:2014];
        [self.taxYearsDAO addTaxYear:2015];
    }
    
    if (![self.catagoriesDAO loadCatagories].count)
    {
        // add some demo data
        [self.catagoriesDAO addCatagoryForName: @"Rice" andColor: [UIColor yellowColor] andNationalAverageCost: 2.5f];

        [self.catagoriesDAO addCatagoryForName: @"Bread" andColor: [UIColor orangeColor] andNationalAverageCost: 5];

        [self.catagoriesDAO addCatagoryForName: @"Meat" andColor: [UIColor redColor] andNationalAverageCost: 7.5f];

        [self.catagoriesDAO addCatagoryForName: @"Flour" andColor: [UIColor lightGrayColor] andNationalAverageCost: 3.0f];

        [self.catagoriesDAO addCatagoryForName: @"Cake" andColor: [UIColor purpleColor] andNationalAverageCost: 8.0f];
    }

    if ( ![self.receiptsDAO loadAllReceipts].count && ![self.recordsDAO loadRecords].count )
    {
        UIImage *testImage1 = [UIImage imageNamed: @"ReceiptPic-1.jpg"];
        UIImage *testImage2 = [UIImage imageNamed: @"ReceiptPic-2.jpg"];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];

        NSInteger numberOfCatagories = [self.catagoriesDAO loadCatagories].count;

        NSDate *currentTime = [[NSDate alloc] init];

        // add ~300 random receipts
        for (int receiptNumber = 0; receiptNumber < 300; receiptNumber++)
        {
            NSString *fileName1 = [NSString stringWithFormat: @"Receipt-%@-%d", [Utils generateUniqueID], 1];
            NSString *fileName2 = [NSString stringWithFormat: @"Receipt-%@-%d", [Utils generateUniqueID], 2];
            
            [Utils saveImage: testImage1 withFilename: fileName1 forUser: @"testKey"];
            [Utils saveImage: testImage2 withFilename: fileName2 forUser: @"testKey"];
            
            [components setDay: [Utils randomNumberBetween: 1 maxNumber: 28]];
            [components setMonth: [Utils randomNumberBetween: 1 maxNumber: 12]];
            [components setYear: [Utils randomNumberBetween: 2013 maxNumber: 2015]];
            [components setHour: [Utils randomNumberBetween: 0 maxNumber: 23]];
            [components setMinute: [Utils randomNumberBetween: 0 maxNumber: 59]];
            
            NSDate *date = [calendar dateFromComponents: components];
            
            if ([date laterDate: currentTime] == date)
            {
                continue;
            }
            
            Receipt *newReceipt = [Receipt new];
            
            newReceipt.localID = [Utils generateUniqueID];
            newReceipt.fileNames = [NSMutableArray arrayWithObjects: fileName1, fileName2, nil];
            newReceipt.dateCreated = date;
            newReceipt.taxYear = [Utils randomNumberBetween: 2013 maxNumber: 2015];
            newReceipt.dataAction = DataActionInsert;
            
            [self.receiptsDAO addReceipt: newReceipt];
            
            // add 1-15 items for each receipt
            int numberOfItems = [Utils randomNumberBetween: 1 maxNumber: 10];
            
            for (int itemNumber = 0; itemNumber < numberOfItems; itemNumber++)
            {
                [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] objectAtIndex: [Utils randomNumberBetween: 0 maxNumber: (int)numberOfCatagories - 1]]
                                           andReceipt: newReceipt
                                          forQuantity: [Utils randomNumberBetween: 1 maxNumber: 10]
                                            forAmount: [Utils randomNumberBetween: 10 maxNumber: 100] / 10.0f];
            }
        }
    }
}

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
        
        [receiptInfo setObject:[NSNumber numberWithInteger:records.count] forKey:kNumberOfRecordsKey];

        for (Record *record in records)
        {
            totalAmountForReceipt = totalAmountForReceipt + [record calculateTotal];
        }

        [receiptInfo setObject: [NSNumber numberWithFloat: totalAmountForReceipt] forKey: kTotalAmountKey];

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
        
        [receiptInfo setObject:[NSNumber numberWithInteger:records.count] forKey:kNumberOfRecordsKey];
        
        for (Record *record in records)
        {
            totalAmountForReceipt = totalAmountForReceipt + [record calculateTotal];
        }
        
        [receiptInfo setObject: [NSNumber numberWithFloat: totalAmountForReceipt] forKey: kTotalAmountKey];
        
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
                totalQty = totalQty + record.quantity;
                totalAmount = totalAmount + [record calculateTotal];
            }

            NSMutableDictionary *catagoryInfo = [NSMutableDictionary new];

            [catagoryInfo setObject: receipt.localID forKey: kReceiptIDKey];
            [catagoryInfo setObject: receipt.dateCreated forKey: kReceiptTimeKey];
            [catagoryInfo setObject: [NSNumber numberWithInteger: totalQty] forKey: kTotalQtyKey];
            [catagoryInfo setObject: [NSNumber numberWithFloat: totalAmount] forKey: kTotalAmountKey];

            [catagoryInfos addObject: catagoryInfo];
        }
    }

    return(catagoryInfos);
}

- (NSArray *) fetchLatestNthCatagoryInfosforCatagory: (NSString *) catagoryID
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

        NSArray *recordsWithGivenCatagoryID = [receipt fetchRecordsOfCatagory: catagoryID usingRecordsDAO: self.recordsDAO];

        if (recordsWithGivenCatagoryID && recordsWithGivenCatagoryID.count)
        {
            NSInteger totalQty = 0;
            float totalAmount = 0.0f;

            // calculate totalQty and totalAmount
            for (Record *record in recordsWithGivenCatagoryID)
            {
                totalQty = totalQty + record.quantity;
                totalAmount = totalAmount + [record calculateTotal];
            }

            NSMutableDictionary *catagoryInfo = [NSMutableDictionary new];

            [catagoryInfo setObject: receipt.localID forKey: kReceiptIDKey];
            [catagoryInfo setObject: receipt.dateCreated forKey: kReceiptTimeKey];
            [catagoryInfo setObject: [NSNumber numberWithInteger: totalQty] forKey: kTotalQtyKey];
            [catagoryInfo setObject: [NSNumber numberWithFloat: totalAmount] forKey: kTotalAmountKey];

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