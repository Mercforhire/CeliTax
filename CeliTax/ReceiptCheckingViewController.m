//
//  ReceiptCheckingViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptCheckingViewController.h"
#import "HorizonalScrollBarView.h"
#import "ReceiptScrollBarView.h"
#import "AddCatagoryViewController.h"
#import "Catagory.h"
#import "User.h"
#import "UserManager.h"
#import "Record.h"
#import "ImageCounterIconView.h"
#import "AddCatagoryViewController.h"
#import "ViewControllerFactory.h"
#import "AlertDialogsProvider.h"
#import "Utils.h"
#import "Receipt.h"
#import "UIView+Helper.h"

@interface ReceiptCheckingViewController () <ImageCounterIconViewProtocol, HorizonalScrollBarViewProtocol, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet ReceiptScrollBarView *receiptScrollView;
@property (weak, nonatomic) IBOutlet UIView *bottombarContainer;
@property (strong, nonatomic) HorizonalScrollBarView *bottomBar;
@property (weak, nonatomic) IBOutlet ImageCounterIconView *recordsCounter;
@property (weak, nonatomic) IBOutlet UIButton *previousItemButton;
@property (weak, nonatomic) IBOutlet UIButton *nextItemButton;
@property (weak, nonatomic) IBOutlet UIButton *addItemButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteItemButton;
@property (weak, nonatomic) IBOutlet UITextField *qtyField;
@property (weak, nonatomic) IBOutlet UITextField *pricePerItemField;
@property (weak, nonatomic) IBOutlet UITextField *totalField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *animatedBar; //space from optional toolbar to bottom bar
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *animatorBar2; //space from receiptScrollView to bottom bar

@property (strong, nonatomic) NSMutableArray *receiptImages;
@property (strong, nonatomic) NSArray *catagories;
@property (strong, nonatomic) NSMutableArray *catagoryNames;


@property (nonatomic, strong) Receipt *receipt;

@property (strong, nonatomic) NSMutableDictionary *records; //all Records for this receipt

@property (nonatomic, strong) Catagory *currentlySelectedCatagory;

@property (strong, nonatomic) NSMutableArray *recordsOfCurrentlySelectedCatagory; //Records from self.records belonging to currentlySelectedCatagory
@property (nonatomic, strong) Record *currentlySelectedRecord;
@property NSInteger currentlySelectedRecordIndex;  //index of the currentlySelectedRecord's position in recordsOfCurrentlySelectedCatagory

@end

