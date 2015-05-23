//
//  DeleteCatagoryViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "DeleteCatagoryViewController.h"
#import "User.h"
#import "UserManager.h"

#define kSecondsBeforeEnableConfirmButton       5

@interface DeleteCatagoryViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (strong, nonatomic) NSTimer *startTimer;
@property NSInteger currentSecond;

@end

@implementation DeleteCatagoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(300, 215);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //enable Confirm Button after 5 seconds
    self.currentSecond = 0;
    
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(nextSecond)
                                   userInfo:nil
                                    repeats:YES];
    
    [self nextSecond];
}

-(void)nextSecond
{
    if (self.currentSecond < kSecondsBeforeEnableConfirmButton)
    {
        [self.confirmButton setTitle:[NSString stringWithFormat:@"%d", (int)(kSecondsBeforeEnableConfirmButton - self.currentSecond)] forState:UIControlStateNormal];
        self.currentSecond++;
    }
    else
    {
        [self.startTimer invalidate];
        self.startTimer = nil;
        
        [self.confirmButton setEnabled:YES];
        [self.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    }
}

- (IBAction)confirmPressed:(UIButton *)sender
{
    [self.manipulationService deleteCatagoryForCatagoryID:self.catagoryToDelete.identifer success:^{
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success"
                                                          message:@"Catagory Deleted"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Ok",nil];
        
        [message show];
        
    } failure:^(NSString *reason) {
        DLog(@"self.manipulationService deleteCatagoryForUserKey FAILED!");
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if( [title isEqualToString: @"Ok"] )
    {
        if (self.delegate)
        {
            [self.delegate requestPopUpToDismiss];
        }
    }
}

@end
