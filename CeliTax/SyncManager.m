//
//  SyncManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-23.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SyncManager.h"
#import "SyncService.h"
#import "Utils.h"
#import "UserManager.h"

#import "CeliTax-Swift.h"

@interface SyncManager ()
{
    BOOL cancelOperations;
}

@property (nonatomic, weak) UserManager *userManager;
@property (nonatomic, weak) id <SyncService> syncService;

@property (nonatomic, strong) NSArray *filenamesToUpload;    /** Filenames that we need to upload */
@property (nonatomic, assign) NSInteger indexOfFileToUpload;

@property (nonatomic) UIBackgroundTaskIdentifier uploadImagesTask;

@property (nonatomic, strong) NSArray *filenamesToDownload;    /** Filenames that we need to download */
@property (nonatomic, strong) NSMutableArray *filenamesFailedToDownload;
@property (nonatomic, assign) NSInteger indexOfFileToDownload;
@property (nonatomic, assign) BOOL downloading;

@property (nonatomic) UIBackgroundTaskIdentifier downloadTask;

@end

@implementation SyncManager

- (instancetype) initWithSyncService: (id <SyncService>)syncService andUserManager:(UserManager *)userManager
{
    if (self = [super init])
    {
        self.syncService = syncService;
        self.userManager = userManager;
    }
    
    return self;
}

- (BOOL) needToBackUp
{
    return [self.syncService needToBackUp];
}

- (NSDate *) getLastBackUpDate
{
    return [self.syncService getLastBackUpDate];
}

- (void)checkUpdate: (NeedsUpdateBlock) needsUpdate
{
    NSString *localDataBatchID = [self.syncService getLocalDataBatchID];
    
    if (!localDataBatchID)
    {
        //no local data batch exist. Meaning the app has never been sync with server
        
        //check the server to see if the server has different data by comparing BatchID
        [self.syncService getLastestServerDataBatchID:^(NSString *batchID) {
            
            if (cancelOperations)
            {
                cancelOperations = NO;
                
                return;
            }
            
            if (!batchID)
            {
                //server has no data
                DLog(@"Server has no data to download.");
            }
            else
            {
                if (needsUpdate)
                {
                    needsUpdate();
                }
            }
            
        } failure:^(NSString *reason) {
            DLog(@"Failed to check update.");
        }];
        
    }
    //app has synced with server before
    else
    {
        //check the server to see if the server has different data by comparing BatchID
        [self.syncService getLastestServerDataBatchID:^(NSString *batchID) {
            
            if (cancelOperations)
            {
                cancelOperations = NO;
                
                return;
            }
            
            if (!batchID)
            {
                //server has no data
            }
            else
            {
                if (![localDataBatchID isEqualToString:batchID])
                {
                    if (needsUpdate)
                    {
                        needsUpdate();
                    }
                }
                
                [self downloadMissingImages];
            }
            
        } failure:^(NSString *reason) {
            
        }];
    }
}

-(void)uploadPhotos: (UploadingPhotosSuccessBlock) success
            failure: (UploadingPhotosFailureBlock) failure
{
    if (self.indexOfFileToUpload < self.filenamesToUpload.count)
    {
        NSString *filenameToUpload = (self.filenamesToUpload)[self.indexOfFileToUpload];
        
        NSData *fileData = [Utils readImageDataWithFileName: filenameToUpload forUser: self.userManager.user.userKey];
        
        if (fileData)
        {
            DLog(@"Uploading %@...", filenameToUpload);
            [self.syncService uploadFile:filenameToUpload andData:fileData success:^{
                
                DLog(@"%@ Uploaded.", filenameToUpload);
                self.indexOfFileToUpload++;
                
                [self uploadPhotos:success failure:failure];
                
            } failure:^(NSString *reason) {
                
                DLog(@"%@ failed to uploaded, stopping all uploads!", filenameToUpload);
                
                [[UIApplication sharedApplication] endBackgroundTask: self.uploadImagesTask];
                
                if (failure)
                {
                    failure(reason);
                }
                
            }];
        }
        
        //if this file doesn't exist, we have a problem with Receipt Data Integrity
        else
        {
            //Skip this file for now
            self.indexOfFileToUpload++;
            
            [self uploadPhotos:success failure:failure];
        }
    }
    else
    {
        [[UIApplication sharedApplication] endBackgroundTask: self.uploadImagesTask];
        
        if (success)
        {
            success();
        }
    }
}

