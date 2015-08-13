//
//  UnitPickerViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-05.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UnitPickerViewController.h"

@interface UnitPickerViewController ()

@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UIButton *unitItemButton;

@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIButton *unitMLButton;
@property (weak, nonatomic) IBOutlet UIButton *unitLButton;
@property (weak, nonatomic) IBOutlet UIButton *unitGButton;
@property (weak, nonatomic) IBOutlet UIButton *unitKGButton;

@end

@implementation UnitPickerViewController

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(60, 204);
    }
    
    return self;
}

-(void)highlightUnitButton:(NSInteger)unitButton
{
    switch (unitButton)
    {
        case UnitItem:
            //highlight unitItemButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitItemButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            break;
            
        case UnitML:
            //highlight unitMLButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitMLButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
            
        case UnitL:
            //highlight unitLButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitLButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
            
        case UnitG:
            //highlight unitGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitGButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
            
        case UnitKG:
            //highlight unitKGButton and un-highlight the rest
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.unitKGButton];
            
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            
            break;
            
        default:
            //un-highlight all buttons
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitItemButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitMLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitGButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitLButton];
            [self.lookAndFeel applyNormalButtonStyleTo:self.unitKGButton];
            
            break;
    }
}

-(void)setupUI
{
    [self.topContainer setBackgroundColor:[UIColor whiteColor]];
    [self.bottomContainer setBackgroundColor:[UIColor whiteColor]];
    
    [self highlightUnitButton:self.defaultSelectedUnit];
    
    [self.lookAndFeel applyGreenBorderTo:self.unitItemButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitMLButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitLButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitGButton];
    [self.lookAndFeel applyGreenBorderTo:self.unitKGButton];
}

-(void)setDefaultSelectedUnit:(NSInteger)defaultSelectedUnit
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
    [self highlightUnitButton:UnitItem];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitItem];
    }
}

- (IBAction)mlButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitML];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitML];
    }
}

- (IBAction)lButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitL];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitL];
    }
}

- (IBAction)gButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitG];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitG];
    }
}

- (IBAction)kgButtonPressed:(UIButton *)sender
{
    [self highlightUnitButton:UnitKG];
    
    if (self.delegate)
    {
        [self.delegate selectedUnit:UnitKG];
    }
}

@end
