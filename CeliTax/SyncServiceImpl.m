//
//  SyncServiceImpl.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SyncServiceImpl.h"
#import "UserDataDAO.h"
#import "Utils.h"
#import "NetworkCommunicator.h"
#import "RecordsDAO.h"
#import "TaxYearsDAO.h"
#import "ReceiptsDAO.h"
#import "CatagoriesDAO.h"

#import "CeliTax-Swift.h"

@implementation SyncServiceImpl

#define kKeyLastUpdatedDateTime        @"LastUpdatedDateTime"
#define kKeyHashString                 @"HashString"

- (void) loadDemoData:(GenerateDemoDataCompleteBlock) complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^() {
        if (![self.taxYearsDAO loadAllTaxYears].count)
        {
            [self.taxYearsDAO addTaxYear:2013 save:NO];
            [self.taxYearsDAO addTaxYear:2014 save:NO];
            [self.taxYearsDAO addTaxYear:2015 save:NO];
        }
        
        if (![self.catagoriesDAO loadCatagories].count)
        {
            [self.catagoriesDAO addCatagoryForName: @"Rice" andColor: [UIColor yellowColor] save:NO];
            
            [self.catagoriesDAO addCatagoryForName: @"Bread" andColor: [UIColor orangeColor] save:NO];
            
            [self.catagoriesDAO addCatagoryForName: @"Meat" andColor: [UIColor redColor] save:NO];
            
            [self.catagoriesDAO addCatagoryForName: @"Flour" andColor: [UIColor lightGrayColor] save:NO];
            
            [self.catagoriesDAO addCatagoryForName: @"Cake" andColor: [UIColor purpleColor] save:NO];
            
            //Give all Categories a random Unit Item national average amount
            NSArray *allCategories = [self.catagoriesDAO loadCatagories];
            
             //Pick 3 random catagories and give them a random national average amount for at least one other Unit
            NSMutableArray *indexesOf3ChoosenCategories = [NSMutableArray new];
            
            int i = 0;
            
            while (i < 2)
            {
                NSNumber *randomIndex = @([Utils randomNumberBetween: 0 maxNumber: (int)allCategories.count - 1]);
                
                if (![indexesOf3ChoosenCategories containsObject:randomIndex])
                {
                    [indexesOf3ChoosenCategories addObject:randomIndex];
                    
                    i++;
                }
            }
            
            for (ItemCategory *category in allCategories)
            {
                NSNumber *indexOfCatagory = [NSNumber numberWithInteger:[allCategories indexOfObject:category]];
                
                if ([indexesOf3ChoosenCategories containsObject:indexOfCatagory])
                {
                    for (int j = UnitTypesUnitItem; j < UnitTypesUnitCount; j++)
                    {
                        //50% Chance of adding a National Average Cost for the current Unit Type
                        if ([Utils randomNumberBetween: 1 maxNumber: 10] <= 5)
                        {
                            [category addOrUpdateNationalAverageCostForUnitType:j amount:[Utils randomNumberBetween: 10 maxNumber: 100] / 10.0f];
                        }
                    }
                }
            }
        }
        
        UIImage *testImage1 = [UIImage imageNamed: @"ReceiptPic-1.jpg"];
        UIImage *testImage2 = [UIImage imageNamed: @"ReceiptPic-2.jpg"];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        
        NSInteger numberOfCatagories = [self.catagoriesDAO loadCatagories].count;
        
        NSDate *currentTime = [[NSDate alloc] init];
        
        // add random receipts
        for (int receiptNumber = 0; receiptNumber < 10; receiptNumber++)
        {
            NSString *fileName1 = [NSString stringWithFormat: @"Receipt-%@-%d", [Utils generateUniqueID], 1];
            NSString *fileName2 = [NSString stringWithFormat: @"Receipt-%@-%d", [Utils generateUniqueID], 2];
            
            [Utils saveImage: testImage1 withFilename: fileName1 forUser: self.userDataDAO.userKey];
            [Utils saveImage: testImage2 withFilename: fileName2 forUser: self.userDataDAO.userKey];
            
            components.day = [Utils randomNumberBetween: 1 maxNumber: 28];
            components.month = [Utils randomNumberBetween: 1 maxNumber: 12];
            components.year = [Utils randomNumberBetween: 2013 maxNumber: 2015];
            components.hour = [Utils randomNumberBetween: 0 maxNumber: 23];
            components.minute = [Utils randomNumberBetween: 0 maxNumber: 59];
            
            NSDate *date = [calendar dateFromComponents: components];
            
            if ([date laterDate: currentTime] == date)
            {
                continue;
            }
            
            Receipt *newReceipt = [Receipt new];
            
            newReceipt.localID = [Utils generateUniqueID];
            newReceipt.fileNames = [NSMutableArray arrayWithObjects: fileName1, fileName2, nil];
            newReceipt.dateCreated = date;
            newReceipt.taxYear = [Utils randomNumberBetween: 2013 maxNumber: 2015];
            newReceipt.dataAction = DataActionStatusDataActionInsert;
            
            [self.receiptsDAO addReceipt: newReceipt save:NO];
            
            // add random items for each receipt
            int numberOfItems = [Utils randomNumberBetween: 1 maxNumber: 10];
            
            for (int itemNumber = 0; itemNumber < numberOfItems; itemNumber++)
            {
                ItemCategory *recordCatagory = [self.catagoriesDAO loadCatagories][[Utils randomNumberBetween: 0 maxNumber: (int)numberOfCatagories - 1]];
                
                NSInteger recordQuantity = [Utils randomNumberBetween: 1 maxNumber: 20];
                
                NSInteger recordUnitType = [Utils randomNumberBetween: UnitTypesUnitItem maxNumber: UnitTypesUnitLb];
                
                float recordAmount = [Utils randomNumberBetween: 10 maxNumber: 100] / 10.0f;
                
                [self.recordsDAO addRecordForCatagory: recordCatagory
                                           andReceipt: newReceipt
                                          forQuantity: recordQuantity
                                               orUnit: recordUnitType
                                            forAmount: recordAmount
                                                 save: NO];
            }
        }
        
        [self.userDataDAO saveUserData];
        
        dispatch_async(dispatch_get_main_queue(), ^()
           {
               complete();
           });
    });
}

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
    return [self.userDataDAO getLastBackUpDate];
}

