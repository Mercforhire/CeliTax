//
// MainViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MainViewController.h"
#import "MainViewTableViewCell.h"
#import "UserManager.h"
#import "AddCategoryViewController.h"
#import "ReceiptCheckingViewController.h"
#import "CameraViewController.h"
#import "ViewControllerFactory.h"
#import "MyAccountViewController.h"
#import "VaultViewController.h"
#import "SelectionsPickerViewController.h"
#import "WYPopoverController.h"
#import "ReceiptBreakDownViewController.h"
#import "TriangleView.h"
#import "LoginViewController.h"
#import "ConfigurationManager.h"
#import "UIView+Helper.h"
#import "NoItemsTableViewCell.h"
#import "TutorialManager.h"
#import "DataService.h"
#import "ManipulationService.h"
#import "MBProgressHUD.h"
#import "SyncManager.h"
#import "Utils.h"
#import "SubscriptionManager.h"

#import "CeliTax-Swift.h"

#define kRecentUploadTableRowHeight                     40
#define kNoItemsTableViewCellIdentifier                 @"NoItemsTableViewCell"

typedef NS_ENUM(NSUInteger, SectionTitles)
{
    SectionReceiptsUploads,
    SectionQuickLinks,
    SectionCount,
};

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, SelectionsPickerPopUpDelegate, UIPickerViewDataSource, UIPickerViewDelegate, TutorialManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *recentUploadsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *quickLinksTitleLabel;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (nonatomic, strong) UIBarButtonItem *addCatagoryMenuItem;
@property (weak, nonatomic) IBOutlet UITableView *recentUploadsTable;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *taxYearLabel;
@property (weak, nonatomic) IBOutlet TriangleView *taxYearTriangle;
@property (strong, nonatomic) UIPickerView *taxYearPicker;
@property (weak, nonatomic) IBOutlet UITextField *invisibleNewTaxYearField;
@property (weak, nonatomic) IBOutlet UIButton *categoriesButton;
@property (weak, nonatomic) IBOutlet UIButton *myAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *vaultButton;
@property (strong, nonatomic) MBProgressHUD *waitView;

@property (nonatomic, strong) WYPopoverController *selectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *taxYearPickerViewController;

// Dictionaries of keys: kReceiptIDKey,kColorKey,kCatagoryNameKey,kCatagoryTotalAmountKey
@property (nonatomic, strong) NSArray *receiptInfos;

// sorted from most recent to oldest
@property (nonatomic, strong) NSArray *existingTaxYears;
@property (nonatomic, strong) NSMutableArray *possibleTaxYears;
@property (nonatomic, copy) NSString *taxYearToAdd;

@property (nonatomic, strong) NSNumber *currentlySelectedYear;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

//Tutorials
@property (nonatomic, strong) NSMutableArray *tutorials;

@end

@implementation MainViewController

