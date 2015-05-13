//
//  NamesPickerViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-12.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "NamesPickerViewController.h"

#define POP_DEFAULT_FONT_SIZE     24
#define POP_DEFAULT_ROW_HEIGHT    44
#define POP_DEFAULT_MAX_HEIGHT    500
#define POP_DEFAULT_MIN_WIDTH    400

@interface NamesPickerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *namesTableView;

@end

@implementation NamesPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.namesTableView.dataSource = self;
    self.namesTableView.delegate = self;
}

-(void)setNames:(NSMutableArray *)names
{
    _names = names;
    
    //Calculate how tall the view should be by multiplying
    //the individual row height by the total number of rows.
    NSInteger rowsCount = [self.names count];
    NSInteger totalRowsHeight = rowsCount * POP_DEFAULT_ROW_HEIGHT + 100;
    if (totalRowsHeight > POP_DEFAULT_MAX_HEIGHT)
    {
        totalRowsHeight = POP_DEFAULT_MAX_HEIGHT;
    }
    
    //Calculate how wide the view should be by finding how
    //wide each string is expected to be
    CGFloat largestLabelWidth = 0;
    for (NSString *valueName in self.names)
    {
        //Checks size of text using the default font for UITableViewCell's textLabel.
        CGSize labelSize = [valueName sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:POP_DEFAULT_FONT_SIZE]}];
        if (labelSize.width > largestLabelWidth)
        {
            largestLabelWidth = labelSize.width;
        }
    }
    
    //Add a little padding to the width
    CGFloat popoverWidth = largestLabelWidth + 50;
    if (popoverWidth < POP_DEFAULT_MIN_WIDTH)
    {
        popoverWidth = POP_DEFAULT_MIN_WIDTH;
    }
    
    //Set the property to tell the popover container how big this view will be.
    self.preferredContentSize = CGSizeMake(popoverWidth, totalRowsHeight);
    
    [self.namesTableView reloadData];
}

#pragma mark - UITableview DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.names.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"NameTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell.textLabel setText:self.names[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return POP_DEFAULT_ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Name %@ clicked", self.names[indexPath.row]);
    
    //Notify the delegate if it exists.
    if (self.delegate != nil)
    {
        [self.delegate selectedName:self.names[indexPath.row]];
    }
}


@end