- (void)startUploadingPhotos: (UploadingPhotosSuccessBlock) success
                     failure: (UploadingPhotosFailureBlock) failure
{
    //Get the list of images the server needs
    [self.syncService getFilesNeedToUpload:^(NSArray *filesnamesToUpload) {
        
        if (filesnamesToUpload.count)
        {
            //Start uploading the images one by one
            DLog(@"Need to upload:"); DLog(@"%@", filesnamesToUpload);
            
            self.filenamesToUpload = filesnamesToUpload;
            
            self.indexOfFileToUpload = 0;
            
            self.uploadImagesTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
            
            [self uploadPhotos:success failure:failure];
        }
        else
        {
            //Nothing to upload
            if (success)
            {
                success();
            }
        }
        
    } failure:^(NSString *reason) {
        
        if (failure)
        {
            failure(reason);
        }

    }];
}

- (void)startSync: (SyncSuccessBlock) success
          failure: (SyncFailureBlock) failure
{
    //1.Upload local data to server
    [self.syncService startSyncingUserData:^(NSDate *updateDate) {
        
        if (cancelOperations)
        {
            cancelOperations = NO;
            
            return;
        }
        
        //2. Download and merge data from server first
        [self.syncService downloadUserData:^{
            
            if (cancelOperations)
            {
                cancelOperations = NO;
                
                return;
            }
            
            //3. Delete Photos no longer attached to any receipts
            [self cleanUpReceiptImages];
            
            if (success)
            {
                success( updateDate );
            }
            
        } failure:^(NSString *reason) {
            
            if (cancelOperations)
            {
                cancelOperations = NO;
                
                return;
            }
            
            if (failure)
            {
                failure(reason);
            }
            
        }];
        
    } failure:^(NSString *reason) {
        
        if (cancelOperations)
        {
            cancelOperations = NO;
            
            return;
        }
        
        if (failure)
        {
            failure(reason);
        }
        
    }];
}

- (void)downloadAndMerge: (DownloadAndMergeDataSuccessBlock) success
                 failure: (DownloadAndMergeDataFailureBlock) failure
{
    [self.syncService downloadUserData:^{
        
        if (cancelOperations)
        {
            cancelOperations = NO;
            
            return;
        }
        
        [self downloadMissingImages];
        
        if (success)
        {
            success ();
        }
        
    } failure:^(NSString *reason) {
        
        if (cancelOperations)
        {
            cancelOperations = NO;
            
            return;
        }
        
        if (failure)
        {
            failure ( reason );
        }
        
    }];
}

-(void)downloadPhotos:(DownloadFilesSuccessBlock) success
              failure: (DownloadFileFailureBlock) failure
{
    if (cancelOperations)
    {
        self.downloading = NO;
        
        [[UIApplication sharedApplication] endBackgroundTask: self.downloadTask];
        
        cancelOperations = NO;
        
        return;
    }
    
    if (self.indexOfFileToDownload < self.filenamesToDownload.count)
    {
        NSString *filenameToDownload = (self.filenamesToDownload)[self.indexOfFileToDownload];
        
        [self.syncService downloadFile:filenameToDownload success:^{
            
            self.indexOfFileToDownload++;
            [self downloadPhotos:success failure: failure];
            
        } failure:^(NSString *reason) {
            
            [self.filenamesFailedToDownload addObject:filenameToDownload];
            
            self.indexOfFileToDownload++;
            [self downloadPhotos:success failure: failure];
            
        }];
    }
    else
    {
        self.downloading = NO;
        
        if (self.filenamesFailedToDownload.count)
        {
            if (failure)
            {
                failure (self.filenamesFailedToDownload);
            }
        }
        else
        {
            if (success)
            {
                success();
            }
        }
        
        [[UIApplication sharedApplication] endBackgroundTask: self.downloadTask];
    }
}

- (void)startDownloadPhotos:(NSArray *)filenames
                    success: (DownloadFilesSuccessBlock) success
                    failure: (DownloadFileFailureBlock) failure
{
    if (cancelOperations)
    {
        cancelOperations = NO;
        
        return;
    }
    
    if (!filenames.count)
    {
        return;
    }
    
    self.downloading = YES;
    
    self.filenamesToDownload = filenames;
    
    self.filenamesFailedToDownload = [NSMutableArray new];
    
    self.indexOfFileToDownload = 0;
    
    self.downloadTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    [self downloadPhotos:success failure:failure];
}

- (NSArray *)getListOfFilesToDownload
{
    return [self.syncService getListOfFilesToDownload];
}

-(void) downloadMissingImages
{
    NSArray *missingImageFiles = [self getListOfFilesToDownload];
    
    if (missingImageFiles.count)
    {
        DLog(@"List of images to download: \n %@", missingImageFiles);
        [self startDownloadPhotos:missingImageFiles success:nil failure:nil];
    }
}

-(void) cleanUpReceiptImages
{
    [self.syncService cleanUpReceiptImages];
}

-(void) cancelAllOperations
{
    cancelOperations = YES;
}

@end
