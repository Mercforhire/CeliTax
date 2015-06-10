//
//  Utils.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Utils.h"
#import "LeftSideMenuView.h"

@implementation Utils

+ (NSString *)getFilePathForFileName:(NSString *)fileName {
	NSString *storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

	NSString *filePath = [storagePath stringByAppendingPathComponent:fileName];

	return filePath;
}

+ (id)unarchiveFile:(NSString *)path {
	id archive = nil;

	@try {
		archive = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

		DLog(@"File read from path %@", path);
	}
	@catch (NSException *exception)
	{
		DLog(@"Unable to unarchive file %@: %@", path, [exception reason]);

		if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}
	}

	return archive;
}

+ (BOOL)archiveFile:(id)objectToArchive toFile:(NSString *)path {
	@try {
		NSString *pathOnly = [path stringByDeletingLastPathComponent];

		if (![[NSFileManager defaultManager] fileExistsAtPath:pathOnly]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:pathOnly withIntermediateDirectories:YES attributes:nil error:nil];
		}

		[NSKeyedArchiver archiveRootObject:objectToArchive toFile:path];

		DLog(@"File saved to %@", path);

		return YES;
	}
	@catch (NSException *exception)
	{
		DLog(@"Unable to unarchive file %@: %@", path, [exception reason]);

		if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}

		return NO;
	}
}

+ (NSString *)getImageStorageFolderPathForUser:(NSString *)userKey {
	NSString *storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

	NSString *imageFolderName = [NSString stringWithFormat:@"/Images-%ld", (unsigned long)[userKey hash]];

	NSString *imageFolderPath = [storagePath stringByAppendingString:imageFolderName];

	return imageFolderPath;
}

+ (NSString *)saveImage:(UIImage *)image withFilename:(NSString *)filename forUser:(NSString *)userKey {
	if (image == nil || filename == nil) {
		return nil;
	}

	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *imageFolderPath = [self getImageStorageFolderPathForUser:userKey];

	if (![fileManager fileExistsAtPath:imageFolderPath]) {
		[fileManager createDirectoryAtPath:imageFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}

	NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.JPG", filename]];

	//delete the old file if it exists
	if ([fileManager fileExistsAtPath:imageFilePath]) {
		[fileManager removeItemAtPath:imageFilePath error:nil];
	}

	//get the NSData from UIIMage
	NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
	[imageData writeToFile:imageFilePath atomically:YES];

	return imageFilePath;
}

+ (UIImage *)readImageWithFileName:(NSString *)filename forUser:(NSString *)userKey {
	if (filename == nil) {
		return nil;
	}

	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *imageFolderPath = [self getImageStorageFolderPathForUser:userKey];

	NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.JPG", filename]];

	if (![fileManager fileExistsAtPath:imageFilePath]) {
		return nil;
	}

	//get the NSData from UIImage
	NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath];

	UIImage *image = [UIImage imageWithData:imageData];

	return image;
}

+ (BOOL)deleteAllPhotosforUser:(NSString *)userKey {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *imageFolderPath = [self getImageStorageFolderPathForUser:userKey];

	NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:imageFolderPath];

	for (NSString *fileName in fileEnumerator) {
		NSString *filePath = [imageFolderPath stringByAppendingPathComponent:fileName];

		if (![fileManager removeItemAtPath:filePath error:nil]) {
			return NO;
		}
	}

	return YES;
}

+ (BOOL)imageWithFileNameExist:(NSString *)filename forUser:(NSString *)userKey {
	if (filename == nil) {
		return NO;
	}

	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *imageFolderPath = [self getImageStorageFolderPathForUser:userKey];

	NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.JPG", filename]];

	return [fileManager fileExistsAtPath:imageFilePath];
}

+ (BOOL)deleteImageWithFileName:(NSString *)filename forUser:(NSString *)userKey {
	if (filename == nil) {
		return NO;
	}

	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *imageFolderPath = [self getImageStorageFolderPathForUser:userKey];

	NSString *imageFilePath = [imageFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.JPG", filename]];

	if ([fileManager fileExistsAtPath:imageFilePath]) {
		return [fileManager removeItemAtPath:imageFilePath error:nil];
	}

	return NO;
}

+ (UIImage *)getCroppedImageUsingRect:(CGRect)cropRect forImage:(UIImage *)originalImage {
	NSLog(@"original image orientation:%ld", (long)originalImage.imageOrientation);

	CGAffineTransform rectTransform;
	switch (originalImage.imageOrientation) {
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
	UIImage *result = [UIImage imageWithCGImage:imageRef scale:originalImage.scale orientation:originalImage.imageOrientation];
	CGImageRelease(imageRef);
	//return result;

	//Now want to scale down cropped image!
	//want to multiply frames by 2 to get retina resolution
	CGRect scaledImgRect = CGRectMake(0, 0, (cropRect.size.width * 2), (cropRect.size.height * 2));

	UIGraphicsBeginImageContextWithOptions(scaledImgRect.size, NO, [UIScreen mainScreen].scale);

	[result drawInRect:scaledImgRect];

	UIImage *scaledNewImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return scaledNewImage;
}

+ (LeftSideMenuView *)getLeftSideViewUsing:(UIImage *)profileImage andUsername:(NSString *)userName andMenuSelections:(NSArray *)menuSelections {
	LeftSideMenuView *leftSideMenuView = [[LeftSideMenuView alloc] init];

	leftSideMenuView.profileImage = profileImage;
	leftSideMenuView.userName = userName;
	leftSideMenuView.menuSelections = menuSelections;

	return leftSideMenuView;
}

+ (NSString *)generateUniqueID
{
    return [[NSUUID UUID] UUIDString];
}

+ (int)randomNumberBetween:(int)min maxNumber:(int)max
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
    
    [calendarComponents setCalendar: calendar]; // Must do this before calling [NSDateComponents date]
    
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
    
    [calendarComponents setCalendar: calendar]; // Must do this before calling [NSDateComponents date]
    
    NSDate *mondayOfPreviousWeek = [calendarComponents date];
    
    return mondayOfPreviousWeek;
}

+ (NSDate *) dateForFirstDayOfThisMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *calendarComponents = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitWeekday) fromDate: [NSDate date]];
    
    [calendarComponents setDay: 1];
    
    [calendarComponents setCalendar: calendar]; // Must do this before calling [NSDateComponents date]
    
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
    
    [calendarComponents setCalendar: calendar]; // Must do this before calling [NSDateComponents date]
    
    NSDate *firstDayOfPreviousMonth = [calendarComponents date];
    
    return firstDayOfPreviousMonth;
}

@end
