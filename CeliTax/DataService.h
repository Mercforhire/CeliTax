//
//  DataService.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatagoriesDAO;

@protocol DataService <NSObject>

typedef void (^FetchCatagoriesSuccessBlock) (NSArray *catagories);
typedef void (^FetchCatagoriesFailureBlock) (NSString *reason);

typedef void (^FetchCatagoryRecordsSuccessBlock) (NSArray *catagoryRecords);
typedef void (^FetchCatagoryRecordsFailureBlock) (NSString *reason);

typedef void (^FetchReceiptsSuccessBlock) (NSArray *receipts);
typedef void (^FetchReceiptsFailureBlock) (NSString *reason);

typedef void (^FetchReceiptInfoSuccessBlock) (NSArray *receiptInfos);
typedef void (^FetchReceiptInfoFailureBlock) (NSString *reason);

@property (nonatomic, strong) CatagoriesDAO     *catagoriesDAO;

- (NSOperation *) fetchCatagoriesForUserKey: (NSString *) userKey
                                    success: (FetchCatagoriesSuccessBlock) success
                                    failure: (FetchCatagoriesFailureBlock) failure;

- (NSOperation *) fetchAllCatagoryRecordsForUserKey: (NSString *) userKey
                                            success: (FetchCatagoryRecordsSuccessBlock) success
                                            failure: (FetchCatagoryRecordsFailureBlock) failure;

- (NSOperation *) fetchCatagoryRecordsForUserKey: (NSString *) userKey
                                   forCatagoryID: (NSInteger) catagoryID
                                         success: (FetchCatagoryRecordsSuccessBlock) success
                                         failure: (FetchCatagoryRecordsFailureBlock) failure;

- (NSOperation *) fetchCatagoryRecordsForUserKey: (NSString *) userKey
                                    forReceiptID: (NSInteger) receiptID
                                         success: (FetchCatagoryRecordsSuccessBlock) success
                                         failure: (FetchCatagoryRecordsFailureBlock) failure;

- (NSOperation *) fetchReceiptsForUserKey: (NSString *) userKey
                                  success: (FetchReceiptsSuccessBlock) success
                                  failure: (FetchReceiptsFailureBlock) failure;

#define kReceiptIDKey       @"ReceiptID"
#define kColorsKey          @"Colors"
#define kUploadTimeKey      @"UploadTime"
#define kTotalAmountKey     @"TotalAmountKey"

- (NSOperation *) fetchNewestTenReceiptInfoForUserKey: (NSString *) userKey
                                              success: (FetchReceiptInfoSuccessBlock) success
                                              failure: (FetchReceiptInfoFailureBlock) failure;

@end
