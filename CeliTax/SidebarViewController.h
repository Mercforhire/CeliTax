//
//  SidebarController.h
//  ADVFlatUI
//
//  Created by Tope on 05/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class GHRevealViewController;

@interface SidebarViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC
					withControllers:(NSArray *)controllers
					  withCellInfos:(NSArray *)cellInfos;

@end
