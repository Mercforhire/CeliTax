//
//  UnitPickerViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-05.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MetricUnitPickerViewController.h"

@interface MetricUnitPickerViewController ()

@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UIButton *unitItemButton;

@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIButton *unitMLButton;
@property (weak, nonatomic) IBOutlet UIButton *unitLButton;
@property (weak, nonatomic) IBOutlet UIButton *unitGButton;
@property (weak, nonatomic) IBOutlet UIButton *unit100GButton;
@property (weak, nonatomic) IBOutlet UIButton *unitKGButton;

@end

@implementation MetricUnitPickerViewController

- (instancetype) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(60, 230);
    }
    
    return self;
}

-(void)highlightUnitButton:(UnitTypes)unitType
{
    switch (unitType)
    {
        case UnitTypesUnitItem:
            //highlight unitItemButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitItemButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unit100GButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            break;
            
        case UnitTypesUnitML:
            //highlight unitMLButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitMLButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unit100GButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
            
        case UnitTypesUnitL:
            //highlight unitLButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitLButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unit100GButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
            
        case UnitTypesUnitG:
            //highlight unitGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitGButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unit100GButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
            
        case UnitTypesUnit100G:
            //highlight unitGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unit100GButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
            
        case UnitTypesUnitKG:
            //highlight unitKGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitKGButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unit100GButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            
            break;
            
        default:
            //un-highlight all buttons
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unit100GButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
    }
}

-(void)setupUI
{
    (self.topContainer).backgroundColor = [UIColor whiteColor];
    (self.bottomContainer).backgroundColor = [UIColor whiteColor];
    
    [self.unitItemButton setTitle:NSLocalizedString(@"Item", nil) forState:UIControlStateNormal];
    [self.unitsLabel setText:NSLocalizedString(@"Units", nil)];
    
    [self highlightUnitButton:self.defaultSelectedUnit];
    
    [self.lookAndFeel applyGreenBorderTo:self.unitItemButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitMLButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitLButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitGButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitKGButton];
}

-(void)setDefaultSelectedUnit:(UnitTypes)defaultSelectedUnit
{
    _defaultSelectedUnit = defaultSelectedUnit;
    
    [self highlightUnitButton:_defaultSelectedUnit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

- (IBAction)itemButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitItem];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitItem];
    }
}

- (IBAction)mlButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitML];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitML];
    }
}

- (IBAction)lButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitL];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitL];
    }
}

- (IBAction)gButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitG];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitG];
    }
}

- (IBAction)g100ButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnit100G];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnit100G];
    }
}

- (IBAction)kgButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitKG];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitKG];
    }
}

@end
