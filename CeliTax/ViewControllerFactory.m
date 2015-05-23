//
//  ViewControllerFactory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ViewControllerFactory.h"
#import "BaseViewController.h"
#import "SplashViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "SidebarViewController.h"
#import "MainScreenRootViewController.h"
#import "MainViewController.h"
#import "FeedbackViewController.h"
#import "SettingsViewController.h"
#import "MyAccountViewController.h"
#import "AddCatagoryViewController.h"
#import "DeleteCatagoryViewController.h"
#import "TransferCatagoryViewController.h"
#import "CatagoriesManagementViewController.h"
#import "VaultViewController.h"
#import "GHRevealViewController.h"
#import "HelpScreenViewController.h"
#import "ModifyCatagoryViewController.h"
#import "ReceiptCheckingViewController.h"
#import "Catagory.h"
#import "NamesPickerViewController.h"
#import "ColorPickerViewController.h"
#import "ModifyCatagoryPopUpViewController.h"
#import "AllColorsPickerViewController.h"
#import "CameraViewController.h"

@implementation ViewControllerFactory

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

- (SidebarViewController *) createSidebarViewControllerWithGHRevealViewController:(GHRevealViewController *)viewController withControllers:(NSArray *)viewControllers withCellInfos:(NSArray *)cellInfos
{
    SidebarViewController *sidebarViewController = [[SidebarViewController alloc] initWithSidebarViewController:viewController withControllers:viewControllers withCellInfos:cellInfos];
    
    [self initializeViewController: sidebarViewController];
    
    return sidebarViewController;
}

- (MainScreenRootViewController *) createMainScreenRootViewController
{
    MainScreenRootViewController *mainScreenRootViewController = [[MainScreenRootViewController alloc] init];
    
    [self initializeViewController: mainScreenRootViewController];
    
    return mainScreenRootViewController;
}

- (MainViewController *) createMainViewControllerWith:(RevealBlock)revealBlock
{
    MainViewController *mainViewController = [[MainViewController alloc] initWithRevealBlock: revealBlock];
    
    [self initializeViewController: mainViewController];
    
    mainViewController.dataService = self.dataService;
    
    return mainViewController;
}

- (FeedbackViewController *) createFeedbackViewControllerWith:(RevealBlock)revealBlock
{
    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] initWithRevealBlock: revealBlock];
    
    [self initializeViewController: feedbackViewController];
    
    return feedbackViewController;
}

- (SettingsViewController *) createSettingsViewControllerWith:(RevealBlock)revealBlock
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithRevealBlock: revealBlock];
    
    [self initializeViewController: settingsViewController];
    
    return settingsViewController;
}

- (VaultViewController *) createVaultViewControllerWith:(RevealBlock)revealBlock
{
    VaultViewController *vaultViewController = [[VaultViewController alloc] initWithRevealBlock: revealBlock];
    
    [self initializeViewController: vaultViewController];
    
    return vaultViewController;
}

- (HelpScreenViewController *) createHelpScreenViewControllerWith:(RevealBlock)revealBlock
{
    HelpScreenViewController *helpScreenViewController = [[HelpScreenViewController alloc] initWithRevealBlock: revealBlock];
    
    [self initializeViewController: helpScreenViewController];
    
    return helpScreenViewController;
}

- (MyAccountViewController *) createMyAccountViewControllerWith:(RevealBlock)revealBlock
{
    MyAccountViewController *myAccountViewController = [[MyAccountViewController alloc] initWithRevealBlock: revealBlock];
    
    [self initializeViewController: myAccountViewController];
    
    myAccountViewController.dataService = self.dataService;
    
    return myAccountViewController;
}

- (DeleteCatagoryViewController *) createDeleteCatagoryViewController:(Catagory *)catagoryToDelete
{
    DeleteCatagoryViewController *deleteCatagoryViewController = [[DeleteCatagoryViewController alloc] initWithNibName:@"DeleteCatagoryViewController" bundle:nil];
    
    [self initializeViewController: deleteCatagoryViewController];
    
    deleteCatagoryViewController.manipulationService = self.manipulationService;
    deleteCatagoryViewController.catagoryToDelete = catagoryToDelete;
    
    return deleteCatagoryViewController;
}

