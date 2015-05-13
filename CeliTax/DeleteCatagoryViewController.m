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

@interface DeleteCatagoryViewController ()

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) NSTimer *startTimer;
@property NSInteger currentSecond;

@end

@implementation DeleteCatagoryViewController

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
        [self.confirmButton setTitle:[NSString stringWithFormat:@"%ld", kSecondsBeforeEnableConfirmButton - self.currentSecond] forState:UIControlStateNormal];
        self.currentSecond++;
    }
    else
    {
        [self.startTimer invalidate];
        self.startTimer = nil;
        
        [self.confirmButton  setEnabled:YES];
        [self.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    }
}

- (IBAction)confirmPressed:(UIButton *)sender
{

}

- (IBAction)cancelPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
