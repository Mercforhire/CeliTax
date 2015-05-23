//
//  AuthenticationServiceImpl.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationService.h"

@class UserDataDAO;

@interface AuthenticationServiceImpl : NSObject <AuthenticationService>

@property (nonatomic, strong) UserDataDAO       *userDataDAO;

@end
