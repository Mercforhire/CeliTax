//
// ViewControllerFactory.m
// CeliTax
//
// Created by Leon Chen on 2015-04-30.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ViewControllerFactory.h"
#import "BaseViewController.h"
#import "SplashViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "MainViewController.h"
#import "SettingsViewController.h"
#import "MyAccountViewController.h"
#import "AddCatagoryViewController.h"
#import "VaultViewController.h"
#import "HelpScreenViewController.h"
#import "ModifyCatagoryViewController.h"
#import "ReceiptCheckingViewController.h"
#import "Catagory.h"
#import "SelectionsPickerViewController.h"
#import "ColorPickerViewController.h"
#import "AllColorsPickerViewController.h"
#import "CameraViewController.h"
#import "ReceiptBreakDownViewController.h"
#import "SendReceiptsToViewController.h"
#import "PasswordRecoveryViewController.h"
#import "PasswordRecoverySentViewController.h"
#import "TransferSelectionsViewController.h"
#import "TutorialManager.h"
#import "MyProfileViewController.h"
#import "UnitPickerViewController.h"
#import "YearSummaryViewController.h"
#import "YearSavingViewController.h"
#import "BackgroundWorker.h"

@implementation ViewControllerFactory
{
    NSArray *menuSelections;
    TutorialManager *tutorialManager;      /** Used to get global configuration values */
}

- (void) initializeViewController: (BaseViewController *) viewController
{
    viewController.configurationManager = self.configurationManager;
    viewController.viewControllerFactory = self;
    viewController.userManager = self.userManager;
    viewController.lookAndFeel = self.lookAndFeel;
    viewController.navigationBarTitleImageContainer = self.navigationBarTitleImageContainer;
    viewController.backgroundWorker = self.backgroundWorker;
    
    if (!tutorialManager)
    {
        tutorialManager = [[TutorialManager alloc] initWithViewControllerFactory:self andLookAndFeel:self.lookAndFeel];
    }
    
    viewController.tutorialManager = tutorialManager;
}

- (SplashViewController *) createSplashViewController
{
    SplashViewController *splashViewController = [[SplashViewController alloc] initWithNibName: @"SplashViewController" bundle: nil];

    [self initializeViewController: splashViewController];

    return splashViewController;
}

- (LoginViewController *) createLoginViewController
{
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName: @"LoginViewController" bundle: nil];

    [self initializeViewController: loginViewController];

    loginViewController.authenticationService = self.authenticationService;

    return loginViewController;
}

- (RegisterViewController *) createRegisterViewController
{
    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName: @"RegisterViewController" bundle: nil];

    [self initializeViewController: registerViewController];

    registerViewController.authenticationService = self.authenticationService;

    return registerViewController;
}

- (MainViewController *) createMainViewController
{
    MainViewController *mainViewController = [[MainViewController alloc] initWithNibName: @"MainViewController" bundle: nil];

    [self initializeViewController: mainViewController];

    mainViewController.manipulationService = self.manipulationService;
    mainViewController.dataService = self.dataService;
    mainViewController.syncManager = self.syncManager;

    return mainViewController;
}

- (SettingsViewController *) createSettingsViewController
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName: @"SettingsViewController" bundle: nil];

    [self initializeViewController: settingsViewController];
    
    settingsViewController.syncService = self.syncService;
    settingsViewController.syncManager = self.syncManager;

    return settingsViewController;
}

- (VaultViewController *) createVaultViewController
{
    VaultViewController *vaultViewController = [[VaultViewController alloc] initWithNibName: @"VaultViewController" bundle: nil];

    [self initializeViewController: vaultViewController];

    vaultViewController.dataService = self.dataService;
    vaultViewController.manipulationService = self.manipulationService;

    return vaultViewController;
}

- (HelpScreenViewController *) createHelpScreenViewController
{
    HelpScreenViewController *helpScreenViewController = [[HelpScreenViewController alloc] initWithNibName: @"HelpScreenViewController" bundle: nil];

    [self initializeViewController: helpScreenViewController];
    
    helpScreenViewController.authenticationService = self.authenticationService;

    return helpScreenViewController;
}