- (TransferCatagoryViewController *) createTransferCatagoryViewController:(Catagory *)fromCatagory
{
    TransferCatagoryViewController *transferCatagoryViewController = [[TransferCatagoryViewController alloc] initWithNibName:@"TransferCatagoryViewController" bundle:nil];
    
    [self initializeViewController: transferCatagoryViewController];
    
    transferCatagoryViewController.fromCatagory = fromCatagory;
    transferCatagoryViewController.manipulationService = self.manipulationService;
    transferCatagoryViewController.dataService = self.dataService;
    
    return transferCatagoryViewController;
}

- (ModifyCatagoryViewController *) createModifyCatagoryViewControllerWith:(Catagory *)catagoryToModify
{
    ModifyCatagoryViewController *modifyCatagoryViewController = [[ModifyCatagoryViewController alloc] initWithNibName:@"ModifyCatagoryViewController"  bundle:nil];
    
    [self initializeViewController: modifyCatagoryViewController];
    
    modifyCatagoryViewController.manipulationService = self.manipulationService;
    modifyCatagoryViewController.catagoryToModify = catagoryToModify;
    
    return modifyCatagoryViewController;
}

- (CatagoriesManagementViewController *) createCatagoriesManagementViewController
{
    CatagoriesManagementViewController *catagoriesManagementViewController = [[CatagoriesManagementViewController alloc] initWithNibName:@"CatagoriesManagementViewController" bundle:nil];
    
    [self initializeViewController: catagoriesManagementViewController];
    
    catagoriesManagementViewController.dataService = self.dataService;
    
    return catagoriesManagementViewController;
}

- (AddCatagoryViewController *) createAddCatagoryViewController
{
    AddCatagoryViewController *addCatagoryViewController = [[AddCatagoryViewController alloc] initWithNibName:@"AddCatagoryViewController" bundle:nil];
    
    [self initializeViewController: addCatagoryViewController];
    
    addCatagoryViewController.manipulationService = self.manipulationService;
    
    return addCatagoryViewController;
}

- (ReceiptCheckingViewController *) createReceiptCheckingViewControllerForReceiptID:(NSInteger)receiptID
{
    ReceiptCheckingViewController *receiptCheckingViewController = [[ReceiptCheckingViewController alloc] initWithNibName:@"ReceiptCheckingViewController" bundle:nil];
    
    [self initializeViewController: receiptCheckingViewController];
    
    receiptCheckingViewController.dataService = self.dataService;
    receiptCheckingViewController.manipulationService = self.manipulationService;
    receiptCheckingViewController.receiptID = receiptID;
    
    return receiptCheckingViewController;
}

- (NamesPickerViewController *) createNamesPickerViewControllerWithNames:(NSArray *)names
{
    NamesPickerViewController *namesPickerViewController = [[NamesPickerViewController alloc] initWithNibName:@"NamesPickerViewController" bundle:nil];
    
    namesPickerViewController.names = names;
    
    return namesPickerViewController;
}

- (ColorPickerViewController *) createColorPickerViewController
{
    ColorPickerViewController *colorPickerViewController = [[ColorPickerViewController alloc] initWithNibName:@"ColorPickerViewController" bundle:nil];
    
    return colorPickerViewController;
}

- (ModifyCatagoryPopUpViewController *) createModifyCatagoryPopUpViewController
{
    ModifyCatagoryPopUpViewController *modifyCatagoryPopUpViewController = [[ModifyCatagoryPopUpViewController alloc] initWithNibName:@"ModifyCatagoryPopUpViewController" bundle:nil];
    
    return modifyCatagoryPopUpViewController;
}

- (AllColorsPickerViewController *) createAllColorsPickerViewController
{
    AllColorsPickerViewController *allColorsPickerViewController = [[AllColorsPickerViewController alloc] initWithNibName:@"AllColorsPickerViewController" bundle:nil];
    
    return allColorsPickerViewController;
}

- (CameraViewController *) createCameraOverlayViewController
{
    CameraViewController *cameraOverlayViewController = [[CameraViewController alloc] initWithNibName:@"CameraOverlayViewController" bundle:nil];
    
    [self initializeViewController: cameraOverlayViewController];
    cameraOverlayViewController.manipulationService = self.manipulationService;
    
    return cameraOverlayViewController;
}

@end