- (void) setupUI
{
    [self.navigationItem setHidesBackButton: YES];
    
    [self.taxYearLabel setText:NSLocalizedString(@"No Tax Year Added", nil)];

    UINib *mainTableCell = [UINib nibWithNibName: @"MainViewTableViewCell" bundle: nil];
    [self.recentUploadsTable registerNib: mainTableCell forCellReuseIdentifier: @"MainTableCell"];
    
    UINib *noItemTableCell = [UINib nibWithNibName: @"NoItemsTableViewCell" bundle: nil];
    [self.recentUploadsTable registerNib: noItemTableCell forCellReuseIdentifier: kNoItemsTableViewCellIdentifier];

    // remove loginViewController from stack
    NSMutableArray *viewControllers = [(self.navigationController).viewControllers mutableCopy];

    for (UIViewController *viewController in viewControllers)
    {
        if ([viewController isKindOfClass: [LoginViewController class]])
        {
            [viewControllers removeObject: viewController];
            break;
        }
    }

    (self.navigationController).viewControllers = viewControllers;
    
    self.possibleTaxYears = [NSMutableArray new];
    for (int year = 2010; year < 2016; year++)
    {
        [self.possibleTaxYears addObject:@(year)];
    }
    
    self.taxYearPicker = [[UIPickerView alloc] init];
    self.taxYearPicker.delegate = self;
    self.taxYearPicker.dataSource = self;
    self.taxYearPicker.showsSelectionIndicator = YES;
    self.taxYearPicker.backgroundColor = [UIColor whiteColor];
    
    self.invisibleNewTaxYearField.inputView = self.taxYearPicker;
    
    // Create Cancel and Add button in UIPickerView toolbar
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.pickerToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *cancelToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Cancel", nil)
                                                                           style: UIBarButtonItemStylePlain
                                                                          target: self
                                                                          action: @selector(cancelAddTaxYear)];
    [cancelToolbarButton setTitleTextAttributes: @{NSFontAttributeName: [UIFont latoBoldFontOfSize: 15], NSForegroundColorAttributeName: self.lookAndFeel.appGreenColor} forState: UIControlStateNormal];
    
    UIBarButtonItem *addToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Done", nil)
                                                                        style: UIBarButtonItemStylePlain
                                                                       target: self
                                                                       action: @selector(addTaxYear)];
    [addToolbarButton setTitleTextAttributes: @{NSFontAttributeName: [UIFont latoBoldFontOfSize: 15], NSForegroundColorAttributeName: self.lookAndFeel.appGreenColor} forState: UIControlStateNormal];
    
    self.pickerToolbar.items = @[cancelToolbarButton,
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                addToolbarButton];
    [self.pickerToolbar sizeToFit];

    
    self.invisibleNewTaxYearField.inputAccessoryView = self.pickerToolbar;
    
    [self.recentUploadsTitleLabel setText:NSLocalizedString(@"Recent Uploads", nil)];
    [self.quickLinksTitleLabel setText:NSLocalizedString(@"Quick Links", nil)];
    [self.categoriesButton setTitle:NSLocalizedString(@"Categories", nil) forState:UIControlStateNormal];
    [self.myAccountButton setTitle:NSLocalizedString(@"My Account", nil) forState:UIControlStateNormal];
    [self.vaultButton setTitle:NSLocalizedString(@"Vault", nil) forState:UIControlStateNormal];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    self.recentUploadsTable.dataSource = self;
    self.recentUploadsTable.delegate = self;

    self.dateFormatter = [[NSDateFormatter alloc] init];

    UITapGestureRecognizer *taxYearPressedTap =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(taxYearPressed)];
    UITapGestureRecognizer *taxYearPressedTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(taxYearPressed)];
    [self.taxYearLabel addGestureRecognizer: taxYearPressedTap];
    [self.taxYearTriangle addGestureRecognizer: taxYearPressedTap2];
    
    if (!self.userManager.subscriptionActive)
    {
        [self.cameraButton setEnabled: NO];
        
        [self.userManager updateUserSubscriptionExpiryDate:^{
            
            [self.cameraButton setEnabled: YES];
            
        } failure:^(NSString *reason) {
            
            [self.cameraButton setEnabled: YES];
            
        }];
    }
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self refreshTaxYears];
    
    if ([self.configurationManager getCurrentTaxYear] &&
        [self.existingTaxYears containsObject: [self.configurationManager getCurrentTaxYear]] )
    {
        self.currentlySelectedYear = [self.configurationManager getCurrentTaxYear];
    }
    else if (self.existingTaxYears.count)
    {
        self.currentlySelectedYear = (self.existingTaxYears).firstObject;
    }
    else
    {
        self.taxYearToAdd = @"2015";
        
        [self addTaxYear];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.tutorialManager hasTutorialBeenShown])
    {
        [self setupTutorials];
        
        // decide which set of tutorials to show based on self.tutorialManager.currentStep
        if (self.tutorialManager.currentStep == 1)
        {
            [self displayTutorialStep:TutorialStep1];
        }
        else if (self.tutorialManager.currentStep == 8)
        {
            [self displayTutorialStep:TutorialStep8];
        }
        else if (self.tutorialManager.currentStep == 18)
        {
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self selectedMenuIndex:RootViewControllerVault];
        }
        else if (self.tutorialManager.currentStep == 21)
        {
            [self displayTutorialStep:TutorialStep21];
        }
    }
    else
    {
        if (!self.userManager.doNotShowDisclaimer)
        {
            NSString *message = NSLocalizedString(@"CeliTax is to be used as a resource tool only! CeliTax is in no way responsible for the accuracy of your tax return. Consult your accountant for all tax related inquiries. Cheers!", nil);
            
            UIAlertView *messageBox = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Notice", nil)
                                                                 message: message
                                                                delegate: self
                                                       cancelButtonTitle: NSLocalizedString(@"Dismiss", nil)
                                                       otherButtonTitles: NSLocalizedString(@"Never show again", nil), nil];
            
            [messageBox show];
        }
        
        [self checkUpdate];
    }
}

