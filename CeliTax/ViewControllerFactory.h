//
// ViewControllerFactory.h
// CeliTax
//
// Created by Leon Chen on 2015-04-30.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConfigurationManager, UserManager;
@class BaseViewController, SplashViewController, LoginViewController, RegisterViewController, FeedbackViewController, SettingsViewController, VaultViewController, HelpScreenViewController, MyAccountViewController, MainViewController, DeleteCatagoryViewController, TransferCatagoryViewController, ModifyCatagoryViewController, CatagoriesManagementViewController, AddCatagoryViewController, SidebarViewController, Catagory, ReceiptCheckingViewController, SelectionsPickerViewController, ColorPickerViewController, ModifyCatagoryPopUpViewController, AllColorsPickerViewController, CameraViewController, ReceiptBreakDownViewController;

@protocol AuthenticationService, DataService, ManipulationService;

@interface ViewControllerFactory : NSObject

@property (nonatomic, weak) UserManager *userManager;
@property (nonatomic, weak) ConfigurationManager *configurationManager;      /** Used to get global configuration values */

@property (nonatomic, weak) id <AuthenticationService> authenticationService;
@property (nonatomic, weak) id <DataService> dataService;
@property (nonatomic, weak) id <ManipulationService> manipulationService;

- (SplashViewController *) createSplashViewController;

- (LoginViewController *) createLoginViewController;

- (RegisterViewController *) createRegisterViewController;

- (MainViewController *) createMainViewController;

- (FeedbackViewController *) createFeedbackViewController;

- (SettingsViewController *) createSettingsViewController;

- (VaultViewController *) createVaultViewController;

- (HelpScreenViewController *) createHelpScreenViewController;

- (MyAccountViewController *) createMyAccountViewController;

- (DeleteCatagoryViewController *) createDeleteCatagoryViewController: (Catagory *) catagoryToDelete;

- (TransferCatagoryViewController *) createTransferCatagoryViewController: (Catagory *) fromCatagory;

- (ModifyCatagoryViewController *) createModifyCatagoryViewControllerWith: (Catagory *) catagoryToModify;

- (CatagoriesManagementViewController *) createCatagoriesManagementViewController;

- (AddCatagoryViewController *) createAddCatagoryViewController;

- (ReceiptCheckingViewController *) createReceiptCheckingViewControllerForReceiptID: (NSString *) receiptID cameFromReceiptBreakDownViewController: (BOOL) cameFromReceiptBreakDownViewController;

- (ReceiptBreakDownViewController *) createReceiptBreakDownViewControllerForReceiptID: (NSString *) receiptID cameFromReceiptCheckingViewController: (BOOL) cameFromReceiptCheckingViewController;

- (SelectionsPickerViewController *) createSelectionsPickerViewControllerWithSelections: (NSArray *) selections;

- (ColorPickerViewController *) createColorPickerViewController;

- (ModifyCatagoryPopUpViewController *) createModifyCatagoryPopUpViewController;

- (AllColorsPickerViewController *) createAllColorsPickerViewController;

- (CameraViewController *) createCameraOverlayViewController;

- (NSArray *) getMenuSelections;

@end