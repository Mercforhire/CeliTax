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
#import "SyncService.h"
#import "MBProgressHUD.h"

#define kRecentUploadTableRowHeight                     40
#define kNoItemsTableViewCellIdentifier                 @"NoItemsTableViewCell"

typedef enum : NSUInteger
{
    SectionReceiptsUploads,
    SectionQuickLinks,
    SectionCount,
} SectionTitles;

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, SelectionsPickerPopUpDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (nonatomic, strong) UIBarButtonItem *addCatagoryMenuItem;
@property (weak, nonatomic) IBOutlet UITableView *recentUploadsTable;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *taxYearLabel;
@property (weak, nonatomic) IBOutlet TriangleView *taxYearTriangle;
@property (strong, nonatomic) UIPickerView *taxYearPicker;
@property (weak, nonatomic) IBOutlet UITextField *invisibleNewTaxYearField;
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

@end

@implementation MainViewController

- (void) setupUI
{
    // setup the navigation bar items
    UIButton *addCatagoryButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 80, 54)];
    [addCatagoryButton setTitle: @"Catagories" forState: UIControlStateNormal];
    [addCatagoryButton.titleLabel setFont: [UIFont latoBoldFontOfSize: 15]];
    addCatagoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [addCatagoryButton setTitleColor: self.lookAndFeel.appGreenColor forState: UIControlStateNormal];
    [addCatagoryButton addTarget: self action: @selector(addCatagoryPressed:) forControlEvents: UIControlEventTouchUpInside];
    [addCatagoryButton sizeToFit];

    self.addCatagoryMenuItem = [[UIBarButtonItem alloc] initWithCustomView: addCatagoryButton];
    self.navigationItem.leftBarButtonItem = self.addCatagoryMenuItem;

    [self.navigationItem setHidesBackButton: YES];

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
    
    self.invisibleNewTaxYearField.inputView = self.taxYearPicker;
    
    // Create Cancel and Add button in UIPickerView toolbar
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.pickerToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *cancelToolbarButton = [[UIBarButtonItem alloc]initWithTitle: @"Cancel" style: UIBarButtonItemStylePlain target: self action: @selector(cancelAddTaxYear)];
    [cancelToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    UIBarButtonItem *addToolbarButton = [[UIBarButtonItem alloc]initWithTitle: @"Done" style: UIBarButtonItemStylePlain target: self action: @selector(addTaxYear)];
    [addToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    
    self.pickerToolbar.items = [NSArray arrayWithObjects:
                                cancelToolbarButton,
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           addToolbarButton, nil];
    [self.pickerToolbar sizeToFit];

    
    self.invisibleNewTaxYearField.inputAccessoryView = self.pickerToolbar;
}

- (void) createAndShowWaitViewForDownload
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
        self.waitView.labelText = @"Please wait";
        self.waitView.detailsLabelText = @"Downloading Data...";
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
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                          message:@"You can not add a duplicate tax year."
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Dimiss",nil];
        
        [message show];
        
        return;
    }
    
    [self.invisibleNewTaxYearField resignFirstResponder];
    
    [self.manipulationService addTaxYear:self.taxYearToAdd.integerValue save:YES];
    
    [self refreshTaxYears];
}

-(void)refreshTaxYears
{
    self.existingTaxYears = [self.dataService fetchTaxYears];
    
    NSMutableArray *yearSelections = [NSMutableArray new];
    
    for (NSNumber *year in self.existingTaxYears )
    {
        [yearSelections addObject: [NSString stringWithFormat: @"%ld Tax Year", (long)year.integerValue]];
    }
    
    [yearSelections addObject:@"Add Tax Year"];
    
    self.taxYearPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: yearSelections];
    self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.taxYearPickerViewController];
    [self.taxYearPickerViewController setDelegate: self];
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
    
    [self refreshTaxYears];
    
    //if there is no selected tax year saved, select the newest year by default
    if (![self.configurationManager getCurrentTaxYear])
    {
        if (self.existingTaxYears.count)
        {
            self.currentlySelectedYear = [self.existingTaxYears firstObject];
        }
    }
    else
    {
        self.currentlySelectedYear = [NSNumber numberWithInteger:[self.configurationManager getCurrentTaxYear]];
    }
}

