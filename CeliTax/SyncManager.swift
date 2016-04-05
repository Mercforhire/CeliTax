//
//  SyncManager.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-14.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

/**
 Emcapsulates some of the more complex Syncing related functions
 */
@objc
class SyncManager : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    typealias SyncSuccessBlock = (syncDate : NSDate) -> Void
    typealias SyncFailureBlock = (reason : String) -> Void
    
    typealias UploadingPhotosSuccessBlock = () -> Void
    typealias UploadingPhotosFailureBlock = (reason : String) -> Void
    
    typealias DownloadAndMergeDataSuccessBlock = () -> Void
    typealias DownloadAndMergeDataFailureBlock = (reason : String) -> Void
    
    typealias DownloadFilesSuccessBlock = () -> Void
    typealias DownloadFileFailureBlock = (filesnamesFailedToDownload : [String]) -> Void
    
    typealias NeedsUpdateBlock = () -> Void
    typealias DoesntNeedsUpdateBlock = () -> Void
    
    private weak var userManager : UserManager!
    private weak var syncService : SyncService!
    
    private var cancelOperations : Bool = false
        
    override init()
    {
        super.init()
    }
    
    init(userManager : UserManager!, syncService : SyncService!)
    {
        self.userManager = userManager
        self.syncService = syncService
    }
    
    /*
    Insert some default categories
    */
    func insertPreloadedCategories()
    {
        self.syncService.insertPreloadedCategories();
    }
    
    /*
    Check to see if local data has a non-0 dataAction
    */
    func needToBackUp() -> Bool
    {
        return self.syncService.needToBackUp()
    }
    
    /*
    Get last Back Up Date
    */
    func getLastBackUpDate() -> NSDate?
    {
        return self.syncService.getLastBackUpDate()
    }
    
    /*
    Check if the local saved data hash ID matches the server's data's hash ID
    */
    func checkUpdate(needsUpdate : NeedsUpdateBlock?, noNeedUpdate : DoesntNeedsUpdateBlock?)
    {
        let localDataBatchID : String? = self.syncService.getLocalDataBatchID()
        
        if (localDataBatchID == nil)
        {
            //no local data batch exist. Meaning the app has never been sync with server
            
            //check the server to see if the server has different data by comparing BatchID
            self.syncService.getLastestServerDataBatchID( { (batchID) in
                
                if (self.cancelOperations)
                {
                    self.cancelOperations = false
                    
                    return
                }
                
                if (needsUpdate != nil)
                {
                    needsUpdate!()
                }
                
                }, failure: { (reason : String) in
                    dLog("Server has no data to download or failed to check update.")
                    
                    if (noNeedUpdate != nil)
                    {
                        noNeedUpdate!()
                    }
            })
        }
        else
        {
            //app has synced with server before
            //check the server to see if the server has different data by comparing BatchID
            self.syncService.getLastestServerDataBatchID( { (batchID) in
                
                if (self.cancelOperations)
                {
                    self.cancelOperations = false
                    
                    return
                }
                
                if (localDataBatchID != batchID)
                {
                    if (needsUpdate != nil)
                    {
                        needsUpdate!()
                    }
                }
                else
                {
                    if (noNeedUpdate != nil)
                    {
                        noNeedUpdate!()
                    }
                }
                
                self.downloadMissingImages()
                
                }, failure:{ (reason) in
                    //serer has no data
                    if (noNeedUpdate != nil)
                    {
                        noNeedUpdate!()
                    }
            })
        }
    }
    
    /*
    Upload any new data to server, download newest data from server, merge with local data
    */
    func startSync(success : SyncSuccessBlock?, failure : SyncFailureBlock?)
    {
        var syncDate : NSDate?
        
        dLog("Start Sync:")
        
        // Create the dispatch groups
        let serviceGroup1 : dispatch_group_t = dispatch_group_create()
        let serviceGroup2 : dispatch_group_t = dispatch_group_create()
        let serviceGroup3 : dispatch_group_t = dispatch_group_create()
    
        // Enter all groups first
        dispatch_group_enter(serviceGroup1)
        dispatch_group_enter(serviceGroup2)
        dispatch_group_enter(serviceGroup3)
        
        // 1.Upload local data to server
        
        if (self.cancelOperations)
        {
            dispatch_group_leave(serviceGroup1)
        }
        else
        {
            dLog("1.Upload local data to server")
            
            self.syncService.startSyncingUserData({ (updateDate) in
                
                dLog("Upload local data to server complete")
                
                syncDate = updateDate
                
                dispatch_group_leave(serviceGroup1)
                
            }) { (reason) in
                
                dispatch_group_leave(serviceGroup1)
                
                if (failure != nil)
                {
                    failure!(reason: reason)
                    
                    self.cancelOperations = true
                }
            }
        }
        
        // 2.Download and merge data from server
        dispatch_group_notify(serviceGroup1, dispatch_get_main_queue()) {
            
            if (self.cancelOperations)
            {
                dispatch_group_leave(serviceGroup2)
            }
            else
            {
                dLog("2.Download and merge data from server")
                
                self.syncService.downloadUserData( {
                    
                    dLog("Download and merge data from server complete")
                    
                    dispatch_group_leave(serviceGroup2)
                    
                    }, failure: { (reason) in
                        
                        dispatch_group_leave(serviceGroup2)
                        
                        if (failure != nil)
                        {
                            failure!(reason: reason)
                            
                            self.cancelOperations = true
                        }
                })
            }
            
        }
        
        // 3.Delete Photos no longer attached to any receipts
        dispatch_group_notify(serviceGroup2, dispatch_get_main_queue()) {
            
            if (self.cancelOperations)
            {
                dispatch_group_leave(serviceGroup3)
            }
            else
            {
                dLog("3.Delete Photos no longer attached to any receipts")
                
                self.cleanUpReceiptImages({ 
                    
                    dLog("Delete Photos no longer attached to any receipts complete")
                    
                    dispatch_group_leave(serviceGroup3)
                    
                })
            }
        }
        
        // Finally, trigger the success block
        dispatch_group_notify(serviceGroup3, dispatch_get_main_queue()) {
            
            if (self.cancelOperations)
            {
                self.cancelOperations = false
                
                return
            }
            
            if (success != nil)
            {
                dLog("Finally, trigger the success block")
                
                success!( syncDate: syncDate! )
            }
        }
    }
    
    /*
    Download existing data from server, merge with local data
    */
    func downloadAndMerge(success : DownloadAndMergeDataSuccessBlock?, failure : DownloadAndMergeDataFailureBlock?)
    {
        self.syncService.downloadUserData( {
            
            if (self.cancelOperations)
            {
                self.cancelOperations = false
                
                return
            }
            
            self.downloadMissingImages()
            
            if (success != nil)
            {
                success! ()
            }
            
            }, failure: { (reason) in
                
                if (self.cancelOperations)
                {
                    self.cancelOperations = false
                    
                    return
                }
                
                if (failure != nil)
                {
                    failure! ( reason: reason )
                }
                
        })
    }
    
    /*
    Secretly upload photos to server
    */
    func startUploadingPhotos(success : UploadingPhotosSuccessBlock?, failure : UploadingPhotosFailureBlock?)
    {
        // 0.Filenames that we need to upload
        var filenames : [String] = []
        
        // Create the dispatch groups
        let serviceGroup1 : dispatch_group_t = dispatch_group_create()
        
        // 1.Get the list of images the server needs
        dispatch_group_enter(serviceGroup1)
        
        self.syncService.getFilesNeedToUpload( { (filesnamesToUpload) in
            
            if (self.cancelOperations)
            {
                self.cancelOperations = false
            }
            else
            {
                if (filesnamesToUpload.count > 0)
                {
                    dLog("Need to upload:")
                    dLog(filesnamesToUpload.description)
                    
                    filenames = filesnamesToUpload
                }
            }
            
            dispatch_group_leave(serviceGroup1)
            
        }, failure: { (reason) in
            
            if (self.cancelOperations)
            {
                self.cancelOperations = false
            }
            else
            {
                failure?(reason: reason)
            }
            
            dispatch_group_leave(serviceGroup1)
        })
        
        // 2.Upload each image
        dispatch_group_notify(serviceGroup1, dispatch_get_main_queue()) {
            
            if (filenames.count == 0)
            {
                return
            }
            
            var uploadImagesTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
            
            dLog("Upload Task started...")
            
            let uploadQueue : NSOperationQueue = NSOperationQueue()
            uploadQueue.name = "Upload queue"
            uploadQueue.maxConcurrentOperationCount = 1
            
            for fileToUpload in filenames
            {
                if (self.cancelOperations)
                {
                    self.cancelOperations = false
                    
                    UIApplication.sharedApplication().endBackgroundTask(uploadImagesTask)
                    uploadImagesTask = UIBackgroundTaskInvalid
                    
                    dLog("Upload Task complete.")
                    
                    break
                }
                
                guard let fileData : NSData = Utils.readImageDataWithFileName(fileToUpload, userKey: self.userManager.user!.userKey) else {
                    continue
                }
                
                let uploadOperation : ImageUploaderOperation = ImageUploaderOperation(syncService: self.syncService, filenameToUpload: fileToUpload, fileData: fileData)
                
                if fileToUpload == filenames.last
                {
                    uploadOperation.completionBlock = {
                        UIApplication.sharedApplication().endBackgroundTask(uploadImagesTask)
                        uploadImagesTask = UIBackgroundTaskInvalid
                        
                        dLog("Upload Task complete.")
                    }
                }
                
                uploadQueue.addOperation(uploadOperation)
            }
        }
    }
    
    /*
    Try to download the files in filenames from the server to local image storage
    */
    func startDownloadPhotos(filenames : [String], success : DownloadFilesSuccessBlock?, failure : DownloadFileFailureBlock?)
    {
        if (self.cancelOperations)
        {
            self.cancelOperations = false
            
            return
        }
        
        if (filenames.count == 0)
        {
            return
        }
        
        // Filenames that we need to download
        var downloadTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        
        dLog("Download Task started...")
        
        let downloadQueue : NSOperationQueue = NSOperationQueue()
        downloadQueue.name = "Download queue"
        downloadQueue.maxConcurrentOperationCount = 1
        
        for fileToDownload in filenames
        {
            if (self.cancelOperations)
            {
                self.cancelOperations = false
                
                UIApplication.sharedApplication().endBackgroundTask(downloadTask)
                downloadTask = UIBackgroundTaskInvalid
                
                dLog("Download Task complete.")
                
                break
            }
            
            let downloadOperation : ImageDownloaderOperation = ImageDownloaderOperation(syncService: self.syncService, filenameToDownload: fileToDownload)
            
            if fileToDownload == filenames.last
            {
                downloadOperation.completionBlock = {
                    UIApplication.sharedApplication().endBackgroundTask(downloadTask)
                    downloadTask = UIBackgroundTaskInvalid
                    
                    dLog("Download Task complete.")
                }
            }
            
            downloadQueue.addOperation(downloadOperation)
        }
       
    }
    
    private func getListOfFilesToDownload() -> [String]
    {
        return self.syncService.getListOfFilesToDownload()
    }
    
    /*
    Get the list of receipt images that need to be downloaded from server
    and start downloading them
    */
    func downloadMissingImages()
    {
        let missingImageFiles : [String] = self.getListOfFilesToDownload()
        
        if (missingImageFiles.count > 0)
        {
            dLog( String.init(format: "List of images to download: \n %@", missingImageFiles) )
            self.startDownloadPhotos(missingImageFiles, success:nil, failure:nil)
        }
    }
    
    /*
    Find any Photo files that are not in an exsting Receipt's filenames and delete these files
    */
    func cleanUpReceiptImages(completion : SyncService.CleanReceiptsCompletionBlock?)
    {
        self.syncService.cleanUpReceiptImages(completion)
    }
    
    func cancelAllOperations()
    {
        cancelOperations = true
    }
    
    func resetCancelOperation()
    {
        cancelOperations = false
    }
}