- (void) createAndShowWaitViewForDownload
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
        self.waitView.labelText = NSLocalizedString(@"Please wait", nil);
        self.waitView.detailsLabelText = NSLocalizedString(@"Downloading Data...", nil);
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview: self.waitView];
    }
    
    [self.waitView show: YES];
}

-(void)cancelAddTaxYear
{
    [self.invisibleNewTaxYearField resignFirstResponder];
}

-(void)addTaxYear
{
    if ([self.existingTaxYears containsObject:self.taxYearToAdd])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                          message:NSLocalizedString(@"Can not add a duplicate tax year", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Dismiss", nil),nil];
        
        [message show];
        
        return;
    }
    
    [self.invisibleNewTaxYearField resignFirstResponder];
    
    [self.manipulationService addTaxYear:self.taxYearToAdd.integerValue save:YES];
    
    [self refreshTaxYears];
    
    if (!self.currentlySelectedYear)
    {
        self.currentlySelectedYear = (self.existingTaxYears).firstObject;
    }
}

-(void)refreshTaxYears
{
    self.existingTaxYears = [self.dataService fetchTaxYears];
    
    NSMutableArray *yearSelections = [NSMutableArray new];
    
    for (NSNumber *year in self.existingTaxYears )
    {
        [yearSelections addObject: [NSString stringWithFormat: NSLocalizedString(@"%ld Tax Year", nil), (long)year.integerValue]];
    }
    
    [yearSelections addObject:NSLocalizedString(@"Add Tax Year", nil)];
    
    self.taxYearPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: yearSelections];
    self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.taxYearPickerViewController];
    (self.taxYearPickerViewController).delegate = self;
}

- (void) reloadReceiptInfo
{
    NSArray *receiptInfos = [self.dataService fetchNewestReceiptInfo: 5
                                                              inYear: self.currentlySelectedYear.integerValue];
    self.receiptInfos = receiptInfos;
    [self.recentUploadsTable reloadData];
}

- (void) setCurrentlySelectedYear: (NSNumber *) currentlySelectedYear
{
    _currentlySelectedYear = currentlySelectedYear;

    [self setYearLabelToBe: self.currentlySelectedYear.integerValue];
    
    [self.configurationManager setCurrentTaxYear:_currentlySelectedYear.integerValue];
    
    self.taxYearPickerViewController.highlightedSelectionIndex = [self.existingTaxYears indexOfObject:self.currentlySelectedYear];

    [self reloadReceiptInfo];
}