- (void) reloadReceiptInfo
{
    NSArray *receiptInfos = [self.dataService fetchNewestReceiptInfo: 5
                                                              inYear: self.currentlySelectedYear.integerValue];
    self.receiptInfos = receiptInfos;
    [self.recentUploadsTable reloadData];
    
    if (self.receiptInfos.count)
    {
        NSInteger currentTutorialStage = [self.tutorialManager getCurrentTutorialStageForViewController:self];
        
        if (currentTutorialStage == 3)
        {
            currentTutorialStage++;
            
            [self.tutorialManager setCurrentTutorialStageForViewController:self forStage:currentTutorialStage];
        }
    }
}

- (void) setCurrentlySelectedYear: (NSNumber *) currentlySelectedYear
{
    _currentlySelectedYear = currentlySelectedYear;

    [self setYearLabelToBe: self.currentlySelectedYear.integerValue];
    
    [self.configurationManager setCurrentTaxYear:_currentlySelectedYear.integerValue];
    
    self.taxYearPickerViewController.highlightedSelectionIndex = [self.existingTaxYears indexOfObject:self.currentlySelectedYear];

    [self reloadReceiptInfo];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
}

-(void)displayTutorials
{
    NSMutableArray *tutorials = [NSMutableArray new];
    
    //Each Stage represents a different group of Tutorial pop ups
    NSInteger currentTutorialStage = [self.tutorialManager getCurrentTutorialStageForViewController:self];
    
    if ( currentTutorialStage == 1 )
    {
        TutorialStep *tutorialStep1 = [TutorialStep new];
        
        tutorialStep1.text = @"Welcome to CeliTax, the simple tax tool designed specifically for Celiacs.\n\nNo manual calculations. No paper receipts. No stress.\n\nYou have enough to worry about already, calculating your GF tax claim should not be one of them!\n\nThis wizard will guide you through each feature of CeliTax so you will quickly get familiar with its functions.\n\nLet’s go!";
        tutorialStep1.size = CGSizeMake(290, 300);
        tutorialStep1.pointsUp = YES;
        
        [tutorials addObject:tutorialStep1];
        
        TutorialStep *tutorialStep2 = [TutorialStep new];
        
        UIView *barButton = (UIView *)[self.pickerToolbar.subviews objectAtIndex:2]; // 0 for the first item
        
        CGPoint barButtonCenter = barButton.center;
        barButtonCenter.x += 30;
        barButtonCenter.y += [UIApplication sharedApplication].statusBarFrame.size.height + 10;
        
        tutorialStep2.origin = barButtonCenter;
        
        tutorialStep2.text = @"Click the Catagories button to add a new food category to keep all of your purchases allocated separately";
        tutorialStep2.size = CGSizeMake(200, 120);
        tutorialStep2.pointsUp = YES;
        
        [tutorials addObject:tutorialStep2];
        
        currentTutorialStage++;
        
        [self.tutorialManager setCurrentTutorialStageForViewController:self forStage:currentTutorialStage];
    }
    else if ( currentTutorialStage == 2)
    {
        TutorialStep *tutorialStep3 = [TutorialStep new];
        
        tutorialStep3.origin = self.cameraButton.center;
        tutorialStep3.text = @"Now that you’ve created your categories, click the camera button to take a photo of your receipt";
        tutorialStep3.size = CGSizeMake(290, 80);
        tutorialStep3.pointsUp = NO;
        
        [tutorials addObject:tutorialStep3];
        
        currentTutorialStage++;
        
        [self.tutorialManager setCurrentTutorialStageForViewController:self forStage:currentTutorialStage];
    }
    else if ( currentTutorialStage == 4)
    {
        TutorialStep *tutorialStep4 = [TutorialStep new];
        
        tutorialStep4.origin = self.recentUploadsTable.center;
        tutorialStep4.text = @"Use recent uploads to quickly manage your latest receipts";
        tutorialStep4.size = CGSizeMake(290, 70);
        tutorialStep4.pointsUp = YES;
        
        [tutorials addObject:tutorialStep4];
        
        TutorialStep *tutorialStep5 = [TutorialStep new];
        
        tutorialStep5.origin = self.myAccountButton.center;
        tutorialStep5.text = @"Use My Account to manage categories, view total allocations, and calculate your tax claim!";
        tutorialStep5.size = CGSizeMake(290, 90);
        tutorialStep5.pointsUp = NO;
        
        [tutorials addObject:tutorialStep5];
        
        TutorialStep *tutorialStep6 = [TutorialStep new];
        
        tutorialStep6.origin = self.vaultButton.center;
        tutorialStep6.text = @"Access all receipts from the Vault\n\nEvery photo capture is automatically saved and stored in the Vault";
        tutorialStep6.size = CGSizeMake(290, 100);
        tutorialStep6.pointsUp = NO;
        
        [tutorials addObject:tutorialStep6];
        
        [self.tutorialManager setTutorialDoneForViewController:self];
    }
    else if ( [self.tutorialManager areAllTutorialsShown] )
    {
        TutorialStep *tutorialStep7 = [TutorialStep new];
        
        tutorialStep7.text = @"There you have it! Calculating that GF tax claim has never been so easy. No more manual calculations or paper receipts to worry about!\n\nIf you ever need help or have questions, please use the help feature located in the (burger) menu.\n\nEnjoy!";
        tutorialStep7.size = CGSizeMake(290, 210);
        tutorialStep7.pointsUp = YES;
        
        [tutorials addObject:tutorialStep7];
        
        [self.tutorialManager resetTutorialStages];
        
        [self.configurationManager setTutorialON:NO];
    }
    else
    {
        //don't show any tutorial
        return;
    }
    
    [self.tutorialManager startTutorialInViewController:self andTutorials:tutorials];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Create tutorial items if it's ON
    if ([self.configurationManager isTutorialOn])
    {
        [self displayTutorials];
    }

    [self syncLocalData];
}

