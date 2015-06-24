//
// ReceiptEditModeTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-06-21.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptEditModeTableViewCell.h"

@implementation ReceiptEditModeTableViewCell

- (void) awakeFromNib
{
    // Initialization code
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

- (void) willTransitionToState: (UITableViewCellStateMask) state
{
    [super willTransitionToState: state];

    if (state == UITableViewCellStateDefaultMask)
    {
        DLog(@"Default");
        // When the cell returns to normal (not editing)
        // Do something...
        self.leftBar.constant = -15;
        self.rightBar.constant = -15;
    }
    else if ((state & UITableViewCellStateShowingEditControlMask) && (state & UITableViewCellStateShowingDeleteConfirmationMask))
    {
        DLog(@"Edit Control + Delete Button");
        // When the cell goes from Showing-the-Edit-Control (-) to Showing-the-Edit-Control (-) AND the Delete Button [Delete]
        // !!! It's important to have this BEFORE just showing the Edit Control because the edit control applies to both cases.!!!
        // Do something...
    }
    else if (state & UITableViewCellStateShowingEditControlMask)
    {
        DLog(@"Edit Control Only");
        // When the cell goes into edit mode and Shows-the-Edit-Control (-)
        // Do something...
        self.leftBar.constant = -46;
        self.rightBar.constant = -49;
    }
    else if (state == UITableViewCellStateShowingDeleteConfirmationMask)
    {
        DLog(@"Swipe to Delete [Delete] button only");
        // When the user swipes a row to delete without using the edit button.
        // Do something...
    }
}

@end