- (void) taxYearPressed
{
    [self.selectionPopover presentPopoverFromRect: self.taxYearLabel.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

- (IBAction) addCatagoryPressed: (UIButton *) sender
{
    // open up the AddCatagoryViewController
    [self.navigationController pushViewController: [self.viewControllerFactory createAddCategoryViewController] animated: YES];
}

- (IBAction) cameraButtonPressed: (UIButton *) sender
{
    if (!self.userManager.subscriptionActive)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                          message:NSLocalizedString(@"The subscription for this account has expired. Would you like to purchases a new subscription?", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                otherButtonTitles:NSLocalizedString(@"Purchase", nil),nil];
        
        [message show];
        
        return;
    }
    
    if (self.currentlySelectedYear.integerValue)
    {
        CameraViewController *cameraVC = [self.viewControllerFactory createCameraOverlayViewControllerWithExistingReceiptID:nil];
        
        [self.navigationController pushViewController: cameraVC animated: YES];
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                          message:NSLocalizedString(@"A tax year must be created before a receipt can be saved", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
        
        [message show];
    }
}

- (void) setYearLabelToBe: (NSInteger) year
{
    (self.taxYearLabel).text = [NSString stringWithFormat: NSLocalizedString(@"%ld Tax Year", nil), (long)year];
}

- (IBAction) myAccountPressed: (UIButton *) sender
{
    [super selectedMenuIndex: RootViewControllerAccount];
}

- (IBAction) vaultPressed: (UIButton *) sender
{
    [super selectedMenuIndex: RootViewControllerVault];
}

-(void)hideWaitingView
{
    if (self.waitView)
    {
        //hide the Waiting view
        [self.waitView hide: YES];
    }
}

-(void)checkUpdate
{
    [self.syncManager checkUpdate:^{
        
        // ask user if they want to download data from server
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Download", nil)
                                                          message: NSLocalizedString(@"The server contains some saved receipt data. Do you want to download and merge the data to the app?", nil)
                                                         delegate: self
                                                cancelButtonTitle: NSLocalizedString(@"No", nil)
                                                otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
        
        [message show];
        
    }];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: NSLocalizedString(@"Yes", nil)])
    {
        [self createAndShowWaitViewForDownload];
        
        [self.syncManager downloadAndMerge:^{
            
            [self refreshTaxYears];
            
            if (self.existingTaxYears.count)
            {
                self.currentlySelectedYear = (self.existingTaxYears).firstObject;
            }
            
            [self.recentUploadsTable reloadData];
            
            [self hideWaitingView];
            
        } failure:^(NSString *reason) {
            
            [self hideWaitingView];
            
        }];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Never show again", nil)])
    {
        [self.userManager doNotShowDisclaimerAgain];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Purchase", nil)])
    {
        // go to Settings Page
        [self selectedMenuIndex:RootViewControllerSettings];
    }
}

#pragma mark - UIPickerView delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.possibleTaxYears.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", self.possibleTaxYears[row]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.taxYearToAdd = self.possibleTaxYears[row];
}

#pragma mark - SelectionsPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController
{
    [self.selectionPopover dismissPopoverAnimated: YES];
    
    if (index < self.existingTaxYears.count)
    {
        self.currentlySelectedYear = self.existingTaxYears[index];
        
        self.taxYearPickerViewController.highlightedSelectionIndex = index;
    }
    else
    {
        self.taxYearToAdd = (self.possibleTaxYears).firstObject;
        
        [self.invisibleNewTaxYearField becomeFirstResponder];
    }
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    if (!self.receiptInfos.count)
    {
        return 1;
    }
    else
    {
        return self.receiptInfos.count;
    }
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (!self.receiptInfos.count)
    {
        //show a NoItemsTableViewCell
        static NSString *cellId2 = kNoItemsTableViewCellIdentifier;
        
        NoItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId2];
        
        if (cell == nil)
        {
            cell = [[NoItemsTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId2];
        }
        
        [cell.label setText:NSLocalizedString(@"No Uploads", nil)];
        
        return cell;
    }
    
    static NSString *cellId = @"MainTableCell";
    MainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

    if (cell == nil)
    {
        cell = [[MainViewTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
    }

    NSDictionary *uploadInfoDictionary = self.receiptInfos [indexPath.row];

    cell.selectedColorBoxColor = self.lookAndFeel.appGreenColor;

    [self.lookAndFeel applyGrayBorderTo: cell.colorBoxView];

    NSDate *uploadDate = uploadInfoDictionary[kUploadTimeKey];

    (self.dateFormatter).dateFormat = @"dd/MM/yyyy";

    (cell.calenderDateLabel).text = [self.dateFormatter stringFromDate: uploadDate];

    (self.dateFormatter).dateFormat = @"hh:mm a";

    (cell.timeOfDayLabel).text = [self.dateFormatter stringFromDate: uploadDate].lowercaseString;

    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kRecentUploadTableRowHeight;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (!self.receiptInfos.count)
    {
        return;
    }
    
    NSDictionary *uploadInfoDictionary = self.receiptInfos [indexPath.row];

    NSString *clickedReceiptID = uploadInfoDictionary[kReceiptIDKey];
    
    //push to Receipt Checking view directly if this receipt has no items
    NSArray *records = [self.dataService fetchRecordsForReceiptID: clickedReceiptID];
    
    if (!records || records.count == 0)
    {
        // push ReceiptCheckingViewController
        [self.navigationController pushViewController: [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID: clickedReceiptID cameFromReceiptBreakDownViewController: YES] animated: YES];
    }
    else
    {
        [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: clickedReceiptID cameFromReceiptCheckingViewController: NO] animated: YES];
    }
}

#pragma mark - Tutorial

typedef NS_ENUM(NSUInteger, TutorialSteps)
{
    TutorialStep1,
    TutorialStep2,
    TutorialStep3,
    TutorialStep4,
    TutorialStep5,
    TutorialStep6,
    TutorialStep8,
    TutorialStep21,
};

-(void)setupTutorials
{
    (self.tutorialManager).delegate = self;
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep1 = [TutorialStep new];
    
    tutorialStep1.text = NSLocalizedString(@"Welcome to CeliTax, the simple, easy-to-use tax tool designed specifically for Celiacs.\n\nWe make claiming your Gluten Free (GF) tax claim easy!", nil);
    tutorialStep1.leftButtonTitle = NSLocalizedString(@"Skip", nil);
    tutorialStep1.rightButtonTitle = NSLocalizedString(@"Begin Tutorial", nil);
    
    [self.tutorials addObject:tutorialStep1];
    
    TutorialStep *tutorialStep2 = [TutorialStep new];
    
    tutorialStep2.text = NSLocalizedString(@"Celiacs are entitled to claim the incremental cost difference between GF and regular food products as a medical expense.", nil);
    tutorialStep2.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep2.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep2];
    
    TutorialStep *tutorialStep3 = [TutorialStep new];
    
    tutorialStep3.text = NSLocalizedString(@"CeliTax will help you organize all of your GF purchases during the year and calculate your tax claim for you!", nil);
    tutorialStep3.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep3.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep3];
    
    TutorialStep *tutorialStep4 = [TutorialStep new];
    
    tutorialStep4.text = NSLocalizedString(@"Easily keep track of all your GF purchases throughout the year and automatically calculate your tax claim with one click!", nil);
    tutorialStep4.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep4.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep4];
    
    TutorialStep *tutorialStep5 = [TutorialStep new];
    
    tutorialStep5.text = NSLocalizedString(@"Let's get started!", nil);
    tutorialStep5.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep5.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep5];
    
    TutorialStep *tutorialStep6 = [TutorialStep new];
    
    tutorialStep6.text = NSLocalizedString(@"Categories will keep all of your GF purchases organized.", nil);
    tutorialStep6.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep6.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep6.pointsUp = NO;
    tutorialStep6.highlightedItemRect = self.categoriesButton.frame;
    
    [self.tutorials addObject:tutorialStep6];
    
    TutorialStep *tutorialStep8 = [TutorialStep new];
    
    tutorialStep8.text = NSLocalizedString(@"After you shop, keep your receipt and take a photo with the app!", nil);
    tutorialStep8.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep8.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep8.highlightedItemRect = self.cameraButton.frame;
    tutorialStep8.pointsUp = NO;
    
    [self.tutorials addObject:tutorialStep8];
    
    TutorialStep *tutorialStep21 = [TutorialStep new];
    
    tutorialStep21.text = NSLocalizedString(@"That's all! Now you are ready to use CeliTax to stay organized all year long. The GF tax claim has never been so easy!", nil);
    tutorialStep21.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep21.rightButtonTitle = NSLocalizedString(@"Done", nil);
    
    [self.tutorials addObject:tutorialStep21];
}