@implementation ReceiptCheckingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.qtyField setDelegate:self];
    [self.qtyField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    [self.pricePerItemField setDelegate:self];
    [self.pricePerItemField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.qtyField.inputAccessoryView = numberToolbar;
    self.pricePerItemField.inputAccessoryView = numberToolbar;
    
    self.animatedBar.constant = -100;
    self.animatorBar2.constant = 20;
    
    self.bottomBar = [[HorizonalScrollBarView alloc] initWithFrame:self.bottombarContainer.frame];
    self.bottomBar.delegate = self;
    [self.view addSubview:self.bottomBar];
    
    self.records = [NSMutableDictionary new];
    
    //load the receiptImages array with some demo images
    self.receiptImages = [NSMutableArray new];
    
    UIImage *receiptImage = [UIImage imageNamed:@"receipt.png"];
    [self.recordsCounter setImage:receiptImage];
    [self.recordsCounter setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //load the receipt images for this receipt
    [self.dataService fetchReceiptForReceiptID:self.receiptID success:^(Receipt *receipt) {
        
        self.receipt = receipt;
        
        //load images from this receipt
        for (NSString *filename in self.receipt.fileNames)
        {
            UIImage *image = [Utils readImageWithFileName:filename forUser:self.userManager.user.userKey];
            if ( image )
            {
                [self.receiptImages addObject:image];
            }
            
            [self.receiptScrollView setImages:self.receiptImages];
        }
        
    } failure:^(NSString *reason) {
        //should not happen
    }];
    
    //load all the catagories
    [self.dataService fetchCatagoriesSuccess:^(NSArray *catagories) {
            
            self.catagories = catagories;
            
        } failure:^(NSString *reason) {
            //if no catagories
        }];
    
    self.catagoryNames = [NSMutableArray new];
    
    for (Catagory *itemCatagory in self.catagories)
    {
        [self.catagoryNames addObject:itemCatagory.name];
    }
    
    //load catagory records for this receipt
    [self.dataService fetchRecordsForReceiptID:self.receiptID
                                       success:^(NSArray *records) {
                                           
                                           [self populateRecordsDictionaryUsing:records];
                                           
                                           [self refreshRecordsCounter];
                                           
                                       } failure:^(NSString *reason) {
                                           //failure
                                       }];
    
    [self refreshButtonBar];
}

-(void)refreshRecordsCounter
{
    NSInteger counter = 0;
    
    for (NSMutableArray *recordsOfThisCatagory in self.records.allValues)
    {
        counter = counter + recordsOfThisCatagory.count;
    }
    
    [self.recordsCounter setCounter:counter];
}

-(void)populateRecordsDictionaryUsing:(NSArray *) records
{
    for (Record *record in records)
    {
        NSMutableArray *recordsOfThisCatagory = [self.records objectForKey:record.catagoryID];
        
        if (!recordsOfThisCatagory)
        {
            recordsOfThisCatagory = [NSMutableArray new];
        }
        
        [recordsOfThisCatagory addObject:record];
        
        [self.records setObject:recordsOfThisCatagory forKey:record.catagoryID];
    }
}

-(void)refreshButtonBar
{
    [self.bottomBar setButtonNames:self.catagoryNames];
}

- (IBAction)addCatagoryPressed:(UIButton *)sender
{
    //open up the AddCatagoryViewController
    [self.navigationController pushViewController:[self.viewControllerFactory createAddCatagoryViewController] animated:YES];
}

- (IBAction)previousRecordPressed:(UIButton *)sender
{
    if (self.currentlySelectedRecordIndex != -1)
    {
        if ( self.currentlySelectedRecordIndex - 1 >= 0 )
        {
            self.currentlySelectedRecordIndex--;
        }
        else
        {
            self.currentlySelectedRecordIndex = self.recordsOfCurrentlySelectedCatagory.count - 1;
        }
        
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory objectAtIndex:self.currentlySelectedRecordIndex];
    }
    else
    {
        //should not happen
        NSAssert(NO, @"self.currentlySelectedRecordIndex must not be -1");
    }
}

- (IBAction)nextRecordPressed:(UIButton *)sender
{
    if (self.currentlySelectedRecordIndex != -1)
    {
        if ( self.currentlySelectedRecordIndex + 1 < self.recordsOfCurrentlySelectedCatagory.count )
        {
            self.currentlySelectedRecordIndex++;
        }
        else
        {
            self.currentlySelectedRecordIndex = 0;
        }
        
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory objectAtIndex:self.currentlySelectedRecordIndex];
    }
    else
    {
        //should not happen
        NSAssert(NO, @"self.currentlySelectedRecordIndex must not be -1");
    }
}

- (IBAction)addRecordPressed:(UIButton *)sender
{
    [self.manipulationService addRecordForCatagoryID:self.currentlySelectedCatagory.identifer forReceiptID:self.receipt.identifer forQuantity:0 forAmount:0 success:^(NSString *newestRecordID) {
        
        [self.dataService fetchRecordForID:newestRecordID success:^(Record *record) {
            
            //add that to self.records
            NSMutableArray *recordsOfThisCatagory = [self.records objectForKey:record.catagoryID];
            
            if (!recordsOfThisCatagory)
            {
                recordsOfThisCatagory = [NSMutableArray new];
            }
            
            [recordsOfThisCatagory addObject:record];
            
            [self.records setObject:recordsOfThisCatagory forKey:record.catagoryID];
            
            //calls the setter to refresh UI
            self.recordsOfCurrentlySelectedCatagory = recordsOfThisCatagory;
            
            //load the newest record (which also refreshes the UI)
            self.currentlySelectedRecord = record;
            
            [self refreshRecordsCounter];
            
        } failure:^(NSString *reason) {
            DLog(@"self.dataService fetchRecordForID failed");
        }];
        
    } failure:^(NSString *reason) {
        DLog(@"self.manipulationService addRecordForCatagoryID failed");
    }];
}

