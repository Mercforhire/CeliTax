//
//  ServiceFactory.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConfigurationManager, DAOFactory;
@protocol AuthenticationService, DataService, ManipulationService;

@interface ServiceFactory : NSObject

@property (nonatomic, weak) ConfigurationManager *configurationManager;     /** Used to access global config values */

@property (nonatomic, weak) DAOFactory  *daoFactory;

- (id<AuthenticationService>) createAuthenticationService;

- (id<DataService>) createDataService;

- (id<ManipulationService>) createManipulationService;

@end
