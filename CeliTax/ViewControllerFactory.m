//
// ViewControllerFactory.m
// CeliTax
//
// Created by Leon Chen on 2015-04-30.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ViewControllerFactory.h"
#import "BaseViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "MainViewController.h"
#import "SettingsViewController.h"
#import "MyAccountViewController.h"
#import "AddCategoryViewController.h"
#import "VaultViewController.h"
#import "HelpScreenViewController.h"
#import "ModifyCatagoryViewController.h"
#import "ReceiptCheckingViewController.h"
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
#import "ProfileSettingsViewController.h"
#import "MetricUnitPickerViewController.h"
#import "YearSummaryViewController.h"
#import "YearSavingViewController.h"
#import "LoginSettingsViewController.h"
#import "ImperialUnitPickerViewController.h"
#import "SubscriptionManager.h"
#import "SubscriptionViewController.h"

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
    viewController.subscriptionManager = self.subscriptionManager;
    
    if (!tutorialManager)
    {
        tutorialManager = [[TutorialManager alloc] initWithViewControllerFactory:self andLookAndFeel:self.lookAndFeel];
    }
    
    viewController.tutorialManager = tutorialManager;
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
    vaultViewController.syncService = self.syncService;

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

- (ModifyCatagoryViewController *) createModifyCatagoryViewControllerWith: (ItemCategory *) catagoryToModify
{
    ModifyCatagoryViewController *modifyCatagoryViewController = [[ModifyCatagoryViewController alloc] initWithNibName: @"ModifyCatagoryViewController"  bundle: nil];

    [self initializeViewController: modifyCatagoryViewController];

    modifyCatagoryViewController.manipulationService = self.manipulationService;
    modifyCatagoryViewController.catagoryToModify = catagoryToModify;

    return modifyCatagoryViewController;
}

- (AddCategoryViewController *) createAddCategoryViewController
{
    AddCategoryViewController *addCategoryViewController = [[AddCategoryViewController alloc] initWithNibName: @"AddCategoryViewController" bundle: nil];

    [self initializeViewController: addCategoryViewController];

    addCategoryViewController.manipulationService = self.manipulationService;
    addCategoryViewController.dataService = self.dataService;

    return addCategoryViewController;
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
    
    passwordRecoveryViewController.authenticationService = self.authenticationService;

    return passwordRecoveryViewController;
}

- (PasswordRecoverySentViewController *) createPasswordRecoverySentViewController
{
    PasswordRecoverySentViewController *passwordRecoverySentViewController = [[PasswordRecoverySentViewController alloc] initWithNibName: @"PasswordRecoverySentViewController" bundle: nil];

    [self initializeViewController: passwordRecoverySentViewController];

    return passwordRecoverySentViewController;
}

- (ProfileSettingsViewController *) createProfileSettingsViewController
{
    ProfileSettingsViewController *myProfileViewController = [[ProfileSettingsViewController alloc] initWithNibName: @"ProfileSettingsViewController" bundle: nil];
    
    [self initializeViewController: myProfileViewController];
    
    myProfileViewController.lookAndFeel = self.lookAndFeel;
    myProfileViewController.authenticationService = self.authenticationService;
    
    return myProfileViewController;
}

- (MetricUnitPickerViewController *) createUnitPickerViewControllerWithDefaultUnit:(NSInteger)defaultUnit
{
    MetricUnitPickerViewController *unitPickerViewController = [[MetricUnitPickerViewController alloc] initWithNibName: @"MetricUnitPickerViewController" bundle: nil];
    
    [self initializeViewController: unitPickerViewController];
    
    unitPickerViewController.lookAndFeel = self.lookAndFeel;
    unitPickerViewController.defaultSelectedUnit = defaultUnit;
    
    return unitPickerViewController;
}

- (ImperialUnitPickerViewController *) createImperialUnitPickerViewControllerWithDefaultUnit:(NSInteger)defaultUnit
{
    ImperialUnitPickerViewController *unitPickerViewController = [[ImperialUnitPickerViewController alloc] initWithNibName: @"ImperialUnitPickerViewController" bundle: nil];
    
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

- (LoginSettingsViewController *) createLoginSettingsViewController
{
    LoginSettingsViewController *loginSettingsViewController = [[LoginSettingsViewController alloc] initWithNibName: @"LoginSettingsViewController" bundle: nil];
    
    [self initializeViewController: loginSettingsViewController];
    
    loginSettingsViewController.lookAndFeel = self.lookAndFeel;
    loginSettingsViewController.authenticationService = self.authenticationService;
    
    return loginSettingsViewController;
}

- (SubscriptionViewController *) createSubscriptionViewController
{
    SubscriptionViewController *subscriptionViewController = [[SubscriptionViewController alloc] initWithNibName: @"SubscriptionViewController" bundle: nil];
    
    [self initializeViewController: subscriptionViewController];
    
    subscriptionViewController.lookAndFeel = self.lookAndFeel;
    
    return subscriptionViewController;
}

@end