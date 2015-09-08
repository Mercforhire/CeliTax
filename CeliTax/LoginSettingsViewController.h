//
//  LoginSettingsViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-09-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "AuthenticationService.h"

@interface LoginSettingsViewController : BaseViewController

@property (nonatomic, weak) id <AuthenticationService> authenticationService;

@end
