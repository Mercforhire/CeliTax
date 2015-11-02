//
// DataService.h
// CeliTax
//
// Created by Leon Chen on 2015-05-02.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatagoriesDAO, Receipt, RecordsDAO, ReceiptsDAO, TaxYearsDAO, Record, ItemCategory;

@protocol DataService <NSObject>

@property (nonatomic, weak) CatagoriesDAO *catagoriesDAO;
@property (nonatomic, weak) RecordsDAO *recordsDAO;
@property (nonatomic, weak) ReceiptsDAO *receiptsDAO;
@property (nonatomic, weak) TaxYearsDAO *taxYearsDAO;

- (NSArray *) fetchCatagories;

- (ItemCategory *) fetchCatagory: (NSString *) catagoryID;

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
                            forCatagory: (NSString *) catagoryID
                            forUnitType: (NSInteger) unitType;

- (NSArray *) fetchLatestNthCatagoryInfosforCatagory: (NSString *) catagoryID
                                         andUnitType: (NSInteger) unitType
                                              forNth: (NSInteger) nTh
                                           inTaxYear: (NSInteger) taxYear;


- (NSArray *) fetchTaxYears;

@end