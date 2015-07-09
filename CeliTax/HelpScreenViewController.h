//
//  HelpScreenViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"

@protocol AuthenticationService;

@interface HelpScreenViewController : BaseSideBarViewController

@property (nonatomic, weak) id <AuthenticationService> authenticationService;

@end
