//
// VaultViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-02.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "VaultViewController.h"
#import "TimePeriodSelectionTableViewCell.h"
#import "ReceiptTimeTableViewCell.h"
#import "Receipt.h"
#import "WYPopoverController.h"
#import "SelectionsPickerViewController.h"
#import "ViewControllerFactory.h"
#import "Utils.h"
#import "M13Checkbox.h"
#import "SendReceiptsToViewController.h"
#import "AlertDialogsProvider.h"
#import "ConfigurationManager.h"
#import "NoItemsTableViewCell.h"
#import "ReceiptBreakDownViewController.h"
#import "ReceiptCheckingViewController.h"
#import "ImageCounterIconView.h"
#import "TransferSelectionsViewController.h"
#import "TutorialManager.h"
#import "TutorialStep.h"
#import "SolidGreenButton.h"
#import "HollowGreenButton.h"
#import "Notifications.h"

typedef enum : NSUInteger
{
    TimePeriodRecent,
    TimePeriodPreviousWeek,
    TimePeriodPreviousMonth,
    TimePeriodViewAll,
    TimePeriodCount
} TimePeriodSelections;

#define kTimePeriodSelectionTableViewCellHeight         44
#define kTimePeriodSelectionTableViewCellIdentifier     @"TimePeriodSelectionTableViewCell"

#define kReceiptTimeTableViewCellHeight                 40
#define kReceiptTimeTableViewCellIdentifier             @"ReceiptTimeTableViewCell"

#define kNoItemsTableViewCellHeight                     40
#define kNoItemsTableViewCellIdentifier                 @"NoItemsTableViewCell"

@interface VaultViewController () <UITableViewDelegate, UITableViewDataSource, SelectionsPickerPopUpDelegate, SendReceiptsViewPopUpDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, TransferSelectionsViewProtocol, TutorialManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *triangleView;
@property (weak, nonatomic) IBOutlet UILabel *taxYearLabel;
@property (weak, nonatomic) IBOutlet M13Checkbox *selectAllCheckBox;
@property (weak, nonatomic) IBOutlet UITableView *uploadHistoryTable;
@property (weak, nonatomic) IBOutlet HollowGreenButton *downloadReceiptButton;

@property (nonatomic, strong) WYPopoverController *taxYearSelectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *taxYearPickerViewController;

@property (nonatomic, strong) WYPopoverController *sendReceiptsPopover;
@property (nonatomic, strong) SendReceiptsToViewController *sendReceiptsToViewController;

@property (nonatomic, strong) WYPopoverController *transferSelectionsPopover;
@property (nonatomic, strong) TransferSelectionsViewController *transferSelectionsViewController;

@property (weak, nonatomic) IBOutlet SolidGreenButton *transferButton;
@property (weak, nonatomic) IBOutlet SolidGreenButton *deleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferButtonHeightBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonHeightBar;
@property (strong, nonatomic) UIPickerView *taxYearPicker;
@property (weak, nonatomic) IBOutlet UITextField *invisibleNewTaxYearField;

@property (nonatomic, strong) NSArray *existingTaxYears; // sorted from most recent to oldest
@property (nonatomic, strong) NSMutableArray *possibleTaxYears;
@property (nonatomic, strong) NSMutableArray *transferYearSelections;
@property (nonatomic, copy) NSString *taxYearToAdd;

@property (nonatomic, strong) NSArray *recentUploadReceipts;
@property (nonatomic, strong) NSArray *previousWeekReceipts;
@property (nonatomic, strong) NSArray *previousMonthReceipts;
@property (nonatomic, strong) NSArray *viewAllReceipts;

@property (nonatomic) BOOL recentUploadSelected;
@property (nonatomic) BOOL previousWeekSelected;
@property (nonatomic) BOOL previousMonthSelected;
@property (nonatomic) BOOL viewAllSelected;

// sorted from most recent to oldest
@property (nonatomic, strong) NSNumber *currentlySelectedYear;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) BOOL selectAllReceipts;
@property (nonatomic, strong) NSMutableDictionary *selectedReceipts;

//Tutorials
@property (nonatomic, strong) NSMutableArray *tutorials;

@end

