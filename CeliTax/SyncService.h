//
//  SyncService.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-12.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkEngine.h"

@class UserDataDAO, TaxYearsDAO, CatagoriesDAO, ReceiptsDAO, RecordsDAO, NetworkCommunicator, CatagoryBuilder, RecordBuilder, ReceiptBuilder, TaxYearBuilder;

typedef void (^GenerateDemoDataCompleteBlock) ();

typedef void (^SyncingSuccessBlock) (NSDate *updateDate);
typedef void (^SyncingFailureBlock) (NSString *reason);

typedef void (^DownloadDataSuccessBlock) ();
typedef void (^DownloadDataFailureBlock) (NSString *reason);

typedef void (^GetLastestServerDataInfoSuccessBlock) (NSString *batchID);
typedef void (^GetLastestServerDataInfoFailureBlock) (NSString *reason);

typedef void (^GetListOfFilesNeedUploadSuccessBlock) (NSArray *filesnamesToUpload);
typedef void (^GetListOfFilesNeedUploadFailureBlock) (NSString *reason);

typedef void (^FileUploadSuccessBlock) ();
typedef void (^FileUploadFailureBlock) (NSString *reason);

typedef void (^FileDownloadSuccessBlock) ();
typedef void (^FileDownloadFailureBlock) (NSString *reason);

@protocol SyncService <NSObject>

@property (nonatomic, strong) UserDataDAO *userDataDAO;

@property (nonatomic, strong) TaxYearsDAO *taxYearsDAO;

@property (nonatomic, strong) RecordsDAO *recordsDAO;

@property (nonatomic, strong) ReceiptsDAO *receiptsDAO;

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;

@property (nonatomic, strong) NetworkCommunicator *networkCommunicator;

@property (nonatomic, strong) CatagoryBuilder *catagoryBuilder;

@property (nonatomic, strong) RecordBuilder *recordBuilder;

@property (nonatomic, strong) ReceiptBuilder *receiptBuilder;

@property (nonatomic, strong) TaxYearBuilder *taxYearBuilder;

/*
 Insert some random receipt data locally for testing purporses
 */
- (void) loadDemoData:(GenerateDemoDataCompleteBlock) complete;

/*
 Check to see if local data has a non-0 dataAction
 */
- (BOOL) needToBackUp;

/*
 Get the date of last successful sync with server
 */
- (NSDate *) getLastBackUpDate;

/*
 Get the batchID of local Data
 */
- (NSString *) getLocalDataBatchID;

/*
 Upload the UserData from app to server, and expect back a hash string of data just uploaded
 */
- (void) startSyncingUserData: (SyncingSuccessBlock) success
                      failure: (SyncingFailureBlock) failure;

/*
 Download the UserData JSON from to server, merge the server's contents with the local UserData
 */
-(void) downloadUserData: (DownloadDataSuccessBlock) success
                 failure: (DownloadDataFailureBlock) failure;

/*
 Ask the server for its most recent hash string of the data
 */
- (void) getLastestServerDataBatchID: (GetLastestServerDataInfoSuccessBlock) success
                             failure: (GetLastestServerDataInfoFailureBlock) failure;

/*
 Assuming the server has the same data as the device
 Ask the server for a list of filenames that it doesn't have, but exists on the device.
 Using the data from UserData.receipts.fileNames
 */
- (void) getFilesNeedToUpload: (GetListOfFilesNeedUploadSuccessBlock) success
                      failure: (GetListOfFilesNeedUploadFailureBlock) failure;

/*
 Upload the given file with the given filename for the currently logged in user
 */
- (void) uploadFile: (NSString *)filename
            andData: (NSData *)data
            success: (FileUploadSuccessBlock) success
            failure: (FileUploadFailureBlock) failure;

/*
 Download the file of the given filename for the currently logged in user
 */
- (void) downloadFile: (NSString *)filename
              success: (FileDownloadSuccessBlock) success
              failure: (FileDownloadFailureBlock) failure;

/*
 Get the list of receipt images that need to be downloaded from server
 */
- (NSArray *) getListOfFilesToDownload;

/*
 Find any Photo files that are not in an exsting Receipt's filenames and delete these files
 */
- (void) cleanUpReceiptImages;

@end