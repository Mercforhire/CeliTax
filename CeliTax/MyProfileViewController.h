//
//  MyProfileViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-24.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "AuthenticationService.h"

@interface MyProfileViewController : BaseViewController

@property (nonatomic, weak) id <AuthenticationService> authenticationService;

@end
