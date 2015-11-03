//
// MyAccountViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MyAccountViewController.h"
#import "AccountTableViewCell.h"
#import "UserManager.h"
#import "AlertDialogsProvider.h"
#import "ViewControllerFactory.h"
#import "XYPieChart.h"
#import "UploadsHistoryTableViewCell.h"
#import "ReceiptBreakDownViewController.h"
#import "Utils.h"
#import "ConfigurationManager.h"
#import "ProfileBarView.h"
#import "TutorialManager.h"
#import "HollowGreenButton.h"
#import "ProfileSettingsViewController.h"
#import "UIView+Helper.h"
#import "YearSavingViewController.h"
#import "TutorialManager.h"
#import "SolidGreenButton.h"
#import "HorizonalScrollBarView.h"
#import "AddCategoryViewController.h"

#import "CeliTax-Swift.h"

@implementation CategoryRow

@end

#define kCatagoryTableRowHeight                     65

#define kCatagoryDetailsKeyTotalQty                 @"CatagoryDetailsKeyTotalQty"
#define kCatagoryDetailsKeyTotalAmount              @"CatagoryDetailsKeyTotalAmount"

#define kAccountTableViewCellIdentifier             @"AccountTableViewCell"
#define kUploadsHistoryTableViewCellIdentifier      @"UploadsHistoryTableViewCell"

@interface MyAccountViewController () <UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource, UITextFieldDelegate, TutorialManagerDelegate, HorizonalScrollBarViewProtocol>

@property (nonatomic, strong) UIView *pieChartContainer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UITableView *accountTableView;
@property (weak, nonatomic) IBOutlet HollowGreenButton *calculateButton;
@property (strong, nonatomic) ProfileBarView *profileBarView;
@property (strong, nonatomic) UIButton *navHelpButton;
@property (nonatomic, strong) UIToolbar *numberToolbar;
@property (weak, nonatomic) IBOutlet HorizonalScrollBarView *categoriesBar;

@property (nonatomic, strong) NSArray *catagories; // of ItemCategory
@property (nonatomic, strong) ItemCategory *currentlySelectedCategory;

@property (strong, nonatomic) NSMutableDictionary *categoryRowsForEachCategory;

@property (nonatomic, strong) NSMutableArray *slicePercentages;
@property (nonatomic, strong) NSMutableArray *sliceColors;
@property (nonatomic, strong) NSMutableArray *sliceNames;

@property (nonatomic, strong) CategoryRow *currentlySelectedRow;
@property (nonatomic, strong) NSArray *catagoryInfosToShow;

@property (nonatomic) BOOL recentUploadsSelected;
@property (nonatomic) BOOL previousWeekSelected;
@property (nonatomic) BOOL previousMonthSelected;
@property (nonatomic) BOOL viewAllSelected;

//Tutorials
@property (nonatomic, strong) NSMutableArray *tutorials;

@end