-(void)displayTutorialStep:(NSInteger)step
{
    if (self.tutorials.count && step < self.tutorials.count)
    {
        TutorialStep *tutorialStep = (self.tutorials)[step];
        
        [self.tutorialManager displayTutorialInViewController:self andTutorial:tutorialStep];
    }
}

- (void) tutorialLeftSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 1:
            self.tutorialManager.currentStep = 1;
            [self.tutorialManager endTutorial];
            [self checkUpdate];
            break;
            
        case 2:
            //Go back to Step 1
            self.tutorialManager.currentStep = 1;
            [self displayTutorialStep:TutorialStep1];
            break;
            
        case 3:
            //Go back to Step 2
            self.tutorialManager.currentStep = 2;
            [self displayTutorialStep:TutorialStep2];
            break;
            
        case 4:
            //Go back to Step 3
            self.tutorialManager.currentStep = 3;
            [self displayTutorialStep:TutorialStep3];
            break;
            
        case 5:
            //Go back to Step 4
            self.tutorialManager.currentStep = 4;
            [self displayTutorialStep:TutorialStep4];
            break;
            
        case 6:
            //Go back to Step 5
            self.tutorialManager.currentStep = 5;
            [self displayTutorialStep:TutorialStep5];
            break;
            
        case 8:
        {
            //Go back to Step 7 in Add Category view
            self.tutorialManager.currentStep = 7;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self addCatagoryPressed:nil];
            }];
        }
            
            break;
            
        case 21:
        {
            //Go back to Step 19 from My Account view
            self.tutorialManager.currentStep = 19;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [super selectedMenuIndex: RootViewControllerAccount];
            }];
        }
            
            break;
            
        default:
            break;
    }
}

