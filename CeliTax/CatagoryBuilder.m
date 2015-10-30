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
    
    catagory.localID = json[kKeyIdentifer];
    catagory.name = json[kKeyName];
    
    catagory.nationalAverageCosts = [[NSMutableDictionary alloc] init];
    
    //Convert a string of format 'item:2.5,ml:1.0:l:5.0,g:6.0,kg:5'
    //To Dictionary of KEY: item; VALUE: 2.5, KEY: ml; VALUE: 1.0,...
    NSString *averageCostString = json[kKeyNationalAverageCost];
    
    NSArray *components = [averageCostString componentsSeparatedByString:@","];
    
    for (NSString *component in components)
    {
        NSArray *components2 = [component componentsSeparatedByString:@":"];
        
        if (components2.count == 2)
        {
            NSString *unitName = components2.firstObject;
            
            NSString *unitValue = components2.lastObject;
            
            (catagory.nationalAverageCosts)[unitName] = @(unitValue.floatValue);
        }
    }
    
    NSString *colorString = json[kKeyColor];
    
    NSArray *colorValues = [colorString componentsSeparatedByString:@","];
    
    if (colorValues.count == 3)
    {
        float redValue = [colorValues.firstObject doubleValue];
        float blueValue = [colorValues[1] doubleValue];
        float greenValue = [colorValues.lastObject doubleValue];
        
        UIColor *color = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1];
        
        catagory.color = color;
    }
    
    return catagory;
}

@end
