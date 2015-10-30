//
//  NSString+Helper.m
//  Inspection
//
//  Created by Phil Denis on 2013-03-02.
//  Copyright (c) 2013 Openlane. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (BOOL) isEmpty
{
    NSString *value = [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return value.length == 0;
}

- (BOOL) isNumeric
{
    NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString: @"0123456789"];

    return [self stringByTrimmingCharactersInSet: numberSet].length == 0;
}

+ (NSString *) stringWithBool: (BOOL) value
{
    NSString *result = @"NO";

    if (value)
    {
        result = @"YES";
    }

    return result;
}

- (NSString *) toBoolString
{
    NSString *result = nil;
    
    if ([self isEqualToString: @"0"] || [self.uppercaseString isEqualToString: @"NO"])
    {
        result = @"NO";
    }
    else if ([self isEqualToString: @"1"] || [self.uppercaseString isEqualToString: @"YES"])
    {
        result = @"YES";
    }
    
    return result;
}

- (NSString *) stripNonAlphaCharacters
{
    NSCharacterSet *charactersToRemove = [NSCharacterSet alphanumericCharacterSet].invertedSet;

    return [[self componentsSeparatedByCharactersInSet: charactersToRemove] componentsJoinedByString: @""];
}

- (NSString *) stripNonNumericCharacters
{
    NSCharacterSet *charactersToRemove = [NSCharacterSet decimalDigitCharacterSet].invertedSet;
    
    return [[self componentsSeparatedByCharactersInSet: charactersToRemove] componentsJoinedByString: @""];
}

- (NSString *) trim
{
    return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) asCurrency
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    NSNumber *num = [nf numberFromString: self];
    nf.numberStyle = NSNumberFormatterCurrencyStyle;    

    return [nf stringFromNumber: num];
}

- (NSString *) asDecimal
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    NSNumber *num = [nf numberFromString: self];
    nf.numberStyle = NSNumberFormatterDecimalStyle;
    
    return [nf stringFromNumber: num];
}

- (BOOL)isEmailAddress
{
    if (self == nil)
    {
        return NO;
    }
    
    NSString *filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];
    
    return [emailTest evaluateWithObject:self];
}


- (BOOL)isCanadianPostalCode
{
    if (self == nil)
    {
        return NO;
    }
    
    NSString *postalPred = @"[a-zA-Z][0-9][a-zA-Z]( )?[0-9][a-zA-Z][0-9]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", postalPred];
    
    return [pred evaluateWithObject:self];
}

- (BOOL)isAmericanPostalCode
{
    if (self == nil)
    {
        return NO;
    }
    
    NSString *postalPred = @"^\\d{5}([\\-]?\\d{4})?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", postalPred];
    
    return [pred evaluateWithObject:self];
}

@end