/*
 Check if local Data is up to date with the server data
 If yes, do nothing, if not, notify the user and download from the server.
 
 DEMO FEATURE: If no data exist locally or remotely, generate the demo data
 */
-(void)syncLocalData
{
    //if no local data exist, start downloading User Data
    if (![self.syncService getLocalDataBatchID])
    {
        if (![self.syncService getLocalDataBatchID])
        {
            //check the server to see if the server has saved data
            [self.syncService getLastestServerDataBatchID:^(NSString *batchID) {
                
                //ask user if they want to download from server
                UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Download"
                                                                  message: @"The server contains saved data. Do you want to download the data to app?"
                                                                 delegate: self
                                                        cancelButtonTitle: @"No"
                                                        otherButtonTitles: @"Yes", nil];
                
                [message show];
                
            } failure:^(NSString *reason) {
                
            }];
        }
    }
    
    //local data exist
    else
    {
        //silently check the server to see if the server has different data by comparing BatchID
        [self.syncService getLastestServerDataBatchID:^(NSString *batchID) {
            
            if ([[self.syncService getLocalDataBatchID] isEqualToString:batchID])
            {
                
            }
            else
            {
                //ask user if they want to download from server
                UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Download"
                                                                  message: @"The server contains different data than what's in the app, do you want to download and merge the new data?"
                                                                 delegate: self
                                                        cancelButtonTitle: @"No"
                                                        otherButtonTitles: @"Yes", nil];
                
                [message show];
            }
            
        } failure:^(NSString *reason) {
            
        }];
    }
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
    CameraViewController *cameraVC = [self.viewControllerFactory createCameraOverlayViewControllerWithExistingReceiptID:nil];

    [self.navigationController pushViewController: cameraVC animated: YES];
}

- (void) setYearLabelToBe: (NSInteger) year
{
    [self.taxYearLabel setText: [NSString stringWithFormat: @"%ld Tax Year", (long)year]];
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

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: @"Yes"])
    {
        [self createAndShowWaitViewForDownload];
        
        [self.syncService downloadUserData:^{
            
            [self refreshTaxYears];
            
            self.currentlySelectedYear = [self.existingTaxYears firstObject];
            
            [self.recentUploadsTable reloadData];
            
            [self hideWaitingView];
            
        } failure:^(NSString *reason) {
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Error"
                                                              message: reason
                                                             delegate: nil
                                                    cancelButtonTitle: @"Dismiss"
                                                    otherButtonTitles: nil];
            
            [message show];
            
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
        
        [cell.label setText:@"No Uploads"];
        
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

@end