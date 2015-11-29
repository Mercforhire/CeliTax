//
// BaseViewController.h
// CeliTax
//
// Created by Leon Chen on 2015-04-29.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LookAndFeel, ConfigurationManager, ViewControllerFactory, UserManager, TutorialManager, BackgroundWorker, SubscriptionManager;

@interface BaseViewController : UIViewController

@property (nonatomic, weak) UIView *navigationBarTitleImageContainer;

@property (nonatomic, weak) ConfigurationManager *configurationManager;   /** Allows all view controllers to access configuration data */

@property (nonatomic, weak) ViewControllerFactory *viewControllerFactory; /** Allows all view controllers to create other view controllers without knowing about the details */

@property (nonatomic, weak) UserManager *userManager;

@property (nonatomic, weak) LookAndFeel *lookAndFeel;

@property (nonatomic, strong) TutorialManager *tutorialManager;

@property (nonatomic, weak) BackgroundWorker *backgroundWorker;

@property (nonatomic, weak) SubscriptionManager *subscriptionManager;

- (void) stopEditing;

@end