- (IBAction)deleteRecordPressed:(UIButton *)sender
{
    
    [self.manipulationService deleteRecord:self.currentlySelectedRecord.identifer WithSuccess:^{
        
        //delete the record from self.records
        NSMutableArray *recordsOfThisCatagory = [self.records objectForKey:self.currentlySelectedRecord.catagoryID];
        
        [recordsOfThisCatagory removeObject:self.currentlySelectedRecord];
        
        [self.records setObject:recordsOfThisCatagory forKey:self.currentlySelectedRecord.catagoryID];
        
        //calls the setter to refresh UI
        self.recordsOfCurrentlySelectedCatagory = recordsOfThisCatagory;
        
        //finally change self.currentlySelectedRecord to the last available record and refresh UI
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory lastObject];
        
        [self refreshRecordsCounter];
        
    } andFailure:^(NSString *reason) {
        DLog(@"self.manipulationService deleteRecord failed");
    }];
}


-(void)loadFirstRecordFromCurrentlySelectedCatagory
{
    self.recordsOfCurrentlySelectedCatagory = [self.records objectForKey:self.currentlySelectedCatagory.identifer];
    
    if (self.recordsOfCurrentlySelectedCatagory.count)
    {
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory firstObject];
        
        self.currentlySelectedRecordIndex = 0;
    }
    else
    {
        self.currentlySelectedRecord = nil;
        
        self.currentlySelectedRecordIndex = -1;
    }
}

-(void)showAddRecordControls
{
    //animate the the animatedBar to 40 and animatorBar2 to 113
    if (self.animatedBar.constant != 40)
    {
        self.animatedBar.constant = 40;
        self.animatorBar2.constant = 113;
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.view layoutIfNeeded]; // Called on parent view
                             
                         }];
    }
}

-(void)hideAddRecordControls
{
    //animate the the animatedBar to -100 and animatorBar2 to 20
    if (self.animatedBar.constant != -10)
    {
        self.animatedBar.constant = -100;
        self.animatorBar2.constant = 20;
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.view layoutIfNeeded]; // Called on parent view
                         }];
    }
}

-(void)calculateTotalField
{
    self.totalField.text = [NSString stringWithFormat:@"%.f", _currentlySelectedRecord.quantity * _currentlySelectedRecord.amount];
    
}

-(void)saveCurrentlySelectedRecord
{
    
    [self.manipulationService modifyRecord:self.currentlySelectedRecord WithSuccess:^{
        
        DLog(@"Record %ld saved",(long)self.currentlySelectedRecord.identifer);
        
    } andFailure:^(NSString *reason) {
        DLog(@"modifyRecord failed");
    }];
    
}

//use these functions to dynamically manage the UI when data is changed
-(void)setCurrentlySelectedRecord:(Record *)currentlySelectedRecord
{
    _currentlySelectedRecord = currentlySelectedRecord;
    
    if (_currentlySelectedRecord)
    {
        //load the record's data to the UI textfields
        self.qtyField.text = [NSString stringWithFormat:@"%ld", (long)_currentlySelectedRecord.quantity];
        self.pricePerItemField.text = [NSString stringWithFormat:@"%.f",_currentlySelectedRecord.amount];
        
        [self.qtyField setEnabled:YES];
        [self.pricePerItemField setEnabled:YES];
        
        [self calculateTotalField];
        
        [self.deleteItemButton setEnabled:YES];
        
        self.currentlySelectedRecordIndex = [self.recordsOfCurrentlySelectedCatagory indexOfObject:_currentlySelectedRecord];
    }
    else
    {
        //clear the textfields
        self.qtyField.text = @"";
        self.pricePerItemField.text = @"";
        self.totalField.text = @"";
        
        [self.qtyField setEnabled:NO];
        [self.pricePerItemField setEnabled:NO];
        
        [self.deleteItemButton setEnabled:NO];
        
        self.currentlySelectedRecordIndex = -1;
    }
}

