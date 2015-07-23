//
//  ItemCatagory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Catagory.h"

#define kKeyIdentifer               @"Identifer"
#define kKeyName                    @"Name"
#define kKeyColor                   @"Color"
#define kKeyNationalAverageCost     @"NationalAverageCost"
#define kKeyDataAction              @"DataAction"

@implementation Catagory

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.localID forKey:kKeyIdentifer];

	[coder encodeObject:self.name forKey:kKeyName];
	[coder encodeObject:self.color forKey:kKeyColor];

	[coder encodeInteger:self.nationalAverageCost forKey:kKeyNationalAverageCost];
    
    [coder encodeInteger:self.dataAction forKey:kKeyDataAction];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [self init];

	self.localID = [coder decodeObjectForKey:kKeyIdentifer];

	self.name = [coder decodeObjectForKey:kKeyName];
	self.color = [coder decodeObjectForKey:kKeyColor];

	self.nationalAverageCost = [coder decodeIntegerForKey:kKeyNationalAverageCost];
    
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
		copy.nationalAverageCost = self.nationalAverageCost;
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

- (NSDictionary *) toJson
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setObject:self.localID forKey:kKeyIdentifer];
    
    [json setObject:self.name forKey:kKeyName];
    
    [json setObject:[self colorToJson:self.color] forKey:kKeyColor];
    
    [json setObject:[NSNumber numberWithFloat:self.nationalAverageCost] forKey:kKeyNationalAverageCost];
    
    [json setObject:[NSNumber numberWithInteger:self.dataAction] forKey:kKeyDataAction];
    
    return json;
}

-(void)copyDataFromCatagory:(Catagory *)thisOne
{
    self.name = [thisOne.name copy];
    self.color = [thisOne.color copy];
    self.nationalAverageCost = thisOne.nationalAverageCost;
    self.dataAction = thisOne.dataAction;
}

@end
