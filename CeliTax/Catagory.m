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

- (instancetype) init
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

- (instancetype)initWithCoder:(NSCoder *)coder
{
	if (self = [self init])
    {
        self.localID = [coder decodeObjectForKey:kKeyIdentifer];
        
        self.name = [coder decodeObjectForKey:kKeyName];
        self.color = [coder decodeObjectForKey:kKeyColor];
        
        NSMutableDictionary *nationalAverageCosts = [coder decodeObjectForKey: kKeyNationalAverageCost];
        self.nationalAverageCosts = [[NSMutableDictionary alloc] initWithDictionary: nationalAverageCosts copyItems: NO];
        
        self.dataAction = [coder decodeIntegerForKey:kKeyDataAction];
    }

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
		copy.nationalAverageCosts = [self.nationalAverageCosts mutableCopy];
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
    
    json[kKeyRed] = @(red);
    
    json[kKeyGreen] = @(green);
    
    json[kKeyBlue] = @(blue);
    
    return json;
}

#define kKeyRed                 @"Red"
#define kKeyGreen               @"Green"
#define kKeyBlue                @"Blue"

- (NSDictionary *) toJson
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    json[kKeyIdentifer] = self.localID;
    
    json[kKeyName] = self.name;
    
    json[kKeyColor] = [self colorToJson:self.color];
    
    //Convert self.nationalAverageCosts dictionary to a string looking like:
    //item:2.5,ml:1.0:l:5.0,g:6.0,kg:5
    NSString *stringOfNationAverageCosts = @"";
    
    for (NSString *key in self.nationalAverageCosts)
    {
        NSNumber *valueForKey = (self.nationalAverageCosts)[key];
        
        NSString *unitNameAndDollarAmount = [NSString stringWithFormat:@"%@:%.2f", key, valueForKey.floatValue];
        
        stringOfNationAverageCosts = [stringOfNationAverageCosts stringByAppendingFormat:@"%@,", unitNameAndDollarAmount];
    }
    
    //Remove the last ,
    if (self.nationalAverageCosts.count)
    {
        stringOfNationAverageCosts = [stringOfNationAverageCosts substringToIndex:stringOfNationAverageCosts.length - 1];
    }
    
    json[kKeyNationalAverageCost] = stringOfNationAverageCosts;
    
    json[kKeyDataAction] = @(self.dataAction);
    
    return json;
}

-(void)copyDataFromCatagory:(Catagory *)thisOne
{
    self.name = [thisOne.name copy];
    self.color = [thisOne.color copy];
    self.nationalAverageCosts = [thisOne.nationalAverageCosts mutableCopy];
    self.dataAction = thisOne.dataAction;
}

-(void)addOrUpdateNationalAverageCostForUnitType:(NSInteger)unitType amount:(float)amount
{
    NSNumber *value = @(amount);
    
    switch (unitType)
    {
        case UnitItem:
            
            (self.nationalAverageCosts)[kUnitItemKey] = value;
            
            break;
            
        case UnitML:
            
            (self.nationalAverageCosts)[kUnitMLKey] = value;
            
            break;
            
        case UnitL:
            
            (self.nationalAverageCosts)[kUnitLKey] = value;
            
            break;
            
        case UnitG:
            
            (self.nationalAverageCosts)[kUnitGKey] = value;
            
            break;
            
        case Unit100G:
            
            (self.nationalAverageCosts)[kUnit100GKey] = value;
            
            break;
            
        case UnitKG:
            
            (self.nationalAverageCosts)[kUnitKGKey] = value;
            
            break;
            
        case UnitFloz:
            
            (self.nationalAverageCosts)[kUnitFlozKey] = value;
            
            break;
            
        case UnitPt:
            
            (self.nationalAverageCosts)[kUnitPtKey] = value;
            
            break;
            
        case UnitQt:
            
            (self.nationalAverageCosts)[kUnitQtKey] = value;
            
            break;
            
        case UnitGal:
            
            (self.nationalAverageCosts)[kUnitGalKey] = value;
            
            break;
        
        case UnitOz:
            
            (self.nationalAverageCosts)[kUnitOzKey] = value;
            
            break;
            
        case UnitLb:
            
            (self.nationalAverageCosts)[kUnitLbKey] = value;
            
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
            
        case UnitFloz:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitFlozKey];
            
            break;
            
        case UnitPt:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitPtKey];
            
            break;
            
        case UnitQt:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitQtKey];
            
            break;
            
        case UnitGal:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitGalKey];
            
            break;
            
        case UnitOz:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitOzKey];
            
            break;
            
        case UnitLb:
            
            [self.nationalAverageCosts removeObjectForKey:kUnitLbKey];
            
            break;
            
        default:
            
            break;
    }
}

@end
