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

        [self.catagoriesDAO addCatagoryForName: @"Bread" andColor: [UIColor orangeColor] andNationalAverageCost: 0];

        [self.catagoriesDAO addCatagoryForName: @"Meat" andColor: [UIColor redColor] andNationalAverageCost: 7.5f];

        [self.catagoriesDAO addCatagoryForName: @"Flour" andColor: [UIColor lightGrayColor] andNationalAverageCost: 5.0f];
    }

    if (![self.receiptsDAO loadReceipts].count && ![self.recordsDAO loadRecords].count)
    {
        UIImage *testImage1 = [UIImage imageNamed: @"ReceiptPic-1.jpg"];
        UIImage *testImage2 = [UIImage imageNamed: @"ReceiptPic-2.jpg"];

        [Utils saveImage: testImage1 withFilename: @"ReceiptPic-1" forUser: @"testKey"];
        [Utils saveImage: testImage2 withFilename: @"ReceiptPic-2" forUser: @"testKey"];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];

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

            [components setDay: 5];
            [components setMonth: month];
            [components setYear: year];
            [components setHour: [Utils randomNumberBetween: 0 maxNumber: 23]];
            [components setMinute: [Utils randomNumberBetween: 0 maxNumber: 59]];

            NSDate *date1 = [calendar dateFromComponents: components];

            [components setDay: 25];
            [components setHour: [Utils randomNumberBetween: 0 maxNumber: 23]];
            [components setMinute: [Utils randomNumberBetween: 0 maxNumber: 59]];
            NSDate *date2 = [calendar dateFromComponents: components];

            Receipt *newReceipt = [Receipt new];

            newReceipt.identifer = [Utils generateUniqueID];
            newReceipt.fileNames = [NSMutableArray arrayWithObjects: @"ReceiptPic-1", @"ReceiptPic-2", nil];
            newReceipt.dateCreated = date1;

            [self.receiptsDAO addReceipt: newReceipt];

            Receipt *newReceipt2 = [Receipt new];

            newReceipt2.identifer = [Utils generateUniqueID];
            newReceipt2.fileNames = [NSMutableArray arrayWithObjects: @"ReceiptPic-1", @"ReceiptPic-2", nil];
            newReceipt2.dateCreated = date2;

            [self.receiptsDAO addReceipt: newReceipt2];

            // add 3 records for each receipt
            [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] firstObject]
                                       andReceipt: newReceipt
                                      forQuantity: 2
                                        forAmount: 2.5f];
            
            [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] firstObject]
                                       andReceipt: newReceipt
                                      forQuantity: 1
                                        forAmount: 5.0f];

            [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] objectAtIndex: 1]
                                       andReceipt: newReceipt
                                      forQuantity: 1
                                        forAmount: 5.0f];

            [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] objectAtIndex: 2]
                                       andReceipt: newReceipt
                                      forQuantity: 3
                                        forAmount: 6.0f];

            [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] firstObject]
                                       andReceipt: newReceipt2
                                      forQuantity: 2
                                        forAmount: 2.5f];
            
            [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] firstObject]
                                       andReceipt: newReceipt2
                                      forQuantity: 1
                                        forAmount: 5.0f];

            [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] objectAtIndex: 1]
                                       andReceipt: newReceipt2
                                      forQuantity: 1
                                        forAmount: 5.0f];

            [self.recordsDAO addRecordForCatagory: [[self.catagoriesDAO loadCatagories] objectAtIndex: 2]
                                       andReceipt: newReceipt2
                                      forQuantity: 3
                                        forAmount: 6.0f];
        }
    }
}

- (NSOperation *) fetchCatagoriesSuccess: (FetchCatagoriesSuccessBlock) success failure: (FetchCatagoriesFailureBlock) failure
{
    NSArray *catagories = [self.catagoriesDAO loadCatagories];

    if (catagories && catagories.count)
    {
        success(catagories);
    }
    else
    {
        failure(@"catagories not found");
    }

    return nil;
}

- (NSOperation *) fetchCatagory: (NSString *) catagoryID
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

    return nil;
}

- (NSOperation *) fetchAllRecordsSuccess: (FetchRecordsSuccessBlock) success failure: (FetchRecordsFailureBlock) failure
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

    return nil;
}

- (NSOperation *) fetchRecordsForCatagoryID: (NSString *) catagoryID success: (FetchRecordsSuccessBlock) success failure: (FetchRecordsFailureBlock) failure
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

    return nil;
}

- (NSOperation *) fetchRecordsForReceiptID: (NSString *) receiptID success: (FetchRecordsSuccessBlock) success failure: (FetchRecordsFailureBlock) failure
{
    NSArray *records = [self.recordsDAO loadRecordsforReceipt: receiptID];

    if (records && records.count)
    {
        success(records);
    }
    else
    {
        failure(@"records not found");
    }

    return nil;
}

- (NSOperation *) fetchRecordForID: (NSString *) recordID
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

    return nil;
}

- (NSOperation *) fetchReceiptsSuccess: (FetchReceiptsSuccessBlock) success failure: (FetchReceiptsFailureBlock) failure
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

    return nil;
}

- (NSOperation *) fetchNewestReceiptInfo: (NSInteger) nThNewest
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

            totalAmountForReceipt = totalAmountForReceipt + record.quantity * record.amount;
        }

        [receiptInfo setObject: receiptColors forKey: kColorsKey];
        [receiptInfo setObject: [NSNumber numberWithFloat: totalAmountForReceipt] forKey: kTotalAmountKey];

        [receiptInfos addObject: receiptInfo];
    }

    success(receiptInfos);

    return nil;
}

- (NSOperation *) fetchReceiptForReceiptID: (NSString *) receiptID success: (FetchReceiptSuccessBlock) success failure: (FetchReceiptFailureBlock) failure
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

    return nil;
}

- (NSOperation *) fetchReceiptsYearsRange: (FetchReceiptsYearsRangeSuccessBlock) success
                                  failure: (FetchReceiptsYearsRangeFailureBlock) failure
{
    NSArray *receipts = [self.receiptsDAO loadReceipts];

    if (!receipts)
    {
        failure (@"receipts is nil");
    }

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

    success (sortedYears);

    return nil;
}

@end