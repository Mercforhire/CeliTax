//
// DataService.h
// CeliTax
//
// Created by Leon Chen on 2015-05-02.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatagoriesDAO, Receipt, RecordsDAO, ReceiptsDAO, Record, Catagory;

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

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;
@property (nonatomic, strong) RecordsDAO *recordsDAO;
@property (nonatomic, strong) ReceiptsDAO *receiptsDAO;

- (void) loadDemoData;

- (NSOperation *) fetchCatagoriesSuccess: (FetchCatagoriesSuccessBlock) success
                                 failure: (FetchCatagoriesFailureBlock) failure;

- (NSOperation *) fetchCatagory: (NSString *) catagoryID
                        Success: (FetchCatagorySuccessBlock) success
                        failure: (FetchCatagoryFailureBlock) failure;

- (NSOperation *) fetchAllRecordsSuccess: (FetchRecordsSuccessBlock) success
                                 failure: (FetchRecordsFailureBlock) failure;

- (NSOperation *) fetchRecordsForCatagoryID: (NSString *) catagoryID
                                    success: (FetchRecordsSuccessBlock) success
                                    failure: (FetchRecordsFailureBlock) failure;

- (NSOperation *) fetchRecordsForReceiptID: (NSString *) receiptID
                                   success: (FetchRecordsSuccessBlock) success
                                   failure: (FetchRecordsFailureBlock) failure;

- (NSOperation *) fetchRecordForID: (NSString *) recordID
                           success: (FetchRecordSuccessBlock) success
                           failure: (FetchRecordFailureBlock) failure;

- (NSOperation *) fetchReceiptsSuccess: (FetchReceiptsSuccessBlock) success
                               failure: (FetchReceiptsFailureBlock) failure;

#define kReceiptIDKey       @"ReceiptID"
#define kColorsKey          @"Colors"
#define kUploadTimeKey      @"UploadTime"
#define kTotalAmountKey     @"TotalAmountKey"

- (NSOperation *) fetchNewestReceiptInfo: (NSInteger) nThNewest
                                  inYear: (NSInteger) year
                                 success: (FetchReceiptInfoSuccessBlock) success
                                 failure: (FetchReceiptInfoFailureBlock) failure;

- (NSOperation *) fetchReceiptForReceiptID: (NSString *) receiptID
                                   success: (FetchReceiptSuccessBlock) success
                                   failure: (FetchReceiptFailureBlock) failure;

- (NSOperation *) fetchReceiptsYearsRange: (FetchReceiptsYearsRangeSuccessBlock) success
                                  failure: (FetchReceiptsYearsRangeFailureBlock) failure;

@end