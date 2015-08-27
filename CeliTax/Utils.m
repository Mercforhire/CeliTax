//
// Utils.m
// CeliTax
//
// Created by Leon Chen on 2015-04-30.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Utils.h"
#import "SideMenuView.h"
#import "User.h"

@implementation Utils

+ (id) unarchiveFile: (NSString *) path
{
    id archive = nil;

    @try {
        archive = [NSKeyedUnarchiver unarchiveObjectWithFile: path];

        DLog(@"File read from path %@", path);
    }
    @catch (NSException *exception)
    {
        DLog(@"Unable to unarchive file %@: %@", path, [exception reason]);

        if ([[NSFileManager defaultManager] fileExistsAtPath: path])
        {
            [[NSFileManager defaultManager] removeItemAtPath: path error: nil];
        }
    }

    return archive;
}

+ (BOOL) archiveFile: (id) objectToArchive toFile: (NSString *) path
{
    @try {
        NSString *pathOnly = [path stringByDeletingLastPathComponent];

        if (![[NSFileManager defaultManager] fileExistsAtPath: pathOnly])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath: pathOnly withIntermediateDirectories: YES attributes: nil error: nil];
        }

        [NSKeyedArchiver archiveRootObject: objectToArchive toFile: path];

        DLog(@"File saved to %@", path);

        return YES;
    }
    @catch (NSException *exception)
    {
        DLog(@"Unable to unarchive file %@: %@", path, [exception reason]);

        if ([[NSFileManager defaultManager] fileExistsAtPath: path])
        {
            [[NSFileManager defaultManager] removeItemAtPath: path error: nil];
        }

        return NO;
    }
}

+ (NSString *) getSavedProfilePath
{
    NSString *storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *profileFilePath = [storagePath stringByAppendingPathComponent: @"USER.acc"];
    
    return profileFilePath;
}

+ (User *) loadSavedUser
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *profilePath = [self getSavedProfilePath];
    
    if ([fileManager fileExistsAtPath: profilePath])
    {
        User *savedUser = [self unarchiveFile:profilePath];
        
        return savedUser;
    }
    
    return nil;
}

+ (BOOL) saveUser:(User *)user
{
    if (!user)
    {
        return NO;
    }
    
    NSString *profilePath = [self getSavedProfilePath];
    
    if ([Utils archiveFile: user toFile: profilePath])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL) deleteSavedUser
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *profilePath = [self getSavedProfilePath];
    
    if ([fileManager fileExistsAtPath: profilePath])
    {
        [fileManager removeItemAtPath: profilePath error: nil];
        
        return YES;
    }
    
    return NO;
}

+ (NSString *) getProfileImagePathForUser: (NSString *) userKey
{
    NSString *storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *imageFilePath = [storagePath stringByAppendingPathComponent: [NSString stringWithFormat: @"PROFILE_IMAGE-%ld.jpg",(unsigned long)[userKey hash]]];
    
    return imageFilePath;
}

+ (UIImage *) readProfileImageForUser: (NSString *) userKey
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imageFilePath = [self getProfileImagePathForUser:userKey];
    
    if (![fileManager fileExistsAtPath: imageFilePath])
    {
        return nil;
    }
    
    // get the NSData from UIImage
    NSData *imageData = [NSData dataWithContentsOfFile: imageFilePath];

    UIImage *image = [UIImage imageWithData: imageData];
    
    return image;
}

+ (void) setProfileImageForUser: (NSString *) userKey image:(UIImage *)image
{
    if (image == nil)
    {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *profileImageFilePath = [self getProfileImagePathForUser:userKey];
    
    // delete the old file if it exists
    if ([fileManager fileExistsAtPath: profileImageFilePath])
    {
        [fileManager removeItemAtPath: profileImageFilePath error: nil];
    }
    
    // get the NSData from UIIMage
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
    
    DLog(@"Saving to file: %@", profileImageFilePath);
    
    [imageData writeToFile: profileImageFilePath atomically: YES];
}

+ (void) deleteProfileImageForUser: (NSString *) userKey
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imageFilePath = [self getProfileImagePathForUser:userKey];
    
    if ([fileManager fileExistsAtPath: imageFilePath])
    {
        DLog(@"Deleting file: %@", imageFilePath);
        
        [fileManager removeItemAtPath: imageFilePath error: nil];
    }
}

+ (NSString *) getImageStorageFolderPathForUser: (NSString *) userKey
{
    NSString *storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSString *imageFolderName = [NSString stringWithFormat: @"/Images-%ld", (unsigned long)[userKey hash]];

    NSString *imageFolderPath = [storagePath stringByAppendingString: imageFolderName];

    return imageFolderPath;
}

