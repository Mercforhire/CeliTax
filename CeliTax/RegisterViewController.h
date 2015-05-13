//
//  RegisterViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "AuthenticationService.h"

@interface RegisterViewController : BaseViewController

@property (nonatomic, weak) id <AuthenticationService> authenticationService;

@end
