//
// BaseSideBarViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-28.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "ViewControllerFactory.h"
#import "SettingsViewController.h"
#import "VaultViewController.h"
#import "HelpScreenViewController.h"
#import "MyAccountViewController.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "ProfileSettingsViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

#import "CeliTax-Swift.h"

static Reachability *_reachability = nil;
BOOL _reachabilityOn;

static inline Reachability* defaultReachability () {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reachability = [Reachability reachabilityForInternetConnection];
    });
    
    return _reachability;
}

@interface BaseSideBarViewController () <CDRTranslucentSideBarDelegate, SideMenuViewProtocol>

@property (strong, nonatomic) MBProgressHUD *waitView;

@end

@implementation BaseSideBarViewController

- (instancetype) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // initialize the slider bar menu button
        UIButton *menuButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 28, 20)];
        [menuButton setBackgroundImage: [UIImage imageNamed: @"menu.png"] forState: UIControlStateNormal];
        menuButton.tintColor = [UIColor colorWithRed: 7.0 / 255 green: 61.0 / 255 blue: 48.0 / 255 alpha: 1.0f];
        [menuButton addTarget: self action: @selector(revealSidebar) forControlEvents: UIControlEventTouchUpInside];

        UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView: menuButton];
        self.navigationItem.rightBarButtonItem = menuItem;

        [self.navigationItem setHidesBackButton: YES];
    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sideMenuView = [Utils getLeftSideViewUsing:self.userManager.user.avatarImage userName:[NSString stringWithFormat: @"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname]];
    self.sideMenuView.delegate = self;
    self.sideMenuView.lookAndFeel = self.lookAndFeel;

    self.rightSideBar = [[CDRTranslucentSideBar alloc] initWithDirectionFromRight: YES];
    (self.rightSideBar).translucentAlpha = 0.98;
    self.rightSideBar.delegate = self;
    
    UITapGestureRecognizer *profileImageViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(profileSettingsPressed)];
    
    [self.sideMenuView.profileImageView addGestureRecognizer: profileImageViewTap];
    
    UITapGestureRecognizer *profileImageViewTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(profileSettingsPressed)];
    
    [self.sideMenuView.usernameLabel addGestureRecognizer: profileImageViewTap2];

    if ([self isKindOfClass: [MainViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerHome;
    }
    else if ([self isKindOfClass: [MyAccountViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerAccount;
    }
    else if ([self isKindOfClass: [VaultViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerVault;
    }
    else if ([self isKindOfClass: [HelpScreenViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerHelp;
    }
    else if ([self isKindOfClass: [SettingsViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerSettings;
    }

    // Set ContentView in SideBar
    [self.rightSideBar setContentViewInSideBar: self.sideMenuView];
}

// slide out the slider bar
- (void) revealSidebar
{
    (self.sideMenuView).profileImage = self.userManager.user.avatarImage;
    
    [self.rightSideBar show];
    
    [[NSNotificationCenter defaultCenter] postNotification: [NSNotification notificationWithName: Notifications.kStopEditingFieldsNotification object: nil userInfo: nil]];
}

- (void) pushAndReplaceTopViewControllerWith: (BaseViewController *) viewController
{
    [self.rightSideBar dismissAnimated: NO];

    // remove CDRTranslucentSideBar
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];

    [viewControllers removeObject: self.rightSideBar];

    [self.navigationController setViewControllers: viewControllers animated: YES];

    // push the new viewController
    [viewControllers addObject:viewController];

    // remove self viewController
    NSMutableArray *viewController2 = [NSMutableArray arrayWithArray: viewControllers];

    [viewController2 removeObject: self];

    // Assign the updated stack with animation
    [self.navigationController setViewControllers: viewController2 animated: YES];
}

- (void) logOffToLoginView
{
    [self.userManager deleteAllLocalUserData];
    
    [self.userManager logOutUser];
    
    // dismiss itself
    [self.rightSideBar dismiss];
    
    [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createLoginViewController]];
}

- (void) createAndShowWaitViewForUpload
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
        self.waitView.labelText = NSLocalizedString(@"Please wait", nil);
        self.waitView.detailsLabelText = NSLocalizedString(@"Uploading Data...", nil);
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview: self.waitView];
    }
    
    [self.waitView show: YES];
}

-(void)hideWaitingView
{
    if (self.waitView)
    {
        //hide the Waiting view
        [self.waitView hide: YES];
    }
}


- (void)profileSettingsPressed
{
    [self.rightSideBar dismissAnimated: NO];
    
    // remove CDRTranslucentSideBar
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
    
    [viewControllers removeObject: self.rightSideBar];
    
    [self.navigationController setViewControllers: viewControllers animated: YES];
    
    [self.navigationController pushViewController: [self.viewControllerFactory createProfileSettingsViewController] animated: YES];
}

- (void)checkForInternetConnectivityAndLogOff
{
    // called after network status changes
    NetworkStatus internetStatus = [defaultReachability() currentReachabilityStatus];
    
    if (internetStatus == NotReachable)
    {
        // ask user if they are sure they want to log off
        NSString *alertMessage = NSLocalizedString(@"There appears to be no internet connection. If you logout while offline you will not be able to login until there is a connection", nil);
        NSString *alertCancel = NSLocalizedString(@"Cancel", nil);
        NSString *alertYes = NSLocalizedString(@"Log Off", nil);
        
        //create the alert items
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:alertCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        
        UIAlertAction *logOffAction = [UIAlertAction actionWithTitle:alertYes style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self logOffToLoginView];
            
        }];
        
        NSArray<UIAlertAction*>* alertActions = @[cancelAction, logOffAction];
        
        [AlertDialogsProvider handlerAlert:nil message:alertMessage action:alertActions];
    }
    else
    {
        [self logOffToLoginView];
    }
}

#pragma mark - LeftSideMenuViewProtocol
- (void) selectedMenuIndex: (NSInteger) index
{
    switch (index)
    {
        case RootViewControllerHome:

            // push MainViewController if self is not already MainViewController
            if (![self isKindOfClass: [MainViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createMainViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerAccount:

            // push MyAccountViewController if self is not already MyAccountViewController
            if (![self isKindOfClass: [MyAccountViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createMyAccountViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerVault:

            // push VaultViewController if self is not already VaultViewController
            if (![self isKindOfClass: [VaultViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createVaultViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerHelp:

            // push HelpScreenViewController if self is not already HelpScreenViewController
            if (![self isKindOfClass: [HelpScreenViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createHelpScreenViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerSettings:

            // push SettingsViewController if self is not already SettingsViewController
            if (![self isKindOfClass: [SettingsViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createSettingsViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerLogOff:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([self.syncManager needToBackUp])
                {
                    // ask user if they want to download data from server
                    NSString *alertTitle = NSLocalizedString(@"Unsaved Data", nil);
                    NSString *alertMessage = NSLocalizedString(@"There are some data that's yet to be uploaded to the server for storage. Logging off will delete all local data. Do you want to upload them now?", nil);
                    NSString *alertCancel = NSLocalizedString(@"Cancel", nil);
                    NSString *alertNo = NSLocalizedString(@"No", nil);
                    NSString *alertYes = NSLocalizedString(@"Yes", nil);
                    
                    //create the alert items
                    UIAlertAction *noAction = [UIAlertAction actionWithTitle:alertNo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [self logOffToLoginView];
                        
                    }];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:alertCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                    }];
                    
                    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:alertYes style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [self.rightSideBar dismiss];
                        
                        [self createAndShowWaitViewForUpload];
                        
                        [self.syncManager startSync:^(NSDate *syncDate)
                         {
                             [self.syncManager startUploadingPhotos:^{
                                 
                                 [self hideWaitingView];
                                 
                                 [self logOffToLoginView];
                                 
                             } failure:^(NSString * _Nonnull reason) {
                                 
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                     message:NSLocalizedString(@"Can not connect to our server, please try again later", nil)
                                                                                    delegate:nil
                                                                           cancelButtonTitle:nil
                                                                           otherButtonTitles:@"Dismiss",nil];
                                 
                                 [alertView show];
                                 
                                 [self hideWaitingView];
                                 
                             }];
                             
                         } failure:^(NSString *reason) {
                             
                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                 message:NSLocalizedString(@"Can not connect to our server, please try again later", nil)
                                                                                delegate:nil
                                                                       cancelButtonTitle:nil
                                                                       otherButtonTitles:@"Dismiss",nil];
                             
                             [alertView show];
                             
                             [self hideWaitingView];
                         }];
                        
                    }];
                    
                    NSArray<UIAlertAction*>* alertActions = @[cancelAction, noAction, yesAction];
                    [AlertDialogsProvider handlerAlert:alertTitle message:alertMessage action:alertActions];
                }
                else
                {
                    [self checkForInternetConnectivityAndLogOff];
                }
                
            });
        }
            break;

        default:
            break;
    }
}

@end