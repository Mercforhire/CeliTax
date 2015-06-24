//
//  ConfigurationManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ConfigurationManager.h"

#define kKeyTaxYear                 @"TaxYear"

@interface ConfigurationManager ()

@property (nonatomic, strong) NSMutableDictionary *settings;

@end

@implementation ConfigurationManager

- (instancetype) init
{
    self = [super init];
    
    self.settings = [[NSMutableDictionary alloc] init];
    
    return self;
}

-(void)loadSettingsFromPersistence
{
    
}

-(void)setNewSettings:(NSDictionary *)settings
{
    
}

-(NSInteger)getCurrentTaxYear
{
    NSNumber *taxYear = [self.settings objectForKey:kKeyTaxYear];
    
    if (taxYear)
    {
        return [taxYear integerValue];
    }
    else
    {
        return 0;
    }
}

-(void)setCurrentTaxYear:(NSInteger)taxYear
{
    [self.settings setObject:[NSNumber numberWithInteger:taxYear] forKey:kKeyTaxYear];
}

@end
