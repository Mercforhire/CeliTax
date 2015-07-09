//
//  TransferConfirmationViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-28.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TransferConfirmationViewController.h"

@interface TransferConfirmationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *yesButton;

@end

@implementation TransferConfirmationViewController

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(180, 49);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.yesButton.layer.cornerRadius = 3.0f;
    [self.yesButton setClipsToBounds: YES];
}

- (IBAction)yesPressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate confirmTransferPressed];
    }
}

@end
