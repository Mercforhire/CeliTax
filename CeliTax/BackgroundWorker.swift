//
//  BackgroundWorker.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-13.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
enum QueueTaskType : Int
{
    case UploadData = 0
    case UploadPhotos = 1
    case UpdateProfileImage = 2
    case UploadProfileData = 3
}

@objc
class BackgroundWorker : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    static let kLastTimeDateKey : String = "LastTimeDateKey"
    static let kQueuedTasksKey : String = "QueuedTasksKey"
    
    private weak var syncManager : SyncManager!
    private weak var authenticationService : AuthenticationService!
    private weak var userManager : UserManager!
    
    private let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    private var active : Bool = false
    
    private var currentTaskIndex : Int = 0
    
    //Data that are persistent in User Defaults:
    private var lastTimeDate : NSDate?
    private var queuedTasks : [Int] = []
    
    override init()
    {
        super.init()
    }
    
    init(syncManager : SyncManager!, authenticationService : AuthenticationService!, userManager : UserManager!)
    {
        self.syncManager = syncManager
        self.authenticationService = authenticationService
        self.userManager = userManager
    }
    
    /*
    This must be called before this Worker does anything, usually when logged in.
    Also will load all queued tasks from User Defaults
    */
    func activeWorker()
    {
        self.active = true
        
        //load previously queued tasks
        let queuedTasks : [Int]? = self.defaults.objectForKey(BackgroundWorker.kQueuedTasksKey) as? [Int]
        
        if (queuedTasks != nil)
        {
            self.queuedTasks = queuedTasks!
        }
    }
    
    /*
    This must be called before when the user logs off,
    Also will also remove all tasks in the queue
    */
    func deactiveWorker()
    {
        self.active = false
        
        //delete any persistent data
        self.defaults.removeObjectForKey(BackgroundWorker.kLastTimeDateKey)
        self.defaults.removeObjectForKey(BackgroundWorker.kQueuedTasksKey)
        
        self.defaults.synchronize()
        
        //stop all network operations
        self.syncManager.cancelAllOperations()
    }
    
    /*
    When this is called by the appDelegate,
    the worker will run all queued tasks if it has been at least 1 hour since last update
    */
    func executeTasks()
    {
        if (self.currentTaskIndex < self.queuedTasks.count)
        {
            let currentTask : QueueTaskType = QueueTaskType.init(rawValue: self.queuedTasks[self.currentTaskIndex])!
            
            switch (currentTask)
            {
            case QueueTaskType.UploadData:
                if (self.syncManager.needToBackUp())
                {
                    self.syncManager.startSync( { (syncDate) in
                        
                        dLog("Automatic syncing success!");
                        
                        //Add a upload photos task
                        self.addTaskToQueue(QueueTaskType.UploadPhotos)
                        
                        //Go on to next task
                        self.currentTaskIndex++
                        
                        self.executeTasks()
                        
                        }, failure: { (reason) in
                            
                            dLog("Error: Syncing Task failed.");
                            
                            //Halting running tasks
                    })
                }
                else
                {
                    dLog("No need to sync, data unchanged.");
                    
                    //Add a upload photos task
                    self.addTaskToQueue(QueueTaskType.UploadPhotos)
                    
                    //Go on to next task
                    self.currentTaskIndex++
                    
                    self.executeTasks()
                }
                
                break
                
            case QueueTaskType.UploadPhotos:
                
                self.syncManager.startUploadingPhotos( {
                    
                    //Go on to next task
                    self.currentTaskIndex++;
                    
                    self.executeTasks()
                    
                    }, failure:{ (reason) in
                        
                        dLog("Error: Uploading Receipt Task failel");
                        
                        //Halting running tasks
                })
                
                break
                
            case QueueTaskType.UpdateProfileImage:
                
                if (self.userManager.doesUserHaveCustomProfileImage())
                {
                    self.authenticationService.updateProfileImage(self.userManager.user!.avatarImage, success: {
                        
                        //Go on to next task
                        self.currentTaskIndex++
                        
                        self.executeTasks()
                        
                        }, failure: { (reason ) in
                            
                            dLog("Error: Update Profile Image Task failed")
                            
                            //Halting running tasks
                            
                    })
                }
                else
                {
                    self.authenticationService.deleteProfileImage( {
                        
                        //Go on to next task
                        self.currentTaskIndex++
                        
                        self.executeTasks()
                        
                        }, failure: { (reason ) in
                            
                            dLog("Error: Update Profile Image Task failed")
                            
                            //Halting running tasks
                            
                    })
                }
                
                break
                
            case QueueTaskType.UploadProfileData:
                
                if (self.userManager.user != nil)
                {
                    self.authenticationService.updateAccountInfo(self.userManager.user!.firstname, lastname: self.userManager.user!.lastname, country: self.userManager.user!.country, success: { () -> Void in
                        
                        //Go on to next task
                        self.currentTaskIndex++
                        
                        self.executeTasks()
                        
                        }, failure: { (reason) -> Void in
                            
                            dLog("Error: Uploading Receipt Task failed");
                            
                            //Halting running tasks
                            
                    })
                }
                else
                {
                    dLog("Error: Uploading Receipt Task failed. Reason: No current user");
                    
                    //Halting running tasks
                }
                
                break
            }
        }
        else
        {
            self.currentTaskIndex = 0
            
            self.queuedTasks.removeAll()
            
            self.defaults.removeObjectForKey(BackgroundWorker.kQueuedTasksKey)
            
            self.defaults.setObject(NSDate.init(), forKey:BackgroundWorker.kLastTimeDateKey)
            
            self.defaults.synchronize()
        }
    }
    
    /*
    Add the task of selected type to BackgroundWorker's queue of tasks,
    that will be executed a sufficient time has passed and 'appIsActive' is called
    
    The queue does not contain duplicate tasks.
    */
    func addTaskToQueue(taskType : QueueTaskType)
    {
        if (!self.queuedTasks.contains(taskType.rawValue))
        {
            self.queuedTasks.append(taskType.rawValue)
            
            self.defaults.setObject(self.queuedTasks, forKey:BackgroundWorker.kQueuedTasksKey)
            
            self.defaults.synchronize()
        }
    }
    
    
    
    func appIsActive()
    {
        if (self.active)
        {
            dLog("Received notification that the app is active");
            
            let lastRefresh : NSDate? = self.defaults.valueForKey(BackgroundWorker.kLastTimeDateKey) as? NSDate
            
            if (lastRefresh == nil)
            {
                self.addTaskToQueue(QueueTaskType.UploadData)
                
                self.executeTasks()
            }
            else
            {
                let minutes : Double = fabs( lastRefresh!.timeIntervalSinceNow / 60 )
                
                if (minutes > 10)
                {
                    self.addTaskToQueue(QueueTaskType.UploadData)
                    
                    self.executeTasks()
                }
                else
                {
                    dLog(String.init(format:"Only %ld minutes since last sync, not needed again", minutes ) )
                }
            }
        }
    }
}