@implementation MyAccountViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"My Account", nil)];
    
    self.profileBarView = [[ProfileBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.profileBarView.profileImageView.layer.cornerRadius = self.profileBarView.profileImageView.frame.size.width / 2;
    self.profileBarView.profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    self.profileBarView.profileImageView.layer.borderWidth = 1.0f;
    [self.profileBarView.profileImageView setClipsToBounds: YES];
    
    [self.profileBarView.editButton1 addTarget:self action:@selector(editProfilePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.profileBarView.editButton2 addTarget:self action:@selector(editProfilePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *profileImageViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(editProfilePressed:)];
    [self.profileBarView.profileImageView addGestureRecognizer: profileImageViewTap];
    
    UITapGestureRecognizer *profileImageViewTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(editProfilePressed:)];
    [self.profileBarView.nameLabel addGestureRecognizer: profileImageViewTap2];
    
    [self.profileBarView setLookAndFeel:self.lookAndFeel];
    
    // set up tableview
    UINib *accountTableCell = [UINib nibWithNibName: @"AccountTableViewCell" bundle: nil];
    [self.accountTableView registerNib: accountTableCell forCellReuseIdentifier: kAccountTableViewCellIdentifier];

    UINib *uploadsHistoryTableViewCell = [UINib nibWithNibName: @"UploadsHistoryTableViewCell" bundle: nil];
    [self.accountTableView registerNib: uploadsHistoryTableViewCell forCellReuseIdentifier: kUploadsHistoryTableViewCellIdentifier];

    // set up pieChart
    self.pieChartContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 250)];
    
    [self.pieChartContainer addSubview: self.profileBarView];

    self.pieChart = [[XYPieChart alloc] initWithFrame: CGRectMake(0, 60, 180, 180)];
    CGPoint pieChartCenter = self.pieChartContainer.center;
    pieChartCenter.y = pieChartCenter.y + 20;
    
    (self.pieChart).center = pieChartCenter;

    [self.pieChartContainer addSubview: self.pieChart];

    (self.pieChart).backgroundColor = [UIColor clearColor];
    (self.pieChart).dataSource = self;
    (self.pieChart).delegate = self;
    [self.pieChart setStartPieAngle: M_PI_2];
    (self.pieChart).animationSpeed = 1.0;
    (self.pieChart).labelFont = [UIFont latoFontOfSize: 10];
    (self.pieChart).labelRadius = self.pieChart.frame.size.width / 4;
    [self.pieChart setShowPercentage: NO];
    [self.pieChart setPieBackgroundColor: [UIColor clearColor]];
    [self.pieChart setUserInteractionEnabled: YES];
    (self.pieChart).labelShadowColor = [UIColor blackColor];
    (self.pieChart).selectedSliceOffsetRadius = 0;
    
    // set up the National Average Cost ? button
    self.navHelpButton = [[UIButton alloc] initWithFrame:CGRectMake(self.pieChartContainer.frame.size.width - 27 - 35,
                                                                    self.pieChartContainer.frame.size.height - 27 - 10,
                                                                    27,
                                                                    27)];
    
    [self.navHelpButton setTitle:@"?" forState:UIControlStateNormal];
    [self.navHelpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    (self.navHelpButton.titleLabel).font = [UIFont latoFontOfSize:15];
    (self.navHelpButton).backgroundColor = self.lookAndFeel.appGreenColor;
    
    self.navHelpButton.layer.cornerRadius = self.navHelpButton.frame.size.width / 2;
    [self.navHelpButton setClipsToBounds: YES];
    
    [self.navHelpButton addTarget:self action:@selector(avgHelpClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pieChartContainer addSubview: self.navHelpButton];
    
    (self.accountTableView).tableHeaderView = self.pieChartContainer;
    
    // other set up
    [self.calculateButton setLookAndFeel:self.lookAndFeel];
    [self.calculateButton setTitle:NSLocalizedString(@"Calculate", nil) forState:UIControlStateNormal];
    
    if (self.configurationManager.getCurrentTaxYear)
    {
        (self.titleLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Tax Year for %ld", nil), (long)self.configurationManager.getCurrentTaxYear.integerValue];
    }
    
    self.numberToolbar = [[UIToolbar alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.numberToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *doneToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Done", nil)
                                                                         style: UIBarButtonItemStyleDone
                                                                        target: self
                                                                        action: @selector(doneOnKeyboardPressed)];
    
    [doneToolbarButton setTitleTextAttributes: @{NSFontAttributeName: [UIFont latoBoldFontOfSize: 15], NSForegroundColorAttributeName: [UIColor blackColor]} forState: UIControlStateNormal];
    
    self.numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                doneToolbarButton];
    
    [self.numberToolbar sizeToFit];
    
    self.categoriesBar.lookAndFeel = self.lookAndFeel;
    self.categoriesBar.backgroundColor = [UIColor clearColor];
}

#pragma mark - Life Cycle Functions

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];
    
    self.categoriesBar.delegate = self;
    self.categoriesBar.unselectable = NO;
    
    self.accountTableView.dataSource = self;
    self.accountTableView.delegate = self;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(openReceiptBreakDownView:)
                                                 name: Notifications.kReceiptItemsTableReceiptPressedNotification
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
    (self.profileBarView.nameLabel).text = [NSString stringWithFormat: @"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname];
    (self.profileBarView.profileImageView).image = self.userManager.user.avatarImage;
    
    // reset all state values
    self.categoryRowsForEachCategory = [NSMutableDictionary new];
    self.slicePercentages = [NSMutableArray new];
    self.sliceColors = [NSMutableArray new];
    self.sliceNames = [NSMutableArray new];
    
    // load Categories
    if (![self.tutorialManager hasTutorialBeenShown] && [self.tutorialManager automaticallyShowTutorialNextTime] )
    {
        //Create fake data
        // add fake categories
        ItemCategory *sampleCategory1 = [ItemCategory new];
        sampleCategory1.name = @"Rice";
        sampleCategory1.color = [UIColor yellowColor];
        sampleCategory1.localID = @"1";
        
        ItemCategory *sampleCategory2 = [ItemCategory new];
        sampleCategory2.name = @"Bread";
        sampleCategory2.color = [UIColor orangeColor];
        sampleCategory2.localID = @"2";
        
        ItemCategory *sampleCategory3 = [ItemCategory new];
        sampleCategory3.name = @"Meat";
        sampleCategory3.color = [UIColor redColor];
        sampleCategory3.localID = @"3";
        
        ItemCategory *sampleCategory4 = [ItemCategory new];
        sampleCategory4.name = @"Flour";
        sampleCategory4.color = [UIColor lightGrayColor];
        sampleCategory4.localID = @"4";
        
        ItemCategory *sampleCategory5 = [ItemCategory new];
        sampleCategory5.name = @"Cake";
        sampleCategory5.color = [UIColor purpleColor];
        sampleCategory5.localID = @"5";
        
        self.catagories = @[sampleCategory1, sampleCategory2, sampleCategory3, sampleCategory4, sampleCategory5];
    }
    else
    {
        // load all ItemCategory
        NSArray *catagories = [self.dataService fetchCatagories];
        
        self.catagories = catagories;
    }
    
    [self refreshButtonBar];
    
    //hide the ? button if no rows exist
    if (!self.catagories.count)
    {
        [self.navHelpButton setHidden:YES];
    }
    
    float totalTaxYearAmount = 0;
    
    // Start filling in self.catagoryRows: (CatagoryID, UnitTypeString, Total Qty/Total Weight, Total $ amount, national average cost)
    
    // Also record the total amount for each ItemCategory
    NSMutableDictionary *categoryTotalAmount = [NSMutableDictionary new];
    
    for (ItemCategory *category in self.catagories)
    {
        float totalAmountForCatagory = 0;
        
        NSArray *recordsForThisCatagory = [self.dataService fetchRecordsForCatagoryID:category.localID taxYear:self.configurationManager.getCurrentTaxYear.integerValue];
        
        // Separate recordsForThisCatagory into groups of the same Unit Type
        NSMutableDictionary *recordsOfEachType = [NSMutableDictionary new];
        
        for (Record *record in recordsForThisCatagory)
        {
            NSString *key = [Record unitTypeIntToUnitTypeString:record.unitType];
            
            NSMutableArray *recordsOfSameType = recordsOfEachType[key];
            
            if (!recordsOfSameType)
            {
                recordsOfSameType = [NSMutableArray new];
            }
            
            [recordsOfSameType addObject:record];
            
            recordsOfEachType[key] = recordsOfSameType;
        }
        
        //Always have a row for kUnitItemKey
        if (!recordsOfEachType[Record.kUnitItemKey])
        {
            float nationalAverageCost = 0;
            
            if (!category.nationalAverageCosts[Record.kUnitItemKey])
            {
                nationalAverageCost = -1;
            }
            else
            {
                nationalAverageCost = [category.nationalAverageCosts[Record.kUnitItemKey] floatValue];
            }
            
            CategoryRow *categoryRow = [CategoryRow new];
            
            categoryRow.categoryID = category.localID;
            categoryRow.unitTypeString = Record.kUnitItemKey;
            categoryRow.totalQtyOrWeight = 0;
            categoryRow.totalAmount = 0;
            categoryRow.nationalAverageCost = nationalAverageCost;
            
            if ((self.categoryRowsForEachCategory)[category.localID])
            {
                [(self.categoryRowsForEachCategory)[category.localID] addObject: categoryRow];
            }
            else
            {
                NSMutableArray *categoryRows = [NSMutableArray new];
                [categoryRows addObject:categoryRow];
                
                (self.categoryRowsForEachCategory)[category.localID] = categoryRows;
            }
            
            //if we are coming back to this View and self.currentlySelectedRow already exist, we need to update self.currentlySelectedRow to point to the new object in self.catagoryRows
            if (self.currentlySelectedRow &&
                [self.currentlySelectedRow.categoryID isEqualToString:category.localID] &&
                [self.currentlySelectedRow.unitTypeString isEqualToString:Record.kUnitItemKey] )
            {
                self.currentlySelectedRow = categoryRow;
                
                [self.accountTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: YES];
            }
        }
        
        //Process the Unit Types in order: Item, ML, L, G, KG
        NSArray *orderOfUnitTypesToProcess = @[Record.kUnitItemKey, Record.kUnitMLKey, Record.kUnitLKey, Record.kUnitGKey, Record.kUnit100GKey, Record.kUnitKGKey, Record.kUnitFlozKey, Record.kUnitPtKey, Record.kUnitQtKey, Record.kUnitGalKey, Record.kUnitOzKey, Record.kUnitLbKey];
        
        for (NSString *key in orderOfUnitTypesToProcess)
        {
            NSMutableArray *recordsOfSameType = recordsOfEachType[key];
            
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
            
            float nationalAverageCost = 0;
            
            if (!category.nationalAverageCosts[key])
            {
                nationalAverageCost = -1;
            }
            else
            {
                nationalAverageCost = [category.nationalAverageCosts[key] floatValue];
            }
            
            CategoryRow *categoryRow = [CategoryRow new];
            
            categoryRow.categoryID = category.localID;
            categoryRow.unitTypeString = key;
            categoryRow.totalQtyOrWeight = totalQuantityForThisCatagoryAndUnitType;
            categoryRow.totalAmount = totalAmountSpentOnThisCatagoryAndUnitType;
            categoryRow.nationalAverageCost = nationalAverageCost;
            
            if ((self.categoryRowsForEachCategory)[category.localID])
            {
                [(self.categoryRowsForEachCategory)[category.localID] addObject: categoryRow];
            }
            else
            {
                NSMutableArray *categoryRows = [NSMutableArray new];
                [categoryRows addObject:categoryRow];
                
                self.categoryRowsForEachCategory[category.localID] = categoryRows;
            }
            
            //if we are coming back to this View and self.currentlySelectedRow already exist, we need to update self.currentlySelectedRow to point to the new object in self.catagoryRows
            if (self.currentlySelectedRow &&
                [self.currentlySelectedRow.categoryID isEqualToString:category.localID] &&
                [self.currentlySelectedRow.unitTypeString isEqualToString:Record.kUnitItemKey] )
            {
                self.currentlySelectedRow = categoryRow;
                
                [self.accountTableView scrollToRowAtIndexPath:
                 [NSIndexPath indexPathForRow: [(self.categoryRowsForEachCategory)[category.localID] indexOfObject:self.currentlySelectedRow] * 2 inSection: 0]
                                             atScrollPosition: UITableViewScrollPositionTop
                                                     animated: YES];
            }
        }
        
        categoryTotalAmount[category.localID] = @(totalAmountForCatagory);
    }
    
    if ((self.categoryRowsForEachCategory)[self.currentlySelectedCategory.localID])
    {
        if ([(self.categoryRowsForEachCategory)[self.currentlySelectedCategory.localID] indexOfObject:self.currentlySelectedRow] == NSNotFound)
        {
            self.currentlySelectedRow = nil;
        }
    }
    else
    {
        self.currentlySelectedRow = nil;
    }
    
    if (self.recentUploadsSelected)
    {
        [self loadRecentUploads];
    }
    
    if (self.previousWeekSelected)
    {
        [self loadPreviousWeekUploads];
    }
    
    if (self.previousMonthSelected)
    {
        [self loadPreviousMonthUploads];
    }
    
    if (self.viewAllSelected)
    {
        [self loadAllUploadsForTheYear];
    }
    
    [self.accountTableView reloadData];
    
    // refresh pie chart
    for (ItemCategory *category in self.catagories)
    {
        [self.sliceColors addObject: category.color];
        [self.sliceNames addObject: category.name];
        
        NSNumber *totalForCategory = categoryTotalAmount[category.localID];
        
        float sumAmount = 0;
        
        if (totalForCategory)
        {
            sumAmount = totalForCategory.floatValue;
        }
        
        if (totalTaxYearAmount == 0)
        {
            [self.slicePercentages addObject: @0];
        }
        else
        {
            [self.slicePercentages addObject: [NSNumber numberWithInt: sumAmount * 100 / totalTaxYearAmount]];
        }
    }
    
    [self.pieChart reloadData];
    
    //select the first category by default
    if (self.catagories.count)
    {
        [self.categoriesBar simulateNormalPressOnButton:0];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.tutorialManager hasTutorialBeenShown] && [self.tutorialManager automaticallyShowTutorialNextTime] )
    {
        [self setupTutorials];
        
        if (self.tutorialManager.currentStep == 19)
        {
            [self displayTutorialStep:TutorialStep19];
        }
    }
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    self.navigationController.navigationBarHidden = NO;

    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: Notifications.kReceiptItemsTableReceiptPressedNotification
                                                  object: nil];
    
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
    NSDictionary *notificationDictionary = notification.userInfo;

    NSString *receiptID = notificationDictionary[DataService.kReceiptIDKey];

    [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: receiptID cameFromReceiptCheckingViewController: NO] animated: YES];
}