- (NSString *) getLocalDataBatchID
{
    return [self.userDataDAO getLastestDataHash];
}

- (void) startSyncingUserData: (SyncingSuccessBlock) success
                      failure: (SyncingFailureBlock) failure
{
    NSDictionary *dictionary = [self.userDataDAO generateJSONToUploadToServer];
    
    NSData *dictionaryData = [NSJSONSerialization dataWithJSONObject: dictionary
                                                             options: NSJSONWritingPrettyPrinted
                                                               error: nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:dictionaryData encoding:NSUTF8StringEncoding];
    
    //DUMP:
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: @"Upload.json"];
//    
//    if ([fileManager fileExistsAtPath: filePath])
//    {
//        [fileManager removeItemAtPath: filePath error: nil];
//    }
//
//    [dictionaryData writeToFile: filePath options: 0 error: nil];
//    
//    DLog(@"Dumped upload JSON to : \n %@", filePath);
    //END DUMP:
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       jsonString,@"data"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"upload"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeURL;
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        NSDate *dateUploaded = [NSDate new];
        
        [self.userDataDAO setLastBackUpDate:dateUploaded];
        
        [self.userDataDAO setLastestDataHash:response[@"batchID"]];
        
        [self.userDataDAO resetAllDataActionsAndClearOutDeletedOnes];
        
        [self.userDataDAO saveUserData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                success ( dateUploaded );
            }
            
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

