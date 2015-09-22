//
//  AllColorsPickerViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AllColorsPickerViewController.h"
#import "NKOColorPickerView.h"
#import "SolidGreenButton.h"

@interface AllColorsPickerViewController ()

@property (weak, nonatomic) IBOutlet NKOColorPickerView *colorPicker;
@property (weak, nonatomic) IBOutlet SolidGreenButton *doneButton;

@end

@implementation AllColorsPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(250, 130);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    
    [self.doneButton setLookAndFeel:self.lookAndFeel];
    [self.doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    
    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color) {
        //Your code handling a color change in the picker view.
        if (self.delegate)
        {
            [self.delegate pickedColor:color];
        }
    };
    
    [self.colorPicker setColor:[UIColor whiteColor]];
    
    [self.colorPicker setDidChangeColorBlock:colorDidChangeBlock];
}
- (IBAction)donePressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate doneButtonPressed];
    }
}

@end
