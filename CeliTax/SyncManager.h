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

/**
 Objects that want updates on the sync process need to conform to this protocol
 */
@protocol SyncManagerDelegate <NSObject>

@optional

- (void) syncManagerNeedsUpdate: (SyncManager *) syncManager;

- (void) syncManagerDownloadAndMergeDataComplete: (SyncManager *) syncManager;

- (void) syncManagerDownloadDataFailed: (SyncManager *) syncManager;

- (void) syncManagerSyncCompleteOn: (NSDate *)date manager:(SyncManager *) syncManager;

- (void) syncManagerSyncFailedWithMessage:(NSString *)message manager:(SyncManager *) syncManager;

- (void) syncManagerDownloadFilesComplete:(SyncManager *) syncManager;

- (void) syncManagerDownloadFilesFailed:(NSArray *)filenamesFailedDownload manager:(SyncManager *) syncManager;

@end

/**
 Handles all network interactions between the app and server here
 */
@interface SyncManager : NSObject

@property (nonatomic, weak) id<SyncManagerDelegate> delegate;

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
- (void)checkUpdate;

/*
 Upload any new data to server
 */
- (void)quickUpdate;

/*
 Upload any new data to server, download newest data from server, merge with local data
 */
- (void)startSync;

/*
 Download existing data from server, merge with local data 
 */
- (void)downloadAndMerge;

/*
 Secretly upload photos to server
 */
- (void)startUploadingPhotos;

/*
 Try to download the files in filenames from the server to local image storage
 */
- (void)startDownloadPhotos:(NSArray *)filenames;

/*
 Get the list of receipt images that need to be downloaded from server
 and start downloading them
 */
-(void) downloadMissingImages;

/*
 Find any Photo files that are not in an exsting Receipt's filenames and delete these files
 */
-(void) cleanUpReceiptImages;

@end
