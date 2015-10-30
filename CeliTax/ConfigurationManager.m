//
//  ConfigurationManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ConfigurationManager.h"

#define kKeyAppSettings             @"AppSettings"
#define kKeyTaxYear                 @"TaxYear"
#define kKeyLanguage                @"Language"
#define kKeyUnitSystem              @"UnitSystem"

@interface ConfigurationManager ()

@property (nonatomic,strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSMutableDictionary *settings;

@end

@implementation ConfigurationManager

- (instancetype) init
{
    if (self = [super init])
    {
        _defaults = [NSUserDefaults standardUserDefaults];
        _settings = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)loadSettingsFromPersistence
{
    //load previous Settings
    NSDictionary *settings = [self.defaults objectForKey:kKeyAppSettings];
    
    if (settings)
    {
        self.settings = [[NSMutableDictionary alloc] initWithDictionary:settings copyItems:NO];
    }
}

-(void)saveSettings
{
    [self.defaults setObject:self.settings forKey:kKeyAppSettings];
    
    [self.defaults synchronize];
}

-(NSNumber *)getCurrentTaxYear
{
    NSNumber *taxYear = (self.settings)[kKeyTaxYear];
    
    return taxYear;
}

-(void)setCurrentTaxYear:(NSInteger)taxYear
{
    (self.settings)[kKeyTaxYear] = @(taxYear);
    
    [self saveSettings];
}

-(NSNumber *)getUnitSystem
{
    NSNumber *unitSystemSelection = (self.settings)[kKeyUnitSystem];
    
    return unitSystemSelection;
}

-(void)setUnitSystem:(NSInteger)unitSystem
{
    (self.settings)[kKeyUnitSystem] = @(unitSystem);
    
    [self saveSettings];
}

@end