- (void) tutorialRightSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 1:
            //Go to Step 2
            self.tutorialManager.currentStep = 2;
            [self displayTutorialStep:TutorialStep2];
            break;
            
        case 2:
            //Go to Step 3
            self.tutorialManager.currentStep = 3;
            [self displayTutorialStep:TutorialStep3];
            break;
            
        case 3:
            //Go to Step 4
            self.tutorialManager.currentStep = 4;
            [self displayTutorialStep:TutorialStep4];
            break;
            
        case 4:
            //Go to Step 5
            self.tutorialManager.currentStep = 5;
            [self displayTutorialStep:TutorialStep5];
            break;
            
        case 5:
            //Go to Step 6
            self.tutorialManager.currentStep = 6;
            [self displayTutorialStep:TutorialStep6];
            break;
            
        case 6:
        {
            //Go to Step 7 in a different View
            self.tutorialManager.currentStep = 7;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self addCatagoryPressed:nil];
            }];
        }
            
            break;
            
        case 8:
        {
            //Go to Step 9 in a Camera view
            self.tutorialManager.currentStep = 9;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self cameraButtonPressed:nil];
            }];
        }
            
            break;
            
        case 21:
        {
            //Completes tutorial
            self.tutorialManager.currentStep = 1;
            
            [self.tutorialManager endTutorial];
            [self checkUpdate];
        }
            break;
            
        default:
            break;
    }
}

@end