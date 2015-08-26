//
//  TaxYearSummaryViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "YearSummaryViewController.h"
#import "YearSummaryTableViewCell.h"
#import "HollowGreenButton.h"
#import "ConfigurationManager.h"
#import "AlertDialogsProvider.h"
#import "Catagory.h"
#import "Record.h"
#import "WYPopoverController.h"
#import "SendReceiptsToViewController.h"
#import "ViewControllerFactory.h"

#define kYearSummaryTableViewCellIdentifier             @"YearSummaryTableViewCell"
#define kYearSummaryTableViewCellHeight                 60

@interface YearSummaryViewController () <UITableViewDataSource, UITableViewDelegate, SendReceiptsViewPopUpDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSavingsLabel;
@property (weak, nonatomic) IBOutlet UITableView *summaryTableView;
@property (weak, nonatomic) IBOutlet HollowGreenButton *exportButton;

@property (nonatomic, strong) WYPopoverController *sendReceiptsPopover;
@property (nonatomic, strong) SendReceiptsToViewController *sendReceiptsToViewController;

@property (nonatomic, strong) NSArray *catagories; // of Catagory
// NSMutableArray of NSArray of a fixed size 4:
// (CatagoryID, UnitTypeString, Total Spent, Total average cost, Total GF savings)
@property (strong, nonatomic) NSMutableArray *catagoryRows;

@end

@implementation YearSummaryViewController

-(void)setupUI
{
    [self.exportButton setLookAndFeel:self.lookAndFeel];
    
    [self.titleLabel setText:[NSString stringWithFormat:@"%ld Gluten-Free Tax Savings", (long)self.configurationManager.getCurrentTaxYear]];
    
    // set up tableview
    UINib *yearSummaryTableViewCell = [UINib nibWithNibName: @"YearSummaryTableViewCell" bundle: nil];
    [self.summaryTableView registerNib: yearSummaryTableViewCell forCellReuseIdentifier: kYearSummaryTableViewCellIdentifier];
    
    self.sendReceiptsToViewController = [self.viewControllerFactory createSendReceiptsToViewController];
    self.sendReceiptsPopover = [[WYPopoverController alloc] initWithContentViewController: self.sendReceiptsToViewController];
    [self.sendReceiptsPopover setTheme: [WYPopoverTheme theme]];
    
    WYPopoverTheme *popUpTheme = self.sendReceiptsPopover.theme;
    popUpTheme.fillTopColor = self.lookAndFeel.appGreenColor;
    popUpTheme.fillBottomColor = self.lookAndFeel.appGreenColor;
    
    [self.sendReceiptsPopover setTheme: popUpTheme];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    // load all Catagory
    NSArray *catagories = [self.dataService fetchCatagories];
    
    self.catagories = catagories;
    
    self.summaryTableView.dataSource = self;
    self.summaryTableView.delegate = self;
    
    [self.sendReceiptsToViewController setDelegate: self];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // reset all state values
    self.catagoryRows = [NSMutableArray new];
    
    float totalSavingsAmount = 0;
    
    // Start filling in self.catagoryRows: (CatagoryID, UnitTypeString, Total Spent, Total average cost, Total GF savings)
    
    for (Catagory *catagory in self.catagories)
    {
        NSArray *recordsForThisCatagory = [self.dataService fetchRecordsForCatagoryID: catagory.localID
                                                                            inTaxYear: self.configurationManager.getCurrentTaxYear];
        
        // Separate recordsForThisCatagory into groups of the same Unit Type
        NSMutableDictionary *recordsOfEachType = [NSMutableDictionary new];
        
        for (Record *record in recordsForThisCatagory)
        {
            NSString *key = [Record unitTypeIntToUnitTypeString:record.unitType];
            
            NSMutableArray *recordsOfSameType = [recordsOfEachType objectForKey:key];
            
            if (!recordsOfSameType)
            {
                recordsOfSameType = [NSMutableArray new];
            }
            
            [recordsOfSameType addObject:record];
            
            [recordsOfEachType setObject:recordsOfSameType forKey:key];
        }
        
        //Process the Unit Types in order: Item, ML, L, G, KG
        NSArray *orderOfUnitTypesToProcess = [NSArray arrayWithObjects:kUnitItemKey, kUnitMLKey, kUnitLKey, kUnitGKey, kUnit100GKey, kUnitKGKey, nil];
        
        for (NSString *key in orderOfUnitTypesToProcess)
        {
            NSMutableArray *recordsOfSameType = [recordsOfEachType objectForKey:key];
            
            if (!recordsOfSameType.count)
            {
                continue;
            }
            
            float totalAmountSpentOnThisCatagoryAndUnitType = 0;
            NSInteger totalQuantityForThisCatagoryAndUnitType = 0;
            
            for (Record *record in recordsOfSameType)
            {
                totalQuantityForThisCatagoryAndUnitType += record.quantity;
                totalAmountSpentOnThisCatagoryAndUnitType += [record calculateTotal];
            }
            
            NSNumber *nationalAverageCost = [catagory.nationalAverageCosts objectForKey:key];
            
            float totalAvgCost = 0;
            
            if (!nationalAverageCost)
            {
                nationalAverageCost = [NSNumber numberWithFloat: -1];
                
                totalAvgCost = -1;
            }
            else
            {
                totalAvgCost = nationalAverageCost.floatValue * totalQuantityForThisCatagoryAndUnitType;
            }
            
            float gfSavings = 0;
            
            if (totalAvgCost >= 0)
            {
                gfSavings = totalAmountSpentOnThisCatagoryAndUnitType - totalAvgCost;
            }
            else
            {
                gfSavings = -1;
            }
            
            if (gfSavings >= 0)
            {
                totalSavingsAmount += gfSavings;
            }
            
            // (CatagoryID, UnitTypeString, Total Spent, Total average cost, Total GF savings)
            NSMutableArray *rowArray = [NSMutableArray arrayWithObjects:catagory.localID, key, [NSNumber numberWithFloat:totalAmountSpentOnThisCatagoryAndUnitType], [NSNumber numberWithFloat: totalAvgCost], [NSNumber numberWithFloat: gfSavings], nil];
            
            [self.catagoryRows addObject:rowArray];
        }
    }
    
    [self.summaryTableView reloadData];
    
    [self.totalSavingsLabel setText: [NSString stringWithFormat: @"$%.2f", totalSavingsAmount]];
}