-(void)loadRecentUploads
{
    // get the last 5 recent uploads
    if (self.currentlySelectedRow)
    {
        NSString *catagoryID = self.currentlySelectedRow.categoryID;
        NSString *unitTypeString = self.currentlySelectedRow.unitTypeString;
        
        NSArray *catagoryInfos =
        [self.dataService fetchLatestNthCatagoryInfosforCatagory:catagoryID unitType:[Record unitTypeStringToUnitTypeInt:unitTypeString] nTh:5 taxYear:self.configurationManager.getCurrentTaxYear.integerValue];
        
        self.catagoryInfosToShow = catagoryInfos;
        
        [self.accountTableView reloadData];
    }
}

-(void)loadPreviousWeekUploads
{
    if (self.currentlySelectedRow)
    {
        NSDate *mondayOfThisWeek = [Utils dateForMondayOfThisWeek];
        DLog(@"Monday of this week is %@", mondayOfThisWeek.description);
        NSDate *mondayOfPreviousWeek = [Utils dateForMondayOfPreviousWeek];
        DLog(@"Monday of previous week is %@", mondayOfPreviousWeek.description);
        
        NSString *catagoryID = self.currentlySelectedRow.categoryID;
        NSString *unitTypeString = self.currentlySelectedRow.unitTypeString;
        
        NSArray *catagoryInfos = [self.dataService fetchCatagoryInfoFromDate:mondayOfPreviousWeek toDate:mondayOfThisWeek taxYear:self.configurationManager.getCurrentTaxYear.integerValue catagoryID:catagoryID unitType:[Record unitTypeStringToUnitTypeInt:unitTypeString]];
        
        self.catagoryInfosToShow = catagoryInfos;
        
        [self.accountTableView reloadData];
    }
}

