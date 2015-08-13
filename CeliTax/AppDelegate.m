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
#import "NetworkCommunicator.h"
#import "BuilderFactory.h"
#import "SyncManager.h"
#import "BackgroundWorker.h"

@class SplashViewController, ConfigurationManager, ViewControllerFactory, UserManager;

@interface AppDelegate ()

@property (nonatomic, strong) ConfigurationManager *configurationManager;
@property (nonatomic, strong) ViewControllerFactory *viewControllerFactory;
@property (nonatomic, strong) UserManager *userManager;
@property (nonatomic, strong) ServiceFactory *serviceFactory;
@property (nonatomic, strong) DAOFactory *daoFactory;
@property (nonatomic, strong) LookAndFeel *lookAndFeel;
@property (nonatomic, strong) BuilderFactory *builderFactory;
@property (nonatomic, strong) NetworkCommunicator *networkCommunicator;
@property (nonatomic, strong) SyncManager *syncManager;
@property (nonatomic, strong) BackgroundWorker *backgroundWorker;

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
    self.viewControllerFactory.syncService = [self.serviceFactory createSyncService];
    self.viewControllerFactory.lookAndFeel = self.lookAndFeel;
    self.viewControllerFactory.navigationBarTitleImageContainer = self.navigationBarTitleImageContainer;
    self.viewControllerFactory.syncManager = self.syncManager;
}

- (void) initializeUserManager
{
    self.userManager = [[UserManager alloc] init];
    self.userManager.authenticationService = [self.serviceFactory createAuthenticationService];
    self.userManager.userDataDAO = [self.daoFactory createUserDataDAO];
    self.userManager.configManager = self.configurationManager;
}

- (void) initializeServiceFactory
{
    self.serviceFactory = [[ServiceFactory alloc] init];
    self.serviceFactory.configurationManager = self.configurationManager;
    self.serviceFactory.daoFactory = self.daoFactory;
    self.serviceFactory.networkCommunicator = self.networkCommunicator;
    self.serviceFactory.builderFactory = self.builderFactory;
}

- (void) initializeDAOFactory
{
    self.daoFactory = [[DAOFactory alloc] init];
}

- (void) initializeNetworkCommunicator
{
    self.networkCommunicator = [[NetworkCommunicator alloc] initWithHostName:WEBSERVICE_URL];
}

- (void) initializeBuilderFactory
{
    self.builderFactory = [[BuilderFactory alloc] init];
}

-(void)initializeSyncManager
{
    self.syncManager = [[SyncManager alloc] initWithSyncService:[self.serviceFactory createSyncService] andUserManager:self.userManager];
}

-(void)initializeBackgroundWorker
{
    self.backgroundWorker = [[BackgroundWorker alloc] init];
}

- (void) customizeGlobalLookAndFeel
{
    // Sets the status and nav bar color
    [[UINavigationBar appearance] setBarTintColor: self.lookAndFeel.navBarColor];
    
    // White elements in the status bar works with our branding
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    
    // We want white buttons in the nav bar
    [[UINavigationBar appearance] setTintColor: [UIColor whiteColor]];
    
    // We want a white title in the nav bar
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
}

#pragma mark App lifecycle

// do loading here
- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    [self initializeNetworkCommunicator];
    [self initializeBuilderFactory];
    [self initializeLookAndFeel];
    [self initializeConfigurationManager];
    [self initializeDAOFactory];
    [self initializeServiceFactory];
    [self initializeUserManager];
    [self initializeSyncManager];
    [self initializeViewControllerFactory];
    [self initializeBackgroundWorker];

    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

    [self.window makeKeyAndVisible];
    
    [self customizeGlobalLookAndFeel];

    if (!self.navigationController)
    {
        self.navigationController = [[UINavigationController alloc] init];
        self.window.rootViewController = self.navigationController;
        [self.navigationController.navigationBar setTranslucent: YES];

        self.navigationBarTitleImageContainer = [[UIView alloc] initWithFrame: self.navigationController.navigationBar.frame];
        [self.navigationBarTitleImageContainer setUserInteractionEnabled: NO];

        UIImageView *titleImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"CelitaxNavBarLogo.png"]];
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