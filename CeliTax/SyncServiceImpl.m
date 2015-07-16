//
//  SyncServiceImpl.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SyncServiceImpl.h"
#import "UserDataDAO.h"
#import "Receipt.h"
#import "Utils.h"

@implementation SyncServiceImpl

#define kKeyLastUpdatedDateTime        @"LastUpdatedDateTime"
#define kKeyHashString                 @"HashString"

-(BOOL)needToBackUp
{
    NSDictionary *data = [self.userDataDAO generateJSONToUploadToServer];
    
    for (NSArray *array in data.allValues)
    {
        if (array.count)
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSDate *) getLastBackUpDate
{
    return [self.userDataDAO getLastUploadDate];
}

- (void) startSyncingUserData: (SyncingSuccessBlock) success
                      failure: (SyncingFailureBlock) failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //simulate 3 seconds wait
        [NSThread sleepForTimeInterval:3.0f];
        
        NSString *userKey = self.userDataDAO.userKey;
        
        NSDictionary *data = [self.userDataDAO generateJSONToUploadToServer];
        
        if (userKey && data)
        {
            //produce some fake data
            NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
            gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *dateStringFromServer = [gmtDateFormatter stringFromDate:[NSDate date]];
            
            //change the local UserData.lastUploadedDate to the one we received from server
            NSDate *dateFromServer = [gmtDateFormatter dateFromString:dateStringFromServer];
            [self.userDataDAO setLastUploadDate:dateFromServer];
            
            [self.userDataDAO setAllDataToDateActionNone];
            
            [self.userDataDAO saveUserData];
            
            //FAKE DATA
            NSString *hashStringFromServer = @"ABC123";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 NSDictionary *lastestDataInfo = [[NSDictionary alloc] initWithObjectsAndKeys:dateFromServer,kKeyLastUpdatedDateTime,hashStringFromServer,kKeyHashString, nil];
                
                success ( lastestDataInfo );
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ( @"uploadUserData failed" );
            });
        }
    });
    
    return;
}

- (void) getLastestServerDataInfo: (GetLastestServerDataInfoSuccessBlock) success
                          failure: (GetLastestServerDataInfoFailureBlock) failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //simulate 3 seconds wait
        [NSThread sleepForTimeInterval:3.0f];
        
        NSString *userKey = self.userDataDAO.userKey;
        
        NSDictionary *data = [self.userDataDAO generateJSONToUploadToServer];
        
        if (userKey && data)
        {
            //produce fake data
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *calendarComponents = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitWeekday) fromDate: [NSDate date]];
            
            NSInteger dayOfYear = [calendarComponents day];
            
            if (dayOfYear > 1)
            {
                dayOfYear = dayOfYear - 1;
            }
            
            [calendarComponents setDay: dayOfYear];
            
            [calendarComponents setCalendar: calendar];  // Must do this before calling [NSDateComponents date]
            
            NSDate *yesterday = [calendarComponents date];
            
            //convert [NSDate date] to string
            NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
            gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *yesterdayDateString = [gmtDateFormatter stringFromDate:yesterday];
            
            //FAKE DATA
            NSDate *dateFromServer = [gmtDateFormatter dateFromString:yesterdayDateString];
            
            //FAKE DATA
            NSString *hashStringFromServer = @"ABC123";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *lastestDataInfo = [[NSDictionary alloc] initWithObjectsAndKeys:dateFromServer,kKeyLastUpdatedDateTime,hashStringFromServer, nil];
                
                success ( lastestDataInfo );
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ( @"getLastestServerDataInfo failed" );
            });
        }
    });
    
    return;
}

- (void) getFilesNeedToUpload: (GetListOfFilesNeedUploadSuccessBlock) success
                      failure: (GetListOfFilesNeedUploadFailureBlock) failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //simulate 3 seconds wait
        [NSThread sleepForTimeInterval:3.0f];
        
        NSMutableArray *filenamesToUpload = [NSMutableArray new];
        
        NSArray *receipts = [self.userDataDAO getReceipts];
        
        for (Receipt *receipt in receipts)
        {
            for (NSString *filename in receipt.fileNames)
            {
                [filenamesToUpload addObject:filename];
            }
        }
        
        success (filenamesToUpload);
    });
    
    return;
}

-(void) uploadFile:(NSString *)filename andData:(NSData *)data success:(FileUploadSuccessBlock) success
           failure: (FileUploadFailureBlock) failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [Utils readImageWithFileName:filename forUser:self.userDataDAO.userKey];
        
        if (!image)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ( @"uploadUserData failed" );
            });
            
            return ;
        }
        
        NSData *dataToUpload = UIImageJPEGRepresentation(image, 0.9);
        
        //simulate 5 seconds wait
        [NSThread sleepForTimeInterval:5.0f];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success ();
        });
    });
    
    return;
}

@end