-(void)loadPreviousMonthUploads
{
    if (self.currentlySelectedRow)
    {
        NSDate *firstDayOfThisMonth = [Utils dateForFirstDayOfThisMonth];
        DLog(@"First day of this month is %@", firstDayOfThisMonth.description);
        
        NSDate *firstDayOfPreviousMonth = [Utils dateForFirstDayOfPreviousMonth];
        DLog(@"First Day Of Previous Month is %@", firstDayOfPreviousMonth.description);
        
        NSString *catagoryID = self.currentlySelectedRow.categoryID;
        NSString *unitTypeString = self.currentlySelectedRow.unitTypeString;
        
        NSArray *catagoryInfos = [self.dataService fetchCatagoryInfoFromDate:firstDayOfPreviousMonth
                                                                      toDate:firstDayOfThisMonth
                                                                     taxYear:self.configurationManager.getCurrentTaxYear.integerValue
                                                                  catagoryID:catagoryID
                                                                    unitType:[Record unitTypeStringToUnitTypeInt:unitTypeString]];
        
        self.catagoryInfosToShow = catagoryInfos;
        
        [self.accountTableView reloadData];
    }
}

-(void)loadAllUploadsForTheYear
{
    if (self.currentlySelectedRow)
    {
        NSString *catagoryID = self.currentlySelectedRow.categoryID;
        NSString *unitTypeString = self.currentlySelectedRow.unitTypeString;
        
        // all receipts from this category
        NSArray *catagoryInfos = [self.dataService fetchLatestNthCatagoryInfosforCatagory:catagoryID unitType:[Record unitTypeStringToUnitTypeInt:unitTypeString] nTh:-1 taxYear:self.configurationManager.getCurrentTaxYear.integerValue];
        
        self.catagoryInfosToShow = catagoryInfos;
        
        [self.accountTableView reloadData];
    }
}

