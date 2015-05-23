//
//  AddReceiptItemViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-16.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AddReceiptItemViewController.h"
#import "ReceiptScrollBarView.h"

@interface AddReceiptItemViewController ()

@property (weak, nonatomic) IBOutlet ReceiptScrollBarView *receiptView;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UITextField *pricePerItemTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalAmountTextField;
@property (weak, nonatomic) IBOutlet UIButton *addMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;

@end

@implementation AddReceiptItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

@end
