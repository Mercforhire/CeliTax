//
//  MainScreenRootViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MainScreenRootViewController.h"
#import "SidebarViewController.h"
#import "GHRevealViewController.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "SettingsViewController.h"
#import "VaultViewController.h"
#import "HelpScreenViewController.h"
#import "MyAccountViewController.h"
#import "FeedbackViewController.h"
#import "ViewControllerFactory.h"

@class MainViewController;

typedef void (^RevealBlock)();

@interface MainScreenRootViewController ()

@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) SidebarViewController *menuController;

@end

@implementation MainScreenRootViewController

-(void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
    
    RevealBlock revealBlock = ^(){
        [self.revealController toggleSidebar:!self.revealController.sidebarShowing
                                duration:kGHRevealSidebarDefaultAnimationDuration];
    };
    
    NSArray *controllers = @[
                             @[
                                 [[UINavigationController alloc] initWithRootViewController:[self.viewControllerFactory createMainViewControllerWith:revealBlock]]
                                 ],
                             @[
                                 [[UINavigationController alloc] initWithRootViewController:[self.viewControllerFactory createHelpScreenViewControllerWith:revealBlock]],
                                 [[UINavigationController alloc] initWithRootViewController:[self.viewControllerFactory createMyAccountViewControllerWith:revealBlock]],
                                 [[UINavigationController alloc] initWithRootViewController:[self.viewControllerFactory createVaultViewControllerWith:revealBlock]],
                                 [[UINavigationController alloc] initWithRootViewController:[self.viewControllerFactory createSettingsViewControllerWith:revealBlock]],
                                 [[UINavigationController alloc] initWithRootViewController:[self.viewControllerFactory createFeedbackViewControllerWith:revealBlock]]
                                 ]
                             ];
    
    NSDictionary* mainScreenButton = [NSDictionary dictionaryWithObjects:@[ @"Take Photos" ] forKeys:@[ @"title" ]];
    NSDictionary* menuButton1 = [NSDictionary dictionaryWithObjects:@[ @"Help" ] forKeys:@[ @"title" ]];
    NSDictionary* menuButton2 = [NSDictionary dictionaryWithObjects:@[ @"My Account" ] forKeys:@[ @"title" ]];
    NSDictionary* menuButton3 = [NSDictionary dictionaryWithObjects:@[ @"Vault" ] forKeys:@[ @"title" ]];
    NSDictionary* menuButton4 = [NSDictionary dictionaryWithObjects:@[ @"Settings" ] forKeys:@[ @"title" ]];
    NSDictionary* menuButton5 = [NSDictionary dictionaryWithObjects:@[ @"Feedback" ] forKeys:@[ @"title" ]];
    NSDictionary* menuButton6 = [NSDictionary dictionaryWithObjects:@[ @"Logout" ] forKeys:@[ @"title" ]];
    
    NSArray *cellInfos = @[
                           @[
                               mainScreenButton
                            ],
                           @[
                               menuButton1,
                               menuButton2,
                               menuButton3,
                               menuButton4,
                               menuButton5,
                               menuButton6
                            ]
                        ];
    
    // Add drag feature to each root navigation controller
    [controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                         action:@selector(dragContentView:)];
            panGesture.cancelsTouchesInView = YES;
            [((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
        }];
    }];
    
    self.menuController = [self.viewControllerFactory createSidebarViewControllerWithGHRevealViewController:self.revealController withControllers:controllers withCellInfos:cellInfos];
    
    // show.
    self.revealController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:self.revealController animated:YES completion:^{
        
    }];
}

//call this upon 'log off' action
-(void)removeRevealController
{
    [self dismissViewControllerAnimated:NO completion:^{
        UIViewController *popToHere;
        for (UIViewController *viewController in self.navigationController.viewControllers)
        {
            if ([viewController isKindOfClass:[LoginViewController class]])
            {
                popToHere = viewController;
            }
            
            break;
        }
        
        [self.navigationController popToViewController:popToHere animated:YES];
    }];
}

@end
