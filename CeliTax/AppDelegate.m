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
#import "MainViewController.h"
#import "DAOFactory.h"
#import "LookAndFeel.h"
#import "TutorialManager.h"
#import "SyncManager.h"
#import "BackgroundWorker.h"
#import "LocalizationManager.h"
#import "SubscriptionManager.h"
#import <Crashlytics/Crashlytics.h>

#import "CeliTax-Swift.h"

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
@property (nonatomic, strong) SubscriptionManager *subscriptionManager;

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
    self.viewControllerFactory.backgroundWorker = self.backgroundWorker;
    self.viewControllerFactory.subscriptionManager = self.subscriptionManager;
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
    self.serviceFactory = [[ServiceFactory alloc] initWithConfigurationManager:self.configurationManager daoFactory:self.daoFactory networkCommunicator:self.networkCommunicator builderFactory:self.builderFactory];
}

- (void) initializeDAOFactory
{
    self.daoFactory = [[DAOFactory alloc] init];
}

- (void) initializeNetworkCommunicator
{
    self.networkCommunicator = [[NetworkCommunicator alloc] initWithHostName: NetworkCommunicator.WEBSERVICE_URL];
}

- (void) initializeBuilderFactory
{
    self.builderFactory = [[BuilderFactory alloc] init];
}

-(void) initializeSyncManager
{
    self.syncManager = [[SyncManager alloc] initWithSyncService:[self.serviceFactory createSyncService] andUserManager:self.userManager];
}

-(void) initializeBackgroundWorker
{
    self.backgroundWorker = [[BackgroundWorker alloc] init];
    self.backgroundWorker.syncManager = self.syncManager;
    self.backgroundWorker.authenticationService = [self.serviceFactory createAuthenticationService];
    self.backgroundWorker.userManager = self.userManager;
}

-(void) initializeSubscriptionManager
{
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 k3MonthServiceProductID,
                                 k6MonthServiceProductID,
                                 nil];
    
    self.subscriptionManager = [[SubscriptionManager alloc] initWithProductIdentifiers:productIdentifiers];
    self.subscriptionManager.userManager = self.userManager;
    self.subscriptionManager.authenticationService = [self.serviceFactory createAuthenticationService];
}

- (void) initializeLocalizationManager
{
    // Make sure we start off with the right string files
    [[LocalizationManager sharedInstance] initialize];
}

- (void) customizeGlobalLookAndFeel
{
    // Sets the status and nav bar color
    [UINavigationBar appearance].barTintColor = self.lookAndFeel.navBarColor;
    
    // White elements in the status bar works with our branding
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // We want white buttons in the nav bar
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    // We want a white title in the nav bar
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [[UIBarButtonItem appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]} forState: UIControlStateNormal];
    
    self.window.backgroundColor = [UIColor whiteColor];
}

#pragma mark App lifecycle

// do loading here
- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    [Crashlytics startWithAPIKey:@"eb922476ab6e34282030b166efc4805103d4a498"];
    
    [self initializeLocalizationManager];
    [self initializeNetworkCommunicator];
    [self initializeBuilderFactory];
    [self initializeLookAndFeel];
    [self initializeConfigurationManager];
    [self initializeDAOFactory];
    [self initializeServiceFactory];
    [self initializeUserManager];
    [self initializeSubscriptionManager];
    self.userManager.subscriptionManager = self.subscriptionManager;
    [self initializeSyncManager];
    [self initializeBackgroundWorker];
    [self initializeViewControllerFactory];

    self.userManager.backgroundWorker = self.backgroundWorker;
    
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];

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
        titleImage.frame = CGRectMake(0, 10, self.navigationController.navigationBar.frame.size.width, 30);
        titleImage.contentMode = UIViewContentModeScaleAspectFit;
        [titleImage setUserInteractionEnabled: NO];

        [self.navigationBarTitleImageContainer addSubview: titleImage];

        [self.navigationController.view addSubview: self.navigationBarTitleImageContainer];

        self.viewControllerFactory.navigationBarTitleImageContainer = self.navigationBarTitleImageContainer;

        if ([self.userManager attemptToLoginSavedUser])
        {
            [self.navigationController pushViewController: [self.viewControllerFactory createMainViewController] animated: YES];
        }
        else
        {
            [self.navigationController pushViewController: [self.viewControllerFactory createLoginViewController] animated: YES];
        }
        
    }
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void) applicationDidBecomeActive: (UIApplication *) application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self.backgroundWorker appIsActive];
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

   - (void) applicationWillTerminate: (UIApplication *) application
   {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   }
 */

@end