- (void) refreshButtonBar
{
    NSMutableArray *categoryNames = [NSMutableArray new];
    NSMutableArray *categoryColors = [NSMutableArray new];
    
    for (ItemCategory *category in self.catagories)
    {
        [categoryNames addObject: category.name];
        [categoryColors addObject: category.color];
    }
    
    [self.categoriesBar setButtonNames: categoryNames andColors: categoryColors];
}

-(void)setCurrentlySelectedCategory:(ItemCategory *)currentlySelectedCategory
{
    _currentlySelectedCategory = currentlySelectedCategory;
    
    [self.accountTableView reloadData];
}

#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification events

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    if (!self.currentlySelectedRow)
    {
        NSDictionary *info = aNotification.userInfo;
        CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
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
    BOOL allNationalAverageCostsEntered = YES;
    
    BOOL hasAtLeastOneItem = NO;
    
    NSString *nameOfCategoryNotEntered;
    
    // Check if all rows containing Records have national average entered
    for (NSString *categoryIDKey in self.categoryRowsForEachCategory.allKeys)
    {
        NSMutableArray *categoryRows = (self.categoryRowsForEachCategory)[categoryIDKey];
        
        if (!allNationalAverageCostsEntered)
        {
            break;
        }
        
        for (CategoryRow *categoryRow in categoryRows)
        {
            NSInteger quantityOrWeight = categoryRow.totalQtyOrWeight;
            
            float amountPerItemOrAllWeight = categoryRow.totalAmount;
            
            float nationalAverageCost = categoryRow.nationalAverageCost;
            
            if (quantityOrWeight > 0 && amountPerItemOrAllWeight > 0)
            {
                hasAtLeastOneItem = YES;
            }
            
            if (quantityOrWeight > 0 && amountPerItemOrAllWeight > 0 && nationalAverageCost < 0)
            {
                allNationalAverageCostsEntered = NO;
                
                nameOfCategoryNotEntered = [self.dataService fetchCatagory:categoryIDKey].name;
                
                break;
            }
        }
    }
    
    if (!hasAtLeastOneItem)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                          message:NSLocalizedString(@"This tax year has no recorded items", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
        
        [message show];
        
        return;
    }
    
    if (allNationalAverageCostsEntered)
    {
        [self.navigationController pushViewController: [self.viewControllerFactory createYearSavingViewController] animated: YES];
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                          message:[NSString stringWithFormat:NSLocalizedString(@"Category %@ has one of its national average cost not entered", nil), nameOfCategoryNotEntered]
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
        
        [message show];
        
        return;
    }
}

