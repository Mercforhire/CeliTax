//
//  BackgroundWorker.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BackgroundWorker.h"
#import "UserManager.h"

@interface BackgroundWorker ()

@property (nonatomic, strong) NSMutableArray *pendingTasks;

@end

@implementation BackgroundWorker

- (instancetype) init
{
    if (self = [super init])
    {
        //Load pending Tasks from User Defaults
        ///TODO:
        //...
    }
    
    return self;
}

-(void)addTask:(NSInteger)task
{
    NSNumber *taskToAdd = [NSNumber numberWithInteger:task];
    
    if (![self.pendingTasks containsObject:taskToAdd])
    {
        [self.pendingTasks addObject:taskToAdd];
    }
}

-(void)removeAllTasks
{
    [self.pendingTasks removeAllObjects];
}

-(BOOL)hasTasks
{
    return (self.pendingTasks.count > 0);
}

@end