- (MyAccountViewController *) createMyAccountViewController
{
    MyAccountViewController *myAccountViewController = [[MyAccountViewController alloc] initWithNibName: @"MyAccountViewController" bundle: nil];

    [self initializeViewController: myAccountViewController];

    myAccountViewController.dataService = self.dataService;
    myAccountViewController.manipulationService = self.manipulationService;

    return myAccountViewController;
}

- (ModifyCatagoryViewController *) createModifyCatagoryViewControllerWith: (Catagory *) catagoryToModify
{
    ModifyCatagoryViewController *modifyCatagoryViewController = [[ModifyCatagoryViewController alloc] initWithNibName: @"ModifyCatagoryViewController"  bundle: nil];

    [self initializeViewController: modifyCatagoryViewController];

    modifyCatagoryViewController.manipulationService = self.manipulationService;
    modifyCatagoryViewController.catagoryToModify = catagoryToModify;

    return modifyCatagoryViewController;
}

- (AddCatagoryViewController *) createAddCatagoryViewController
{
    AddCatagoryViewController *addCatagoryViewController = [[AddCatagoryViewController alloc] initWithNibName: @"AddCatagoryViewController" bundle: nil];

    [self initializeViewController: addCatagoryViewController];

    addCatagoryViewController.manipulationService = self.manipulationService;
    addCatagoryViewController.dataService = self.dataService;

    return addCatagoryViewController;
}

- (ReceiptCheckingViewController *) createReceiptCheckingViewControllerForReceiptID: (NSString *) receiptID cameFromReceiptBreakDownViewController: (BOOL) cameFromReceiptBreakDownViewController
{
    ReceiptCheckingViewController *receiptCheckingViewController = [[ReceiptCheckingViewController alloc] initWithNibName: @"ReceiptCheckingViewController" bundle: nil];

    [self initializeViewController: receiptCheckingViewController];

    receiptCheckingViewController.dataService = self.dataService;
    receiptCheckingViewController.manipulationService = self.manipulationService;
    receiptCheckingViewController.receiptID = receiptID;
    receiptCheckingViewController.cameFromReceiptBreakDownViewController = cameFromReceiptBreakDownViewController;
    receiptCheckingViewController.syncManager = self.syncManager;

    return receiptCheckingViewController;
}

- (ReceiptBreakDownViewController *) createReceiptBreakDownViewControllerForReceiptID: (NSString *) receiptID cameFromReceiptCheckingViewController: (BOOL) cameFromReceiptCheckingViewController
{
    ReceiptBreakDownViewController *receiptBreakDownViewController = [[ReceiptBreakDownViewController alloc] initWithNibName: @"ReceiptBreakDownViewController" bundle: nil];

    [self initializeViewController: receiptBreakDownViewController];

    receiptBreakDownViewController.dataService = self.dataService;
    receiptBreakDownViewController.manipulationService = self.manipulationService;
    receiptBreakDownViewController.receiptID = receiptID;
    receiptBreakDownViewController.cameFromReceiptCheckingViewController = cameFromReceiptCheckingViewController;

    return receiptBreakDownViewController;
}

- (SelectionsPickerViewController *) createSelectionsPickerViewControllerWithSelections: (NSArray *) selections
{
    SelectionsPickerViewController *namesPickerViewController = [[SelectionsPickerViewController alloc] initWithNibName: @"SelectionsPickerViewController" bundle: nil];

    [self initializeViewController: namesPickerViewController];
    
    namesPickerViewController.selections = selections;

    return namesPickerViewController;
}

- (TransferSelectionsViewController *) createTransferSelectionsViewController: (NSArray *) selections
{
    TransferSelectionsViewController *transferSelectionsViewController = [[TransferSelectionsViewController alloc] initWithNibName: @"TransferSelectionsViewController" bundle: nil];
    
    [self initializeViewController: transferSelectionsViewController];
    
    transferSelectionsViewController.selections = selections;
    
    return transferSelectionsViewController;
}

- (ColorPickerViewController *) createColorPickerViewController
{
    ColorPickerViewController *colorPickerViewController = [[ColorPickerViewController alloc] initWithNibName: @"ColorPickerViewController" bundle: nil];

    [self initializeViewController: colorPickerViewController];

    return colorPickerViewController;
}

