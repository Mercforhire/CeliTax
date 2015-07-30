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
#import "User.h"

@interface SyncManager ()

@property (nonatomic, weak) UserManager *userManager;

@property (nonatomic, weak) id <SyncService> syncService;

@property (nonatomic, strong) NSArray *filenamesToUpload;    /** Filenames that we need to upload */
@property (nonatomic, assign) NSInteger indexOfFileToUpload;
@property (nonatomic, assign) BOOL uploading;

@property (nonatomic) UIBackgroundTaskIdentifier uploadTask;

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

- (void)checkUpdate
{
    NSString *localDataBatchID = [self.syncService getLocalDataBatchID];
    
    if (!localDataBatchID)
    {
        //no local data batch exist. Meaning the app has never been sync with server
        if (self.delegate)
        {
            [self.delegate syncManagerNeedsUpdate:self];
        }
    }
    //app has synced with server before
    else
    {
        //check the server to see if the server has different data by comparing BatchID
        [self.syncService getLastestServerDataBatchID:^(NSString *batchID) {
            
            if (!batchID)
            {
                //server has no data
            }
            else
            {
                if (![localDataBatchID isEqualToString:batchID])
                {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(syncManagerNeedsUpdate:)])
                    {
                        [self.delegate syncManagerNeedsUpdate:self];
                    }
                }
                
                [self downloadMissingImages];
            }
            
        } failure:^(NSString *reason) {
            
        }];
    }
}

-(void)uploadPhotos
{
    if (self.indexOfFileToUpload < self.filenamesToUpload.count)
    {
        NSString *filenameToUpload = [self.filenamesToUpload objectAtIndex:self.indexOfFileToUpload];
        
        NSData *fileData = [Utils readImageDataWithFileName: filenameToUpload forUser: self.userManager.user.userKey];
        
        if (fileData)
        {
            [self.syncService uploadFile:filenameToUpload andData:fileData success:^{
                
                self.indexOfFileToUpload++;
                [self uploadPhotos];
                
            } failure:^(NSString *reason) {
                
                //stop uploading
                self.uploading = NO;
                
                [[UIApplication sharedApplication] endBackgroundTask: self.uploadTask];
                
            }];
        }
        
        //if this file doesn't exist, we have a problem with Receipt Data Integrity
        else
        {
            //Skip this file for now
            self.indexOfFileToUpload++;
            [self uploadPhotos];
        }
        
    }
    else
    {
        self.uploading = NO;
        
        [[UIApplication sharedApplication] endBackgroundTask: self.uploadTask];
    }
}

- (void)startUploadingPhotos
{
    if (self.uploading)
    {
        return;
    }
    
    self.uploading = YES;
    
    //Get the list of images the server needs
    [self.syncService getFilesNeedToUpload:^(NSArray *filesnamesToUpload) {
        
        if (filesnamesToUpload.count)
        {
            //Start uploading the images one by one
            DLog(@"Need to upload:"); DLog(@"%@", filesnamesToUpload);
            
            self.filenamesToUpload = filesnamesToUpload;
            
            self.indexOfFileToUpload = 0;
            
            self.uploadTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
            
            [self uploadPhotos];
        }
        
    } failure:^(NSString *reason) {
        
        //ignore
        
        self.uploading = NO;
        
    }];
}

- (void)startSync
{
    //1.Upload local data to server
    [self.syncService startSyncingUserData:^(NSDate *updateDate) {
        
        //2. Download and merge data from server first
        [self.syncService downloadUserData:^{
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(syncManagerSyncFailedWithMessage:manager:)])
            {
                [self.delegate syncManagerSyncCompleteOn:updateDate manager:self];
            }
            
            //3. Delete Photos no longer attached to any receipts
            [self cleanUpReceiptImages];
            
            //4. Silently starts uploading images:
            [self startUploadingPhotos];
            
        } failure:^(NSString *reason) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(syncManagerSyncFailedWithMessage:manager:)])
            {
                [self.delegate syncManagerSyncFailedWithMessage:reason manager:self];
            }
            
        }];
        
    } failure:^(NSString *reason) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(syncManagerSyncFailedWithMessage:manager:)])
        {
            [self.delegate syncManagerSyncFailedWithMessage:reason manager:self];
        }
        
    }];
}

- (void)downloadAndMerge
{
    [self.syncService downloadUserData:^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(syncManagerDownloadAndMergeDataComplete:)])
        {
            [self.delegate syncManagerDownloadAndMergeDataComplete:self];
        }
        
    } failure:^(NSString *reason) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(syncManagerDownloadDataFailed:)])
        {
            [self.delegate syncManagerDownloadDataFailed:self];
        }
        
    }];
}

-(void)downloadPhotos
{
    if (self.indexOfFileToDownload < self.filenamesToDownload.count)
    {
        NSString *filenameToDownload = [self.filenamesToDownload objectAtIndex:self.indexOfFileToDownload];
        
        [self.syncService downloadFile:filenameToDownload success:^{
            
            self.indexOfFileToDownload++;
            [self downloadPhotos];
            
        } failure:^(NSString *reason) {
            
            [self.filenamesFailedToDownload addObject:filenameToDownload];
            
            self.indexOfFileToDownload++;
            [self downloadPhotos];
            
        }];
    }
    else
    {
        self.downloading = NO;
        
        if (self.filenamesFailedToDownload.count)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(syncManagerDownloadFilesFailed:manager:)])
            {
                [self.delegate syncManagerDownloadFilesFailed:self.filenamesFailedToDownload manager:self];
            }
        }
        else
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(syncManagerDownloadFilesComplete:)])
            {
                [self.delegate syncManagerDownloadFilesComplete:self];
            }
        }
        
        [[UIApplication sharedApplication] endBackgroundTask: self.uploadTask];
    }
}

- (void)startDownloadPhotos:(NSArray *)filenames
{
    if (!filenames.count)
    {
        return;
    }
    
    if (self.downloading)
    {
        return;
    }
    
    self.downloading = YES;
    
    self.filenamesToDownload = filenames;
    
    self.filenamesFailedToDownload = [NSMutableArray new];
    
    self.indexOfFileToDownload = 0;
    
    self.downloadTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    [self downloadPhotos];
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
        [self startDownloadPhotos:missingImageFiles];
    }
}

-(void) cleanUpReceiptImages
{
    [self.syncService cleanUpReceiptImages];
}

@end
