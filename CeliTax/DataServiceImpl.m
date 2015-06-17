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
#import "Receipt.h"
#import "Utils.h"

@interface DataServiceImpl ()

@end

@implementation DataServiceImpl

- (void) loadDemoData
{
    if (![self.catagoriesDAO loadCatagories].count)
    {
        // add some demo data
        [self.catagoriesDAO addCatagoryForName: @"Rice" andColor: [UIColor yellowColor] andNationalAverageCost: 2.5f];

        [self.catagoriesDAO addCatagoryForName: @"Bread" andColor: [UIColor orangeColor] andNationalAverageCost: 5];

        [self.catagoriesDAO addCatagoryForName: @"Meat" andColor: [UIColor redColor] andNationalAverageCost: 7.5f];

        [self.catagoriesDAO addCatagoryForName: @"Flour" andColor: [UIColor lightGrayColor] andNationalAverageCost: 3.0f];

        [self.catagoriesDAO addCatagoryForName: @"Cake" andColor: [UIColor purpleColor] andNationalAverageCost: 8.0f];
    }

    if (![self.receiptsDAO loadReceipts].count && ![self.recordsDAO loadRecords].count)
    {
        UIImage *testImage1 = [UIImage imageNamed: @"ReceiptPic-1.jpg"];
        UIImage *testImage2 = [UIImage imageNamed: @"ReceiptPic-2.jpg"];

        [Utils saveImage: testImage1 withFilename: @"ReceiptPic-1" forUser: @"testKey"];
        [Utils saveImage: testImage2 withFilename: @"ReceiptPic-2" forUser: @"testKey"];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];

        NSInteger numberOfCatagories = [self.catagoriesDAO loadCatagories].count;

        NSDate *currentTime = [[NSDate alloc] init];

        // from Jan 2014 to Dec 2015, generate 2 receipts for each month
        for (int monthCounter = 1; monthCounter <= 24; monthCounter++)
        {
            int year = 2014;
            int month = monthCounter;

            if (monthCounter > 12)
            {
                year = 2015;
            }

            if (month > 12)
            {
                month = month - 12;
            }

            // add 15 random receipts per month
            for (int receiptNumber = 0; receiptNumber < 15; receiptNumber++)
            {
                [components setDay: [Utils randomNumberBetween: 1 maxNumber: 28]];
                [components setMonth: month];
                [components setYear: year];
                [components setHour: [Utils randomNumberBetween: 0 maxNumber: 23]];
                [components setMinute: [Utils randomNumberBetween: 0 maxNumber: 59]];

                NSDate *date = [calendar dateFromComponents: components];

                if ([date laterDate: currentTime] == date)
                {
                    break;
                }

                Receipt *newReceipt = [Receipt new];

                newReceipt.identifer = [Utils generateUniqueID];
                newReceipt.fileNames = [NSMutableArray arrayWithObjects: @"ReceiptPic-1", @"ReceiptPic-2", nil];
                newReceipt.dateCreated = date;

                [self.receiptsDAO addReceipt: newReceipt];

                // add 1-10 items for each receipt
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
}

- (void) fetchCatagoriesSuccess: (FetchCatagoriesSuccessBlock) success failure: (FetchCatagoriesFailureBlock) failure
{
    NSArray *catagories = [self.catagoriesDAO loadCatagories];

    success(catagories);

    return;
}

- (void) fetchCatagory: (NSString *) catagoryID
               Success: (FetchCatagorySuccessBlock) success
               failure: (FetchCatagoryFailureBlock) failure
{
    Catagory *catagory = [self.catagoriesDAO loadCatagory: catagoryID];

    if (catagory)
    {
        success(catagory);
    }
    else
    {
        failure(@"catagory not found");
    }

    return;
}

- (void) fetchAllRecordsSuccess: (FetchRecordsSuccessBlock) success failure: (FetchRecordsFailureBlock) failure
{
    NSArray *records = [self.recordsDAO loadRecords];

    if (records && records.count)
    {
        success(records);
    }
    else
    {
        failure(@"records not found");
    }

    return;
}

- (void) fetchRecordsForCatagoryID: (NSString *) catagoryID success: (FetchRecordsSuccessBlock) success failure: (FetchRecordsFailureBlock) failure
{
    NSArray *records = [self.recordsDAO loadRecordsforCatagory: catagoryID];

    if (records && records.count)
    {
        success(records);
    }
    else
    {
        failure(@"records not found");
    }

    return;
}

- (void) fetchRecordsForReceiptID: (NSString *) receiptID success: (FetchRecordsSuccessBlock) success failure: (FetchRecordsFailureBlock) failure
{
    NSArray *records = [self.recordsDAO loadRecordsforReceipt: receiptID];

    if (records)
    {
        success(records);
    }
    else
    {
        failure(@"records not found");
    }

    return;
}

- (void) fetchRecordForID: (NSString *) recordID
                  success: (FetchRecordSuccessBlock) success
                  failure: (FetchRecordFailureBlock) failure
{
    Record *record = [self.recordsDAO loadRecord: recordID];

    if (record)
    {
        success(record);
    }
    else
    {
        failure(@"record not found");
    }

    return;
}

- (void) fetchReceiptsSuccess: (FetchReceiptsSuccessBlock) success failure: (FetchReceiptsFailureBlock) failure
{
    NSArray *receipts = [self.receiptsDAO loadReceipts];

    if (receipts && receipts.count)
    {
        success(receipts);
    }
    else
    {
        failure(@"receipts not found");
    }

    return;
}

- (void) fetchNewestReceiptInfo: (NSInteger) nThNewest
                         inYear: (NSInteger) year
                        success: (FetchReceiptInfoSuccessBlock) success
                        failure: (FetchReceiptInfoFailureBlock) failure
{
    NSMutableArray *receiptInfos = [NSMutableArray new];

    NSArray *receipts = [self.receiptsDAO loadNewestNthReceipts: nThNewest inYear: year];

    for (Receipt *receipt in receipts)
    {
        NSMutableDictionary *receiptInfo = [NSMutableDictionary new];

        [receiptInfo setObject: receipt.identifer forKeyedSubscript: kReceiptIDKey];
        [receiptInfo setObject: receipt.dateCreated forKeyedSubscript: kUploadTimeKey];

        NSMutableArray *receiptColors = [NSMutableArray new];

        float totalAmountForReceipt = 0.0f;

        // get all catagories for this receipt
        NSArray *records = [self.recordsDAO loadRecordsforReceipt: receipt.identifer];

        for (Record *record in records)
        {
            Catagory *catagory = [self.catagoriesDAO loadCatagory: record.catagoryID];

            [receiptColors addObject: catagory.color];

            totalAmountForReceipt = totalAmountForReceipt + [record calculateTotal];
        }

        [receiptInfo setObject: receiptColors forKey: kColorsKey];
        [receiptInfo setObject: [NSNumber numberWithFloat: totalAmountForReceipt] forKey: kTotalAmountKey];

        [receiptInfos addObject: receiptInfo];
    }

    success(receiptInfos);

    return;
}

- (void) fetchReceiptInfoFromDate: (NSDate *) fromDate
                           toDate: (NSDate *) toDate
                          success: (FetchReceiptInfoSuccessBlock) success
                          failure: (FetchReceiptInfoFailureBlock) failure
{
    NSMutableArray *receiptInfos = [NSMutableArray new];
    
    NSArray *allReceipts = [self.receiptsDAO loadReceipts];
    
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
        
        [receiptInfo setObject: receipt.identifer forKeyedSubscript: kReceiptIDKey];
        [receiptInfo setObject: receipt.dateCreated forKeyedSubscript: kUploadTimeKey];
        
        NSMutableArray *receiptColors = [NSMutableArray new];
        
        float totalAmountForReceipt = 0.0f;
        
        // get all catagories for this receipt
        NSArray *records = [self.recordsDAO loadRecordsforReceipt: receipt.identifer];
        
        for (Record *record in records)
        {
            Catagory *catagory = [self.catagoriesDAO loadCatagory: record.catagoryID];
            
            [receiptColors addObject: catagory.color];
            
            totalAmountForReceipt = totalAmountForReceipt + [record calculateTotal];
        }
        
        [receiptInfo setObject: receiptColors forKey: kColorsKey];
        [receiptInfo setObject: [NSNumber numberWithFloat: totalAmountForReceipt] forKey: kTotalAmountKey];
        
        [receiptInfos addObject: receiptInfo];
    }
    
    success(receiptInfos);
    
    return;
}

- (void) fetchReceiptForReceiptID: (NSString *) receiptID success: (FetchReceiptSuccessBlock) success failure: (FetchReceiptFailureBlock) failure
{
    Receipt *receipt = [self.receiptsDAO loadReceipt: receiptID];

    if (receipt)
    {
        success(receipt);
    }
    else
    {
        failure(@"Receipt not found");
    }

    return;
}

- (void) fetchReceiptsYearsRange: (FetchReceiptsYearsRangeSuccessBlock) success
                         failure: (FetchReceiptsYearsRangeFailureBlock) failure
{
    NSArray *receipts = [self.receiptsDAO loadReceipts];

    NSMutableDictionary *years = [NSMutableDictionary new];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components;

    for (Receipt *receipt in receipts)
    {
        NSDate *date = receipt.dateCreated;

        components = [calendar components: NSCalendarUnitYear fromDate: date];
        NSInteger year = [components year]; // gives you year

        [years setObject: @"GARBAGE" forKey: [NSNumber numberWithInteger: year]];
    }

    NSArray *sortedYears = [years.allKeys sortedArrayUsingComparator: ^NSComparisonResult (NSNumber *a, NSNumber *b) {
        return b.integerValue > a.integerValue;
    }];

    success(sortedYears);

    return;
}

- (void) fetchCatagoryInfoFromDate: (NSDate *) fromDate
                            toDate: (NSDate *) toDate
                       forCatagory: (NSString *) catagoryID
                           success: (FetchCatagoryInfoSuccessBlock) success
                           failure: (FetchCatagoryInfoFailureBlock) failure
{
    NSMutableArray *catagoryInfos = [NSMutableArray new];

    NSArray *allReceiptsFromTheDateRange = [self.receiptsDAO loadReceiptsFrom: fromDate toDate: toDate];

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

            [catagoryInfo setObject: receipt.identifer forKey: kReceiptIDKey];
            [catagoryInfo setObject: receipt.dateCreated forKey: kReceiptTimeKey];
            [catagoryInfo setObject: [NSNumber numberWithInteger: totalQty] forKey: kTotalQtyKey];
            [catagoryInfo setObject: [NSNumber numberWithFloat: totalAmount] forKey: kTotalAmountKey];

            [catagoryInfos addObject: catagoryInfo];
        }
    }

    success(catagoryInfos);

    return;
}

- (void) fetchLatestNthCatagoryInfosforCatagory: (NSString *) catagoryID
                                         forNth: (NSInteger) nTh
                                        success: (FetchCatagoryInfoSuccessBlock) success
                                        failure: (FetchCatagoryInfoFailureBlock) failure
{
    NSMutableArray *catagoryInfos = [NSMutableArray new];

    NSArray *allReceipts = [self.receiptsDAO loadReceipts];

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

            [catagoryInfo setObject: receipt.identifer forKey: kReceiptIDKey];
            [catagoryInfo setObject: receipt.dateCreated forKey: kReceiptTimeKey];
            [catagoryInfo setObject: [NSNumber numberWithInteger: totalQty] forKey: kTotalQtyKey];
            [catagoryInfo setObject: [NSNumber numberWithFloat: totalAmount] forKey: kTotalAmountKey];

            [catagoryInfos addObject: catagoryInfo];

            counter++;
        }
    }

    success(catagoryInfos);

    return;
}

@end