- (void) editProfilePressed: (UIButton *) sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createProfileSettingsViewController] animated: YES];
}

-(void)avgHelpClicked
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (IBAction) addCatagoryPressed: (UIButton *) sender
{
    // open up the AddCatagoryViewController
    [self.navigationController pushViewController: [self.viewControllerFactory createAddCategoryViewController] animated: YES];
}

#pragma mark - HorizonalScrollBarViewProtocol

- (void) buttonClickedWithIndex: (NSInteger) index andName: (NSString *) name
{
    self.currentlySelectedCategory = (self.catagories)[index];
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
    NSMutableArray *categoryRows = (self.categoryRowsForEachCategory)[self.currentlySelectedCategory.localID];
    
    CategoryRow *dataForThisRow = categoryRows[textField.tag];
    
    NSString *catagoryID = dataForThisRow.categoryID;
    
    NSString *unitTypeString = dataForThisRow.unitTypeString;
    
    NSInteger unitType = [Record unitTypeStringToUnitTypeInt:unitTypeString];
    
    // if user types nothing for a textField, we default it to ----
    if (textField.text.length == 0 || textField.text.floatValue == 0)
    {
        textField.text = @"--";
        
        [self.manipulationService deleteNationalAverageCostForCatagoryID:catagoryID andUnitType:unitType save:YES];
        
        dataForThisRow.nationalAverageCost = -1;
        
        [categoryRows setObject:dataForThisRow atIndexedSubscript:textField.tag];
    }
    else
    {
        textField.text = [NSString stringWithFormat: @"%.2f", textField.text.floatValue];
        
        [self.manipulationService addOrUpdateNationalAverageCostForCatagoryID:catagoryID andUnitType:unitType amount:textField.text.floatValue save:YES];
        
        dataForThisRow.nationalAverageCost = textField.text.floatValue;
        
        [categoryRows setObject:dataForThisRow atIndexedSubscript:textField.tag];
    }
}

#pragma mark - XYPieChart Data Source

- (NSUInteger) numberOfSlicesInPieChart: (XYPieChart *) pieChart
{
    return self.slicePercentages.count;
}

- (CGFloat) pieChart: (XYPieChart *) pieChart valueForSliceAtIndex: (NSUInteger) index
{
    return [(self.slicePercentages)[index] intValue];
}

- (UIColor *) pieChart: (XYPieChart *) pieChart colorForSliceAtIndex: (NSUInteger) index
{
    return (self.sliceColors)[(index % self.sliceColors.count)];
}

