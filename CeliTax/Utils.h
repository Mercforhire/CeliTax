//
//  Utils.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)getFilePathForFileName: (NSString *)fileName;

+ (id) unarchiveFile: (NSString *) path;

+ (BOOL) archiveFile:(id) objectToArchive toFile: (NSString *) path;

+ (NSString *)getImageStorageFolderPathForUser:(NSString *)userKey;

+ (NSString *)saveImage:(UIImage *)image withFilename:(NSString *)filename forUser:(NSString *)userKey;

+ (UIImage *)readImageWithFileName:(NSString *)filename forUser:(NSString *)userKey;

+ (BOOL)deleteAllPhotosforUser:(NSString *)userKey;

+ (BOOL)imageWithFileNameExist:(NSString *)filename forUser:(NSString *)userKey;

+ (BOOL)deleteImageWithFileName:(NSString *)filename forUser:(NSString *)userKey;

+ (UIImage *) getCroppedImageUsingRect:(CGRect)cropRect forImage:(UIImage *)originalImage;

@end
