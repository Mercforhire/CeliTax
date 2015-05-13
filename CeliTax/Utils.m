//
//  Utils.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString *)getFilePathForFileName: (NSString *)fileName
{
    NSString *storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filePath = [storagePath stringByAppendingPathComponent:fileName];
    
    return filePath;
}

+ (id) unarchiveFile: (NSString *) path
{
    id archive = nil;
    
    @try
    {
        archive = [NSKeyedUnarchiver unarchiveObjectWithFile: path];
        
        DLog(@"File read from path %@", path);
    }
    @catch (NSException* exception)
    {
        DLog(@"Unable to unarchive file %@: %@", path, [exception reason]);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: path])
        {
            [[NSFileManager defaultManager] removeItemAtPath: path error: nil];
        }
    }
    
    return archive;
}

+ (BOOL) archiveFile:(id) objectToArchive toFile: (NSString *) path
{
    @try
    {
        NSString *pathOnly = [path stringByDeletingLastPathComponent];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath: pathOnly])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath: pathOnly withIntermediateDirectories: YES attributes: nil error: nil];
        }
        
        [NSKeyedArchiver archiveRootObject: objectToArchive toFile: path];
        
        DLog(@"File saved to %@", path);
        
        return YES;
    }
    @catch (NSException* exception)
    {
        DLog(@"Unable to unarchive file %@: %@", path, [exception reason]);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: path])
        {
            [[NSFileManager defaultManager] removeItemAtPath: path error: nil];
        }
        
        return NO;
    }
}

@end
