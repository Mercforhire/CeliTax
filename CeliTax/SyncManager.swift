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
    
    private var filenamesToUpload : [String] = []    /** Filenames that we need to upload */
    private var indexOfFileToUpload : Int = -1
    
    private var uploadImagesTask : UIBackgroundTaskIdentifier?
    
    private var filenamesToDownload : [String] = []    /** Filenames that we need to download */
    private var filenamesFailedToDownload : [String] = []
    private var indexOfFileToDownload : Int = -1
    private var downloading : Bool = false
    
    private var downloadTask : UIBackgroundTaskIdentifier?
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
        //1.Upload local data to server
        self.syncService.startSyncingUserData( { (updateDate) in
            
            if (self.cancelOperations)
            {
                self.cancelOperations = false
                
                return
            }
            
            //2. Download and merge data from server first
            self.syncService.downloadUserData( {
                
                if (self.cancelOperations)
                {
                    self.cancelOperations = false
                    
                    return
                }
                
                //3. Delete Photos no longer attached to any receipts
                self.cleanUpReceiptImages()
                
                if (success != nil)
                {
                    success!( syncDate: updateDate )
                }
                
                }, failure: { (reason) in
                    
                    if (self.cancelOperations)
                    {
                        self.cancelOperations = false
                        
                        return;
                    }
                    
                    if (failure != nil)
                    {
                        failure!(reason: reason)
                    }
            })
            
            }, failure: { (reason) in
                
                if (self.cancelOperations)
                {
                    self.cancelOperations = false
                    
                    return;
                }
                
                if (failure != nil)
                {
                    failure!(reason: reason)
                }
        })
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
    
    private func uploadPhotos(success : UploadingPhotosSuccessBlock?, failure : UploadingPhotosFailureBlock?)
    {
        if (self.indexOfFileToUpload < self.filenamesToUpload.count)
        {
            let filenameToUpload : String = self.filenamesToUpload[self.indexOfFileToUpload]
            
            let fileData : NSData? = Utils.readImageDataWithFileName(filenameToUpload, userKey: self.userManager.user!.userKey)
            
            if (fileData != nil)
            {
                dLog( String.init(format: "Uploading %@...", filenameToUpload) )
                
                self.syncService.uploadFile(filenameToUpload, data: fileData!, success: {
                    
                    dLog( String.init(format: "%@ Uploaded.", filenameToUpload) )
                    self.indexOfFileToUpload++
                    
                    self.uploadPhotos(success, failure:failure)
                    
                    }, failure: { (reason) in
                        
                        dLog( String.init(format: "%@ failed to uploaded, stopping all uploads!", filenameToUpload) )
                        
                        UIApplication.sharedApplication().endBackgroundTask(self.uploadImagesTask!)
                        
                        if (failure != nil)
                        {
                            failure! (reason: reason)
                        }
                        
                })
            }
            else
            {
                //if this file doesn't exist, we have a problem with receipt data integrity
                
                //skip this file for now
                self.indexOfFileToUpload++
                
                self.uploadPhotos(success, failure:failure)
            }
        }
        else
        {
            UIApplication.sharedApplication().endBackgroundTask(self.uploadImagesTask!)
            
            if (success != nil)
            {
                success!()
            }
        }
    }
    
    /*
    Secretly upload photos to server
    */
    func startUploadingPhotos(success : UploadingPhotosSuccessBlock?, failure : UploadingPhotosFailureBlock?)
    {
        //Get the list of images the server needs
        self.syncService.getFilesNeedToUpload( { (filesnamesToUpload) in
            
            if (filesnamesToUpload.count > 0)
            {
                //Start uploading the images one by one
                dLog("Need to upload:")
                dLog(filesnamesToUpload.description)
                
                self.filenamesToUpload = filesnamesToUpload
                
                self.indexOfFileToUpload = 0
                
                self.uploadImagesTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                    
                })
                
                self.uploadPhotos(success, failure:failure)
            }
            else
            {
                //Nothing to upload
                if (success != nil)
                {
                    success!()
                }
            }
            
            }, failure: { (reason) in
                
                if (failure != nil)
                {
                    failure!(reason: reason)
                }
        })
    }
    
    private func downloadPhotos(success : DownloadFilesSuccessBlock?, failure : DownloadFileFailureBlock?)
    {
        if (cancelOperations)
        {
            self.downloading = false
            
            UIApplication.sharedApplication().endBackgroundTask(self.downloadTask!)
            
            cancelOperations = false
            
            return
        }
        
        if (self.indexOfFileToDownload < self.filenamesToDownload.count)
        {
            let filenameToDownload : String = self.filenamesToDownload[self.indexOfFileToDownload]
            
            self.syncService.downloadFile(filenameToDownload, success: {
                
                self.indexOfFileToDownload++
                self.downloadPhotos(success, failure: failure)
                
                }, failure: { (reason) in
                    
                    self.filenamesFailedToDownload.append(filenameToDownload)
                    
                    self.indexOfFileToDownload++
                    self.downloadPhotos(success, failure: failure)
                    
            })
        }
        else
        {
            self.downloading = false
            
            if (self.filenamesFailedToDownload.count > 0)
            {
                if (failure != nil)
                {
                    failure! (filesnamesFailedToDownload: self.filenamesFailedToDownload)
                }
            }
            else
            {
                if (success != nil)
                {
                    success!()
                }
            }
            
            UIApplication.sharedApplication().endBackgroundTask(self.downloadTask!)
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
            
            return;
        }
        
        if (filenames.count == 0)
        {
            return
        }
        
        self.downloading = true
        
        self.filenamesToDownload = filenames
        
        self.filenamesFailedToDownload = []
        
        self.indexOfFileToDownload = 0
        
        self.downloadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            
        })
        
        self.downloadPhotos(success, failure: failure)
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
    func cleanUpReceiptImages()
    {
        self.syncService.cleanUpReceiptImages()
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