@implementation VaultViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Vault", nil)];
    
    [self.taxYearLabel setText:NSLocalizedString(@"No Tax Year Added", nil)];
    
    [self.downloadReceiptButton setLookAndFeel:self.lookAndFeel];
    [self.downloadReceiptButton setTitle:NSLocalizedString(@"Download", nil) forState:UIControlStateNormal];

    [self.selectAllCheckBox.titleLabel setFont: [UIFont latoFontOfSize: 13]];
    [self.selectAllCheckBox.titleLabel setTextColor: [UIColor blackColor]];
    [self.selectAllCheckBox setStrokeColor: [UIColor grayColor]];
    [self.selectAllCheckBox setCheckColor: self.lookAndFeel.appGreenColor];
    [self.selectAllCheckBox setCheckAlignment: M13CheckboxAlignmentLeft];
    [self.selectAllCheckBox.titleLabel setText: NSLocalizedString(@"Select All", nil)];

    UINib *timePeriodSelectionTableViewCell = [UINib nibWithNibName: @"TimePeriodSelectionTableViewCell" bundle: nil];
    UINib *receiptTimeTableViewCellTableViewCell = [UINib nibWithNibName: @"ReceiptTimeTableViewCell" bundle: nil];
    UINib *noItemsTableViewCell = [UINib nibWithNibName: @"NoItemsTableViewCell" bundle: nil];

    [self.uploadHistoryTable registerNib: timePeriodSelectionTableViewCell forCellReuseIdentifier: kTimePeriodSelectionTableViewCellIdentifier];
    [self.uploadHistoryTable registerNib: receiptTimeTableViewCellTableViewCell forCellReuseIdentifier: kReceiptTimeTableViewCellIdentifier];
    [self.uploadHistoryTable registerNib: noItemsTableViewCell forCellReuseIdentifier: kNoItemsTableViewCellIdentifier];

    self.sendReceiptsToViewController = [self.viewControllerFactory createSendReceiptsToViewController];
    self.sendReceiptsPopover = [[WYPopoverController alloc] initWithContentViewController: self.sendReceiptsToViewController];
    [self.sendReceiptsPopover setTheme: [WYPopoverTheme theme]];

    WYPopoverTheme *popUpTheme = self.sendReceiptsPopover.theme;
    popUpTheme.fillTopColor = self.lookAndFeel.appGreenColor;
    popUpTheme.fillBottomColor = self.lookAndFeel.appGreenColor;

    [self.sendReceiptsPopover setTheme: popUpTheme];
    
    [self.transferButton setLookAndFeel:self.lookAndFeel];
    [self.transferButton setTitle:NSLocalizedString(@"Transfer", nil) forState:UIControlStateNormal];
    
    [self.deleteButton setLookAndFeel:self.lookAndFeel];
    [self.deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    
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
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    pickerToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *cancelToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Cancel", nil) style: UIBarButtonItemStylePlain target: self action: @selector(cancelAddTaxYear)];
    [cancelToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    UIBarButtonItem *addToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Done", nil) style: UIBarButtonItemStylePlain target: self action: @selector(addTaxYear)];
    [addToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    pickerToolbar.items = [NSArray arrayWithObjects:
                           cancelToolbarButton,
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           addToolbarButton, nil];
    [pickerToolbar sizeToFit];
    
    
    self.invisibleNewTaxYearField.inputAccessoryView = pickerToolbar;
}

#pragma mark - Life Cycle Functions

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    self.selectedReceipts = [NSMutableDictionary new];
    
    self.uploadHistoryTable.dataSource = self;
    self.uploadHistoryTable.delegate = self;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    UITapGestureRecognizer *taxYearPressedTap =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(taxYearPressed)];
    [self.taxYearLabel addGestureRecognizer: taxYearPressedTap];
    
    UITapGestureRecognizer *taxYearPressedTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(taxYearPressed)];
    [self.triangleView addGestureRecognizer: taxYearPressedTap2];
    
    [self.selectAllCheckBox addTarget: self
                               action: @selector(selectAllCheckChangedValue:)
                     forControlEvents: UIControlEventValueChanged];
    
    [self.sendReceiptsToViewController setDelegate: self];
    
    [self refreshTaxYears];

    if ([self.configurationManager getCurrentTaxYear])
    {
        // this triggers loading of receipts for this year
        self.currentlySelectedYear = [self.configurationManager getCurrentTaxYear];
    }
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refreshData)
                                                 name: kReceiptDatabaseChangedNotification
                                               object: nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.tutorialManager hasTutorialBeenShown] && [self.tutorialManager automaticallyShowTutorialNextTime])
    {
        [self setupTutorials];
        
        if (self.tutorialManager.currentStep == 18)
        {
            // create some fake receipts and automatically check mark first, then the 2 and 3 receipt
            self.recentUploadSelected = YES;
            
            NSMutableDictionary *fakeReceiptInfo1 = [NSMutableDictionary new];
            
            [fakeReceiptInfo1 setObject:[NSNumber numberWithInteger:4] forKey:kNumberOfRecordsKey];
            [fakeReceiptInfo1 setObject:[NSDate date] forKey:kUploadTimeKey];
            
            NSMutableDictionary *fakeReceiptInfo2 = [NSMutableDictionary new];
            
            [fakeReceiptInfo2 setObject:[NSNumber numberWithInteger:2] forKey:kNumberOfRecordsKey];
            [fakeReceiptInfo2 setObject:[NSDate date] forKey:kUploadTimeKey];
            
            NSMutableDictionary *fakeReceiptInfo3 = [NSMutableDictionary new];
            
            [fakeReceiptInfo3 setObject:[NSNumber numberWithInteger:8] forKey:kNumberOfRecordsKey];
            [fakeReceiptInfo3 setObject:[NSDate date] forKey:kUploadTimeKey];
            
            self.recentUploadReceipts = [NSArray arrayWithObjects:fakeReceiptInfo1, fakeReceiptInfo2, fakeReceiptInfo3, nil];
            
            [self.uploadHistoryTable reloadData];
            
            [self displayTutorialStep:TutorialStep18];
        }
    }
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kReceiptDatabaseChangedNotification
                                                  object: nil];
}

