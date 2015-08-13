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
        // When the cell returns to normal (not editing)
        // Do something...
        self.leftBar.constant = -15;
        self.rightBar.constant = -15;
        
        if (self.addPhotoButtonShouldBeVisible)
            [self.addPhotoButton setHidden:NO];
        else
            [self.addPhotoButton setHidden:YES];
    }
    else if ((state & UITableViewCellStateShowingEditControlMask) && (state & UITableViewCellStateShowingDeleteConfirmationMask))
    {
        // When the cell goes from Showing-the-Edit-Control (-) to Showing-the-Edit-Control (-) AND the Delete Button [Delete]
        // !!! It's important to have this BEFORE just showing the Edit Control because the edit control applies to both cases.!!!
        // Do something...
        [self.addPhotoButton setHidden:YES];
    }
    else if (state & UITableViewCellStateShowingEditControlMask)
    {
        // When the cell goes into edit mode and Shows-the-Edit-Control (-)
        // Do something...
        self.leftBar.constant = -46;
        self.rightBar.constant = -49;
        
        if (self.addPhotoButtonShouldBeVisible)
            [self.addPhotoButton setHidden:NO];
        else
            [self.addPhotoButton setHidden:YES];
    }
    else if (state == UITableViewCellStateShowingDeleteConfirmationMask)
    {
        // When the user swipes a row to delete without using the edit button.
        // Do something...
        [self.addPhotoButton setHidden:YES];
    }
}

-(UIView *) findReorderView:(UIView *) view
{
    UIView *reorderView = nil;
    for (UIView *subview in view.subviews)
    {
        if ([[[subview class] description] rangeOfString:@"Reorder"].location != NSNotFound)
        {
            reorderView = subview;
            break;
        }
        else
        {
            reorderView = [self findReorderView:subview];
            if (reorderView != nil)
            {
                break;
            }
        }
    }
    return reorderView;
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing)
    {
        // find the reorder view here
        // place the previous method either directly in your
        // subclassed UITableViewCell, or in a category
        // defined on UIView
        UIView *reorderView = [self findReorderView:self];
        if (reorderView)
        {
            // here, I am changing the background color to match my custom cell
            // you may not want or need to do this
            reorderView.backgroundColor = self.contentView.backgroundColor;
            // now scan the reorder control's subviews for the reorder image
            for (UIView *sv in reorderView.subviews)
            {
                if ([sv isKindOfClass:[UIImageView class]])
                {
                    // and replace the image with one that you want
                    ((UIImageView *)sv).image = [UIImage imageNamed:@"menu.png"];
                    // it may be necessary to properly size the image's frame
                    // for your new image - in my experience, this was necessary
                    // the upper left position of the UIImageView's frame
                    // does not seem to matter - the parent reorder control
                    // will center it properly for you
                    sv.frame = CGRectMake(0, 0, 25, 20);
                }
            }
        }
    }
}

@end