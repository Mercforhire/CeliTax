//
// MyAccountViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MyAccountViewController.h"
#import "AccountTableViewCell.h"
#import "Catagory.h"
#import "Record.h"
#import "UserManager.h"
#import "User.h"
#import "AlertDialogsProvider.h"
#import "ViewControllerFactory.h"
#import "XYPieChart.h"
#import "UploadsHistoryTableViewCell.h"
#import "Notifications.h"
#import "ReceiptBreakDownViewController.h"
#import "Utils.h"
#import "ConfigurationManager.h"
#import "ProfileBarView.h"
#import "TutorialManager.h"
#import "TutorialStep.h"
#import "HollowGreenButton.h"
#import "MyProfileViewController.h"
#import "UIView+Helper.h"

#define kCatagoryTableRowHeight                     65

#define kCatagoryDetailsKeyTotalQty                 @"CatagoryDetailsKeyTotalQty"
#define kCatagoryDetailsKeyTotalAmount              @"CatagoryDetailsKeyTotalAmount"

#define kAccountTableViewCellIdentifier             @"AccountTableViewCell"
#define kUploadsHistoryTableViewCellIdentifier      @"UploadsHistoryTableViewCell"

@interface MyAccountViewController () <UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UITableView *accountTableView;
@property (weak, nonatomic) IBOutlet HollowGreenButton *calculateButton;
@property (strong, nonatomic) ProfileBarView *profileBarView;
@property (strong, nonatomic) UIButton *navHelpButton;
@property (nonatomic, strong) UIToolbar *numberToolbar;

@property (nonatomic, strong) NSArray *catagories; // of Catagory

// NSMutableArray of NSArray of a fixed size 4:
// (CatagoryID, UnitTypeString, Total Qty/Total Weight, Total $ amount, national average cost)
@property (strong, nonatomic) NSMutableArray *catagoryRows;

@property (nonatomic, strong) NSMutableArray *slicePercentages;
@property (nonatomic, strong) NSMutableArray *sliceColors;
@property (nonatomic, strong) NSMutableArray *sliceNames;

@property (nonatomic, strong) NSArray *currentlySelectedRow;
@property (nonatomic, strong) NSArray *catagoryInfosToShow;

@property (nonatomic) BOOL recentUploadsSelected;
@property (nonatomic) BOOL previousWeekSelected;
@property (nonatomic) BOOL previousMonthSelected;
@property (nonatomic) BOOL viewAllSelected;

@end

@implementation MyAccountViewController