- (AllColorsPickerViewController *) createAllColorsPickerViewController
{
    AllColorsPickerViewController *allColorsPickerViewController = [[AllColorsPickerViewController alloc] initWithNibName: @"AllColorsPickerViewController" bundle: nil];

    [self initializeViewController: allColorsPickerViewController];

    return allColorsPickerViewController;
}

- (CameraViewController *) createCameraOverlayViewControllerWithExistingReceiptID:(NSString *) receiptID
{
    CameraViewController *cameraOverlayViewController = [[CameraViewController alloc] initWithNibName: @"CameraViewController" bundle: nil];

    [self initializeViewController: cameraOverlayViewController];
    cameraOverlayViewController.dataService = self.dataService;
    cameraOverlayViewController.manipulationService = self.manipulationService;
    cameraOverlayViewController.existingReceiptID = receiptID;

    return cameraOverlayViewController;
}

- (SendReceiptsToViewController *) createSendReceiptsToViewController
{
    SendReceiptsToViewController *sendReceiptsToViewController = [[SendReceiptsToViewController alloc] initWithNibName: @"SendReceiptsToViewController" bundle: nil];

    [self initializeViewController: sendReceiptsToViewController];

    return sendReceiptsToViewController;
}

- (PasswordRecoveryViewController *) createPasswordRecoveryViewController
{
    PasswordRecoveryViewController *passwordRecoveryViewController = [[PasswordRecoveryViewController alloc] initWithNibName: @"PasswordRecoveryViewController" bundle: nil];

    [self initializeViewController: passwordRecoveryViewController];

    return passwordRecoveryViewController;
}

- (PasswordRecoverySentViewController *) createPasswordRecoverySentViewController
{
    PasswordRecoverySentViewController *passwordRecoverySentViewController = [[PasswordRecoverySentViewController alloc] initWithNibName: @"PasswordRecoverySentViewController" bundle: nil];

    [self initializeViewController: passwordRecoverySentViewController];

    return passwordRecoverySentViewController;
}

- (MyProfileViewController *) createMyProfileViewController
{
    MyProfileViewController *myProfileViewController = [[MyProfileViewController alloc] initWithNibName: @"MyProfileViewController" bundle: nil];
    
    [self initializeViewController: myProfileViewController];
    
    myProfileViewController.lookAndFeel = self.lookAndFeel;
    myProfileViewController.authenticationService = self.authenticationService;
    
    return myProfileViewController;
}

- (UnitPickerViewController *) createUnitPickerViewControllerWithDefaultUnit:(NSInteger)defaultUnit
{
    UnitPickerViewController *unitPickerViewController = [[UnitPickerViewController alloc] initWithNibName: @"UnitPickerViewController" bundle: nil];
    
    [self initializeViewController: unitPickerViewController];
    
    unitPickerViewController.lookAndFeel = self.lookAndFeel;
    unitPickerViewController.defaultSelectedUnit = defaultUnit;
    
    return unitPickerViewController;
}

- (YearSummaryViewController *) createYearSummaryViewController
{
    YearSummaryViewController *yearSummaryViewController = [[YearSummaryViewController alloc] initWithNibName: @"YearSummaryViewController" bundle: nil];
    
    [self initializeViewController: yearSummaryViewController];
    
    yearSummaryViewController.lookAndFeel = self.lookAndFeel;
    yearSummaryViewController.dataService = self.dataService;
    
    return yearSummaryViewController;
}

- (YearSavingViewController *) createYearSavingViewController
{
    YearSavingViewController *yearSavingViewController = [[YearSavingViewController alloc] initWithNibName: @"YearSavingViewController" bundle: nil];
    
    [self initializeViewController: yearSavingViewController];
    
    yearSavingViewController.lookAndFeel = self.lookAndFeel;
    yearSavingViewController.dataService = self.dataService;
    
    return yearSavingViewController;
}

- (NSArray *) getMenuSelections
{
    if (!menuSelections)
    {
        menuSelections = [NSArray arrayWithObjects: @"Home", @"Account", @"Vault", @"Help", @"Settings", @"Logout", nil];
    }

    return menuSelections;
}

@end