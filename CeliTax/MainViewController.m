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

#define kRecentUploadTableRowHeight         40

typedef enum : NSUInteger
{
    SectionReceiptsUploads,
    SectionQuickLinks,
    SectionCount,
} SectionTitles;

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, SelectionsPickerPopUpDelegate>

@property (weak, nonatomic) IBOutlet UITableView *recentUploadsTable;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *taxYearLabel;
@property (weak, nonatomic) IBOutlet TriangleView *taxYearTriangle;

@property (nonatomic, strong) WYPopoverController *selectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *taxYearPickerViewController;

// Dictionaries of keys: kReceiptIDKey,kColorKey,kCatagoryNameKey,kCatagoryTotalAmountKey
@property (nonatomic, strong) NSArray *receiptInfos;

// sorted from most recent to oldest
@property (nonatomic, strong) NSArray *taxYears;

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
    UITapGestureRecognizer *taxYearPressedTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(taxYearPressed)];
    [self.taxYearLabel addGestureRecognizer: taxYearPressedTap];
    [self.taxYearTriangle addGestureRecognizer: taxYearPressedTap2];

    self.taxYears = [self.dataService fetchTaxYears];
    
    NSMutableArray *yearSelections = [NSMutableArray new];
    
    for (NSNumber *year in self.taxYears )
    {
        [yearSelections addObject: [NSString stringWithFormat: @"%ld Tax Year", (long)year.integerValue]];
    }
    
    self.taxYearPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: yearSelections];
    self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.taxYearPickerViewController];
    [self.taxYearPickerViewController setDelegate: self];
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
    
    [self.configurationManager setCurrentTaxYear:_currentlySelectedYear.integerValue];
    
    self.taxYearPickerViewController.highlightedSelectionIndex = [self.taxYears indexOfObject:self.currentlySelectedYear];

    [self reloadReceiptInfo];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    //if there is no selected tax year saved, select the newest year by default
    if (![self.configurationManager getCurrentTaxYear])
    {
        self.currentlySelectedYear = [self.taxYears firstObject];
    }
    else
    {
        self.currentlySelectedYear = [NSNumber numberWithInteger:[self.configurationManager getCurrentTaxYear]];
    }
    
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

#pragma mark - SelectionsPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController
{
    [self.selectionPopover dismissPopoverAnimated: YES];

    self.currentlySelectedYear = self.taxYears[index];

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

    NSString *clickedReceiptID = [uploadInfoDictionary objectForKey: kReceiptIDKey];
    
    //push to Receipt Checking view directly if this receipt has no items
    [self.dataService fetchRecordsForReceiptID: clickedReceiptID
                                       success: ^(NSArray *records)
     {
         if (!records || records.count == 0)
         {
             // push ReceiptCheckingViewController
             [self.navigationController pushViewController: [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID: clickedReceiptID cameFromReceiptBreakDownViewController: YES] animated: YES];
         }
         else
         {
             [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: clickedReceiptID cameFromReceiptCheckingViewController: NO] animated: YES];
         }
         
     } failure: ^(NSString *reason) {
         // failure
     }];

}

@end