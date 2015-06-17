//
// ReceiptCheckingViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-06.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptCheckingViewController.h"
#import "HorizonalScrollBarView.h"
#import "AddCatagoryViewController.h"
#import "Catagory.h"
#import "User.h"
#import "UserManager.h"
#import "Record.h"
#import "ImageCounterIconView.h"
#import "AddCatagoryViewController.h"
#import "ViewControllerFactory.h"
#import "Utils.h"
#import "Receipt.h"
#import "UIView+Helper.h"
#import "ReceiptBreakDownViewController.h"
#import "ReceiptScrollView.h"

@interface ReceiptCheckingViewController () <ImageCounterIconViewProtocol, HorizonalScrollBarViewProtocol, UITextFieldDelegate, ReceiptScrollViewProtocol,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet HorizonalScrollBarView *catagoriesBar;
@property (weak, nonatomic) IBOutlet ImageCounterIconView *recordsCounter;
@property (weak, nonatomic) IBOutlet UIButton *previousItemButton;
@property (weak, nonatomic) IBOutlet UIButton *nextItemButton;
@property (weak, nonatomic) IBOutlet UIButton *addItemButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteItemButton;
@property (weak, nonatomic) IBOutlet UITextField *qtyField;
@property (weak, nonatomic) IBOutlet UITextField *pricePerItemField;
@property (weak, nonatomic) IBOutlet UITextField *totalField;
@property (weak, nonatomic) IBOutlet UILabel *currentItemStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *itemControlsContainer;
@property (weak, nonatomic) IBOutlet ReceiptScrollView *receiptScrollView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *completeButton;
@property (nonatomic, strong) UIBarButtonItem *leftMenuItem;
@property (nonatomic, strong) UIBarButtonItem *rightMenuItem;

@property (strong, nonatomic) NSMutableArray *receiptImages;
@property (strong, nonatomic) NSArray *catagories;
@property (nonatomic, strong) Receipt *receipt;
@property (strong, nonatomic) NSMutableDictionary *records; // all Records for this receipt
@property (nonatomic, strong) Catagory *currentlySelectedCatagory;
@property (strong, nonatomic) NSMutableArray *recordsOfCurrentlySelectedCatagory; // Records belonging to currentlySelectedCatagory
@property (nonatomic, strong) Record *currentlySelectedRecord;
@property (nonatomic) NSInteger currentlySelectedRecordIndex;  // index of the currentlySelectedRecord's position in recordsOfCurrentlySelectedCatagory

@end

@implementation ReceiptCheckingViewController

- (void) setupUI
{
    self.catagoriesBar.lookAndFeel = self.lookAndFeel;

    UIToolbar *numberToolbar = [[UIToolbar alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           [[UIBarButtonItem alloc]initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.qtyField.inputAccessoryView = numberToolbar;
    self.pricePerItemField.inputAccessoryView = numberToolbar;

    UIImage *receiptImage = [UIImage imageNamed: @"receipt_icon.png"];
    [self.recordsCounter setImage: receiptImage];

    self.receiptScrollView.lookAndFeel = self.lookAndFeel;
    self.receiptScrollView.delegate = self;
    [self.receiptScrollView setBackgroundColor: [UIColor whiteColor]];
    
    [self.lookAndFeel applyGrayBorderTo:self.qtyField];
    [self.lookAndFeel applyGrayBorderTo:self.pricePerItemField];
    [self.lookAndFeel applyGrayBorderTo:self.totalField];
    [self.lookAndFeel applySolidGreenButtonStyleTo:self.addItemButton];
    [self.lookAndFeel applySolidGreenButtonStyleTo:self.deleteItemButton];


    // if we are straight from the camera, we show the X, and Complete button while hiding the Back button
    if (!self.cameFromReceiptBreakDownViewController)
    {
        // initialize the left side Cancel menu button button
        self.cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 25, 25)];
        [self.cancelButton setTitle: @"X" forState: UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont: [UIFont latoBoldFontOfSize: 14]];
        [self.cancelButton addTarget: self action: @selector(cancelPressed) forControlEvents: UIControlEventTouchUpInside];

        self.leftMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.cancelButton];
        self.navigationItem.leftBarButtonItem = self.leftMenuItem;

        // initialize the right side Complete menu button button
        self.completeButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 80, 25)];
        [self.completeButton setTitle: @"Complete" forState: UIControlStateNormal];
        [self.completeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [self.completeButton setTitleEdgeInsets: UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.completeButton.titleLabel setFont: [UIFont latoFontOfSize: 12]];
        [self.lookAndFeel applySolidGreenButtonStyleTo: self.completeButton];
        [self.completeButton addTarget: self action: @selector(completePressed) forControlEvents: UIControlEventTouchUpInside];

        self.rightMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.completeButton];
        self.navigationItem.rightBarButtonItem = self.rightMenuItem;
    }

    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void) cancelPressed
{
    // if the user has added at least one item, show a confirmation dialog,
    // upon confirmation, delete this Receipt and all of its Records
    // otherwise, just delete the current receipt and pop the view
    
    if ([self calculateNumberOfRecords] > 0)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Delete this receipt"
                                                          message: @"Are you sure you want delete this receipt along with all its items?"
                                                         delegate: self
                                                cancelButtonTitle: @"No"
                                                otherButtonTitles: @"Yes", nil];
        
        [message show];
    }
    else
    {
        [self deleteCurrentReceiptAndQuit];
    }
}

