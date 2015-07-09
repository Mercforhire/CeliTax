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

typedef void (^FetchCatagoriesSuccessBlock)(NSArray *catagories);
typedef void (^FetchCatagoriesFailureBlock)(NSString *reason);

typedef void (^FetchCatagorySuccessBlock)(Catagory *catagory);
typedef void (^FetchCatagoryFailureBlock)(NSString *reason);

typedef void (^FetchRecordsSuccessBlock)(NSArray *records);
typedef void (^FetchRecordsFailureBlock)(NSString *reason);

typedef void (^FetchRecordSuccessBlock)(Record *record);
typedef void (^FetchRecordFailureBlock)(NSString *reason);

typedef void (^FetchReceiptsSuccessBlock)(NSArray *receipts);
typedef void (^FetchReceiptsFailureBlock)(NSString *reason);

typedef void (^FetchReceiptInfoSuccessBlock)(NSArray *receiptInfos);
typedef void (^FetchReceiptInfoFailureBlock)(NSString *reason);

typedef void (^FetchReceiptSuccessBlock)(Receipt *receipt);
typedef void (^FetchReceiptFailureBlock)(NSString *reason);

typedef void (^FetchReceiptsYearsRangeSuccessBlock)(NSArray *yearsRange);
typedef void (^FetchReceiptsYearsRangeFailureBlock)(NSString *reason);

typedef void (^FetchCatagoryInfoSuccessBlock)(NSArray *catagoryInfos);
typedef void (^FetchCatagoryInfoFailureBlock)(NSString *reason);

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;
@property (nonatomic, strong) RecordsDAO *recordsDAO;
@property (nonatomic, strong) ReceiptsDAO *receiptsDAO;
@property (nonatomic, strong) TaxYearsDAO *taxYearsDAO;

- (void) loadDemoData;

- (void) fetchCatagories: (FetchCatagoriesSuccessBlock) success
                 failure: (FetchCatagoriesFailureBlock) failure;

- (void) fetchCatagory: (NSString *) catagoryID
               success: (FetchCatagorySuccessBlock) success
               failure: (FetchCatagoryFailureBlock) failure;

- (void) fetchAllRecordsSuccess: (FetchRecordsSuccessBlock) success
                        failure: (FetchRecordsFailureBlock) failure;

- (void) fetchRecordsForCatagoryID: (NSString *) catagoryID
                         inTaxYear: (NSInteger) taxYear
                           success: (FetchRecordsSuccessBlock) success
                           failure: (FetchRecordsFailureBlock) failure;

- (void) fetchRecordsForReceiptID: (NSString *) receiptID
                          success: (FetchRecordsSuccessBlock) success
                          failure: (FetchRecordsFailureBlock) failure;

- (void) fetchRecordForID: (NSString *) recordID
                  success: (FetchRecordSuccessBlock) success
                  failure: (FetchRecordFailureBlock) failure;

- (void) fetchReceiptsInTaxYear: (NSInteger) taxYear
                        success: (FetchReceiptsSuccessBlock) success
                        failure: (FetchReceiptsFailureBlock) failure;

#define kReceiptIDKey       @"ReceiptID"
#define kUploadTimeKey      @"UploadTime"
#define kTotalAmountKey     @"TotalAmount"
#define kReceiptTimeKey     @"ReceiptTime"
#define kTotalQtyKey        @"TotalQty"
#define kNumberOfRecordsKey @"NumberOfRecords"

- (void) fetchNewestReceiptInfo: (NSInteger) nThNewest
                         inYear: (NSInteger) year
                        success: (FetchReceiptInfoSuccessBlock) success
                        failure: (FetchReceiptInfoFailureBlock) failure;

- (void) fetchReceiptInfoFromDate: (NSDate *) fromDate
                           toDate: (NSDate *) toDate
                        inTaxYear: (NSInteger) taxYear
                          success: (FetchReceiptInfoSuccessBlock) success
                          failure: (FetchReceiptInfoFailureBlock) failure;

- (void) fetchReceiptForReceiptID: (NSString *) receiptID
                          success: (FetchReceiptSuccessBlock) success
                          failure: (FetchReceiptFailureBlock) failure;

//- (void) fetchReceiptsYearsRange: (FetchReceiptsYearsRangeSuccessBlock) success
//                         failure: (FetchReceiptsYearsRangeFailureBlock) failure;




- (void) fetchCatagoryInfoFromDate: (NSDate *) fromDate
                            toDate: (NSDate *) toDate
                         inTaxYear: (NSInteger) taxYear
                       forCatagory: (NSString *) catagoryID
                           success: (FetchCatagoryInfoSuccessBlock) success
                           failure: (FetchCatagoryInfoFailureBlock) failure;

- (void) fetchLatestNthCatagoryInfosforCatagory: (NSString *) catagoryID
                                         forNth: (NSInteger) nTh
                                      inTaxYear: (NSInteger) taxYear
                                        success: (FetchCatagoryInfoSuccessBlock) success
                                        failure: (FetchCatagoryInfoFailureBlock) failure;


- (NSArray *) fetchTaxYears;

@end