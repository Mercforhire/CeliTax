//
// MainViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MainViewController.h"
#import "Catagory.h"
#import "MainViewTableViewCell.h"
#import "UserManager.h"
#import "User.h"
#import "AddCatagoryViewController.h"
#import "AlertDialogsProvider.h"
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
#import "TutorialStep.h"
#import "DataService.h"
#import "ManipulationService.h"
#import "MBProgressHUD.h"
#import "SyncManager.h"

#define kRecentUploadTableRowHeight                     40
#define kNoItemsTableViewCellIdentifier                 @"NoItemsTableViewCell"

typedef enum : NSUInteger
{
    SectionReceiptsUploads,
    SectionQuickLinks,
    SectionCount,
} SectionTitles;

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
@property (nonatomic) NSUInteger currentTutorialStep;

@property (nonatomic) BOOL shouldDisplaySecondSetOfTutorials;

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
    NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];

    for (UIViewController *viewController in viewControllers)
    {
        if ([viewController isKindOfClass: [LoginViewController class]])
        {
            [viewControllers removeObject: viewController];
            break;
        }
    }

    [self.navigationController setViewControllers: viewControllers];
    
    self.possibleTaxYears = [NSMutableArray new];
    for (int year = 2010; year < 2016; year++)
    {
        [self.possibleTaxYears addObject:[NSNumber numberWithInteger:year]];
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
    [cancelToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    UIBarButtonItem *addToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Done", nil)
                                                                        style: UIBarButtonItemStylePlain
                                                                       target: self
                                                                       action: @selector(addTaxYear)];
    [addToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    self.pickerToolbar.items = [NSArray arrayWithObjects:
                                cancelToolbarButton,
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                addToolbarButton, nil];
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
        self.currentlySelectedYear = [self.existingTaxYears firstObject];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.tutorialManager hasTutorialBeenShown])
    {
        [self.tutorialManager setAutomaticallyShowTutorialNextTime];
        
        if ([self.tutorialManager automaticallyShowTutorialNextTime])
        {
            if (!self.shouldDisplaySecondSetOfTutorials)
            {
                [self setupTutorials];
                
                [self displayTutorialStep:0];
            }
            else
            {
                self.shouldDisplaySecondSetOfTutorials = NO;
                
                [self.tutorialManager setAutomaticallyShowTutorialNextTime];
                
                //go to Vault View
                [super selectedMenuIndex:RootViewControllerVault];
            }
        }
    }
    else
    {
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
        self.currentlySelectedYear = [self.existingTaxYears firstObject];
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
    [self.taxYearPickerViewController setDelegate: self];
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
    [self.navigationController pushViewController: [self.viewControllerFactory createAddCatagoryViewController] animated: YES];
}

- (IBAction) cameraButtonPressed: (UIButton *) sender
{
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
    [self.taxYearLabel setText: [NSString stringWithFormat: NSLocalizedString(@"%ld Tax Year", nil), (long)year]];
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
                self.currentlySelectedYear = [self.existingTaxYears firstObject];
            }
            
            [self.recentUploadsTable reloadData];
            
            [self hideWaitingView];
            
        } failure:^(NSString *reason) {
            
            [self hideWaitingView];
            
        }];
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
        self.taxYearToAdd = [self.possibleTaxYears firstObject];
        
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

    NSDate *uploadDate = [uploadInfoDictionary objectForKey: kUploadTimeKey];

    [self.dateFormatter setDateFormat: @"dd/MM/yyyy"];

    [cell.calenderDateLabel setText: [self.dateFormatter stringFromDate: uploadDate]];

    [self.dateFormatter setDateFormat: @"hh:mm a"];

    [cell.timeOfDayLabel setText: [[self.dateFormatter stringFromDate: uploadDate] lowercaseString]];

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

    NSString *clickedReceiptID = [uploadInfoDictionary objectForKey: kReceiptIDKey];
    
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

typedef enum : NSUInteger
{
    TutorialStep1,
    TutorialStep2,
    TutorialStep3,
    TutorialStep4,
    TutorialStep5,
    TutorialStep6,
    TutorialStep7,
    TutorialStepsCount,
} TutorialSteps;