- (void) completePressed
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    [self.qtyField setDelegate: self];
    [self.qtyField addTarget: self
                      action: @selector(textFieldDidChange:)
            forControlEvents: UIControlEventEditingChanged];

    [self.pricePerItemField setDelegate: self];
    [self.pricePerItemField addTarget: self
                               action: @selector(textFieldDidChange:)
                     forControlEvents: UIControlEventEditingChanged];

    self.catagoriesBar.delegate = self;

    self.records = [NSMutableDictionary new];

    self.receiptImages = [NSMutableArray new];

    [self.recordsCounter setDelegate: self];

    [self hideAddRecordControls];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];

    // load the receipt images for this receipt
    [self.dataService fetchReceiptForReceiptID: self.receiptID success: ^(Receipt *receipt) {
        self.receipt = receipt;

        // load images from this receipt
        for (NSString *filename in self.receipt.fileNames)
        {
            UIImage *image = [Utils readImageWithFileName: filename forUser: self.userManager.user.userKey];

            if (image)
            {
                [self.receiptImages addObject: image];
            }
        }

        [self.receiptScrollView setImages: self.receiptImages];
    } failure: ^(NSString *reason) {
        // should not happen
    }];

    // load all the catagories
    [self.dataService fetchCatagoriesSuccess: ^(NSArray *catagories) {
        self.catagories = catagories;

        [self refreshButtonBar];
    } failure: ^(NSString *reason) {
        // if no catagories
    }];

    // load catagory records for this receipt
    [self.dataService fetchRecordsForReceiptID: self.receiptID
                                       success: ^(NSArray *records) {
        [self populateRecordsDictionaryUsing: records];

        [self refreshRecordsCounter];
    } failure: ^(NSString *reason) {
        // failure
    }];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

-(NSInteger) calculateNumberOfRecords
{
    NSInteger counter = 0;
    
    for (NSMutableArray *recordsOfThisCatagory in self.records.allValues)
    {
        counter = counter + recordsOfThisCatagory.count;
    }
    
    return counter;
}

- (void) refreshRecordsCounter
{
    [self.recordsCounter setCounter: [self calculateNumberOfRecords]];
}

- (void) populateRecordsDictionaryUsing: (NSArray *) records
{
    for (Record *record in records)
    {
        NSMutableArray *recordsOfThisCatagory = [self.records objectForKey: record.catagoryID];

        if (!recordsOfThisCatagory)
        {
            recordsOfThisCatagory = [NSMutableArray new];
        }

        [recordsOfThisCatagory addObject: record];

        [self.records setObject: recordsOfThisCatagory forKey: record.catagoryID];
    }
}

- (void) refreshButtonBar
{
    NSMutableArray *catagoryNames = [NSMutableArray new];
    NSMutableArray *catagoryColors = [NSMutableArray new];

    for (Catagory *catagory in self.catagories)
    {
        [catagoryNames addObject: catagory.name];
        [catagoryColors addObject: catagory.color];
    }

    [self.catagoriesBar setButtonNames: catagoryNames andColors: catagoryColors];
}