- (void) setupUI
{
    self.profileBarView = [[ProfileBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];

    self.profileBarView.profileImageView.layer.cornerRadius = self.profileBarView.profileImageView.frame.size.width / 2;
    self.profileBarView.profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    self.profileBarView.profileImageView.layer.borderWidth = 1.0f;
    [self.profileBarView.profileImageView setClipsToBounds: YES];
    
    [self.profileBarView.editButton1 addTarget:self action:@selector(editProfilePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.profileBarView.editButton2 addTarget:self action:@selector(editProfilePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // set up tableview
    UINib *accountTableCell = [UINib nibWithNibName: @"AccountTableViewCell" bundle: nil];
    [self.accountTableView registerNib: accountTableCell forCellReuseIdentifier: kAccountTableViewCellIdentifier];

    UINib *uploadsHistoryTableViewCell = [UINib nibWithNibName: @"UploadsHistoryTableViewCell" bundle: nil];
    [self.accountTableView registerNib: uploadsHistoryTableViewCell forCellReuseIdentifier: kUploadsHistoryTableViewCellIdentifier];

    // set up pieChart
    UIView *pieChartContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 250)];
    
    [pieChartContainer addSubview: self.profileBarView];

    self.pieChart = [[XYPieChart alloc] initWithFrame: CGRectMake(0, 60, 180, 180)];
    CGPoint pieChartCenter = pieChartContainer.center;
    pieChartCenter.y = pieChartCenter.y + 30;
    
    [self.pieChart setCenter: pieChartCenter];

    [pieChartContainer addSubview: self.pieChart];

    [self.pieChart setBackgroundColor: [UIColor clearColor]];
    [self.pieChart setDataSource: self];
    [self.pieChart setDelegate: self];
    [self.pieChart setStartPieAngle: M_PI_2];
    [self.pieChart setAnimationSpeed: 1.0];
    [self.pieChart setLabelFont: [UIFont latoFontOfSize: 10]];
    [self.pieChart setLabelRadius: self.pieChart.frame.size.width / 4];
    [self.pieChart setShowPercentage: NO];
    [self.pieChart setPieBackgroundColor: [UIColor clearColor]];
    [self.pieChart setUserInteractionEnabled: YES];
    [self.pieChart setLabelShadowColor: [UIColor blackColor]];
    [self.pieChart setSelectedSliceOffsetRadius: 0];
    
    // set up the National Average Cost ? button
    
    self.navHelpButton = [[UIButton alloc] initWithFrame:CGRectMake(pieChartContainer.frame.size.width - 27 - 15,
                                                                         pieChartContainer.frame.size.height - 27 - 15,
                                                                         27,
                                                                         27)];
    
    [self.navHelpButton setTitle:@"?" forState:UIControlStateNormal];
    [self.navHelpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navHelpButton.titleLabel setFont:[UIFont latoFontOfSize:15]];
    [self.navHelpButton setBackgroundColor:self.lookAndFeel.appGreenColor];
    
    self.navHelpButton.layer.cornerRadius = self.navHelpButton.frame.size.width / 2;
    [self.navHelpButton setClipsToBounds: YES];
    
    [self.navHelpButton addTarget:self action:@selector(avgHelpClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [pieChartContainer addSubview: self.navHelpButton];
    
    [self.accountTableView setTableHeaderView: pieChartContainer];
    
    // other set up
    [self.calculateButton setLookAndFeel:self.lookAndFeel];
    
    if (self.configurationManager.getCurrentTaxYear)
    {
        [self.titleLabel setText:[NSString stringWithFormat:@"Tax Year for %ld", (long)self.configurationManager.getCurrentTaxYear]];
    }
    
    self.numberToolbar = [[UIToolbar alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.numberToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *doneToolbarButton = [[UIBarButtonItem alloc]initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(doneOnKeyboardPressed)];
    [doneToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    self.numberToolbar.items = [NSArray arrayWithObjects:
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                doneToolbarButton,
                                nil];
    
    [self.numberToolbar sizeToFit];
}

#pragma mark - Life Cycle Functions

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];

    self.accountTableView.dataSource = self;
    self.accountTableView.delegate = self;
    
    // load all Catagory
    NSArray *catagories = [self.dataService fetchCatagories];
    
    self.catagories = catagories;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(openReceiptBreakDownView:)
                                                 name: kReceiptItemsTableReceiptPressedNotification
                                               object: nil];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];

    // load user info
    [self.profileBarView.nameLabel setText: [NSString stringWithFormat: @"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname]];
    [self.profileBarView.profileImageView setImage: self.userManager.user.avatarImage];
    
    // reset all state values
    self.catagoryRows = [NSMutableArray new];
    self.slicePercentages = [NSMutableArray new];
    self.sliceColors = [NSMutableArray new];
    self.sliceNames = [NSMutableArray new];
    
    float totalTaxYearAmount = 0;
    
    // Start filling in self.catagoryRows: (CatagoryID, UnitTypeString, Total Qty/Total Weight, Total $ amount, national average cost)
    
    // Also record the total amount for each Catagory
    NSMutableDictionary *categoryTotalAmount = [NSMutableDictionary new];
    
    for (Catagory *catagory in self.catagories)
    {
        float totalAmountForCatagory = 0;
        
        NSArray *recordsForThisCatagory = [self.dataService fetchRecordsForCatagoryID: catagory.localID
                                                                            inTaxYear: self.configurationManager.getCurrentTaxYear];
        
        // Separate recordsForThisCatagory into groups of the same Unit Type
        NSMutableDictionary *recordsOfEachType = [NSMutableDictionary new];
        
        for (Record *record in recordsForThisCatagory)
        {
            NSString *key = [self unitTypeIntToUnitTypeString:record.unitType];
            
            NSMutableArray *recordsOfSameType = [recordsOfEachType objectForKey:key];
            
            if (!recordsOfSameType)
            {
                recordsOfSameType = [NSMutableArray new];
            }
            
            [recordsOfSameType addObject:record];
            
            [recordsOfEachType setObject:recordsOfSameType forKey:key];
        }
        
        //Always have a row for kUnitItemKey
        if (![recordsOfEachType objectForKey:kUnitItemKey])
        {
            NSNumber *nationalAverageCost = [catagory.nationalAverageCosts objectForKey:kUnitItemKey];
            
            if (!nationalAverageCost)
            {
                nationalAverageCost = [NSNumber numberWithFloat:-1];
            }
            
            NSMutableArray *rowArray = [NSMutableArray arrayWithObjects:catagory.localID, kUnitItemKey, [NSNumber numberWithInteger:0], [NSNumber numberWithFloat:0], nationalAverageCost, nil];
            
            [self.catagoryRows addObject:rowArray];
            
            //if we are coming back to this View and self.currentlySelectedRow already exist, we need to update self.currentlySelectedRow to point to the new object in self.catagoryRows
            if (self.currentlySelectedRow &&
                [[self.currentlySelectedRow firstObject] isEqualToString:catagory.localID] &&
                [[self.currentlySelectedRow objectAtIndex: 1] isEqualToString:kUnitItemKey] )
            {
                self.currentlySelectedRow = rowArray;
            }
                
        }
        
        //Process the Unit Types in order: Item, ML, L, G, KG
        NSArray *orderOfUnitTypesToProcess = [NSArray arrayWithObjects:kUnitItemKey, kUnitMLKey, kUnitLKey, kUnitGKey, kUnitKGKey, nil];
        
        for (NSString *key in orderOfUnitTypesToProcess)
        {
            NSMutableArray *recordsOfSameType = [recordsOfEachType objectForKey:key];
            
            if (!recordsOfSameType.count)
            {
                continue;
            }
            
            NSInteger totalQuantityForThisCatagoryAndUnitType = 0;
            float totalAmountSpentOnThisCatagoryAndUnitType = 0;
            
            for (Record *record in recordsOfSameType)
            {
                totalQuantityForThisCatagoryAndUnitType += record.quantity;
                totalAmountSpentOnThisCatagoryAndUnitType += [record calculateTotal];
            }
            
            totalTaxYearAmount += totalAmountSpentOnThisCatagoryAndUnitType;
            
            totalAmountForCatagory += totalAmountSpentOnThisCatagoryAndUnitType;
            
            NSNumber *nationalAverageCost = [catagory.nationalAverageCosts objectForKey:key];
            
            if (!nationalAverageCost)
            {
                nationalAverageCost = [NSNumber numberWithFloat:-1];
            }
            
            NSMutableArray *rowArray = [NSMutableArray arrayWithObjects:catagory.localID, key, [NSNumber numberWithInteger: totalQuantityForThisCatagoryAndUnitType], [NSNumber numberWithFloat: totalAmountSpentOnThisCatagoryAndUnitType], nationalAverageCost, nil];
            
            [self.catagoryRows addObject:rowArray];
            
            //if we are coming back to this View and self.currentlySelectedRow already exist, we need to update self.currentlySelectedRow to point to the new object in self.catagoryRows
            if (self.currentlySelectedRow &&
                [[self.currentlySelectedRow firstObject] isEqualToString:catagory.localID] &&
                [[self.currentlySelectedRow objectAtIndex: 1] isEqualToString:key] )
            {
                self.currentlySelectedRow = rowArray;
            }
        }
        
        [categoryTotalAmount setObject:[NSNumber numberWithFloat:totalAmountForCatagory] forKey:catagory.localID];
    }
    
    [self.accountTableView reloadData];
    
    // refresh pie chart
    for (Catagory *catagory in self.catagories)
    {
        [self.sliceColors addObject: catagory.color];
        [self.sliceNames addObject: catagory.name];
        
        NSNumber *totalForCategory = [categoryTotalAmount objectForKey:catagory.localID];
        
        float sumAmount = 0;
        
        if (totalForCategory)
        {
            sumAmount = [totalForCategory floatValue];
        }
        
        if (totalTaxYearAmount == 0)
        {
            [self.slicePercentages addObject: [NSNumber numberWithInt: 0]];
        }
        else
        {
            [self.slicePercentages addObject: [NSNumber numberWithInt: sumAmount * 100 / totalTaxYearAmount]];
        }
    }
    
    [self.pieChart reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Create tutorial items if it's ON
    if ([self.configurationManager isTutorialOn])
    {
        [self displayTutorials];
    }
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    self.navigationController.navigationBarHidden = NO;

    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kReceiptItemsTableReceiptPressedNotification
                                                  object: nil];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

#pragma mark - View Controller functions

//Called when receive a kReceiptItemsTableReceiptPressedNotification Notification
- (void) openReceiptBreakDownView: (NSNotification *) notification
{
    NSDictionary *notificationDictionary = [notification userInfo];

    NSString *receiptID = [notificationDictionary objectForKey: kReceiptIDKey];

    [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: receiptID cameFromReceiptCheckingViewController: NO] animated: YES];
}

-(NSInteger)unitTypeStringToUnitTypeInt:(NSString *)unitTypeString
{
    if ([unitTypeString isEqualToString:kUnitItemKey])
    {
        return UnitItem;
    }
    else if ([unitTypeString isEqualToString:kUnitGKey])
    {
        return UnitG;
    }
    else if ([unitTypeString isEqualToString:kUnitKGKey])
    {
        return UnitKG;
    }
    else if ([unitTypeString isEqualToString:kUnitLKey])
    {
        return UnitL;
    }
    else if ([unitTypeString isEqualToString:kUnitMLKey])
    {
        return UnitML;
    }
    
    return -1;
}
             
-(NSString *)unitTypeIntToUnitTypeString:(NSInteger)unitTypeInt
{
    switch (unitTypeInt)
    {
        case UnitItem:
            return kUnitItemKey;
            
            break;
            
        case UnitML:
            return kUnitMLKey;
            
            break;
            
        case UnitL:
            return kUnitLKey;
            
            break;
            
        case UnitG:
            return kUnitGKey;
            
            break;
            
        case UnitKG:
            return kUnitKGKey;
            
            break;
            
        default:
            return nil;
            break;
    }
}

-(NSArray *)getFirstRowForCatagory:(Catagory *)catagory
{
    for (NSArray *row in self.catagoryRows)
    {
        NSString *catagoryID = [row firstObject];
        
        if ([catagoryID isEqualToString:catagory.localID])
        {
            return row;
        }
    }
    
    return nil;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    if (!self.currentlySelectedRow)
    {
        NSDictionary *info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        [self.view scrollToY: 0 - kbSize.height];

    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
}

#pragma mark - Button press events

- (void) doneOnKeyboardPressed
{
    [self.view endEditing: YES];
}

- (IBAction) calculateButtonPressed: (UIButton *) sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (void) editProfilePressed: (UIButton *) sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createMyProfileViewController] animated: YES];
}

-(void)avgHelpClicked
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
    if ( [textField.text isEqualToString: @"--"] )
    {
        textField.text = @"";
    }
    
    if (!self.currentlySelectedRow)
    {
        [self.accountTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: textField.tag * 2 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    }
    else
    {
        [self.accountTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: textField.tag * 2 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    NSMutableArray *dataForThisRow = [self.catagoryRows objectAtIndex: textField.tag];
    
    NSString *catagoryID = [dataForThisRow firstObject];
    
    NSString *unitTypeString = [dataForThisRow objectAtIndex:1];
    
    NSInteger unitType = [self unitTypeStringToUnitTypeInt:unitTypeString];
    
    // if user types nothing for a textField, we default it to ----
    if (textField.text.length == 0 || textField.text.floatValue == 0)
    {
        textField.text = @"--";
        
        [self.manipulationService deleteNationalAverageCostForCatagoryID:catagoryID andUnitType:unitType save:YES];
        
        [dataForThisRow setObject:[NSNumber numberWithFloat:0] atIndexedSubscript:4];
        
        [self.catagoryRows setObject:dataForThisRow atIndexedSubscript:textField.tag];
    }
    else
    {
        [textField setText: [NSString stringWithFormat: @"%.2f", textField.text.floatValue]];
        
        [self.manipulationService addOrUpdateNationalAverageCostForCatagoryID:catagoryID andUnitType:unitType amount:textField.text.floatValue save:YES];
        
        [dataForThisRow setObject:[NSNumber numberWithFloat:textField.text.floatValue] atIndexedSubscript:4];
        
        [self.catagoryRows setObject:dataForThisRow atIndexedSubscript:textField.tag];
    }
}

#pragma mark - XYPieChart Data Source

- (NSUInteger) numberOfSlicesInPieChart: (XYPieChart *) pieChart
{
    return self.slicePercentages.count;
}

- (CGFloat) pieChart: (XYPieChart *) pieChart valueForSliceAtIndex: (NSUInteger) index
{
    return [[self.slicePercentages objectAtIndex: index] intValue];
}

- (UIColor *) pieChart: (XYPieChart *) pieChart colorForSliceAtIndex: (NSUInteger) index
{
    return [self.sliceColors objectAtIndex: (index % self.sliceColors.count)];
}

- (NSString *) pieChart: (XYPieChart *) pieChart textForSliceAtIndex: (NSUInteger) index
{
    NSString *sliceText = [NSString stringWithFormat: @"%@\n%d%%",
                           [self.sliceNames objectAtIndex: (index % self.sliceNames.count)],
                           [[self.slicePercentages objectAtIndex: index] intValue]];

    return sliceText;
}

#pragma mark - XYPieChart Delegate
- (void) pieChart: (XYPieChart *) pieChart didDeselectSliceAtIndex: (NSUInteger) index
{
    // does same thing as didSelectSliceAtIndex
    [self pieChart: pieChart didSelectSliceAtIndex: index];
}

- (void) pieChart: (XYPieChart *) pieChart didSelectSliceAtIndex: (NSUInteger) index
{
    Catagory *thisCatagory = [self.catagories objectAtIndex: index];

    //TODO: Selected the first row that is the above Catagory
    self.currentlySelectedRow = [self getFirstRowForCatagory:thisCatagory];

    self.catagoryInfosToShow = nil;

    [self.accountTableView reloadData];
    
    NSInteger indexToScrollTo = [self.catagoryRows indexOfObject:self.currentlySelectedRow];
    
    indexToScrollTo = indexToScrollTo * 2;

    [self.accountTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexToScrollTo inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: YES];

    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;
}

#pragma mark - UploadsHistoryTableViewCell functions

- (void) recentUploadsLabelPressed
{
    NSAssert(self.currentlySelectedRow, @"currentlySelectedRow must not be nil");

    if (self.recentUploadsSelected)
    {
        self.recentUploadsSelected = NO;
        self.catagoryInfosToShow = nil;

        [self.accountTableView reloadData];

        return;
    }

    self.recentUploadsSelected = YES;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;

    // get the last 5 recent uploads
    if (self.currentlySelectedRow)
    {
        NSString *catagoryID = [self.currentlySelectedRow firstObject];
        NSString *unitTypeString = [self.currentlySelectedRow objectAtIndex:1];
        
        NSArray *catagoryInfos =
        [self.dataService fetchLatestNthCatagoryInfosforCatagory: catagoryID
                                                     andUnitType: [self unitTypeStringToUnitTypeInt:unitTypeString]
                                                          forNth: 5
                                                       inTaxYear: self.configurationManager.getCurrentTaxYear];
        
        self.catagoryInfosToShow = catagoryInfos;
        
        [self.accountTableView reloadData];
    }
}

- (void) previousWeekLabelPressed
{
    NSAssert(self.currentlySelectedRow, @"currentlySelectedRow must not be nil");

    if (self.previousWeekSelected)
    {
        self.previousWeekSelected = NO;
        self.catagoryInfosToShow = nil;

        [self.accountTableView reloadData];

        return;
    }

    self.recentUploadsSelected = NO;
    self.previousWeekSelected = YES;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;

    NSDate *mondayOfThisWeek = [Utils dateForMondayOfThisWeek];
    DLog(@"Monday of this week is %@", mondayOfThisWeek.description);
    NSDate *mondayOfPreviousWeek = [Utils dateForMondayOfPreviousWeek];
    DLog(@"Monday of previous week is %@", mondayOfPreviousWeek.description);
    
    NSString *catagoryID = [self.currentlySelectedRow firstObject];
    NSString *unitTypeString = [self.currentlySelectedRow objectAtIndex:1];
    
    NSArray *catagoryInfos = [self.dataService fetchCatagoryInfoFromDate:mondayOfPreviousWeek toDate:mondayOfThisWeek inTaxYear:self.configurationManager.getCurrentTaxYear forCatagory:catagoryID forUnitType:[self unitTypeStringToUnitTypeInt:unitTypeString]];
    
    DLog(@"%@", catagoryInfos);
    self.catagoryInfosToShow = catagoryInfos;
    
    [self.accountTableView reloadData];
}

- (void) previousMonthLabelPressed
{
    NSAssert(self.currentlySelectedRow, @"currentlySelectedRow must not be nil");

    if (self.previousMonthSelected)
    {
        self.previousMonthSelected = NO;
        self.catagoryInfosToShow = nil;

        [self.accountTableView reloadData];

        return;
    }

    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = YES;
    self.viewAllSelected = NO;

    NSDate *firstDayOfThisMonth = [Utils dateForFirstDayOfThisMonth];
    DLog(@"First day of this month is %@", firstDayOfThisMonth.description);

    NSDate *firstDayOfPreviousMonth = [Utils dateForFirstDayOfPreviousMonth];
    DLog(@"First Day Of Previous Month is %@", firstDayOfPreviousMonth.description);
    
    NSString *catagoryID = [self.currentlySelectedRow firstObject];
    NSString *unitTypeString = [self.currentlySelectedRow objectAtIndex:1];
    
    NSArray *catagoryInfos = [self.dataService fetchCatagoryInfoFromDate:firstDayOfPreviousMonth toDate:firstDayOfThisMonth inTaxYear:self.configurationManager.getCurrentTaxYear forCatagory:catagoryID forUnitType:[self unitTypeStringToUnitTypeInt:unitTypeString]];
    
    DLog(@"%@", catagoryInfos);
    self.catagoryInfosToShow = catagoryInfos;
    
    [self.accountTableView reloadData];
}

- (void) viewAllLabelPressed
{
    NSAssert(self.currentlySelectedRow, @"currentlySelectedRow must not be nil");

    if (self.viewAllSelected)
    {
        self.viewAllSelected = NO;
        self.catagoryInfosToShow = nil;

        [self.accountTableView reloadData];

        return;
    }

    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = YES;
    
    NSString *catagoryID = [self.currentlySelectedRow firstObject];
    NSString *unitTypeString = [self.currentlySelectedRow objectAtIndex:1];

    // all receipts from this catagory
    NSArray *catagoryInfos = [self.dataService fetchLatestNthCatagoryInfosforCatagory:catagoryID andUnitType:[self unitTypeStringToUnitTypeInt:unitTypeString] forNth:-1 inTaxYear:self.configurationManager.getCurrentTaxYear];
    
    self.catagoryInfosToShow = catagoryInfos;
    
    [self.accountTableView reloadData];
}

#pragma mark - UITableview DataSource

#define kBiggestLabelHeight         20
#define kMargin                     10
#define kTableCellHeight            35
#define kNoItemsTableViewCellHeight 40

- (CGFloat) calculateHeightForCellWithNumberOfCatagoryInfos: (NSInteger) numberOfCatagoryInfos
{
    if (numberOfCatagoryInfos)
    {
        float totalHeight = (kMargin + kBiggestLabelHeight + kMargin) * 4 + kTableCellHeight * numberOfCatagoryInfos ;
        
        return totalHeight;
    }
    else
    {
        float totalHeight = (kMargin + kBiggestLabelHeight + kMargin) * 4 + kNoItemsTableViewCellHeight ;
        
        return totalHeight;
    }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.catagoryRows.count * 2;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a AccountTableCell
    if (indexPath.row % 2 == 0)
    {
        static NSString *cellId = kAccountTableViewCellIdentifier;
        AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[AccountTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
            cell.clipsToBounds = YES;
        }

        // (CatagoryID, UnitTypeString, Total Qty/Total Weight, Total $ amount, national average cost)
        NSArray *dataForThisRow = [self.catagoryRows objectAtIndex:indexPath.row / 2];
        
        NSString *catagoryID = [dataForThisRow firstObject];
        
        Catagory *thisCatagory = [self.dataService fetchCatagory:catagoryID];
        
        NSString *unitTypeString = [dataForThisRow objectAtIndex:1];
        
        NSInteger quantity = [[dataForThisRow objectAtIndex:2] integerValue];
        
        float amount = [[dataForThisRow objectAtIndex:3] floatValue];

        if ( [unitTypeString isEqualToString:kUnitItemKey] )
        {
            cell.colorBoxColor = thisCatagory.color;
            
            cell.colorBox.backgroundColor = thisCatagory.color;
        }
        else
        {
            cell.colorBoxColor = [UIColor lightGrayColor];
            
            cell.colorBox.backgroundColor = [UIColor lightGrayColor];
        }

        if ([unitTypeString isEqualToString:kUnitItemKey])
        {
            [cell.catagoryNameLabel setText: thisCatagory.name];
        }
        else if ([unitTypeString isEqualToString:kUnitGKey])
        {
            [cell.catagoryNameLabel setText: @"(g)"];
        }
        else if ([unitTypeString isEqualToString:kUnitKGKey])
        {
            [cell.catagoryNameLabel setText: @"(kg)"];
        }
        else if ([unitTypeString isEqualToString:kUnitLKey])
        {
            [cell.catagoryNameLabel setText: @"(L)"];
        }
        else if ([unitTypeString isEqualToString:kUnitMLKey])
        {
            [cell.catagoryNameLabel setText: @"(ml)"];
        }
        
        [cell.totalQuantityField setText: [NSString stringWithFormat: @"%ld", (long)quantity]];
        [cell.totalAmountField setText: [NSString stringWithFormat: @"%.2f", amount]];
        
        [self.lookAndFeel applyGrayBorderTo: cell.totalQuantityField];
        [self.lookAndFeel applyGrayBorderTo: cell.totalAmountField];

        float nationalAverageCost = [[dataForThisRow objectAtIndex:4] floatValue];
        
        if (nationalAverageCost >= 0)
        {
            [cell.averageNationalPriceField setText: [NSString stringWithFormat: @"%.2f", nationalAverageCost]];
        }
        else
        {
            [cell.averageNationalPriceField setText: @"--"];
        }
        
        [cell.averageNationalPriceField setDelegate: self];
        
        //set the tag to be the index of the data for this row in respect to self.catagoryRows
        [cell.averageNationalPriceField setTag: indexPath.row / 2];
        
        cell.averageNationalPriceField.inputAccessoryView = self.numberToolbar;

        [self.lookAndFeel applyGreenBorderTo: cell.averageNationalPriceField];
        
        // User have selected one row
        if (self.currentlySelectedRow)
        {
            if ( dataForThisRow == self.currentlySelectedRow )
            {
                [cell makeCellAppearActive];
            }
            else
            {
                [cell makeCellAppearInactive];
            }
        }
        else
        {
            [cell makeCellAppearActive];
        }
        
        [self.lookAndFeel applySlightlyDarkerBorderTo: cell.colorBox];
        
        if ([unitTypeString isEqualToString:kUnitItemKey])
        {
            [cell.totalQtyLabel setText:@"Total Qty."];
        }
        else
        {
            [cell.totalQtyLabel setText:@"Weight"];
        }

        return cell;
    }
    // display a UploadsHistoryTableViewCell
    else
    {
        static NSString *cellId = kUploadsHistoryTableViewCellIdentifier;
        UploadsHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[UploadsHistoryTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        cell.lookAndFeel = self.lookAndFeel;

        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        
        cell.clipsToBounds = YES;

        UITapGestureRecognizer *recentUploadsLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(recentUploadsLabelPressed)];

        UITapGestureRecognizer *previousWeekLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(previousWeekLabelPressed)];

        UITapGestureRecognizer *previousMonthLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(previousMonthLabelPressed)];

        UITapGestureRecognizer *viewAllLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(viewAllLabelPressed)];

        [cell.recentUploadsLabel addGestureRecognizer: recentUploadsLabelTap];

        [cell.previousWeekLabel addGestureRecognizer: previousWeekLabelTap];

        [cell.previousMonthLabel addGestureRecognizer: previousMonthLabelTap];

        [cell.viewAllLabel addGestureRecognizer: viewAllLabelTap];

        NSArray *dataForThisRow = [self.catagoryRows objectAtIndex:(indexPath.row - 1) / 2];
        
        NSString *catagoryID = [dataForThisRow firstObject];
        
        NSString *unitTypeString = [dataForThisRow objectAtIndex:1];
        
        Catagory *thisCatagory = [self.dataService fetchCatagory:catagoryID];
        
        cell.catagoryColor = thisCatagory.color;

        if ([unitTypeString isEqualToString:kUnitItemKey])
        {
            [cell setToDisplayItems];
        }
        else
        {
            [cell setToDisplayWeight];
        }
        
        // this cell should only be visible if a Category is selected
        if (dataForThisRow == self.currentlySelectedRow)
        {
            if (self.recentUploadsSelected)
            {
                cell.recentUploadReceipts = self.catagoryInfosToShow;

                [cell selectRecentUpload];
            }
            else if (self.previousWeekSelected)
            {
                cell.previousWeekReceipts = self.catagoryInfosToShow;

                [cell selectPreviousWeek];
            }
            else if (self.previousMonthSelected)
            {
                cell.previousMonthReceipts = self.catagoryInfosToShow;

                [cell selectPreviousMonth];
            }
            else if (self.viewAllSelected)
            {
                cell.viewAllReceipts = self.catagoryInfosToShow;
                
                [cell selectViewAll];
            }
            else
            {
                [cell selectNothing];
            }
        }

        return cell;
    }
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a AccountTableCell for the all rows except the last
    if (indexPath.row % 2 == 0)
    {
        return kCatagoryTableRowHeight;
    }
    // display a UploadsHistoryTableViewCell
    else
    {
        NSArray *dataForThisRow = [self.catagoryRows objectAtIndex:(indexPath.row - 1) / 2];
        
        if (self.currentlySelectedRow && self.currentlySelectedRow == dataForThisRow)
        {
            return [self calculateHeightForCellWithNumberOfCatagoryInfos: self.catagoryInfosToShow.count];
        }
    }

    return 0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row % 2 == 0)
    {
        NSArray *dataForThisRow = [self.catagoryRows objectAtIndex:indexPath.row / 2];
        
        // Deselect
        if ( dataForThisRow == self.currentlySelectedRow )
        {
            self.currentlySelectedRow = nil;
            
            self.catagoryInfosToShow = nil;
            
            [tableView reloadData];
        }
        // Select
        else
        {
            self.currentlySelectedRow = dataForThisRow;
            
            self.catagoryInfosToShow = nil;
            
            [tableView reloadData];
            
            [tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        }
        
        self.recentUploadsSelected = NO;
        self.previousWeekSelected = NO;
        self.previousMonthSelected = NO;
        self.viewAllSelected = NO;
    }
}

#pragma mark - Tutorial

-(void)displayTutorials
{
    NSMutableArray *tutorials = [NSMutableArray new];
    
    //Each Stage represents a different group of Tutorial pop ups
    NSInteger currentTutorialStage = [self.tutorialManager getCurrentTutorialStageForViewController:self];
    
    if ( currentTutorialStage == 1 )
    {
        TutorialStep *tutorialStep1 = [TutorialStep new];
        
        tutorialStep1.text = @"Quickly view purchase totals for each category.\n\nClick a receipt to easily edit/transfer/delete the purchase allocations";
        tutorialStep1.size = CGSizeMake(290, 120);
        tutorialStep1.pointsUp = YES;
        
        [tutorials addObject:tutorialStep1];
        
        TutorialStep *tutorialStep2 = [TutorialStep new];
        
        tutorialStep2.origin = self.calculateButton.center;
        
        tutorialStep2.text = @"The Calculate button is the MOST important feature. Simply click Calculate and we will provide you with the correct GF tax claim based on your allocations for you!";
        tutorialStep2.size = CGSizeMake(290, 120);
        tutorialStep2.pointsUp = NO;
        
        [tutorials addObject:tutorialStep2];
        
        TutorialStep *tutorialStep3 = [TutorialStep new];
        
        tutorialStep3.text = @"All you need to do is add in the average price of a regular food item per category before the calculate feature can be used.\n\nYou can find these average food price items either online or in the quick help link we have provided";
        tutorialStep3.size = CGSizeMake(290, 160);
        tutorialStep3.pointsUp = YES;
        
        [tutorials addObject:tutorialStep3];
        
        [self.tutorialManager setTutorialDoneForViewController:self];
    }
    else
    {
        //don't show any tutorial
        return;
    }
    
    [self.tutorialManager startTutorialInViewController:self andTutorials:tutorials];
}

@end