+ (NSString *) getFilePathForImage: (NSString *) fileName forUser: (NSString *) userKey
{
    NSString *imageFolderPath = [self getImageStorageFolderPathForUser: userKey];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: imageFolderPath])
    {
        [fileManager createDirectoryAtPath: imageFolderPath withIntermediateDirectories: YES attributes: nil error: nil];
    }
    
    NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.jpg", fileName]];
    
    return imageFilePath;
}

+ (NSString *) saveImage: (UIImage *) image withFilename: (NSString *) filename forUser: (NSString *) userKey
{
    if (image == nil || filename == nil)
    {
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *imageFolderPath = [self getImageStorageFolderPathForUser: userKey];

    if (![fileManager fileExistsAtPath: imageFolderPath])
    {
        [fileManager createDirectoryAtPath: imageFolderPath withIntermediateDirectories: YES attributes: nil error: nil];
    }

    NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.jpg", filename]];

    // delete the old file if it exists
    if ([fileManager fileExistsAtPath: imageFilePath])
    {
        [fileManager removeItemAtPath: imageFilePath error: nil];
    }

    // get the NSData from UIIMage
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
    [imageData writeToFile: imageFilePath atomically: YES];

    DLog(@"Saving to file: %@", imageFilePath);
    
    return imageFilePath;
}

+ (NSData *) readImageDataWithFileName: (NSString *) filename forUser: (NSString *) userKey
{
    if (filename == nil)
    {
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imageFolderPath = [self getImageStorageFolderPathForUser: userKey];
    
    NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.jpg", filename]];
    
    if (![fileManager fileExistsAtPath: imageFilePath])
    {
        return nil;
    }
    
    // get the NSData from UIImage
    NSData *imageData = [NSData dataWithContentsOfFile: imageFilePath];
    
    return imageData;
}

+ (UIImage *) readImageWithFileName: (NSString *) filename forUser: (NSString *) userKey
{
    // get the NSData first
    NSData *imageData = [self readImageDataWithFileName:filename forUser:userKey];

    UIImage *image = [UIImage imageWithData: imageData];

    return image;
}

+ (BOOL) deleteAllPhotosforUser: (NSString *) userKey
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *imageFolderPath = [self getImageStorageFolderPathForUser: userKey];

    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath: imageFolderPath];

    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [imageFolderPath stringByAppendingPathComponent: fileName];
        
        DLog(@"Deleting file: %@", filePath);
        
        if (![fileManager removeItemAtPath: filePath error: nil])
        {
            return NO;
        }
    }

    return YES;
}

+ (BOOL) imageWithFileNameExist: (NSString *) filename forUser: (NSString *) userKey
{
    if (filename == nil)
    {
        return NO;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *imageFolderPath = [self getImageStorageFolderPathForUser: userKey];

    NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.jpg", filename]];

    return [fileManager fileExistsAtPath: imageFilePath];
}

+ (BOOL) deleteImageWithFileName: (NSString *) filename forUser: (NSString *) userKey
{
    if (filename == nil)
    {
        return NO;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *imageFolderPath = [self getImageStorageFolderPathForUser: userKey];

    NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.jpg", filename]];

    if ([fileManager fileExistsAtPath: imageFilePath])
    {
        DLog(@"Deleting file: %@", imageFilePath);
        
        return [fileManager removeItemAtPath: imageFilePath error: nil];
    }

    return NO;
}

+ (UIImage *) getCroppedImageUsingRect: (CGRect) cropRect forImage: (UIImage *) originalImage
{
    NSLog(@"original image orientation:%ld", (long)originalImage.imageOrientation);

    CGAffineTransform rectTransform;

    switch (originalImage.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -originalImage.size.height);
            break;

        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -originalImage.size.width, 0);
            break;

        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -originalImage.size.width, -originalImage.size.height);
            break;

        default:
            rectTransform = CGAffineTransformIdentity;
    }

    rectTransform = CGAffineTransformScale(rectTransform, originalImage.scale, originalImage.scale);

    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectApplyAffineTransform(cropRect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage: imageRef scale: originalImage.scale orientation: originalImage.imageOrientation];
    CGImageRelease(imageRef);
    // return result;

    // Now want to scale down cropped image!
    // want to multiply frames by 2 to get retina resolution
    CGRect scaledImgRect = CGRectMake(0, 0, (cropRect.size.width * 2), (cropRect.size.height * 2));

    UIGraphicsBeginImageContextWithOptions(scaledImgRect.size, NO, [UIScreen mainScreen].scale);

    [result drawInRect: scaledImgRect];

    UIImage *scaledNewImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return scaledNewImage;
}