-(void)setCurrentlySelectedCatagory:(Catagory *)currentlySelectedCatagory
{
    if ( !_currentlySelectedCatagory && !currentlySelectedCatagory )
    {
        //do nothing
        return;
    }
    
    if ( _currentlySelectedCatagory && !currentlySelectedCatagory )
    {
        //deselect currentlySelectedRecord and self.recordsOfCurrentlySelectedCatagory
        self.currentlySelectedRecord = nil;
        self.recordsOfCurrentlySelectedCatagory = nil;
        
        [self.addItemButton setEnabled:NO];
        
        [self hideAddRecordControls];
        
        _currentlySelectedCatagory = currentlySelectedCatagory;
    }
    
    else if ( !_currentlySelectedCatagory && currentlySelectedCatagory )
    {
        [self showAddRecordControls];
        
        [self.addItemButton setEnabled:YES];
        
        _currentlySelectedCatagory = currentlySelectedCatagory;
        
        [self loadFirstRecordFromCurrentlySelectedCatagory];
    }
    
    //user is changing to viewing another catagory's records
    else if ( _currentlySelectedCatagory && currentlySelectedCatagory )
    {
        _currentlySelectedCatagory = currentlySelectedCatagory;
        
        [self loadFirstRecordFromCurrentlySelectedCatagory];
    }
}

-(void)setRecordsOfCurrentlySelectedCatagory:(NSMutableArray *)recordsOfCurrentlySelectedCatagory
{
    _recordsOfCurrentlySelectedCatagory = recordsOfCurrentlySelectedCatagory;
    
    //enable the Left and Right buttons only if there are more than 1 records to browse from
    if (_recordsOfCurrentlySelectedCatagory.count > 1)
    {
        [self.previousItemButton setEnabled:YES];
        [self.nextItemButton setEnabled:YES];
        
        [self.previousItemButton setBackgroundColor:self.previousItemButton.tintColor];
        [self.nextItemButton setBackgroundColor:self.nextItemButton.tintColor];
    }
    else
    {
        [self.previousItemButton setEnabled:NO];
        [self.nextItemButton setEnabled:NO];
        
        [self.previousItemButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.nextItemButton setBackgroundColor:[UIColor lightGrayColor]];
    }
}

-(void)doneWithNumberPad
{
    if ([self.qtyField isFirstResponder])
    {
        [self.qtyField resignFirstResponder];
    }
    
    if ([self.pricePerItemField isFirstResponder])
    {
        [self.pricePerItemField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view scrollToView:self.previousItemButton];
}

-(void)textFieldDidChange:(UITextField *)textfield
{
    //nothing yet
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //if user types nothing for a textField, we default it to 0
    if (textField == self.qtyField && textField.text.length == 0)
    {
        self.qtyField.text = [NSString stringWithFormat:@"%d", 0];
    }
    
    else if (textField == self.pricePerItemField && textField.text.length == 0)
    {
        self.pricePerItemField.text = [NSString stringWithFormat:@"%.f", 0.0f];
    }
    
    self.currentlySelectedRecord.quantity = [self.qtyField.text integerValue];
    
    self.currentlySelectedRecord.amount = [self.pricePerItemField.text integerValue];
    
    [self calculateTotalField];
    
    [self saveCurrentlySelectedRecord];
    
    [self.view scrollToY:0];
    
    [textField resignFirstResponder];
}

#pragma mark - ImageCounterIconViewProtocol

-(void)imageCounterIconClicked
{
    DLog(@"Image counter icon clicked");
    
    [AlertDialogsProvider showWorkInProgressDialog];
}

#pragma mark - HorizonalScrollBarViewProtocol

-(void)buttonClickedWithIndex:(NSInteger)index andName:(NSString *)name
{
    DLog(@"Bottom Bar button %ld:%@ pressed", (long)index, name);
    
    self.currentlySelectedCatagory = [self.catagories objectAtIndex:index];
    
    [self loadFirstRecordFromCurrentlySelectedCatagory];
    
    [self showAddRecordControls];
}

-(void)buttonUnselected
{
    DLog(@"Bottom Bar buttons unselected");
    
    self.currentlySelectedCatagory = nil;
    
    [self hideAddRecordControls];
}

@end
