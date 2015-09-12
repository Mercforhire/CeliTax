//
//  LocalizationManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-09-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Language : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *display;

@end

/**
 Used to manage the retrieval of language specific strings from the correct language bundle
 */
@interface LocalizationManager : NSObject

@property (nonatomic, strong, readonly) Language *currentLanguage;

/**
 Used to access the singleton instance of the localization manager
 */
+ (LocalizationManager *) sharedInstance;

/**
 Initializes the localization manager
 */
- (void) initialize;

/**
 Changes the language used in the application
 
 @param language NSString that represents the language to switch to
 */
- (void) changeLanguage: (NSString *) language;

/**
 Used to retrieve a localized string
 
 @param key NSString that represents the key to use in the lookup
 @param value NSString that represents the value that will be returned if nothing is found for key
 @param tableName NSString that represents the localization table name
 
 @returns NSString that found for key. If not found, value is returned
 */
- (NSString *) localizedStringForKey: (NSString *) key value: (NSString *) value table: (NSString *) tableName;

@end