#pragma mark - View Controller functions

-(void)refreshData
{
    //refresh UI
    self.currentlySelectedYear = self.currentlySelectedYear;
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
    
    //if no tax year was available to be selected before, automatically select the first one
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
    self.taxYearSelectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.taxYearPickerViewController];
    [self.taxYearPickerViewController setDelegate: self];
}

-(BOOL)thisYearHasNoReceipts
{
    return (!self.recentUploadReceipts.count && !self.previousWeekReceipts.count &&
            !self.previousMonthReceipts.count  && !self.viewAllReceipts.count);
}


-(void)enableTransferButton:(BOOL)enableTransferButton andEnableDeleteButton:(BOOL)enableDeleteButton
{
    if (enableTransferButton || enableDeleteButton)
    {
        //show the buttons
        self.transferButtonHeightBar.constant = 30;
        self.deleteButtonHeightBar.constant = 30;
    }
    else
    {
        //hide the buttons
        self.transferButtonHeightBar.constant = 0;
        self.deleteButtonHeightBar.constant = 0;
    }
    
    [self.view setNeedsUpdateConstraints];
    
    if (enableTransferButton && [self.dataService fetchTaxYears].count > 1)
    {
        [self.transferButton setEnabled:YES];
    }
    else
    {
        [self.transferButton setEnabled:NO];
    }
    
    if (enableDeleteButton)
    {
        [self.deleteButton setEnabled:YES];
    }
    else
    {
        [self.deleteButton setEnabled:NO];
    }
}

- (void) selectAllCheckChangedValue: (M13Checkbox *) checkBox
{
    if (checkBox.checkState == M13CheckboxStateChecked)
    {
        self.selectAllReceipts = YES;

        [self enableTransferButton:YES andEnableDeleteButton:YES];
    }
    else
    {
        self.selectAllReceipts = NO;

        if (self.selectedReceipts.count)
        {
            [self enableTransferButton:YES andEnableDeleteButton:YES];
        }
        else
        {
            [self enableTransferButton:NO andEnableDeleteButton:NO];
        }
    }

    [self.uploadHistoryTable reloadData];
}

