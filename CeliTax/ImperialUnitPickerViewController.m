//
//  ImperialUnitPickerViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-09-07.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ImperialUnitPickerViewController.h"

@interface ImperialUnitPickerViewController ()

@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UIButton *unitItemButton;

@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIButton *unitflOZButton;
@property (weak, nonatomic) IBOutlet UIButton *unitptButton;
@property (weak, nonatomic) IBOutlet UIButton *unitqtButton;
@property (weak, nonatomic) IBOutlet UIButton *unitgalButton;
@property (weak, nonatomic) IBOutlet UIButton *unitozButton;
@property (weak, nonatomic) IBOutlet UIButton *unitlbButton;

@end

@implementation ImperialUnitPickerViewController

- (instancetype) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(60, 260);
    }
    
    return self;
}

-(void)highlightUnitButton:(UnitTypes)unitButton
{
    switch (unitButton)
    {
        case UnitTypesUnitItem:
            //highlight unitItemButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitItemButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitflOZButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitptButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitqtButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitgalButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitozButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitlbButton];
            break;
            
        case UnitTypesUnitFloz:
            //highlight unitMLButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitflOZButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitptButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitqtButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitgalButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitozButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitlbButton];
            
            break;
            
        case UnitTypesUnitPt:
            //highlight unitLButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitptButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitflOZButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitqtButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitgalButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitozButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitlbButton];
            
            break;
            
        case UnitTypesUnitQt:
            //highlight unitGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitqtButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitflOZButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitptButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitgalButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitozButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitlbButton];
            
            break;
            
        case UnitTypesUnitGal:
            //highlight unitGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitgalButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitflOZButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitptButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitqtButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitozButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitlbButton];
            
            break;
            
        case UnitTypesUnitOz:
            //highlight unitKGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitozButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitflOZButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitptButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitqtButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitgalButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitlbButton];
            
            break;
            
        case UnitTypesUnitLb:
            //highlight unitKGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitlbButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitflOZButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitptButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitqtButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitgalButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitozButton];
            
            break;
            
        default:
            //un-highlight all buttons
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitflOZButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitptButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitqtButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitgalButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitlbButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitozButton];
            
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
    [self.lookAndFeel applyGreenBorderTo:self.unitflOZButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitptButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitqtButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitlbButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitozButton];
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

- (IBAction)flozButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitFloz];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitFloz];
    }
}

- (IBAction)ptButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitPt];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitPt];
    }
}

- (IBAction)qtButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitQt];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitQt];
    }
}

- (IBAction)galButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitGal];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitGal];
    }
}

- (IBAction)ozButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitOz];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitOz];
    }
}

- (IBAction)lbButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitTypesUnitLb];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitTypesUnitLb];
    }
}

@end
