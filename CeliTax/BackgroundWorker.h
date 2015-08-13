//
//  BackgroundWorker.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TaskRemoveProfileImage,
    TaskUpdateUserProfile,
    TaskUpdateProfileImage,
    TaskQuickUpdate
} TaskTypes;

@class UserManager, SyncManager;

/**
 Add tasks to this worker that will be executed when a Internet connection is detected
 */
@interface BackgroundWorker : NSObject

@property (nonatomic, weak) UserManager *userManager;

@property (nonatomic, weak) SyncManager *syncManager;

/*
 Add a task to be executed on the next cycle
 */
-(void)addTask:(NSInteger)task;

/*
 Remove all tasks
 */
-(void)removeAllTasks;

/*
 Has unfinished Tasks
 */
-(BOOL)hasTasks;

///TODO: Add functions
//...

@end