- (void) disablePreviousItemButton
{
    [self.previousItemButton setEnabled: NO];
    [self.previousItemButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
}

- (void) enablePreviousItemButton
{
    [self.previousItemButton setEnabled: YES];
    [self.previousItemButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
}

- (void) disableNextItemButton
{
    [self.nextItemButton setEnabled: NO];
    [self.nextItemButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
}

- (void) enableNextItemButton
{
    [self.nextItemButton setEnabled: YES];
    [self.nextItemButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
}

- (IBAction) addCatagoryPressed: (UIButton *) sender
{
    // open up the AddCatagoryViewController
    [self.navigationController pushViewController: [self.viewControllerFactory createAddCatagoryViewController] animated: YES];
}

- (IBAction) previousRecordPressed: (UIButton *) sender
{
    if (self.currentlySelectedRecordIndex != -1)
    {
        if (self.currentlySelectedRecordIndex > 0)
        {
            self.currentlySelectedRecordIndex--;
        }

        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory objectAtIndex: self.currentlySelectedRecordIndex];
    }
    else
    {
        // should not happen
        NSAssert(NO, @"self.currentlySelectedRecordIndex must not be -1");
    }
}

-(void)deleteCurrentReceiptAndQuit
{
    //delete the receipt
    [self.manipulationService deleteReceiptAndAllItsRecords:self.receiptID success:^{
        [self.navigationController popViewControllerAnimated: YES];
    } failure:^(NSString *reason) {
        DLog(@"%@",reason);
    }];
}

- (IBAction) nextRecordPressed: (UIButton *) sender
{
    if (self.currentlySelectedRecordIndex != -1)
    {
        if (self.currentlySelectedRecordIndex + 1 < self.recordsOfCurrentlySelectedCatagory.count)
        {
            self.currentlySelectedRecordIndex++;
        }

        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory objectAtIndex: self.currentlySelectedRecordIndex];
    }
}

- (IBAction) addRecordPressed: (UIButton *) sender
{
    [self.manipulationService addRecordForCatagoryID: self.currentlySelectedCatagory.identifer forReceiptID: self.receipt.identifer forQuantity: 0 forAmount: 0 success: ^(NSString *newestRecordID) {
        [self.dataService fetchRecordForID: newestRecordID success: ^(Record *record) {
            // add that to self.records
            NSMutableArray *recordsOfThisCatagory = [self.records objectForKey: record.catagoryID];

            if (!recordsOfThisCatagory)
            {
                recordsOfThisCatagory = [NSMutableArray new];
            }

            [recordsOfThisCatagory addObject: record];

            [self.records setObject: recordsOfThisCatagory forKey: record.catagoryID];

            // calls the setter to refresh UI
            self.recordsOfCurrentlySelectedCatagory = recordsOfThisCatagory;

            // load the newest record (which also refreshes the UI)
            self.currentlySelectedRecord = record;

            [self refreshRecordsCounter];
        } failure: ^(NSString *reason) {
            DLog(@"self.dataService fetchRecordForID failed");
        }];
    } failure: ^(NSString *reason) {
        DLog(@"self.manipulationService addRecordForCatagoryID failed");
    }];
}

- (IBAction) deleteRecordPressed: (UIButton *) sender
{
    [self.manipulationService deleteRecord: self.currentlySelectedRecord.identifer WithSuccess: ^{
        // delete the record from self.records
        NSMutableArray *recordsOfThisCatagory = [self.records objectForKey: self.currentlySelectedRecord.catagoryID];

        [recordsOfThisCatagory removeObject: self.currentlySelectedRecord];

        [self.records setObject: recordsOfThisCatagory forKey: self.currentlySelectedRecord.catagoryID];

        // calls the setter to refresh UI
        self.recordsOfCurrentlySelectedCatagory = recordsOfThisCatagory;

        // finally change self.currentlySelectedRecord to the last available record and refresh UI
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory lastObject];

        [self refreshRecordsCounter];
    } andFailure: ^(NSString *reason) {
        DLog(@"self.manipulationService deleteRecord failed");
    }];
}

- (void) loadFirstRecordFromCurrentlySelectedCatagory
{
    self.recordsOfCurrentlySelectedCatagory = [self.records objectForKey: self.currentlySelectedCatagory.identifer];

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

- (void) showAddRecordControls
{
    [self.itemControlsContainer setHidden: NO];
}

- (void) hideAddRecordControls
{
    [self.itemControlsContainer setHidden: YES];
}

- (void) calculateTotalField
{
    self.totalField.text = [NSString stringWithFormat: @"%.f", _currentlySelectedRecord.quantity * _currentlySelectedRecord.amount];
}

- (void) saveCurrentlySelectedRecord
{
    [self.manipulationService modifyRecord: self.currentlySelectedRecord WithSuccess: ^{
        DLog(@"Record %ld saved", (long)self.currentlySelectedRecord.identifer);
    } andFailure: ^(NSString *reason) {
        DLog(@"modifyRecord failed");
    }];
}

// use these functions to dynamically manage the UI when data is changed
- (void) setCurrentlySelectedRecord: (Record *) currentlySelectedRecord
{
    _currentlySelectedRecord = currentlySelectedRecord;

    if (_currentlySelectedRecord)
    {
        // load the record's data to the UI textfields
        self.qtyField.text = [NSString stringWithFormat: @"%ld", (long)_currentlySelectedRecord.quantity];
        self.pricePerItemField.text = [NSString stringWithFormat: @"%.f", _currentlySelectedRecord.amount];

        [self calculateTotalField];

        [self.deleteItemButton setEnabled: YES];

        self.currentlySelectedRecordIndex = [self.recordsOfCurrentlySelectedCatagory indexOfObject: _currentlySelectedRecord];
    }
    else
    {
        // clear the textfields
        self.qtyField.text = @"";
        self.pricePerItemField.text = @"";
        self.totalField.text = @"";
        [self.currentItemStatusLabel setText: [NSString stringWithFormat: @"%d/%ld", 0, (unsigned long)self.recordsOfCurrentlySelectedCatagory.count]];

        [self.deleteItemButton setEnabled: NO];

        self.currentlySelectedRecordIndex = -1;
    }
}

- (void) setCurrentlySelectedRecordIndex: (NSInteger) currentlySelectedRecordIndex
{
    _currentlySelectedRecordIndex = currentlySelectedRecordIndex;

    if (_currentlySelectedRecordIndex != -1)
    {
        [self.currentItemStatusLabel setText: [NSString stringWithFormat: @"%ld/%ld", (long)(currentlySelectedRecordIndex + 1), (unsigned long)self.recordsOfCurrentlySelectedCatagory.count]];

        if (currentlySelectedRecordIndex == 0)
        {
            [self disablePreviousItemButton];
        }
        else
        {
            [self enablePreviousItemButton];
        }

        if (currentlySelectedRecordIndex == self.recordsOfCurrentlySelectedCatagory.count - 1)
        {
            [self disableNextItemButton];
        }
        else
        {
            [self enableNextItemButton];
        }
    }
    else
    {
        [self disableNextItemButton];
        [self disablePreviousItemButton];
    }
}

- (void) setCurrentlySelectedCatagory: (Catagory *) currentlySelectedCatagory
{
    if (!_currentlySelectedCatagory && !currentlySelectedCatagory)
    {
        // do nothing
        return;
    }

    if (_currentlySelectedCatagory && !currentlySelectedCatagory)
    {
        // deselect currentlySelectedRecord and self.recordsOfCurrentlySelectedCatagory
        self.currentlySelectedRecord = nil;
        self.recordsOfCurrentlySelectedCatagory = nil;

        [self.addItemButton setEnabled: NO];

        [self hideAddRecordControls];

        _currentlySelectedCatagory = currentlySelectedCatagory;
    }
    else if (!_currentlySelectedCatagory && currentlySelectedCatagory)
    {
        [self showAddRecordControls];

        [self.addItemButton setEnabled: YES];

        _currentlySelectedCatagory = currentlySelectedCatagory;

        [self loadFirstRecordFromCurrentlySelectedCatagory];
    }
    // user is changing to viewing another catagory's records
    else if (_currentlySelectedCatagory && currentlySelectedCatagory)
    {
        _currentlySelectedCatagory = currentlySelectedCatagory;

        [self loadFirstRecordFromCurrentlySelectedCatagory];
    }
}

- (void) setRecordsOfCurrentlySelectedCatagory: (NSMutableArray *) recordsOfCurrentlySelectedCatagory
{
    _recordsOfCurrentlySelectedCatagory = recordsOfCurrentlySelectedCatagory;
}

- (void) doneWithNumberPad
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

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self.view scrollToY: 0 - kbSize.height];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ( [title isEqualToString: @"Yes"] )
    {
        [self deleteCurrentReceiptAndQuit];
    }
}