-(NSDictionary *)getReceiptInfoFromTag:(NSInteger)tag
{
    // get the Receipt object refered to by the checkBox's tag
    
    NSInteger timePeriodSelection = tag / 10000;
    
    NSInteger receiptIndex = tag % 10000;
    
    NSDictionary *receiptInfo;
    
    switch (timePeriodSelection)
    {
        case TimePeriodRecent:
            receiptInfo = [self.recentUploadReceipts objectAtIndex: receiptIndex];
            break;
            
        case TimePeriodPreviousWeek:
            receiptInfo = [self.previousWeekReceipts objectAtIndex: receiptIndex];
            break;
            
        case TimePeriodPreviousMonth:
            receiptInfo = [self.previousMonthReceipts objectAtIndex: receiptIndex];
            break;
            
        case TimePeriodViewAll:
            receiptInfo = [self.viewAllReceipts objectAtIndex: receiptIndex];
            break;
            
        default:
            break;
    }
    
    return receiptInfo;
}

- (void) singleReceiptCheckChangedValue: (M13Checkbox *) checkBox
{
    NSDictionary *thisReceiptInfo = [self getReceiptInfoFromTag:checkBox.tag];

    NSString *receiptID = [thisReceiptInfo objectForKey: kReceiptIDKey];

    if (checkBox.checkState == M13CheckboxStateChecked)
    {
        [self.selectedReceipts setObject: @"GARBAGE" forKey: receiptID];
    }
    else
    {
        [self.selectedReceipts removeObjectForKey: receiptID];
    }
    
    if (self.selectedReceipts.count)
    {
        [self enableTransferButton:YES andEnableDeleteButton:YES];
    }
    else
    {
        [self enableTransferButton:NO andEnableDeleteButton:NO];
    }

    [self.uploadHistoryTable reloadData];
}

- (void) setYearLabelToBe: (NSInteger) year
{
    [self.taxYearLabel setText: [NSString stringWithFormat: NSLocalizedString(@"%ld Tax Year", nil), (long)year]];
}

- (void) setCurrentlySelectedYear: (NSNumber *) currentlySelectedYear
{
    _currentlySelectedYear = currentlySelectedYear;

    [self setYearLabelToBe: self.currentlySelectedYear.integerValue];

    [self.configurationManager setCurrentTaxYear:_currentlySelectedYear.integerValue];
    
    self.taxYearPickerViewController.highlightedSelectionIndex = [self.existingTaxYears indexOfObject:self.currentlySelectedYear];
    
    //reset the self.uploadHistoryTable table
    [self.selectedReceipts removeAllObjects];
    
    self.recentUploadReceipts = nil;
    self.previousWeekReceipts = nil;
    self.previousMonthReceipts = nil;
    self.viewAllReceipts = nil;
    
    [self fetchRecentUploadReceipts];
    
    [self fetchPreviousWeekReceipts];
    
    [self fetchPreviousMonthReceipts];
    
    [self fetchViewAllReceipts];
    
    [self.selectAllCheckBox setCheckState:M13CheckboxStateUnchecked];
    
    [self selectAllCheckChangedValue:self.selectAllCheckBox];
    
    //if this year has no receipts disable the 'Select All' checkbox
    if ( [self thisYearHasNoReceipts] )
    {
        [self.selectAllCheckBox setEnabled:NO];
    }
    else
    {
        [self.selectAllCheckBox setEnabled:YES];
    }
}

-(void)fetchRecentUploadReceipts
{
    NSArray *receiptInfos = [self.dataService fetchNewestReceiptInfo : 5
                                                               inYear: self.currentlySelectedYear.integerValue];
    
    self.recentUploadReceipts = receiptInfos;
}

-(void)fetchPreviousWeekReceipts
{
    NSDate *mondayOfThisWeek = [Utils dateForMondayOfThisWeek];
    
    NSDate *mondayOfPreviousWeek = [Utils dateForMondayOfPreviousWeek];
    
    NSArray *receiptInfos = [self.dataService fetchReceiptInfoFromDate: mondayOfPreviousWeek
                                                                toDate: mondayOfThisWeek
                                                             inTaxYear: self.currentlySelectedYear.integerValue];
    self.previousWeekReceipts = receiptInfos;
}

-(void)fetchPreviousMonthReceipts
{
    NSDate *firstDayOfThisMonth = [Utils dateForFirstDayOfThisMonth];
    
    NSDate *firstDayOfPreviousMonth = [Utils dateForFirstDayOfPreviousMonth];
    
    NSArray *receiptInfos = [self.dataService fetchReceiptInfoFromDate: firstDayOfPreviousMonth
                                                                toDate: firstDayOfThisMonth
                                                             inTaxYear: self.currentlySelectedYear.integerValue];
    
    self.previousMonthReceipts = receiptInfos;
}

