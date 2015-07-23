//
//  CatagoryBuilder.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-20.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoryBuilder.h"

#define kKeyIdentifer               @"identifier"
#define kKeyName                    @"name"
#define kKeyColor                   @"color"
#define kKeyNationalAverageCost     @"national_average_cost"

@implementation CatagoryBuilder

- (Catagory *) buildCatagoryFrom: (NSDictionary *) json
{
    if (![json isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    Catagory *catagory = [[Catagory alloc] init];
    
    catagory.localID = [json objectForKey: kKeyIdentifer];
    catagory.name = [json objectForKey: kKeyName];
    catagory.nationalAverageCost = [[json objectForKey: kKeyNationalAverageCost] doubleValue];
    
    NSString *colorString = [json objectForKey: kKeyColor];
    
    NSArray *colorValues = [colorString componentsSeparatedByString:@","];
    
    if (colorValues.count == 3)
    {
        float redValue = [[colorValues firstObject] doubleValue];
        float blueValue = [[colorValues objectAtIndex:1] doubleValue];
        float greenValue = [[colorValues lastObject] doubleValue];
        
        UIColor *color = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1];
        
        catagory.color = color;
    }
    
    return catagory;
}

@end
