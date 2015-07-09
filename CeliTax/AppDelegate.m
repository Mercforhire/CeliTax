//
// AppDelegate.m
// CeliTax
//
// Created by Leon Chen on 2015-04-28.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllerFactory.h"
#import "ConfigurationManager.h"
#import "UserManager.h"
#import "LoginViewController.h"
#import "ServiceFactory.h"
#import "DAOFactory.h"
#import "LookAndFeel.h"
#import "TutorialManager.h"

@class SplashViewController, ConfigurationManager, ViewControllerFactory, UserManager;

@interface AppDelegate ()

@property (nonatomic, strong) ConfigurationManager *configurationManager;
@property (nonatomic, strong) ViewControllerFactory *viewControllerFactory;
@property (nonatomic, strong) UserManager *userManager;
@property (nonatomic, strong) ServiceFactory *serviceFactory;
@property (nonatomic, strong) DAOFactory *daoFactory;
@property (nonatomic, strong) LookAndFeel *lookAndFeel;

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIView *navigationBarTitleImageContainer;

@end

@implementation AppDelegate

- (void) initializeLookAndFeel
{
    self.lookAndFeel = [[LookAndFeel alloc] init];
}

- (void) initializeConfigurationManager
{
    self.configurationManager = [[ConfigurationManager alloc] init];
}

- (void) initializeViewControllerFactory
{
    self.viewControllerFactory = [[ViewControllerFactory alloc] init];

    self.viewControllerFactory.configurationManager = self.configurationManager;
    self.viewControllerFactory.userManager = self.userManager;
    self.viewControllerFactory.authenticationService = [self.serviceFactory createAuthenticationService];
    self.viewControllerFactory.dataService = [self.serviceFactory createDataService];
    self.viewControllerFactory.manipulationService = [self.serviceFactory createManipulationService];
    self.viewControllerFactory.lookAndFeel = self.lookAndFeel;
    self.viewControllerFactory.navigationBarTitleImageContainer = self.navigationBarTitleImageContainer;
}

- (void) initializeUserManager
{
    self.userManager = [[UserManager alloc] init];
}

- (void) initializeServiceFactory
{
    self.serviceFactory = [[ServiceFactory alloc] init];
    self.serviceFactory.configurationManager = self.configurationManager;
    self.serviceFactory.daoFactory = self.daoFactory;
}

- (void) initializeDAOFactory
{
    self.daoFactory = [[DAOFactory alloc] init];
}

#pragma mark App lifecycle

// do loading here
- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    [self initializeLookAndFeel];
    [self initializeConfigurationManager];
    [self initializeDAOFactory];
    [self initializeServiceFactory];
    [self initializeUserManager];
    [self initializeViewControllerFactory];

    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

    [self.window makeKeyAndVisible];

    if (!self.navigationController)
    {
        self.navigationController = [[UINavigationController alloc] init];
        self.window.rootViewController = self.navigationController;
        [self.navigationController.navigationBar setTranslucent: YES];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];

        self.navigationBarTitleImageContainer = [[UIView alloc] initWithFrame: self.navigationController.navigationBar.frame];
        [self.navigationBarTitleImageContainer setUserInteractionEnabled: NO];

        UIImageView *titleImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"celitaxlogo_small.png"]];
        [titleImage setFrame: CGRectMake(0, 10, self.navigationController.navigationBar.frame.size.width, 30)];
        [titleImage setContentMode: UIViewContentModeScaleAspectFit];
        [titleImage setUserInteractionEnabled: NO];

        [self.navigationBarTitleImageContainer addSubview: titleImage];

        [self.navigationController.view addSubview: self.navigationBarTitleImageContainer];

        self.viewControllerFactory.navigationBarTitleImageContainer = self.navigationBarTitleImageContainer;

        // if not logged in, push login screen. Else push main app screen
        [self.navigationController pushViewController: [self.viewControllerFactory createLoginViewController] animated: YES];
    }
    
    [self.window makeKeyAndVisible];

    return YES;
}

/*
   - (void) applicationWillResignActive: (UIApplication *) application
   {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   }

   - (void) applicationDidEnterBackground: (UIApplication *) application
   {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   }

   - (void) applicationWillEnterForeground: (UIApplication *) application
   {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   }

   - (void) applicationDidBecomeActive: (UIApplication *) application
   {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   }

   - (void) applicationWillTerminate: (UIApplication *) application
   {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   }
 */

@end