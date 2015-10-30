//
//  BackgroundWorker.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QueueTaskTypes) {
    QueueTaskUploadData,
    QueueTaskUploadPhotos,
    QueueTaskUpdateProfileImage,
    QueueTaskUploadProfileData
};

@class SyncManager,UserManager;

@protocol AuthenticationService;

/**
 Purpose of this BackgroundWorker is to store and execute requests that deals 
 with communicating with the server in the background. Such as uploading, downloading 
 images, upload profile image changes, upload profile data change and etc.
 */
@interface BackgroundWorker : NSObject

@property (nonatomic, weak) SyncManager *syncManager;
@property (nonatomic, weak) id <AuthenticationService> authenticationService;
@property (nonatomic, weak) UserManager *userManager;

/*
 This must be called before this Worker does anything, usually when logged in.
 Also will load all queued tasks from User Defaults
 */
-(void)activeWorker;

/*
 This must be called before when the user logs off,
 Also will also remove all tasks in the queue
 */
-(void)deactiveWorker;

/*
 When this is called by the appDelegate,
 the worker will run all queued tasks if it has been at least 1 hour since last update
 */
-(void)appIsActive;

/*
 Add the task of selected type to BackgroundWorker's queue of tasks,
 that will be executed a sufficient time has passed and 'appIsActive' is called
 
 The queue does not contain duplicate tasks.
 */
-(void)addTaskToQueue:(NSUInteger)taskType;

@end
