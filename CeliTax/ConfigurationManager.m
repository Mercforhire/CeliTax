//
//  ConfigurationManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ConfigurationManager.h"

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

@end
