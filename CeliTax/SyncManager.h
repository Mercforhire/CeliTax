//
//  SyncManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-23.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SyncManager, UserManager;

@protocol SyncService;

typedef void (^SyncSuccessBlock) (NSDate *syncDate);
typedef void (^SyncFailureBlock) (NSString *reason);

typedef void (^UploadingPhotosSuccessBlock) ();
typedef void (^UploadingPhotosFailureBlock) (NSString *reason);

typedef void (^DownloadAndMergeDataSuccessBlock) ();
typedef void (^DownloadAndMergeDataFailureBlock) (NSString *reason);

typedef void (^DownloadFilesSuccessBlock) ();
typedef void (^DownloadFileFailureBlock) (NSArray *filesnamesFailedToDownload);

typedef void (^NeedsUpdateBlock) ();

/**
 Handles all network interactions between the app and server here
 */
@interface SyncManager : NSObject

- (instancetype) initWithSyncService: (id <SyncService>)syncService andUserManager:(UserManager *)userManager;

/*
 Check to see if local data has a non-0 dataAction
 */
- (BOOL) needToBackUp;

/*
 Get last Back Up Date
 */
- (NSDate *) getLastBackUpDate;

/*
 Check if the local saved data hash ID matches the server's data's hash ID
 */
- (void)checkUpdate: (NeedsUpdateBlock) needsUpdate;

/*
 Upload any new data to server, download newest data from server, merge with local data
 */
- (void)startSync: (SyncSuccessBlock) success
          failure: (SyncFailureBlock) failure;

/*
 Download existing data from server, merge with local data
 */
- (void)downloadAndMerge: (DownloadAndMergeDataSuccessBlock) success
                 failure: (DownloadAndMergeDataFailureBlock) failure;

/*
 Secretly upload photos to server
 */
- (void)startUploadingPhotos: (UploadingPhotosSuccessBlock) success
                     failure: (UploadingPhotosFailureBlock) failure;

/*
 Try to download the files in filenames from the server to local image storage
 */
- (void)startDownloadPhotos:(NSArray *)filenames
                    success: (DownloadFilesSuccessBlock) success
                    failure: (DownloadFileFailureBlock) failure;

/*
 Get the list of receipt images that need to be downloaded from server
 and start downloading them
 */
-(void) downloadMissingImages;

/*
 Find any Photo files that are not in an exsting Receipt's filenames and delete these files
 */
-(void) cleanUpReceiptImages;

/*
 Cancel any ongoing network operations
 */
-(void) cancelAllOperations;

@end