-(void)fetchViewAllReceipts
{
    NSArray *receiptInfos = [self.dataService fetchNewestReceiptInfo: 999
                                                              inYear: self.currentlySelectedYear.integerValue];
    
    self.viewAllReceipts = receiptInfos;
}

#pragma mark - Button press events

- (void) taxYearPressed
{
    [self.taxYearSelectionPopover presentPopoverFromRect: self.taxYearLabel.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

-(void)receiptDetailsPressed:(UIButton *)sender
{
    NSDictionary *thisReceiptInfo = [self getReceiptInfoFromTag:sender.tag];
    
    NSString *receiptID = [thisReceiptInfo objectForKey: kReceiptIDKey];
    
    //push to Receipt Checking view directly if this receipt has no items
    NSArray *records = [self.dataService fetchRecordsForReceiptID: receiptID];
    
    if (!records || records.count == 0)
    {
        // push ReceiptCheckingViewController
        [self.navigationController pushViewController: [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID: receiptID cameFromReceiptBreakDownViewController: YES] animated: YES];
    }
    else
    {
        [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: receiptID cameFromReceiptCheckingViewController: NO] animated: YES];
    }
}

- (IBAction)transferButtonPressed:(UIButton *)sender
{
    self.transferYearSelections = [NSMutableArray new];
    
    for (NSNumber *year in self.existingTaxYears)
    {
        if ( year.integerValue != self.currentlySelectedYear.integerValue )
        {
            [self.transferYearSelections addObject: [NSString stringWithFormat: NSLocalizedString(@"%ld Tax Year", nil), (long)year.integerValue]];
        }
    }
    
    self.transferSelectionsViewController = [self.viewControllerFactory createTransferSelectionsViewController: self.transferYearSelections];
    
    self.transferSelectionsPopover = [[WYPopoverController alloc] initWithContentViewController: self.transferSelectionsViewController];
    
    [self.transferSelectionsViewController setDelegate: self];
    
    [self.transferSelectionsViewController setHighlightedSelectionIndex: -1];
    
    [self.transferSelectionsPopover presentPopoverFromRect: self.transferButton.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionDown animated: YES];
}

- (IBAction)deleteButtonPressed:(UIButton *)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete selected receipts", nil)
                                                      message: NSLocalizedString(@"Are you sure you want delete the selected receipts along with all their items?", nil)
                                                     delegate: self
                                            cancelButtonTitle: NSLocalizedString(@"No", nil)
                                            otherButtonTitles: NSLocalizedString(@"Delete", nil), nil];
    
    [message show];
}

- (IBAction) downloadReceiptsPressed: (UIButton *) sender
{
    if ( [self thisYearHasNoReceipts] )
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"This year has no saved receipts"
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Dismiss",nil];
        
        [message show];
        
        return;
    }
    
    if (self.selectAllReceipts || self.selectedReceipts.count)
    {
        // open up 'Send Receipts To' pop up
        [self.sendReceiptsPopover presentPopoverFromRect: self.downloadReceiptButton.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionDown animated: YES];
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                          message:NSLocalizedString(@"Please select all or at least one receipt", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Dismiss", nil),nil];
        
        [message show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: NSLocalizedString(@"Delete", nil)])
    {
        NSMutableArray *receiptIDsToDelete = [[NSMutableArray alloc] init];
        
        if (self.selectAllReceipts)
        {
            for (NSDictionary *receiptInfo in self.recentUploadReceipts)
            {
                NSString *receiptID = [receiptInfo objectForKey: kReceiptIDKey];
                
                [receiptIDsToDelete addObject:receiptID];
            }
            
            for (NSDictionary *receiptInfo in self.previousWeekReceipts)
            {
                NSString *receiptID = [receiptInfo objectForKey: kReceiptIDKey];
                
                [receiptIDsToDelete addObject:receiptID];
            }
            
            for (NSDictionary *receiptInfo in self.previousMonthReceipts)
            {
                NSString *receiptID = [receiptInfo objectForKey: kReceiptIDKey];
                
                [receiptIDsToDelete addObject:receiptID];
            }
            
            for (NSDictionary *receiptInfo in self.viewAllReceipts)
            {
                NSString *receiptID = [receiptInfo objectForKey: kReceiptIDKey];
                
                [receiptIDsToDelete addObject:receiptID];
            }
        }
        else
        {
            receiptIDsToDelete = [self.selectedReceipts.allKeys mutableCopy];
        }
        
        for (NSString *receiptID in receiptIDsToDelete)
        {
            DLog(@"Delete receipt: %@", receiptID);
            
            [self.manipulationService deleteReceiptAndAllItsRecords:receiptID save:YES];
        }
        
        [self refreshData];
    }
}

