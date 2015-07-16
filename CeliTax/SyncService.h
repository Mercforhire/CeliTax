//
//  SyncService.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-12.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserDataDAO;

typedef void (^SyncingSuccessBlock) (NSDictionary *lastestDataInfo);
typedef void (^SyncingFailureBlock) (NSString *reason);

typedef void (^GetLastestServerDataInfoSuccessBlock) (NSDictionary *lastestDataInfo);
typedef void (^GetLastestServerDataInfoFailureBlock) (NSString *reason);

typedef void (^GetListOfFilesNeedUploadSuccessBlock) (NSArray *filesnamesToUpload);
typedef void (^GetListOfFilesNeedUploadFailureBlock) (NSString *reason);

typedef void (^FileUploadSuccessBlock) ();
typedef void (^FileUploadFailureBlock) (NSString *reason);

@protocol SyncService <NSObject>

@property (nonatomic, strong) UserDataDAO *userDataDAO;

/*
 Check to see if local data has a non-0 dataAction
 */
-(BOOL)needToBackUp;

/*
 Get the date of last successful sync with server
 */
- (NSDate *) getLastBackUpDate;

/*
 Upload the UserData from app to server, and expect a NSDictionary
 containing the Date/Time of this upload and hash string of data just uploaded
 */
- (void) startSyncingUserData: (SyncingSuccessBlock) success
                      failure: (SyncingFailureBlock) failure;

/*
 Ask the server for the Date/Time of its most recent update and hash string of the data
 */
- (void) getLastestServerDataInfo: (GetLastestServerDataInfoSuccessBlock) success
                          failure: (GetLastestServerDataInfoFailureBlock) failure;

/*
 Assuming the server has the same data as the device
 Ask the server for a list of filenames that it doesn't have, but exists on the device.
 Using the data from UserData.receipts.fileNames
 */
- (void) getFilesNeedToUpload: (GetListOfFilesNeedUploadSuccessBlock) success
                      failure: (GetListOfFilesNeedUploadFailureBlock) failure;

/*
 Upload the given file with the given filename for the currently logged in user
 */
-(void) uploadFile: (NSString *)filename
           andData: (NSData *)data
           success: (FileUploadSuccessBlock) success
           failure: (FileUploadFailureBlock) failure;


@end