-(void) downloadUserData: (DownloadDataSuccessBlock) success
                 failure: (DownloadDataFailureBlock) failure
{
    MKNetworkOperation *networkOperation = [self.networkCommunicator getRequestToServer:[WEB_API_FILE stringByAppendingPathComponent:@"download"]];
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( response[@"error"] && [response[@"error"] boolValue] == NO )
        {
            NSDictionary *dataDictionary = response[@"data"];
            
            //First merge the Tax Years
            
            NSArray *taxYearNumbers = dataDictionary[@"TaxYears"];
            
            NSMutableArray *taxYears = [NSMutableArray new];
            
            for (NSNumber *taxYearNumber in taxYearNumbers)
            {
                TaxYear *taxYear = [self.taxYearBuilder buildTaxYearFrom:taxYearNumber.integerValue];
                
                if (taxYear)
                {
                    [taxYears addObject:taxYear];
                }
            }
            
            [self.taxYearsDAO mergeWith:taxYears save:NO];
            
            //Second merge the Catagories
            
            NSArray *catagoryDictionaries = dataDictionary[@"Catagories"];
            
            NSMutableArray *catagories = [NSMutableArray new];
            
            for (NSDictionary *catagoryDictionary in catagoryDictionaries)
            {
                ItemCategory *category = [self.catagoryBuilder buildCategoryFrom:catagoryDictionary];
                
                if (category)
                {
                    [catagories addObject:category];
                }
            }
            
            [self.catagoriesDAO mergeWith:catagories save:NO];
            
            //Third the receipts
            
            NSArray *receiptDictionaries = dataDictionary[@"Receipts"];
            
            NSMutableArray *receipts = [NSMutableArray new];
            
            for (NSDictionary *receiptDictionary in receiptDictionaries)
            {
                Receipt *receipt = [self.receiptBuilder buildReceiptFrom:receiptDictionary];
                
                if (receipt)
                {
                    [receipts addObject:receipt];
                }
            }
            
            [self.receiptsDAO mergeWith:receipts save:NO];
            
            //Lastly, the records
            
            NSArray *recordDictionaries = dataDictionary[@"Records"];
            
            NSMutableArray *records = [NSMutableArray new];
            
            for (NSDictionary *recordDictionary in recordDictionaries)
            {
                Record *record = [self.recordBuilder buildRecordFrom:recordDictionary];
                
                //check if catagoryID is valid
                
                if (![self.catagoriesDAO loadCatagory:record.catagoryID])
                {
                    DLog(@"ERROR: Record has an invalid catagoryID");
                    record.dataAction = DataActionStatusDataActionDelete;
                }
                
                //check if receiptID is valid
                if (![self.receiptsDAO loadReceipt:record.receiptID])
                {
                    DLog(@"ERROR: Record has an invalid receiptID");
                    record.dataAction = DataActionStatusDataActionDelete;
                }
                
                if (record)
                {
                    [records addObject:record];
                }
            }
            
            [self.recordsDAO mergeWith:records save:NO];
            
            [self.userDataDAO setLastestDataHash:response[@"batchID"]];
            
            [self.userDataDAO saveUserData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success)
                {
                    success ( );
                }
                
            });
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (failure)
                {
                    failure ( USER_NO_DATA );
                }
                
            });
        }
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) getLastestServerDataBatchID: (GetLastestServerDataInfoSuccessBlock) success
                             failure: (GetLastestServerDataInfoFailureBlock) failure
{
    MKNetworkOperation *networkOperation = [self.networkCommunicator getRequestToServer:[WEB_API_FILE stringByAppendingPathComponent:@"data_batchid"]];
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        NSString *batchID = response[@"batchID"];
        
        if ( response[@"error"] && [response[@"error"] boolValue] == NO)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success)
                {
                    success ( batchID );
                }
                
            });
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (failure)
                {
                    failure ( USER_NO_DATA );
                }
                
            });
        }
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) getFilesNeedToUpload: (GetListOfFilesNeedUploadSuccessBlock) success
                      failure: (GetListOfFilesNeedUploadFailureBlock) failure
{
    MKNetworkOperation *networkOperation = [self.networkCommunicator getRequestToServer:[WEB_API_FILE stringByAppendingPathComponent:@"get_files_need_upload"]];
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        NSArray *filesnamesToUpload = response[@"files_need_upload"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                success ( filesnamesToUpload );
            }
            
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

-(void) uploadFile:(NSString *)filename andData:(NSData *)data success:(FileUploadSuccessBlock) success
           failure: (FileUploadFailureBlock) failure
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       filename,@"filename"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"upload_photo"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    //used for server temp storage file name. Not important
    NSString *fileNameWithExtension = [NSString stringWithFormat:@"%@.jpg",filename];
    
    [networkOperation addData:data forKey:@"photos" mimeType:@"image/jpeg" fileName:fileNameWithExtension];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                success ( );
            }
            
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
            
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) downloadFileFromURL: (NSString *)url
                      toPath: (NSString *)filePath
                     success: (FileDownloadSuccessBlock) success
                     failure: (FileDownloadFailureBlock) failure
{
    MKNetworkOperation *networkOperation = [self.networkCommunicator downloadFileFrom:url toFile:filePath];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                DLog(@"Downloaded image from %@", url);
                success ( );
            }
            
        });
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                DLog(@"Failed to download image from %@", url);
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
}

