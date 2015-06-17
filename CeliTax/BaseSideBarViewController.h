//
// BaseSideBarViewController.h
// CeliTax
//
// Created by Leon Chen on 2015-05-28.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "SideMenuView.h"
#import "CDRTranslucentSideBar.h"

enum RootViewControllers
{
    RootViewControllerHome,
    RootViewControllerAccount,
    RootViewControllerVault,
    RootViewControllerHelp,
    RootViewControllerSettings,
    RootViewControllerLogOff
};

@interface BaseSideBarViewController : BaseViewController

@property (nonatomic, strong) SideMenuView *sideMenuView;
@property (nonatomic, strong) CDRTranslucentSideBar *rightSideBar;

- (void) selectedMenuIndex: (NSInteger) index;

@end