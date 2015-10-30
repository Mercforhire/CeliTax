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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    }
    else if ((state & UITableViewCellStateShowingEditControlMask) && (state & UITableViewCellStateShowingDeleteConfirmationMask))
    {
        // When the cell goes from Showing-the-Edit-Control (-) to Showing-the-Edit-Control (-) AND the Delete Button [Delete]
        // !!! It's important to have this BEFORE just showing the Edit Control because the edit control applies to both cases.!!!
        // Do something...=
    }
    else if (state & UITableViewCellStateShowingEditControlMask)
    {
        // When the cell goes into edit mode and Shows-the-Edit-Control (-)
        // Do something...
        self.leftBar.constant = -46;
        self.rightBar.constant = -49;
    }
    else if (state == UITableViewCellStateShowingDeleteConfirmationMask)
    {
        // When the user swipes a row to delete without using the edit button.
        // Do something...=
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
    
    UIImageView *burgerImageView;
    
    if (editing)
    {
        // add the custom burger image
        burgerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, self.frame.size.height / 2 - 10, 25, 20)];
        burgerImageView.image = [UIImage imageNamed:@"menu.png"];
        
        [self addSubview:burgerImageView];
        
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
                    // hide the original gray burger image
                    ((UIImageView *)sv).image = nil;
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