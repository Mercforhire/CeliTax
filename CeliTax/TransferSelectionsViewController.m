//
//  TransferSelectionsViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TransferSelectionsViewController.h"
#import "SelectionsPickerTableViewCell.h"
#import "WYPopoverController.h"
#import "TransferConfirmationViewController.h"

#import "CeliTax-Swift.h"

#define POP_DEFAULT_FONT_SIZE       14
#define POP_DEFAULT_ROW_HEIGHT      40
#define POP_DEFAULT_MAX_HEIGHT      500
#define POP_DEFAULT_MIN_WIDTH       50
#define kSelectionsPickerTableViewCellIdentifier     @"SelectionsPickerTableViewCell"

@interface TransferSelectionsViewController () <UITableViewDelegate, UITableViewDataSource, TransferConfirmationViewProtocol>

@property (weak, nonatomic) IBOutlet UITableView *namesTableView;
@property (nonatomic, strong) WYPopoverController *transferConfirmatationPopover;
@property (nonatomic, strong) TransferConfirmationViewController *transferConfirmationViewController;

@property (nonatomic) NSInteger clickedIndex;

@end

@implementation TransferSelectionsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *selectionsPickerTableViewCell = [UINib nibWithNibName: @"SelectionsPickerTableViewCell" bundle: nil];
    
    [self.namesTableView registerNib: selectionsPickerTableViewCell forCellReuseIdentifier: kSelectionsPickerTableViewCellIdentifier];
    
    (self.namesTableView).separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.namesTableView.dataSource = self;
    self.namesTableView.delegate = self;
    
    self.transferConfirmationViewController = [[TransferConfirmationViewController alloc] initWithNibName:@"TransferConfirmationViewController" bundle:nil];
    self.transferConfirmatationPopover = [[WYPopoverController alloc] initWithContentViewController: self.transferConfirmationViewController];
    (self.transferConfirmatationPopover).popoverContentSize = self.transferConfirmationViewController.viewSize;
    (self.transferConfirmationViewController).delegate = self;
    
    (self.transferConfirmatationPopover).theme = [WYPopoverTheme theme];
    
    WYPopoverTheme *popUpTheme = self.transferConfirmatationPopover.theme;
    popUpTheme.fillTopColor = self.lookAndFeel.appGreenColor;
    popUpTheme.fillBottomColor = self.lookAndFeel.appGreenColor;
    
    (self.transferConfirmatationPopover).theme = popUpTheme;
}

- (void) setSelections: (NSArray *) selections
{
    _selections = selections;
    
    // Calculate how tall the view should be by multiplying
    // the individual row height by the total number of rows.
    NSInteger rowsCount = (self.selections).count;
    NSInteger totalRowsHeight = rowsCount * POP_DEFAULT_ROW_HEIGHT + 10;
    
    if (totalRowsHeight > POP_DEFAULT_MAX_HEIGHT)
    {
        totalRowsHeight = POP_DEFAULT_MAX_HEIGHT;
    }
    
    // Calculate how wide the view should be by finding how
    // wide each string is expected to be
    CGFloat largestLabelWidth = 0;
    
    for (NSString *valueName in self.selections)
    {
        // Checks size of text using the default font for UITableViewCell's textLabel.
        CGSize labelSize = [valueName sizeWithAttributes: @{ NSFontAttributeName: [UIFont latoFontOfSize: POP_DEFAULT_FONT_SIZE] }];
        
        if (labelSize.width > largestLabelWidth)
        {
            largestLabelWidth = labelSize.width;
        }
    }
    
    // Add a little padding to the width
    CGFloat popoverWidth = largestLabelWidth + 50;
    
    if (popoverWidth < POP_DEFAULT_MIN_WIDTH)
    {
        popoverWidth = POP_DEFAULT_MIN_WIDTH;
    }
    
    // Set the property to tell the popover container how big this view will be.
    self.preferredContentSize = CGSizeMake(popoverWidth, totalRowsHeight);
    
    [self.namesTableView reloadData];
}

-(void)setHighlightedSelectionIndex:(NSInteger)highlightedSelectionIndex
{
    _highlightedSelectionIndex = highlightedSelectionIndex;
    
    [self.namesTableView reloadData];
}

#pragma mark - UITableview TransferConfirmationViewProtocol

- (void) confirmTransferPressed
{
    [self.transferConfirmatationPopover dismissPopoverAnimated:YES];
    
    if (self.delegate)
    {
        [self.delegate selectedTransferSelectionAtIndex:self.clickedIndex];
    }
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.selections.count;
}

- (SelectionsPickerTableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellId = kSelectionsPickerTableViewCellIdentifier;
    SelectionsPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    
    if (cell == nil)
    {
        cell = [[SelectionsPickerTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
    }
    
    (cell.selectionLabel).text = self.selections [indexPath.row];
    
    if (self.highlightedSelectionIndex == indexPath.row)
    {
        [self.lookAndFeel applyGreenBorderTo: cell.selectionLabel];
        (cell.selectionLabel).textColor = [UIColor whiteColor];
        (cell.selectionLabel).backgroundColor = self.lookAndFeel.appGreenColor;
    }
    else
    {
        [self.lookAndFeel applyGrayBorderTo: cell.selectionLabel];
        (cell.selectionLabel).textColor = [UIColor blackColor];
        (cell.selectionLabel).backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return POP_DEFAULT_ROW_HEIGHT;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    // Notify the delegate if it exists.
    if (self.delegate != nil)
    {
        CGRect rectOfCellInTableView = [self.namesTableView rectForRowAtIndexPath: indexPath];
        CGRect rectOfCellInSuperview = [self.namesTableView convertRect: rectOfCellInTableView toView: (self.namesTableView).superview];
        
        CGRect tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + rectOfCellInSuperview.size.width / 2,
                                     rectOfCellInSuperview.origin.y + rectOfCellInSuperview.size.height / 2,
                                     1,
                                     1);
        
        [self.transferConfirmatationPopover presentPopoverFromRect: tinyRect inView: self.view permittedArrowDirections: WYPopoverArrowDirectionLeft animated: YES];
        
        self.clickedIndex = indexPath.row;
    }
}

@end