- (NSString *) pieChart: (XYPieChart *) pieChart textForSliceAtIndex: (NSUInteger) index
{
    NSString *sliceText = [NSString stringWithFormat: @"%@\n%d%%",
                           (self.sliceNames)[(index % self.sliceNames.count)],
                           [(self.slicePercentages)[index] intValue]];

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
    [self.categoriesBar simulateNormalPressOnButton:index];
    
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

    [self loadRecentUploads];
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

    [self loadPreviousWeekUploads];
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

    [self loadPreviousMonthUploads];
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
    
    [self loadAllUploadsForTheYear];
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
    else if (self.recentUploadsSelected || self.previousWeekSelected ||
             self.previousMonthSelected || self.viewAllSelected)
    {
        float totalHeight = (kMargin + kBiggestLabelHeight + kMargin) * 4 + kNoItemsTableViewCellHeight;
        
        return totalHeight;
    }
    else
    {
        float totalHeight = (kMargin + kBiggestLabelHeight + kMargin) * 4;
        
        return totalHeight;
    }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    if (self.currentlySelectedCategory)
    {
        NSMutableArray *categoryRows = (self.categoryRowsForEachCategory)[self.currentlySelectedCategory.localID];
        
        return categoryRows.count * 2;
    }
    else
    {
        return 0;
    }
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

        NSMutableArray *categoryRows = (self.categoryRowsForEachCategory)[self.currentlySelectedCategory.localID];
        
        CategoryRow *dataForPreviousRow;
        
        if (indexPath.row >= 2)
        {
            dataForPreviousRow = categoryRows[(indexPath.row - 2) / 2];
        }
        
        CategoryRow *dataForThisRow = categoryRows[indexPath.row / 2];
        
        NSString *unitTypeString = dataForThisRow.unitTypeString;
        
        NSInteger quantity = dataForThisRow.totalQtyOrWeight;
        
        float amount = dataForThisRow.totalAmount;

        if ( [unitTypeString isEqualToString:Record.kUnitItemKey] )
        {
            cell.colorBoxColor = self.currentlySelectedCategory.color;
            
            cell.colorBox.backgroundColor = self.currentlySelectedCategory.color;
        }
        else
        {
            cell.colorBoxColor = [UIColor lightGrayColor];
            
            cell.colorBox.backgroundColor = [UIColor lightGrayColor];
        }

        if ([unitTypeString isEqualToString:Record.kUnitItemKey])
        {
            (cell.categoryNameLabel).text = self.currentlySelectedCategory.name;
        }
        else if ([unitTypeString isEqualToString:Record.kUnitGKey])
        {
            (cell.categoryNameLabel).text = @"(g)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnit100GKey])
        {
            (cell.categoryNameLabel).text = @"(100g)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitKGKey])
        {
            (cell.categoryNameLabel).text = @"(kg)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitLKey])
        {
            (cell.categoryNameLabel).text = @"(L)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitMLKey])
        {
            (cell.categoryNameLabel).text = @"(mL)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitFlozKey])
        {
            (cell.categoryNameLabel).text = @"(fl oz)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitPtKey])
        {
            (cell.categoryNameLabel).text = @"(pt)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitQtKey])
        {
            (cell.categoryNameLabel).text = @"(qt)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitGalKey])
        {
            (cell.categoryNameLabel).text = @"(gal)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitOzKey])
        {
            (cell.categoryNameLabel).text = @"(oz)";
        }
        else if ([unitTypeString isEqualToString:Record.kUnitLbKey])
        {
            (cell.categoryNameLabel).text = @"(lb)";
        }
        
        (cell.totalQuantityField).text = [NSString stringWithFormat: @"%ld", (long)quantity];
        (cell.totalAmountField).text = [NSString stringWithFormat: @"%.2f", amount];
        
        [self.lookAndFeel applyGrayBorderTo: cell.totalQuantityField];
        [self.lookAndFeel applyGrayBorderTo: cell.totalAmountField];

        float nationalAverageCost = dataForThisRow.nationalAverageCost;
        
        if (nationalAverageCost >= 0)
        {
            (cell.averageNationalPriceField).text = [NSString stringWithFormat: @"%.2f", nationalAverageCost];
        }
        else
        {
            (cell.averageNationalPriceField).text = @"--";
        }
        
        (cell.averageNationalPriceField).delegate = self;
        
        //set the tag to be the index of the data for this row in respect to self.catagoryRows
        (cell.averageNationalPriceField).tag = indexPath.row / 2;
        
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
            
            if (dataForPreviousRow)
            {
                // hide cell labels if the previous cell is same type
                NSString *unitTypeStringPreviousRow = dataForPreviousRow.unitTypeString;
                
                BOOL isCurrentRowAItem = [unitTypeString isEqualToString:Record.kUnitItemKey];
                
                BOOL isPreviousRowAItem = [unitTypeStringPreviousRow isEqualToString:Record.kUnitItemKey];
                
                if (isCurrentRowAItem == isPreviousRowAItem)
                {
                    [cell hideLabels];
                }
                else
                {
                    [cell showLabels];
                }
                
                [cell.avgPriceLabel setHidden:YES];
            }
            else
            {
                // this is the first row
                [cell showLabels];
            }
        }
        
        [self.lookAndFeel applySlightlyDarkerBorderTo: cell.colorBox];
        
        if ([unitTypeString isEqualToString:Record.kUnitItemKey])
        {
            [cell.totalQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
        }
        else
        {
            [cell.totalQtyLabel setText:NSLocalizedString(@"Weight", nil)];
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

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.clipsToBounds = YES;

        UITapGestureRecognizer *recentUploadsLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(recentUploadsLabelPressed)];
        
        UITapGestureRecognizer *recentUploadsLabelTap2 =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(recentUploadsLabelPressed)];

        UITapGestureRecognizer *previousWeekLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(previousWeekLabelPressed)];
        
        UITapGestureRecognizer *previousWeekLabelTap2 =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(previousWeekLabelPressed)];

        UITapGestureRecognizer *previousMonthLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(previousMonthLabelPressed)];
        
        UITapGestureRecognizer *previousMonthLabelTap2 =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(previousMonthLabelPressed)];

        UITapGestureRecognizer *viewAllLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(viewAllLabelPressed)];
        
        UITapGestureRecognizer *viewAllLabelTap2 =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(viewAllLabelPressed)];

        [cell.recentUploadsLabel addGestureRecognizer: recentUploadsLabelTap];
        [cell.recentUploadsTriangle setUserInteractionEnabled:YES];
        [cell.recentUploadsTriangle addGestureRecognizer: recentUploadsLabelTap2];

        [cell.previousWeekLabel addGestureRecognizer: previousWeekLabelTap];
        [cell.previousWeekTriangle setUserInteractionEnabled:YES];
        [cell.previousWeekTriangle addGestureRecognizer: previousWeekLabelTap2];

        [cell.previousMonthLabel addGestureRecognizer: previousMonthLabelTap];
        [cell.previousMonthTriangle setUserInteractionEnabled:YES];
        [cell.previousMonthTriangle addGestureRecognizer: previousMonthLabelTap2];

        [cell.viewAllLabel addGestureRecognizer: viewAllLabelTap];
        [cell.viewAllTriangle setUserInteractionEnabled:YES];
        [cell.viewAllTriangle addGestureRecognizer: viewAllLabelTap2];

        NSMutableArray *categoryRows = (self.categoryRowsForEachCategory)[self.currentlySelectedCategory.localID];
        
        CategoryRow *dataForThisRow = categoryRows[(indexPath.row - 1) / 2];
        
        NSString *unitTypeString = dataForThisRow.unitTypeString;
        
        cell.catagoryColor = self.currentlySelectedCategory.color;

        if ([unitTypeString isEqualToString:Record.kUnitItemKey])
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
        NSMutableArray *categoryRows = (self.categoryRowsForEachCategory)[self.currentlySelectedCategory.localID];
        
        CategoryRow *dataForThisRow = categoryRows[(indexPath.row - 1) / 2];
        
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
        NSMutableArray *categoryRows = (self.categoryRowsForEachCategory)[self.currentlySelectedCategory.localID];
        
        CategoryRow *dataForThisRow = categoryRows[indexPath.row / 2];
        
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

typedef NS_ENUM(NSUInteger, TutorialSteps)
{
    TutorialStep19,
    TutorialStep20
};

-(void)setupTutorials
{
    (self.tutorialManager).delegate = self;
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep19 = [TutorialStep new];
    
    tutorialStep19.text = NSLocalizedString(@"Calculating your GF tax claim is easy, just be sure to enter an average non-GF cost equivelant first for each category.", nil);
    tutorialStep19.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep19.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    CGRect tableRowsFrame = CGRectMake(self.view.frame.size.width - 75, self.accountTableView.frame.origin.y + self.pieChartContainer.frame.size.height + 10, 66, 66);
    
    tutorialStep19.highlightedItemRect = tableRowsFrame;
    tutorialStep19.pointsUp = NO;
    
    [self.tutorials addObject:tutorialStep19];
    
    TutorialStep *tutorialStep20 = [TutorialStep new];
    
    tutorialStep20.text = NSLocalizedString(@"Click calculate and we'll do the work for you!", nil);
    tutorialStep20.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep20.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep20.pointsUp = NO;
    
    tutorialStep20.highlightedItemRect = [Utils returnRectBiggerThan:self.calculateButton.frame by: 3];;
    
    [self.tutorials addObject:tutorialStep20];
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
        case 19:
        {
            //Go back to Step 18 in Vault
            self.tutorialManager.currentStep = 18;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self selectedMenuIndex:RootViewControllerVault];
            }];
        }
            
            break;
            
        case 20:
            //Go back to Step 19
            self.tutorialManager.currentStep = 19;
            [self displayTutorialStep:TutorialStep19];
            break;
            
        default:
            break;
    }
}

- (void) tutorialRightSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 19:
            //Go to Step 20
            self.tutorialManager.currentStep = 20;
            [self displayTutorialStep:TutorialStep20];
            break;
            
        case 20:
        {
            //Go back to Main view
            self.tutorialManager.currentStep = 21;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self selectedMenuIndex:RootViewControllerHome];
            }];
        }
            break;
            
        default:
            break;
    }
}

@end