+ (NSArray *) getImageFilenamesForUser: (NSString *) userKey
{
    NSString *imageFolderPath = [self getImageStorageFolderPathForUser: userKey];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:imageFolderPath  error:nil];
    
    NSMutableArray *filenames = [NSMutableArray new];
    
    for (NSString *filePath in filePathsArray)
    {
        NSArray *filePathComponents = [filePath componentsSeparatedByString:@"/"];
        
        NSString *wholeFilename = [filePathComponents lastObject];
        
        NSArray *filenameComponents = [wholeFilename componentsSeparatedByString:@"."];
        
        NSString *filename = [filenameComponents firstObject];
        
        [filenames addObject:filename];
    }
    
    return filenames;
}

+ (SideMenuView *) getLeftSideViewUsing: (UIImage *) profileImage andUsername: (NSString *) userName andMenuSelections: (NSArray *) menuSelections
{
    SideMenuView *leftSideMenuView = [[SideMenuView alloc] init];

    leftSideMenuView.profileImage = profileImage;
    leftSideMenuView.userName = userName;
    leftSideMenuView.menuSelections = menuSelections;

    return leftSideMenuView;
}

+ (NSString *) generateUniqueID
{
    return [[NSUUID UUID] UUIDString];
}

+ (int) randomNumberBetween: (int) min maxNumber: (int) max
{
    return min + arc4random_uniform(max - min + 1);
}

+ (NSInteger) currentYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *calendarComponents = [calendar components: NSCalendarUnitYear fromDate: [NSDate date]];

    NSInteger currentYear = [calendarComponents year];

    return currentYear;
}

+ (NSDate *) dateForMondayOfThisWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *calendarComponents = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitWeekday) fromDate: [NSDate date]];

    NSInteger weekDayOfToday = [calendarComponents weekday]; // 1 = Sunday, 2 = Monday, etc.

    NSInteger numberOfDaysSinceMonday = 0;

    if (weekDayOfToday == 1)
    {
        numberOfDaysSinceMonday = 6;
    }
    else
    {
        numberOfDaysSinceMonday =  weekDayOfToday - 2;
    }

    [calendarComponents setDay: (calendarComponents.day - numberOfDaysSinceMonday)];

    [calendarComponents setCalendar: calendar];  // Must do this before calling [NSDateComponents date]

    NSDate *mondayOfThisWeek = [calendarComponents date];

    return mondayOfThisWeek;
}

+ (NSDate *) dateForMondayOfPreviousWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *calendarComponents = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitWeekday) fromDate: [NSDate date]];

    NSInteger weekDayOfToday = [calendarComponents weekday]; // 1 = Sunday, 2 = Monday, etc.

    NSInteger numberOfDaysSinceMonday = 0;

    if (weekDayOfToday == 1)
    {
        numberOfDaysSinceMonday = 6;
    }
    else
    {
        numberOfDaysSinceMonday =  weekDayOfToday - 2;
    }

    [calendarComponents setDay: (calendarComponents.day - numberOfDaysSinceMonday)];

    [calendarComponents setDay: (calendarComponents.day - 7)];

    [calendarComponents setCalendar: calendar];  // Must do this before calling [NSDateComponents date]

    NSDate *mondayOfPreviousWeek = [calendarComponents date];

    return mondayOfPreviousWeek;
}

+ (NSDate *) dateForFirstDayOfThisMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *calendarComponents = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitWeekday) fromDate: [NSDate date]];

    [calendarComponents setDay: 1];

    [calendarComponents setCalendar: calendar];  // Must do this before calling [NSDateComponents date]

    NSDate *firstDayOfThisMonth = [calendarComponents date];

    return firstDayOfThisMonth;
}

+ (NSDate *) dateForFirstDayOfPreviousMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *calendarComponents = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitWeekday) fromDate: [NSDate date]];

    [calendarComponents setDay: 1];

    NSInteger currentMonth = [calendarComponents month];

    // if current month is January, we want to set the month to December of last year
    if (currentMonth == 1)
    {
        [calendarComponents setYear: calendarComponents.year - 1];

        [calendarComponents setMonth: 12];
    }
    else
    {
        [calendarComponents setMonth: calendarComponents.month - 1];
    }

    [calendarComponents setCalendar: calendar];  // Must do this before calling [NSDateComponents date]

    NSDate *firstDayOfPreviousMonth = [calendarComponents date];

    return firstDayOfPreviousMonth;
}

+ (CGRect) returnRectBiggerThan:(CGRect)originalRect by:(float)points
{
    CGRect slightBiggerRect = originalRect;
    
    slightBiggerRect.origin.x -= points;
    slightBiggerRect.origin.y -= points;
    slightBiggerRect.size.width += points * 2;
    slightBiggerRect.size.height += points * 2;
    
    return slightBiggerRect;
}

@end