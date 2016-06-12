//
// ViewControllerFactory.h
// CeliTax
//
// Created by Leon Chen on 2015-04-30.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AuthenticationService, ConfigurationManager, UserManager, LookAndFeel, DataService, ManipulationService, SyncService;
@class BaseViewController, LoginViewController, RegisterViewController, SettingsViewController, VaultViewController, HelpScreenViewController, MyAccountViewController, MainViewController, ModifyCatagoryViewController, AddCategoryViewController, SidebarViewController, ItemCategory, ReceiptCheckingViewController, SelectionsPickerViewController, ColorPickerViewController, AllColorsPickerViewController, CameraViewController, ReceiptBreakDownViewController, SendReceiptsToViewController, PasswordRecoverySentViewController, PasswordRecoveryViewController, TransferSelectionsViewController, TutorialManager, SyncManager, ProfileSettingsViewController, ImperialUnitPickerViewController, MetricUnitPickerViewController, YearSummaryViewController, YearSavingViewController, BackgroundWorker, LoginSettingsViewController;

@interface ViewControllerFactory : NSObject

@property (nonatomic, weak) UserManager *userManager;
@property (nonatomic, weak) ConfigurationManager *configurationManager;      /** Used to get global configuration values */

@property (nonatomic, weak) AuthenticationService *authenticationService;
@property (nonatomic, weak) DataService *dataService;
@property (nonatomic, weak) ManipulationService *manipulationService;
@property (nonatomic, weak) SyncService *syncService;
@property (nonatomic, weak) LookAndFeel *lookAndFeel;
@property (nonatomic, weak) SyncManager *syncManager;
@property (nonatomic, weak) BackgroundWorker *backgroundWorker;

@property (nonatomic, weak) UIView *navigationBarTitleImageContainer;

- (LoginViewController *) createLoginViewController;

- (RegisterViewController *) createRegisterViewController;

- (MainViewController *) createMainViewController;

- (SettingsViewController *) createSettingsViewController;

- (VaultViewController *) createVaultViewController;

- (HelpScreenViewController *) createHelpScreenViewController;

- (MyAccountViewController *) createMyAccountViewController;

- (ModifyCatagoryViewController *) createModifyCatagoryViewControllerWith: (ItemCategory *) catagoryToModify;

- (AddCategoryViewController *) createAddCategoryViewController;

- (ReceiptCheckingViewController *) createReceiptCheckingViewControllerForReceiptID: (NSString *) receiptID cameFromReceiptBreakDownViewController: (BOOL) cameFromReceiptBreakDownViewController;

- (ReceiptBreakDownViewController *) createReceiptBreakDownViewControllerForReceiptID: (NSString *) receiptID cameFromReceiptCheckingViewController: (BOOL) cameFromReceiptCheckingViewController;

- (SelectionsPickerViewController *) createSelectionsPickerViewControllerWithSelections: (NSArray *) selections;

- (TransferSelectionsViewController *) createTransferSelectionsViewController: (NSArray *) selections;

- (ColorPickerViewController *) createColorPickerViewController;

- (AllColorsPickerViewController *) createAllColorsPickerViewController;

- (CameraViewController *) createCameraOverlayViewControllerWithExistingReceiptID:(NSString *) receiptID;

- (SendReceiptsToViewController *) createSendReceiptsToViewController:(NSString *)defaultEmailAddress;

- (PasswordRecoveryViewController *) createPasswordRecoveryViewController;

- (PasswordRecoverySentViewController *) createPasswordRecoverySentViewController;

- (ProfileSettingsViewController *) createProfileSettingsViewController;

- (MetricUnitPickerViewController *) createUnitPickerViewControllerWithDefaultUnit:(NSInteger)defaultUnit;

- (ImperialUnitPickerViewController *) createImperialUnitPickerViewControllerWithDefaultUnit:(NSInteger)defaultUnit;

- (YearSummaryViewController *) createYearSummaryViewController;

- (YearSavingViewController *) createYearSavingViewController;

- (LoginSettingsViewController *) createLoginSettingsViewController;

@end