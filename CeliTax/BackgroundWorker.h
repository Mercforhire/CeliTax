//
//  BackgroundWorker.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SyncManager;

/**
 Add tasks to this worker that will be executed when a Internet connection is detected
 */
@interface BackgroundWorker : NSObject

@property (nonatomic, weak) SyncManager *syncManager;

/*
 This must be called before this Worker does anything
 */
-(void)activeWorker;

-(void)deactiveWorker;

/*
 When this is called by the appDelegate,
 the worker will run all queued tasks if it has been at least 1 hour since last update
 */
-(void)appIsActive;

@end
