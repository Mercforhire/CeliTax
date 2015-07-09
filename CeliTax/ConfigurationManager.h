//
//  ConfigurationManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigurationManager : NSObject

-(void)loadSettingsFromPersistence;

-(void)setNewSettings:(NSDictionary *)settings;


-(NSInteger)getCurrentTaxYear;

-(void)setCurrentTaxYear:(NSInteger)taxYear;

-(BOOL)isTutorialOn;

-(void)setTutorialON:(BOOL)on;

@end
