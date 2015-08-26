//
//  ItemCatagory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Catagory.h"
#import "Record.h"

#define kKeyIdentifer               @"Identifer"
#define kKeyName                    @"Name"
#define kKeyColor                   @"Color"
#define kKeyNationalAverageCost     @"NationalAverageCosts"
#define kKeyDataAction              @"DataAction"

@implementation Catagory

- (id) init
{
    if (self = [super init])
    {
        self.nationalAverageCosts = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.localID forKey:kKeyIdentifer];

	[coder encodeObject:self.name forKey:kKeyName];
	[coder encodeObject:self.color forKey:kKeyColor];

	[coder encodeObject:self.nationalAverageCosts forKey:kKeyNationalAverageCost];
    
    [coder encodeInteger:self.dataAction forKey:kKeyDataAction];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [self init];

	self.localID = [coder decodeObjectForKey:kKeyIdentifer];

	self.name = [coder decodeObjectForKey:kKeyName];
	self.color = [coder decodeObjectForKey:kKeyColor];

    NSMutableDictionary *nationalAverageCosts = [coder decodeObjectForKey: kKeyNationalAverageCost];
    self.nationalAverageCosts = [[NSMutableDictionary alloc] initWithDictionary: nationalAverageCosts copyItems: NO];
    
    self.dataAction = [coder decodeIntegerForKey:kKeyDataAction];

	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	Catagory *copy = [[[self class] alloc] init];

	if (copy)
    {
		copy.localID = [self.localID copy];
		copy.name = [self.name copy];
		copy.color = [self.color copy];
		copy.nationalAverageCosts = [self.nationalAverageCosts copy];
        copy.dataAction = self.dataAction;
	}

	return copy;
}

#define kKeyRed                 @"Red"
#define kKeyGreen               @"Green"
#define kKeyBlue                @"Blue"

- (NSDictionary *) colorToJson:(UIColor *)color
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    [json setObject:[NSNumber numberWithFloat:red] forKey:kKeyRed];
    
    [json setObject:[NSNumber numberWithFloat:green] forKey:kKeyGreen];
    
    [json setObject:[NSNumber numberWithFloat:blue] forKey:kKeyBlue];
    
    return json;
}

#define kKeyRed                 @"Red"
#define kKeyGreen               @"Green"
#define kKeyBlue                @"Blue"

- (NSDictionary *) toJson
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setObject:self.localID forKey:kKeyIdentifer];
    
    [json setObject:self.name forKey:kKeyName];
    
    [json setObject:[self colorToJson:self.color] forKey:kKeyColor];
    
    //Convert self.nationalAverageCosts dictionary to a string looking like:
    //item:2.5,ml:1.0:l:5.0,g:6.0,kg:5
    NSString *stringOfNationAverageCosts = @"";
    
    for (NSString *key in self.nationalAverageCosts)
    {
        NSNumber *valueForKey = [self.nationalAverageCosts objectForKey:key];
        
        NSString *unitNameAndDollarAmount = [NSString stringWithFormat:@"%@:%.2f", key, [valueForKey floatValue]];
        
        stringOfNationAverageCosts = [stringOfNationAverageCosts stringByAppendingFormat:@"%@,", unitNameAndDollarAmount];
    }
    
    //Remove the last ,
    if (self.nationalAverageCosts.count)
    {
        stringOfNationAverageCosts = [stringOfNationAverageCosts substringToIndex:stringOfNationAverageCosts.length - 1];
    }
    
    [json setObject:stringOfNationAverageCosts forKey:kKeyNationalAverageCost];
    
    [json setObject:[NSNumber numberWithInteger:self.dataAction] forKey:kKeyDataAction];
    
    return json;
}

-(void)copyDataFromCatagory:(Catagory *)thisOne
{
    self.name = [thisOne.name copy];
    self.color = [thisOne.color copy];
    self.nationalAverageCosts = [thisOne.nationalAverageCosts copy];
    self.dataAction = thisOne.dataAction;
}

-(void)addOrUpdateNationalAverageCostForUnitType:(NSInteger)unitType amount:(float)amount
{
    NSNumber *value = [NSNumber numberWithFloat:amount];
    
    switch (unitType)
    {
        case UnitItem:
            
            [self.nationalAverageCosts setObject:value forKey:kUnitItemKey];
            
            break;
            
        case UnitML:
            
            [self.nationalAverageCosts setObject:value forKey:kUnitMLKey];
            
            break;
            
        case UnitL:
            
            [self.nationalAverageCosts setObject:value forKey:kUnitLKey];
            
            break;
            
        case UnitG:
            
            [self.nationalAverageCosts setObject:value forKey:kUnitGKey];
            
            break;
            
        case Unit100G:
            
            [self.nationalAverageCosts setObject:value forKey:kUnit100GKey];
            
            break;
            
        case UnitKG:
            
            [self.nationalAverageCosts setObject:value forKey:kUnitKGKey];
            
            break;
            
        default:
            
            break;
    }
}

-(void)deleteNationalAverageCostForUnitType:(NSInteger)unitType
{
    switch (unitType)
    {
        case UnitItem:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitItemKey];
            
            break;
            
        case UnitML:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitMLKey];
            
            break;
            
        case UnitL:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitLKey];
            
            break;
            
        case UnitG:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitGKey];
            
            break;
            
        case Unit100G:
            
            [self.nationalAverageCosts removeObjectForKey:kUnit100GKey];
            
            break;
            
        case UnitKG:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitKGKey];
            
            break;
            
        default:
            
            break;
    }
}

@end