#pragma mark - TransferSelectionsViewProtocol delegate

-(void)selectedTransferSelectionAtIndex:(NSInteger)index
{
    [self.transferSelectionsPopover dismissPopoverAnimated: YES];
    
    NSNumber *yearToTransferTo = self.transferYearSelections[index];
    
    NSMutableArray *receiptIDsToTransfer = [[NSMutableArray alloc] init];
    
    if (self.selectAllReceipts)
    {
        if (!self.recentUploadReceipts)
        {
            [self fetchRecentUploadReceipts];
        }
        
        if (!self.previousWeekReceipts)
        {
            [self fetchPreviousWeekReceipts];
        }
        
        if (!self.previousMonthReceipts)
        {
            [self fetchPreviousMonthReceipts];
        }
        
        if (!self.viewAllReceipts)
        {
            [self fetchViewAllReceipts];
        }
        
        for (NSDictionary *receiptInfo in self.recentUploadReceipts)
        {
            NSString *receiptID = [receiptInfo objectForKey: kReceiptIDKey];
            
            [receiptIDsToTransfer addObject:receiptID];
        }
        
        for (NSDictionary *receiptInfo in self.previousWeekReceipts)
        {
            NSString *receiptID = [receiptInfo objectForKey: kReceiptIDKey];
            
            [receiptIDsToTransfer addObject:receiptID];
        }
        
        for (NSDictionary *receiptInfo in self.previousMonthReceipts)
        {
            NSString *receiptID = [receiptInfo objectForKey: kReceiptIDKey];
            
            [receiptIDsToTransfer addObject:receiptID];
        }
        
        for (NSDictionary *receiptInfo in self.viewAllReceipts)
        {
            NSString *receiptID = [receiptInfo objectForKey: kReceiptIDKey];
            
            [receiptIDsToTransfer addObject:receiptID];
        }
    }
    else
    {
        receiptIDsToTransfer = [self.selectedReceipts.allKeys mutableCopy];
    }
    
    for (NSString *receiptID in receiptIDsToTransfer)
    {
        Receipt *receipt = [self.dataService fetchReceiptForReceiptID:receiptID];
        
        receipt.taxYear = yearToTransferTo.integerValue;
        
        [self.manipulationService modifyReceipt:receipt save:YES];
    }
    
    //refresh UI
    self.currentlySelectedYear = self.currentlySelectedYear;
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

#pragma mark - SendReceiptsViewPopUpDelegate

- (void) sendReceiptsToEmailRequested: (NSString *) emailAddress
{
    [self.sendReceiptsPopover dismissPopoverAnimated: YES];

    [AlertDialogsProvider showWorkInProgressDialog];
}

#pragma mark - SelectionsPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController
{
    if (popUpController == self.taxYearPickerViewController)
    {
        [self.taxYearSelectionPopover dismissPopoverAnimated: YES];
        
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
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return TimePeriodCount;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    switch (section)
    {
        case TimePeriodRecent:

            if (self.recentUploadSelected)
            {
                if (self.recentUploadReceipts.count)
                {
                    return (1 + self.recentUploadReceipts.count);
                }
                else
                {
                    return 2;
                }
                
            }

            break;

        case TimePeriodPreviousWeek:

            if (self.previousWeekSelected)
            {
                if (self.previousWeekReceipts.count)
                {
                    return (1 + self.previousWeekReceipts.count);
                }
                else
                {
                    return 2;
                }
            }

            break;

        case TimePeriodPreviousMonth:

            if (self.previousMonthSelected)
            {
                if (self.previousMonthReceipts.count)
                {
                    return (1 + self.previousMonthReceipts.count);
                }
                else
                {
                    return 2;
                }
            }

            break;

        case TimePeriodViewAll:

            if (self.viewAllSelected)
            {
                if (self.viewAllReceipts.count)
                {
                    return (1 + self.viewAllReceipts.count);
                }
                else
                {
                    return 2;
                }
            }

            break;

        default:
            break;
    }

    return 1;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a TimePeriodSelectionTableViewCell
    if (indexPath.row == 0)
    {
        static NSString *cellId = kTimePeriodSelectionTableViewCellIdentifier;
        TimePeriodSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[TimePeriodSelectionTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        switch (indexPath.section)
        {
            case TimePeriodRecent:
                [cell.periodLabel setText: NSLocalizedString(@"Recent Uploads", nil)];
                
                if (self.recentUploadSelected)
                {
                    [cell.triangle setGreenArrowUp];
                }
                else
                {
                    [cell.triangle setGreenArrowDown];
                }
                
                break;

            case TimePeriodPreviousWeek:
                [cell.periodLabel setText: NSLocalizedString(@"Previous Week", nil)];
                
                if (self.previousWeekSelected)
                {
                    [cell.triangle setGreenArrowUp];
                }
                else
                {
                    [cell.triangle setGreenArrowDown];
                }
                
                break;

            case TimePeriodPreviousMonth:
                [cell.periodLabel setText: NSLocalizedString(@"Previous Month", nil)];
                
                if (self.previousMonthSelected)
                {
                    [cell.triangle setGreenArrowUp];
                }
                else
                {
                    [cell.triangle setGreenArrowDown];
                }
                
                break;

            case TimePeriodViewAll:
                [cell.periodLabel setText: NSLocalizedString(@"View All", nil)];
                
                if (self.viewAllSelected)
                {
                    [cell.triangle setGreenArrowUp];
                }
                else
                {
                    [cell.triangle setGreenArrowDown];
                }
                
                break;

            default:
                break;
        }

        return cell;
    }
    // display a ReceiptTimeTableViewCell or NoItemsTableViewCell
    else
    {
        NSDictionary *thisReceiptInfo;

        NSInteger checkBoxTagOffset = indexPath.section * 10000;

        switch (indexPath.section)
        {
            case TimePeriodRecent:
                if (self.recentUploadReceipts.count)
                {
                    thisReceiptInfo = [self.recentUploadReceipts objectAtIndex: indexPath.row - 1];
                }
                break;

            case TimePeriodPreviousWeek:
                if (self.previousWeekReceipts.count)
                {
                    thisReceiptInfo = [self.previousWeekReceipts objectAtIndex: indexPath.row - 1];
                }
                break;

            case TimePeriodPreviousMonth:
                if (self.previousMonthReceipts.count)
                {
                    thisReceiptInfo = [self.previousMonthReceipts objectAtIndex: indexPath.row - 1];

                }
                break;

            case TimePeriodViewAll:
                if (self.viewAllReceipts.count)
                {
                    thisReceiptInfo = [self.viewAllReceipts objectAtIndex: indexPath.row - 1];
                }
                break;

            default:
                break;
        }
        
        if (!thisReceiptInfo)
        {
            //show a NoItemsTableViewCell
            static NSString *cellId3 = kNoItemsTableViewCellIdentifier;
            
            NoItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId3];
            
            if (cell == nil)
            {
                cell = [[NoItemsTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId3];
            }
            
            return cell;
        }
        else
        {
            static NSString *cellId2 = kReceiptTimeTableViewCellIdentifier;
            ReceiptTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId2];
            
            if (cell == nil)
            {
                cell = [[ReceiptTimeTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId2];
            }
            
            [cell.checkBoxView.titleLabel setFont: [UIFont latoFontOfSize: 13]];
            [cell.checkBoxView.titleLabel setTextColor: [UIColor blackColor]];
            [cell.checkBoxView setStrokeColor: [UIColor grayColor]];
            [cell.checkBoxView setCheckColor: self.lookAndFeel.appGreenColor];
            [cell.checkBoxView setCheckAlignment: M13CheckboxAlignmentLeft];
            [cell.checkBoxView setTag: (checkBoxTagOffset + indexPath.row - 1)];
            [cell.checkBoxView addTarget: self action: @selector(singleReceiptCheckChangedValue:) forControlEvents: UIControlEventValueChanged];
            
            NSString *receiptID = [thisReceiptInfo objectForKey: kReceiptIDKey];
            
            if (self.selectAllReceipts || [self.selectedReceipts objectForKey: receiptID])
            {
                [cell.checkBoxView setCheckState: M13CheckboxStateChecked];
            }
            else
            {
                [cell.checkBoxView setCheckState: M13CheckboxStateUnchecked];
            }
            
            NSDate *receiptDate = [thisReceiptInfo objectForKey: kUploadTimeKey];
            
            [self.dateFormatter setDateFormat: @"dd/MM/yyyy"];
            
            [cell.dateLabel setText: [self.dateFormatter stringFromDate: receiptDate]];
            
            [self.dateFormatter setDateFormat: @"hh:mm a"];
            
            cell.receiptCounterView.imageButton.tag = (checkBoxTagOffset + indexPath.row - 1);
            [cell.receiptCounterView.imageButton addTarget:self action:@selector(receiptDetailsPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            NSInteger numberOfRecords = [[thisReceiptInfo objectForKey:kNumberOfRecordsKey] integerValue];
            
            [cell.receiptCounterView setCounter:numberOfRecords];
            
            [cell.receiptCounterView setToGreen];
            
            if (cell.checkBoxView.checkState == M13CheckboxStateChecked)
            {
                [cell.receiptCounterView setHidden:NO];
            }
            else
            {
                [cell.receiptCounterView setHidden:YES];
            }
            
            return cell;
        }
    }

    return nil;
}

#pragma mark - UITableview Delegate
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == 0)
    {
        return kTimePeriodSelectionTableViewCellHeight;
    }
    else
    {
        return kReceiptTimeTableViewCellHeight;
    }
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == 0)
    {
        switch (indexPath.section)
        {
            case TimePeriodRecent:
                self.recentUploadSelected = !self.recentUploadSelected;
                
                if (!self.recentUploadReceipts)
                {
                    [self fetchRecentUploadReceipts];
                }

                break;

            case TimePeriodPreviousWeek:
                self.previousWeekSelected = !self.previousWeekSelected;

                if (!self.previousWeekReceipts)
                {
                    [self fetchPreviousWeekReceipts];
                }

                break;

            case TimePeriodPreviousMonth:
                self.previousMonthSelected = !self.previousMonthSelected;

                if ( !self.previousMonthReceipts )
                {
                    [self fetchPreviousMonthReceipts];
                }
                
                break;

            case TimePeriodViewAll:
                self.viewAllSelected = !self.viewAllSelected;
                
                if (!self.viewAllReceipts)
                {
                    [self fetchViewAllReceipts];
                }
                
                break;

            default:
                break;
        }

        [tableView reloadData];
        
        [tableView scrollToRowAtIndexPath: indexPath
                         atScrollPosition: UITableViewScrollPositionTop
                                 animated: YES];
    }
}

#pragma mark - Tutorial

typedef enum : NSUInteger
{
    TutorialStep18,
} TutorialSteps;

-(void)setupTutorials
{
    [self.tutorialManager setDelegate:self];
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep18 = [TutorialStep new];
    
    tutorialStep18.text = NSLocalizedString(@"Select receipts to send the images directly to your email for tax/audit evidence.", nil);
    
    tutorialStep18.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep18.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep18.pointsUp = NO;
    tutorialStep18.highlightedItemRect = self.downloadReceiptButton.frame;
    
    [self.tutorials addObject:tutorialStep18];
}

-(void)displayTutorialStep:(NSInteger)step
{
    if (self.tutorials.count && step < self.tutorials.count)
    {
        TutorialStep *tutorialStep = [self.tutorials objectAtIndex:step];
        
        [self.tutorialManager displayTutorialInViewController:self andTutorial:tutorialStep];
    }
}

- (void) tutorialLeftSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 18:
        {
            //Go back to Step 11 in Receipt Overlay view
            self.tutorialManager.currentStep = 11;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            
            ReceiptCheckingViewController *receiptCheckingViewController = [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID:nil cameFromReceiptBreakDownViewController:NO];
            
            [self.tutorialManager dismissTutorial:^{
                // push the new viewController
                [self.navigationController pushViewController: receiptCheckingViewController animated: YES];
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
        case 18:
        {
            //Go to Step 19 in My Account
            self.tutorialManager.currentStep = 19;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self selectedMenuIndex:RootViewControllerAccount];
            }];
        }
            break;
            
        default:
            break;
    }
}

@end