- (void) downloadFile: (NSString *)filename
              success: (FileDownloadSuccessBlock) success
              failure: (FileDownloadFailureBlock) failure
{
    // 1.get the URL of the image first
    
    NSString *filePath = [Utils getFilePathForImage:filename forUser: self.userDataDAO.userKey];
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       filename,@"filename"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path:[WEB_API_FILE stringByAppendingPathComponent:@"request_file_url"]];
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        NSString *url = response[@"url"];
        
        if ( response[@"error"] && [response[@"error"] boolValue] == NO && url)
        {
            // 2.start downloading the image from the url
            DLog(@"Received URL of image: %@", url);
            [self downloadFileFromURL:url toPath:filePath success:success failure:failure];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (failure)
                {
                    DLog(@"Failed to get URL of image: %@", filename);
                    failure ( RECEIPT_IMAGE_FILE_NO_LONGER_EXIST );
                }
                
            });
        }
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
            
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (NSArray *) getListOfFilesToDownload
{
    NSMutableArray *allFilenames = [NSMutableArray new];
    
    NSArray *allReceipts = [self.receiptsDAO loadAllReceipts];
    
    for (Receipt *receipt in allReceipts)
    {
        [allFilenames addObjectsFromArray:receipt.fileNames];
    }
    
    NSMutableArray *filesNeedToDownload = [NSMutableArray new];
    
    //check which file in allFilenames doesn't exist
    for (NSString *filename in allFilenames)
    {
        if (![Utils imageWithFileNameExist:filename forUser:self.userDataDAO.userKey])
        {
            [filesNeedToDownload addObject:filename];
        }
    }
    
    return filesNeedToDownload;
}

- (void) cleanUpReceiptImages
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^() {
        
        //1. Get all names of files we should keep
        NSMutableArray *allFilenames = [NSMutableArray new];
        
        NSArray *allReceipts = [self.receiptsDAO loadAllReceipts];
        
        for (Receipt *receipt in allReceipts)
        {
            [allFilenames addObjectsFromArray:receipt.fileNames];
        }
        
        //2. Get names of all files that exist
        NSArray *existingFilenames = [Utils getImageFilenamesForUser:self.userDataDAO.userKey];
        
        //3. Check if each existing file also exist in the list of files those we should keep
        for (NSString *existingFilename in existingFilenames)
        {
            if (![allFilenames containsObject:existingFilename])
            {
                //delete this file
                [Utils deleteImageWithFileName:existingFilename forUser:self.userDataDAO.userKey];
            }
        }
        
    });
};

@end
