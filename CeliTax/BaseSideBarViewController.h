//
//  BaseSideBarViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-28.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "LeftSideMenuView.h"
#import "CDRTranslucentSideBar.h"

enum RootViewControllers {
    RootViewControllerHome,
    RootViewControllerAccount,
    RootViewControllerVault,
    RootViewControllerHelp,
    RootViewControllerSettings
};

@interface BaseSideBarViewController : BaseViewController

@property (nonatomic, strong) LeftSideMenuView *leftSideMenuView;
@property (nonatomic, strong) CDRTranslucentSideBar *rightSideBar;

- (void)selectedMenuIndex:(NSInteger)index;

@end
