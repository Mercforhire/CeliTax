//
//  BackgroundWorker.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BackgroundWorker.h"
#import "SyncManager.h"

#define kLastTimeDateKey              @"LastTimeDateKey"

@interface BackgroundWorker ()

@property (nonatomic,strong) NSUserDefaults *defaults;

@property (nonatomic) BOOL active;

@property (nonatomic, strong) NSDate *lastTimeDate;

@end

@implementation BackgroundWorker

- (instancetype) init
{
    if (self = [super init])
    {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

-(void)activeWorker
{
    self.active = YES;
}

-(void)deactiveWorker
{
    self.active = NO;
}

-(void)syncIfNeccessary
{
    if ([self.syncManager needToBackUp])
    {
        [self.syncManager startSync:^(NSDate *syncDate) {
            
            DLog(@"Automatic syncing success!");
            [self.defaults setValue:syncDate forKey:kLastTimeDateKey];
            
            [self.defaults synchronize];
            
            [self.syncManager startUploadingPhotos];
            
        } failure:^(NSString *reason) {
            
            DLog(@"Error: automatic syncing failed. Reason: %@", reason);
            
        }];
    }
    else
    {
        DLog(@"No need to sync, data unchanged.");
        
        [self.syncManager startUploadingPhotos];
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
            [self syncIfNeccessary];
        }
        else
        {
            double minutes = fabs( [lastRefresh timeIntervalSinceNow] / 60 );
            
            if (minutes > 5)
            {
                [self syncIfNeccessary];
            }
            else
            {
                DLog(@"Only %ld minutes since last sync, not needed again", (long)minutes);
            }
        }
    }
}

@end
