//
//  AppDelegate.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-28.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllerFactory.h"
#import "ConfigurationManager.h"
#import "UserManager.h"
#import "SplashViewController.h"
#import "LoginViewController.h"
#import "ServiceFactory.h"
#import "DAOFactory.h"

@class SplashViewController,ConfigurationManager,ViewControllerFactory,UserManager;

@interface AppDelegate ()

@property (nonatomic, strong) ConfigurationManager *configurationManager;
@property (nonatomic, strong) ViewControllerFactory *viewControllerFactory;
@property (nonatomic, strong) UserManager *userManager;
@property (nonatomic, strong) ServiceFactory *serviceFactory;
@property (nonatomic, strong) DAOFactory *daoFactory;

@property (nonatomic, strong) SplashViewController *splash;
@property (nonatomic, strong) UINavigationController *navController;

@end

@implementation AppDelegate

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

//do loading here
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeConfigurationManager];
    [self initializeDAOFactory];
    [self initializeServiceFactory];
    [self initializeUserManager];
    [self initializeViewControllerFactory];
    
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.splash = [self.viewControllerFactory createSplashViewController];
    
    self.window.rootViewController = self.splash;
    
    [self.window makeKeyAndVisible];
    
    if (!self.navController)
    {
        self.navController = [[UINavigationController alloc] init];
        self.window.rootViewController = self.navController;
        
        //if not logged in, push login screen. Else push main app screen
        [self.navController pushViewController: [self.viewControllerFactory createLoginViewController] animated:YES];
        
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
