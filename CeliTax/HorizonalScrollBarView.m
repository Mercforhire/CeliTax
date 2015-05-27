//
//  HorizonalScrollBarView.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "HorizonalScrollBarView.h"

#define kButtonMargin       15

@implementation HorizonalScrollBarView
{
    UIScrollView *scrollView;
    NSMutableArray *buttons;
    NSMutableArray *buttonColors;
    NSInteger selectedButtonIndex;
    UIColor *selectedButtonColor;
}

-(void)baseInit
{
    buttons = [NSMutableArray new];
    buttonColors = [NSMutableArray new];
    selectedButtonIndex = -1;
    selectedButtonColor = self.tintColor;
    
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setBounces:NO];
    
    [self addSubview:scrollView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self baseInit];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    //Prevent "Unable to simultaneously satisfy constraints" crash
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //self.frame will now return something
    [self baseInit];
}

-(void)setButtonNames:(NSArray *)buttonNames
{
    _buttonNames = buttonNames;
    
    //remove all subviews
    NSArray *viewsToRemove = [scrollView subviews];
    for (UIView *v in viewsToRemove)
    {
        [v removeFromSuperview];
    }
    [buttons removeAllObjects];
    [buttonColors removeAllObjects];
    
    UIFont *defaultFont = [UIFont systemFontOfSize:15];
    
    long widthOfAllButtons = 0;
    int nThButton = 0;
    float colorDelta = (0.96 - 0.75) / buttonNames.count;
    
    NSMutableArray *buttonLengthes = [NSMutableArray new];
    
    float sumOfButtonLengthes = 0;
    //see if length of all buttons is longer than the view.frame
    //if yes, use the following formula for button sizes
    //if no, find out how much space is left, split that space equally among the buttons
    for (NSString *buttonName in buttonNames)
    {
        float widthOfThisButtonText = [buttonName sizeWithAttributes:@{NSFontAttributeName: defaultFont}].width;
        
        float widthOfThisButton = widthOfThisButtonText + kButtonMargin * 2;
        
        sumOfButtonLengthes = sumOfButtonLengthes + widthOfThisButton;
        
        [buttonLengthes addObject:[ NSNumber numberWithFloat:widthOfThisButton ]];
    }
    
    if ( sumOfButtonLengthes < self.frame.size.width )
    {
        float leftoverSpace = self.frame.size.width - sumOfButtonLengthes;
        
        for (int i = 0; i < buttonLengthes.count; i++)
        {
            buttonLengthes[i] = [ NSNumber numberWithFloat:[buttonLengthes[i] floatValue] + leftoverSpace / buttonLengthes.count ];
        }
    }
    
    //create buttons
    for ( NSNumber *buttonLength in buttonLengthes )
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(widthOfAllButtons, 0, [buttonLength floatValue], self.frame.size.height)];
        
        [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [button setTitle:buttonNames[nThButton] forState:UIControlStateNormal];
        [button.titleLabel setFont:defaultFont];
        
        //Button color goes from [UIColor colorWithWhite:0.75 alpha:1] to [UIColor colorWithWhite:0.96 alpha:1]
        UIColor *buttonColor = [UIColor colorWithWhite:0.75 + colorDelta * nThButton alpha:1];
        [buttonColors addObject:buttonColor];
        
        button.backgroundColor = buttonColor;
        
        [button setTag:nThButton];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollView addSubview:button];
        
        [buttons addObject:button];
        
        widthOfAllButtons = widthOfAllButtons + button.frame.size.width;
        nThButton++;
    }
    
    [scrollView setContentSize:CGSizeMake(widthOfAllButtons, self.frame.size.height)];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    [self setNeedsDisplay];
}

-(void)buttonClicked:(UIButton *)sender
{
    //none is selected
    if (selectedButtonIndex == -1)
    {
        UIButton *selectedButton = [buttons objectAtIndex:sender.tag];
        [selectedButton setBackgroundColor:selectedButtonColor];
        
        NSString *clickedName = [self.buttonNames objectAtIndex:sender.tag];
        
        if (self.delegate)
        {
            [self.delegate buttonClickedWithIndex:sender.tag andName:clickedName];
        }
        
        selectedButtonIndex = sender.tag;
    }
    //deselect the previously selected
    else if (sender.tag == selectedButtonIndex)
    {
        UIButton *deselectedButton = [buttons objectAtIndex:sender.tag];
        [deselectedButton setBackgroundColor:[buttonColors objectAtIndex:sender.tag]];
        
        if (self.delegate)
        {
            [self.delegate buttonUnselected];
        }
        
        selectedButtonIndex = -1;
    }
    //deselect the previously selected and select the new one
    else
    {
        UIButton *deselectedButton = [buttons objectAtIndex:selectedButtonIndex];
        [deselectedButton setBackgroundColor:[buttonColors objectAtIndex:selectedButtonIndex]];
        
        UIButton *selectedButton = [buttons objectAtIndex:sender.tag];
        [selectedButton setBackgroundColor:selectedButtonColor];
        
        NSString *clickedName = [self.buttonNames objectAtIndex:sender.tag];
        
        if (self.delegate)
        {
            [self.delegate buttonClickedWithIndex:sender.tag andName:clickedName];
        }
        
        selectedButtonIndex = sender.tag;
    }
}

@end