#pragma mark - ReceiptScrollViewProtocol

- (void) selectedChanged
{
    // should I care?
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
    [self.view scrollToView: self.previousItemButton];
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    // nothing yet
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    // if user types nothing for a textField, we default it to 0
    if (textField == self.qtyField && textField.text.length == 0)
    {
        self.qtyField.text = [NSString stringWithFormat: @"%d", 0];
    }
    else if (textField == self.pricePerItemField && textField.text.length == 0)
    {
        self.pricePerItemField.text = [NSString stringWithFormat: @"%.f", 0.0f];
    }

    self.currentlySelectedRecord.quantity = [self.qtyField.text integerValue];

    self.currentlySelectedRecord.amount = [self.pricePerItemField.text integerValue];

    [self calculateTotalField];

    [self saveCurrentlySelectedRecord];

    [self.view scrollToY: 0];

    [textField resignFirstResponder];
}

#pragma mark - ImageCounterIconViewProtocol

- (void) imageCounterIconClicked
{
    DLog(@"Image counter icon clicked");

    if (self.cameFromReceiptBreakDownViewController)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
    else
    {
        // push ReceiptCheckingViewController
        [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: self.receiptID cameFromReceiptCheckingViewController: YES] animated: YES];
    }
}

#pragma mark - HorizonalScrollBarViewProtocol

- (void) buttonClickedWithIndex: (NSInteger) index andName: (NSString *) name
{
    DLog(@"Bottom Bar button %ld:%@ pressed", (long)index, name);

    self.currentlySelectedCatagory = [self.catagories objectAtIndex: index];

    [self loadFirstRecordFromCurrentlySelectedCatagory];

    [self showAddRecordControls];
}

- (void) buttonUnselected
{
    DLog(@"Bottom Bar buttons unselected");

    self.currentlySelectedCatagory = nil;

    [self hideAddRecordControls];
}

@end