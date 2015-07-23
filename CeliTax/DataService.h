//
// DataService.h
// CeliTax
//
// Created by Leon Chen on 2015-05-02.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatagoriesDAO, Receipt, RecordsDAO, ReceiptsDAO, TaxYearsDAO, Record, Catagory;

@protocol DataService <NSObject>

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;
@property (nonatomic, strong) RecordsDAO *recordsDAO;
@property (nonatomic, strong) ReceiptsDAO *receiptsDAO;
@property (nonatomic, strong) TaxYearsDAO *taxYearsDAO;

- (NSArray *) fetchCatagories;

- (Catagory *) fetchCatagory: (NSString *) catagoryID;

- (NSArray *) fetchAllRecords;

- (NSArray *) fetchRecordsForCatagoryID: (NSString *) catagoryID
                              inTaxYear: (NSInteger) taxYear;

- (NSArray *) fetchRecordsForReceiptID: (NSString *) receiptID;

- (Record *) fetchRecordForID: (NSString *) recordID;

- (NSArray *) fetchReceiptsInTaxYear: (NSInteger) taxYear;

#define kReceiptIDKey       @"ReceiptID"
#define kUploadTimeKey      @"UploadTime"
#define kTotalAmountKey     @"TotalAmount"
#define kReceiptTimeKey     @"ReceiptTime"
#define kTotalQtyKey        @"TotalQty"
#define kNumberOfRecordsKey @"NumberOfRecords"

- (NSArray *) fetchNewestReceiptInfo: (NSInteger) nThNewest
                              inYear: (NSInteger) year;

- (NSArray *) fetchReceiptInfoFromDate: (NSDate *) fromDate
                                toDate: (NSDate *) toDate
                             inTaxYear: (NSInteger) taxYear;

- (Receipt *) fetchReceiptForReceiptID: (NSString *) receiptID;



- (NSArray *) fetchCatagoryInfoFromDate: (NSDate *) fromDate
                                 toDate: (NSDate *) toDate
                              inTaxYear: (NSInteger) taxYear
                            forCatagory: (NSString *) catagoryID;

- (NSArray *) fetchLatestNthCatagoryInfosforCatagory: (NSString *) catagoryID
                                              forNth: (NSInteger) nTh
                                           inTaxYear: (NSInteger) taxYear;


- (NSArray *) fetchTaxYears;

@end