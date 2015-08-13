//
//  ConfigurationManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ConfigurationManager.h"

#define kKeyTaxYear                 @"TaxYear"
#define kTutorialOn                 @"TutorialOn"

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
    ///TODO:
    //...
}

-(void)setNewSettings:(NSDictionary *)settings
{
    ///TODO:
    //...
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

-(BOOL)isTutorialOn
{
    if ([self.settings objectForKey:kTutorialOn])
    {
        return YES;
    }
    
    return NO;
}

-(void)setTutorialON:(BOOL)on
{
    if (on)
    {
        [self.settings setObject:@"ON" forKey:kTutorialOn];
    }
    else
    {
        [self.settings removeObjectForKey:kTutorialOn];
    }
}

@end
