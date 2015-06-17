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

#define kRecentUploadTableRowHeight         40

typedef enum : NSUInteger
{
    SectionReceiptsUploads,
    SectionQuickLinks,
    SectionCount,
} SectionTitles;

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, SelectionsPickerPopUpDelegate, CameraControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *recentUploadsTable;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *taxYearLabel;
@property (nonatomic, strong) WYPopoverController *selectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *taxYearPickerViewController;

// Dictionaries of keys: kReceiptIDKey,kColorKey,kCatagoryNameKey,kCatagoryTotalAmountKey
@property (nonatomic, strong) NSArray *receiptInfos;

// NSNumbers of the years of all receipts timestamps, sorted from most recent to oldest
@property (nonatomic, strong) NSArray *yearsRange;

@property (nonatomic, strong) NSNumber *currentlySelectedYear;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// open up the ReceiptCheckingViewController for the most recent receipt
@property (nonatomic) BOOL shouldJumpToMostRecentReceipt;

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

    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView: addCatagoryButton];
    self.navigationItem.leftBarButtonItem = menuItem;

    [self.navigationItem setHidesBackButton: YES];

    UINib *mainTableCell = [UINib nibWithNibName: @"MainViewTableViewCell" bundle: nil];
    [self.recentUploadsTable registerNib: mainTableCell forCellReuseIdentifier: @"MainTableCell"];

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
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    [self.dataService loadDemoData];

    self.recentUploadsTable.dataSource = self;
    self.recentUploadsTable.delegate = self;

    self.dateFormatter = [[NSDateFormatter alloc] init];

    UITapGestureRecognizer *taxYearPressedTap =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(taxYearPressed)];
    [self.taxYearLabel addGestureRecognizer: taxYearPressedTap];

    [self.dataService fetchReceiptsYearsRange: ^(NSArray *yearsRange)
    {
        self.yearsRange = yearsRange;
        self.currentlySelectedYear = [self.yearsRange firstObject];

        NSMutableArray *yearSelections = [NSMutableArray new];

        for (NSNumber *year in yearsRange)
        {
            [yearSelections addObject: [NSString stringWithFormat: @"%ld Tax Year", (long)year.integerValue]];
        }

        self.taxYearPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: yearSelections];
        self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.taxYearPickerViewController];
        [self.taxYearPickerViewController setDelegate: self];
    }                                 failure: ^(NSString *reason) {
        // should not happen
    }];
}

- (void) reloadReceiptInfo
{
    [self.dataService fetchNewestReceiptInfo: 5
                                      inYear: self.currentlySelectedYear.integerValue
                                     success: ^(NSArray *receiptInfos)
    {
        self.receiptInfos = receiptInfos;
        [self.recentUploadsTable reloadData];
    }                                failure: ^(NSString *reason)
    {
        // should not happen
    }];
}

- (void) setCurrentlySelectedYear: (NSNumber *) currentlySelectedYear
{
    _currentlySelectedYear = currentlySelectedYear;

    [self setYearLabelToBe: self.currentlySelectedYear.integerValue];

    [self reloadReceiptInfo];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    [self reloadReceiptInfo];

    if (self.shouldJumpToMostRecentReceipt)
    {
        self.shouldJumpToMostRecentReceipt = NO;

        NSDictionary *uploadInfoDictionaryForMostRecentUpload = self.receiptInfos [0];

        NSString *receiptIDForMostRecentUpload = [uploadInfoDictionaryForMostRecentUpload objectForKey: kReceiptIDKey];

        [self.navigationController pushViewController: [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID:receiptIDForMostRecentUpload cameFromReceiptBreakDownViewController:NO] animated: YES];
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
    CameraViewController *cameraVC = [self.viewControllerFactory createCameraOverlayViewController];
    cameraVC.delegate = self;

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

#pragma mark - CameraControllerDelegate
- (void) hasJustCreatedNewReceipt
{
    self.shouldJumpToMostRecentReceipt = YES;
}

#pragma mark - SelectionsPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController
{
    [self.selectionPopover dismissPopoverAnimated: YES];

    self.currentlySelectedYear = self.yearsRange [index];

    self.taxYearPickerViewController.highlightedSelectionIndex = index;
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.receiptInfos.count;
}

- (MainViewTableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
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
    NSDictionary *uploadInfoDictionary = self.receiptInfos [indexPath.row];

    DLog(@"Receipt ID %@ clicked", [uploadInfoDictionary objectForKey: kReceiptIDKey]);

    NSString *clickedReceiptID = [uploadInfoDictionary objectForKey: kReceiptIDKey];

    [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: clickedReceiptID cameFromReceiptCheckingViewController: NO] animated: YES];
}

@end