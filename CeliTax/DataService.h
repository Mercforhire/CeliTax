//
//  DataService.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatagoriesDAO,Receipt,RecordsDAO,ReceiptsDAO;

@protocol DataService <NSObject>

typedef void (^FetchCatagoriesSuccessBlock) (NSArray *catagories);
typedef void (^FetchCatagoriesFailureBlock) (NSString *reason);

typedef void (^FetchRecordsSuccessBlock) (NSArray *Records);
typedef void (^FetchRecordsFailureBlock) (NSString *reason);

typedef void (^FetchReceiptsSuccessBlock) (NSArray *receipts);
typedef void (^FetchReceiptsFailureBlock) (NSString *reason);

typedef void (^FetchReceiptInfoSuccessBlock) (NSArray *receiptInfos);
typedef void (^FetchReceiptInfoFailureBlock) (NSString *reason);

typedef void (^FetchReceiptSuccessBlock) (Receipt *receipt);
typedef void (^FetchReceiptFailureBlock) (NSString *reason);

@property (nonatomic, strong) CatagoriesDAO     *catagoriesDAO;
@property (nonatomic, strong) RecordsDAO        *recordsDAO;
@property (nonatomic, strong) ReceiptsDAO       *receiptsDAO;

-(void)loadDemoData;

- (NSOperation *) fetchCatagoriesSuccess: (FetchCatagoriesSuccessBlock) success
                                 failure: (FetchCatagoriesFailureBlock) failure;

- (NSOperation *) fetchAllRecordsSuccess: (FetchRecordsSuccessBlock) success
                                 failure: (FetchRecordsFailureBlock) failure;

- (NSOperation *) fetchRecordsForCatagoryID: (NSInteger) catagoryID
                                    success: (FetchRecordsSuccessBlock) success
                                    failure: (FetchRecordsFailureBlock) failure;

- (NSOperation *) fetchRecordsForReceiptID: (NSInteger) receiptID
                                   success: (FetchRecordsSuccessBlock) success
                                   failure: (FetchRecordsFailureBlock) failure;

- (NSOperation *) fetchReceiptsSuccess: (FetchReceiptsSuccessBlock) success
                               failure: (FetchReceiptsFailureBlock) failure;

#define kReceiptIDKey       @"ReceiptID"
#define kColorsKey          @"Colors"
#define kUploadTimeKey      @"UploadTime"
#define kTotalAmountKey     @"TotalAmountKey"

- (NSOperation *) fetchNewestTenReceiptInfoSuccess: (FetchReceiptInfoSuccessBlock) success
                                           failure: (FetchReceiptInfoFailureBlock) failure;

- (NSOperation *) fetchReceiptForReceiptID: (NSInteger) receiptID
                                   success: (FetchReceiptSuccessBlock) success
                                   failure: (FetchReceiptFailureBlock) failure;


@end
