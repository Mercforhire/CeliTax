//
//  BackgroundWorker.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BackgroundWorker.h"
#import "SyncManager.h"
#import "AuthenticationService.h"
#import "UserManager.h"
#import "User.h"

#define kLastTimeDateKey                @"LastTimeDateKey"
#define kQueuedTasksKey                 @"QueuedTasksKey"

@interface BackgroundWorker ()

@property (nonatomic, strong) NSUserDefaults *defaults;

@property (nonatomic) BOOL active;

@property (nonatomic) NSInteger currentTaskIndex;

//Data that are persistent in User Defaults:
@property (nonatomic, strong) NSDate *lastTimeDate;
@property (nonatomic, strong) NSMutableArray *queuedTasks;

@end

@implementation BackgroundWorker

- (instancetype) init
{
    if (self = [super init])
    {
        _defaults = [NSUserDefaults standardUserDefaults];
        _queuedTasks = [NSMutableArray new];
    }
    
    return self;
}

-(void)activeWorker
{
    self.active = YES;
    
    //load previously queued tasks
    NSArray *queuedTasks = [self.defaults objectForKey:kQueuedTasksKey];
    
    if (queuedTasks)
    {
        self.queuedTasks = [[NSMutableArray alloc] initWithArray: queuedTasks copyItems: NO];
    }
}

-(void)deactiveWorker
{
    self.active = NO;
    
    //delete any persistent data
    [self.defaults removeObjectForKey:kLastTimeDateKey];
    [self.defaults removeObjectForKey:kQueuedTasksKey];
    
    [self.defaults synchronize];
    
    //stop all network operations
    [self.syncManager cancelAllOperations];
}

-(void)executeTasks
{
    if (self.currentTaskIndex < self.queuedTasks.count)
    {
        NSNumber *currentTask = [self.queuedTasks objectAtIndex:self.currentTaskIndex];
        
        switch (currentTask.integerValue)
        {
            case QueueTaskUploadData:
            {
                if ([self.syncManager needToBackUp])
                {
                    [self.syncManager startSync:^(NSDate *syncDate) {
                        
                        DLog(@"Automatic syncing success!");
                        
                        //Add a upload photos task
                        [self addTaskToQueue:QueueTaskUploadPhotos];
                        
                        //Go on to next task
                        self.currentTaskIndex++;
                        
                        [self executeTasks];
                        
                    } failure:^(NSString *reason) {
                        
                        DLog(@"Error: Syncing Task failed. Reason: %@", reason);
                        
                        //Halting running tasks
                    }];
                }
                else
                {
                    DLog(@"No need to sync, data unchanged.");
                    
                    //Add a upload photos task
                    [self addTaskToQueue:QueueTaskUploadPhotos];
                    
                    //Go on to next task
                    self.currentTaskIndex++;
                    
                    [self executeTasks];
                }
            }
                break;
                
            case QueueTaskUploadPhotos:
            {
                [self.syncManager startUploadingPhotos:^{
                    
                    //Go on to next task
                    self.currentTaskIndex++;
                    
                    [self executeTasks];
                    
                } failure:^(NSString *reason) {
                    
                    DLog(@"Error: Uploading Receipt Task failed. Reason: %@", reason);
                    
                    //Halting running tasks
                    
                }];
            }
                break;
                
            case QueueTaskUpdateProfileImage:
            {
                if ([self.userManager doesUserHaveCustomProfileImage])
                {
                    [self.authenticationService updateProfileImage:self.userManager.user.avatarImage success:^{
                        
                        //Go on to next task
                        self.currentTaskIndex++;
                        
                        [self executeTasks];
                        
                    } failure:^(NSString *reason) {
                        
                        DLog(@"Error: Update Profile Image Task failed. Reason: %@", reason);
                        
                        //Halting running tasks
                        
                    }];
                }
                else
                {
                    [self.authenticationService deleteProfileImage:^{
                        
                        //Go on to next task
                        self.currentTaskIndex++;
                        
                        [self executeTasks];
                        
                    } failure:^(NSString *reason) {
                        
                        DLog(@"Error: Update Profile Image Task failed. Reason: %@", reason);
                        
                        //Halting running tasks
                        
                    }];
                }
            }
                break;
                
            case QueueTaskUploadProfileData:
            {
                if (self.userManager.user)
                {
                    [self.authenticationService updateAccountInfo: self.userManager.user.firstname
                                                     withLastname: self.userManager.user.lastname
                                                      withCountry:self.userManager.user.country
                                                          success:^{
                                                              
                                                              //Go on to next task
                                                              self.currentTaskIndex++;
                                                              
                                                              [self executeTasks];
                                                              
                                                          } failure:^(NSString *reason) {
                                                              
                                                              DLog(@"Error: Uploading Receipt Task failed. Reason: %@",reason);
                                                              
                                                              //Halting running tasks
                                                              
                                                          }];
                }
                else
                {
                    DLog(@"Error: Uploading Receipt Task failed. Reason: No current user");
                    
                    //Halting running tasks
                }
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        DLog(@"No more tasks to execute");
        
        self.currentTaskIndex = 0;
        
        [self.queuedTasks removeAllObjects];
        
        [self.defaults removeObjectForKey:kQueuedTasksKey];
        
        [self.defaults setObject:[NSDate date] forKey:kLastTimeDateKey];
        
        [self.defaults synchronize];
    }
}

-(void)appIsActive
{
    if (self.active)
    {
        DLog(@"Received notification that the app is active");
        
        NSDate *lastRefresh = [self.defaults valueForKey:kLastTimeDateKey];
        
        if (!lastRefresh)
        {
            [self addTaskToQueue:QueueTaskUploadData];
            
            [self executeTasks];
        }
        else
        {
            double minutes = fabs( [lastRefresh timeIntervalSinceNow] / 60 );
            
            if (minutes > 10)
            {
                [self addTaskToQueue:QueueTaskUploadData];
                
                [self executeTasks];
            }
            else
            {
                DLog(@"Only %ld minutes since last sync, not needed again", (long)minutes);
            }
        }
    }
}

-(void)addTaskToQueue:(NSUInteger)taskType
{
    NSNumber *task = [NSNumber numberWithInteger:taskType];
    
    if (![self.queuedTasks containsObject:task])
    {
        [self.queuedTasks addObject:task];
        
        [self.defaults setObject:self.queuedTasks forKey:kQueuedTasksKey];
        
        [self.defaults synchronize];
    }
}

@end
