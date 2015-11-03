//
//  YearSavingViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-14.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "YearSavingViewController.h"
#import "HollowWhiteButton.h"
#import "ConfigurationManager.h"
#import "YearSummaryViewController.h"
#import "ViewControllerFactory.h"

#import "CeliTax-Swift.h"

@interface YearSavingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *yearSavingsTitle;
@property (weak, nonatomic) IBOutlet UILabel *amountTitle;
@property (weak, nonatomic) IBOutlet HollowWhiteButton *viewDetailsButton;

@end

@implementation YearSavingViewController

-(void)setupUI
{
    (self.view).backgroundColor = self.lookAndFeel.appGreenColor;
    
    [self.viewDetailsButton setLookAndFeel:self.lookAndFeel];
    [self.viewDetailsButton setTitle:NSLocalizedString(@"View Details", nil) forState:UIControlStateNormal];
    
    (self.yearSavingsTitle).text = [NSString stringWithFormat:NSLocalizedString(@"Your %ld savings:", nil), (long)self.configurationManager.getCurrentTaxYear.integerValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // load all ItemCategory
    NSArray *catagories = [self.dataService fetchCatagories];
    
    float totalSavingsAmount = 0;
    
    for (ItemCategory *category in catagories)
    {
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
        
        //Process the Unit Types in order: Item, ML, L, G, KG
        NSArray *orderOfUnitTypesToProcess = @[Record.kUnitItemKey, Record.kUnitMLKey, Record.kUnitLKey, Record.kUnitGKey, Record.kUnit100GKey, Record.kUnitKGKey, Record.kUnitFlozKey, Record.kUnitPtKey, Record.kUnitQtKey, Record.kUnitGalKey, Record.kUnitOzKey, Record.kUnitLbKey];
        
        for (NSString *key in orderOfUnitTypesToProcess)
        {
            NSMutableArray *recordsOfSameType = recordsOfEachType[key];
            
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
            
            NSNumber *nationalAverageCost = category.nationalAverageCosts[key];
            
            float totalAvgCost = 0;
            
            if (!nationalAverageCost)
            {
                nationalAverageCost = @-1.0f;
                
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
        }
    }
    
    (self.amountTitle).text = [NSString stringWithFormat: @"$%.2f", totalSavingsAmount];
}

- (IBAction)viewDetailsPressed:(HollowWhiteButton *)sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createYearSummaryViewController] animated: YES];
}

@end