- (IBAction)exportPressed:(HollowGreenButton *)sender
{
    // open up 'Send Receipts To' pop up
    [self.sendReceiptsPopover presentPopoverFromRect: self.exportButton.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionDown animated: YES];
}

-(void)showSavingWarningDialog
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                      message:@"The total average price should not be higher than the actual total spent, please check to see if the correct average price was entered."
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok",nil];
    
    [message show];
}

#pragma mark - SendReceiptsViewPopUpDelegate

- (void) sendReceiptsToEmailRequested: (NSString *) emailAddress
{
    [self.sendReceiptsPopover dismissPopoverAnimated: YES];
    
    [AlertDialogsProvider showWorkInProgressDialog];
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.catagoryRows.count;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellId = kYearSummaryTableViewCellIdentifier;
    YearSummaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    
    if (cell == nil)
    {
        cell = [[YearSummaryTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        cell.clipsToBounds = YES;
    }
    
    // (CatagoryID, UnitTypeString, Total Spent, Total average cost, Total GF savings)
    NSArray *dataForThisRow = [self.catagoryRows objectAtIndex:indexPath.row];
    
    NSString *catagoryID = [dataForThisRow firstObject];
    
    Catagory *thisCatagory = [self.dataService fetchCatagory:catagoryID];
    
    NSString *unitTypeString = [dataForThisRow objectAtIndex:1];
    
    float totalSpent = [[dataForThisRow objectAtIndex:2] floatValue];
    
    float totalAvgCost = [[dataForThisRow objectAtIndex:3] floatValue];
    
    float totalSavings = [[dataForThisRow objectAtIndex:4] floatValue];
    
    cell.colorView.backgroundColor = thisCatagory.color;
    
    if ([unitTypeString isEqualToString:kUnitItemKey])
    {
        [cell.catagoryNameLabel setText: thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:kUnitGKey])
    {
        [cell.catagoryNameLabel setText: [NSString stringWithFormat:@"%@ per (g)", thisCatagory.name]];
    }
    else if ([unitTypeString isEqualToString:kUnit100GKey])
    {
        [cell.catagoryNameLabel setText: [NSString stringWithFormat:@"%@ per (100g)", thisCatagory.name]];
    }
    else if ([unitTypeString isEqualToString:kUnitKGKey])
    {
        [cell.catagoryNameLabel setText: [NSString stringWithFormat:@"%@ per (kg)", thisCatagory.name]];
    }
    else if ([unitTypeString isEqualToString:kUnitLKey])
    {
        [cell.catagoryNameLabel setText: [NSString stringWithFormat:@"%@ per (L)", thisCatagory.name]];
    }
    else if ([unitTypeString isEqualToString:kUnitMLKey])
    {
        [cell.catagoryNameLabel setText: [NSString stringWithFormat:@"%@ per (ml)", thisCatagory.name]];
    }
    
    [cell.totalSpentField setText: [NSString stringWithFormat: @"%.2f", totalSpent]];
    [cell.totalAvgCostField setText: [NSString stringWithFormat: @"%.2f", totalAvgCost]];
    
    if (totalSavings >= 0)
    {
        [cell.gfSavingsField setText: [NSString stringWithFormat: @"%.2f", totalSavings]];
        [cell.gfSavingsField setTextColor:self.lookAndFeel.appGreenColor];
        [cell.gfSavingsField setEnabled:YES];
        [cell.exclaimationButton setHidden:YES];
    }
    else
    {
        [cell.gfSavingsField setText: @""];
        [cell.gfSavingsField setEnabled:NO];
        [cell.exclaimationButton setHidden:NO];
        
        [cell.exclaimationButton addTarget:self
                                    action:@selector(showSavingWarningDialog)
                          forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.lookAndFeel applyGrayBorderTo: cell.totalSpentField];
    [self.lookAndFeel applyGrayBorderTo: cell.totalAvgCostField];
    [self.lookAndFeel applyGreenBorderTo: cell.gfSavingsField];
    
    [self.lookAndFeel applySlightlyDarkerBorderTo: cell.colorView];
    
    if (indexPath.row == 0)
    {
        [cell showLabels];
    }
    else
    {
        [cell hideLabels];
    }
    
    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kYearSummaryTableViewCellHeight;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    //
}

@end
