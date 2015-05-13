//
//  UserManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Helper.h"

/**
 Additions to the NSString class
 */
@interface NSString (Helper)

/**
 @returns Yes or No depending on BOOL value
*/
+ (NSString *) stringWithBool: (BOOL) value;

/**
 @returns Yes or No Depending on BOOL string value, nil if no BOOL value
 */
- (NSString *) toBoolString;

/**
 Tests for a blank string.  Will trim the string of white space

 @return BOOL is an empty string
*/
- (BOOL) isEmpty;

/**
 Checks to see if this NSString contains only numbers
 
 @returns YES if all numbers, NO otherwise
 */
- (BOOL) isNumeric;

/**
 Removes all non alpha numeric characters from self
 
 @returns NSString that only contains numeric characters
 */
- (NSString *) stripNonAlphaCharacters;

/**
 Removes all non numeric characters from self
 
 @returns NSString that only contains numeric characters
 */
- (NSString *) stripNonNumericCharacters;

/**
 Removes white space from before and after the string
 */
- (NSString *) trim;

/**
 Format this NSString as currency with the current locale
 */
- (NSString *) asCurrency;

/**
 Format this NSString as decimal with the current locale
 */
- (NSString *) asDecimal;

/// Ensures the string is a valid email address.
- (BOOL)isEmailAddress;

/// Ensure the string is a valid Canadian postal code
- (BOOL)isCanadianPostalCode;

/// Ensure the string is a valid American postal code
- (BOOL)isAmericanPostalCode;

@end
