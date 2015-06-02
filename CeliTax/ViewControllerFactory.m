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
#import "FeedbackViewController.h"
#import "SettingsViewController.h"
#import "MyAccountViewController.h"
#import "AddCatagoryViewController.h"
#import "DeleteCatagoryViewController.h"
#import "TransferCatagoryViewController.h"
#import "CatagoriesManagementViewController.h"
#import "VaultViewController.h"
#import "HelpScreenViewController.h"
#import "ModifyCatagoryViewController.h"
#import "ReceiptCheckingViewController.h"
#import "Catagory.h"
#import "SelectionsPickerViewController.h"
#import "ColorPickerViewController.h"
#import "ModifyCatagoryPopUpViewController.h"
#import "AllColorsPickerViewController.h"
#import "CameraViewController.h"
#import "ReceiptBreakDownViewController.h"

@implementation ViewControllerFactory {
    NSArray *menuSelections;
}

- (void) initializeViewController: (BaseViewController *) viewController
{
    viewController.configurationManager = self.configurationManager;
    viewController.viewControllerFactory = self;
    viewController.userManager = self.userManager;
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

    mainViewController.dataService = self.dataService;

    return mainViewController;
}

- (FeedbackViewController *) createFeedbackViewController
{
    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] initWithNibName: @"FeedbackViewController" bundle: nil];

    [self initializeViewController: feedbackViewController];

    return feedbackViewController;
}

- (SettingsViewController *) createSettingsViewController
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName: @"SettingsViewController" bundle: nil];

    [self initializeViewController: settingsViewController];

    return settingsViewController;
}

- (VaultViewController *) createVaultViewController
{
    VaultViewController *vaultViewController = [[VaultViewController alloc] initWithNibName: @"VaultViewController" bundle: nil];

    [self initializeViewController: vaultViewController];

    return vaultViewController;
}

- (HelpScreenViewController *) createHelpScreenViewController
{
    HelpScreenViewController *helpScreenViewController = [[HelpScreenViewController alloc] initWithNibName: @"HelpScreenViewController" bundle: nil];

    [self initializeViewController: helpScreenViewController];

    return helpScreenViewController;
}

- (MyAccountViewController *) createMyAccountViewController
{
    MyAccountViewController *myAccountViewController = [[MyAccountViewController alloc] initWithNibName: @"MyAccountViewController" bundle: nil];

    [self initializeViewController: myAccountViewController];

    myAccountViewController.dataService = self.dataService;

    return myAccountViewController;
}

- (DeleteCatagoryViewController *) createDeleteCatagoryViewController: (Catagory *) catagoryToDelete
{
    DeleteCatagoryViewController *deleteCatagoryViewController = [[DeleteCatagoryViewController alloc] initWithNibName: @"DeleteCatagoryViewController" bundle: nil];

    [self initializeViewController: deleteCatagoryViewController];

    deleteCatagoryViewController.manipulationService = self.manipulationService;
    deleteCatagoryViewController.catagoryToDelete = catagoryToDelete;

    return deleteCatagoryViewController;
}

- (TransferCatagoryViewController *) createTransferCatagoryViewController: (Catagory *) fromCatagory
{
    TransferCatagoryViewController *transferCatagoryViewController = [[TransferCatagoryViewController alloc] initWithNibName: @"TransferCatagoryViewController" bundle: nil];

    [self initializeViewController: transferCatagoryViewController];

    transferCatagoryViewController.fromCatagory = fromCatagory;
    transferCatagoryViewController.manipulationService = self.manipulationService;
    transferCatagoryViewController.dataService = self.dataService;

    return transferCatagoryViewController;
}

- (ModifyCatagoryViewController *) createModifyCatagoryViewControllerWith: (Catagory *) catagoryToModify
{
    ModifyCatagoryViewController *modifyCatagoryViewController = [[ModifyCatagoryViewController alloc] initWithNibName: @"ModifyCatagoryViewController"  bundle: nil];

    [self initializeViewController: modifyCatagoryViewController];

    modifyCatagoryViewController.manipulationService = self.manipulationService;
    modifyCatagoryViewController.catagoryToModify = catagoryToModify;

    return modifyCatagoryViewController;
}

- (CatagoriesManagementViewController *) createCatagoriesManagementViewController
{
    CatagoriesManagementViewController *catagoriesManagementViewController = [[CatagoriesManagementViewController alloc] initWithNibName: @"CatagoriesManagementViewController" bundle: nil];

    [self initializeViewController: catagoriesManagementViewController];

    catagoriesManagementViewController.dataService = self.dataService;

    return catagoriesManagementViewController;
}

- (AddCatagoryViewController *) createAddCatagoryViewController
{
    AddCatagoryViewController *addCatagoryViewController = [[AddCatagoryViewController alloc] initWithNibName: @"AddCatagoryViewController" bundle: nil];

    [self initializeViewController: addCatagoryViewController];

    addCatagoryViewController.manipulationService = self.manipulationService;

    return addCatagoryViewController;
}

- (ReceiptCheckingViewController *) createReceiptCheckingViewControllerForReceiptID: (NSString *) receiptID
{
    ReceiptCheckingViewController *receiptCheckingViewController = [[ReceiptCheckingViewController alloc] initWithNibName: @"ReceiptCheckingViewController" bundle: nil];

    [self initializeViewController: receiptCheckingViewController];

    receiptCheckingViewController.dataService = self.dataService;
    receiptCheckingViewController.manipulationService = self.manipulationService;
    receiptCheckingViewController.receiptID = receiptID;

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

- (SelectionsPickerViewController *) createNamesPickerViewControllerWithNames: (NSArray *) names
{
    SelectionsPickerViewController *namesPickerViewController = [[SelectionsPickerViewController alloc] initWithNibName: @"NamesPickerViewController" bundle: nil];

    namesPickerViewController.names = names;

    return namesPickerViewController;
}

- (ColorPickerViewController *) createColorPickerViewController
{
    ColorPickerViewController *colorPickerViewController = [[ColorPickerViewController alloc] initWithNibName: @"ColorPickerViewController" bundle: nil];

    return colorPickerViewController;
}

- (ModifyCatagoryPopUpViewController *) createModifyCatagoryPopUpViewController
{
    ModifyCatagoryPopUpViewController *modifyCatagoryPopUpViewController = [[ModifyCatagoryPopUpViewController alloc] initWithNibName: @"ModifyCatagoryPopUpViewController" bundle: nil];

    return modifyCatagoryPopUpViewController;
}

- (AllColorsPickerViewController *) createAllColorsPickerViewController
{
    AllColorsPickerViewController *allColorsPickerViewController = [[AllColorsPickerViewController alloc] initWithNibName: @"AllColorsPickerViewController" bundle: nil];

    return allColorsPickerViewController;
}

- (CameraViewController *) createCameraOverlayViewController
{
    CameraViewController *cameraOverlayViewController = [[CameraViewController alloc] initWithNibName: @"CameraViewController" bundle: nil];

    [self initializeViewController: cameraOverlayViewController];
    cameraOverlayViewController.manipulationService = self.manipulationService;

    return cameraOverlayViewController;
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