-(void)setupTutorials
{
    [self.tutorialManager setDelegate:self];
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep1 = [TutorialStep new];
    
    tutorialStep1.text = NSLocalizedString(@"Welcome to CeliTax, the simple, easy to use tax tool designed specifically for Celiacs.\n\nWe make your Gluten Free (GF) tax claim easy!\n\nNo complicated spreadsheets, no paper receipts, no stress.", nil);
    tutorialStep1.leftButtonTitle = NSLocalizedString(@"Skip", nil);
    tutorialStep1.rightButtonTitle = NSLocalizedString(@"Begin Tutorial", nil);
    
    [self.tutorials addObject:tutorialStep1];
    
    TutorialStep *tutorialStep2 = [TutorialStep new];
    
    tutorialStep2.text = NSLocalizedString(@"Individuals diagnosed with Celiacs disease are entitled to a government tax claim based on the incremental difference between the cost of GF products and regular food items.", nil);
    tutorialStep2.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep2.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep2];
    
    TutorialStep *tutorialStep3 = [TutorialStep new];
    
    tutorialStep3.text = NSLocalizedString(@"CeliTax is here to simplify your life. You already have enough to worry about, taxes should not be one of them.", nil);
    tutorialStep3.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep3.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep3];
    
    TutorialStep *tutorialStep4 = [TutorialStep new];
    
    tutorialStep4.text = NSLocalizedString(@"Lets get started!", nil);
    tutorialStep4.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep4.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep4];
    
    TutorialStep *tutorialStep5 = [TutorialStep new];
    
    tutorialStep5.text = NSLocalizedString(@"CeliTax helps you organize your GF food purchases by allocating each item to a custom GF food category. No need for complex spreadsheets.", nil);
    tutorialStep5.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep5.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep5];
    
    TutorialStep *tutorialStep6 = [TutorialStep new];
    
    tutorialStep6.text = NSLocalizedString(@"Quickly keep track of your GF spending throughout the year and automatically calculate your GF tax claim in one simple click!", nil);
    tutorialStep6.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep6.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep6];
    
    TutorialStep *tutorialStep7 = [TutorialStep new];
    
    tutorialStep7.text = NSLocalizedString(@"Once you obtain your grocery receipt, simply take a photo of it and start allocating your GF purchases to your categories!", nil);
    tutorialStep7.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep7.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    tutorialStep7.highlightedItemRect = self.cameraButton.frame;
    tutorialStep7.pointsUp = NO;
    
    [self.tutorials addObject:tutorialStep7];
    
    self.currentTutorialStep = TutorialStep1;
}

-(void)displayTutorialStep:(NSInteger)step
{
    if (self.tutorials.count && step < self.tutorials.count)
    {
        TutorialStep *tutorialStep = [self.tutorials objectAtIndex:step];
        
        [self.tutorialManager displayTutorialInViewController:self andTutorial:tutorialStep];
        
        self.currentTutorialStep = step;
    }
}

- (void) tutorialLeftSideButtonPressed
{
    switch (self.currentTutorialStep)
    {
        case TutorialStep1:
        {
            [self.tutorialManager setTutorialsAsShown];
            
            //Close tutorial
            [self.tutorialManager dismissTutorial:^{
                
                [self checkUpdate];
                
            }];
        }
            break;
            
        case TutorialStep2:
            //Go back to Step 1
            [self displayTutorialStep:TutorialStep1];
            break;
            
        case TutorialStep3:
            //Go back to Step 2
            [self displayTutorialStep:TutorialStep2];
            break;
            
        case TutorialStep4:
            //Go back to Step 3
            [self displayTutorialStep:TutorialStep3];
            break;
            
        case TutorialStep5:
            //Go back to Step 4
            [self displayTutorialStep:TutorialStep4];
            break;
            
        case TutorialStep6:
            //Go back to Step 5
            [self displayTutorialStep:TutorialStep5];
            break;
            
        case TutorialStep7:
            //Go back to Step 6
            [self displayTutorialStep:TutorialStep6];
            break;
            
        default:
            break;
    }
}

- (void) tutorialRightSideButtonPressed
{
    switch (self.currentTutorialStep)
    {
        case TutorialStep1:
            //Go to Step 2
            [self displayTutorialStep:TutorialStep2];
            break;
            
        case TutorialStep2:
            //Go to Step 3
            [self displayTutorialStep:TutorialStep3];
            break;
            
        case TutorialStep3:
            //Go to Step 4
            [self displayTutorialStep:TutorialStep4];
            break;
            
        case TutorialStep4:
            //Go to Step 5
            [self displayTutorialStep:TutorialStep5];
            break;
            
        case TutorialStep5:
            //Go to Step 6
            [self displayTutorialStep:TutorialStep6];
            break;
            
        case TutorialStep6:
            //Go to Step 7
            [self displayTutorialStep:TutorialStep7];
            break;
            
        case TutorialStep7:
        {
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            
            [self.tutorialManager dismissTutorial:^{
                
                self.shouldDisplaySecondSetOfTutorials = YES;
                
                //Go to Camera view
                [self cameraButtonPressed:self.cameraButton];
                
            }];
        }
            break;
            
        default:
            break;
    }
}

@end