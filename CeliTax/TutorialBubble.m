//
//  TutorialBubbleUp.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TutorialBubble.h"
#import "LookAndFeel.h"
#import "Triangle.h"

@interface TutorialBubble ()

@property (weak, nonatomic) IBOutlet Triangle *topArrowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topArrowLeftDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topArrowTopDistance;

@property (weak, nonatomic) IBOutlet Triangle *bottomArrowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomArrowLeftDistance;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewHeightBar; //+80 than textViewHeightBar

@property (weak, nonatomic) IBOutlet UIView *bubbleView;

@property (weak, nonatomic) IBOutlet UITextView *tutorialTextView;

@property (strong, nonatomic) UIFont *textViewFont;

@end

@implementation TutorialBubble
{
    TutorialBubble *customView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // 1. Load the .xib file .xib file must match classname
        NSString *className = NSStringFromClass([self class]);
        customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Add as a subview
        [self addSubview:customView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        // 1. Load .xib file
        NSString *className = NSStringFromClass([self class]);
        customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Add as a subview
        [self addSubview:customView];
    }
    return self;
}

-(void)setTutorialText:(NSString *)tutorialText
{
    _tutorialText = tutorialText;
    
    self.tutorialTextView.text = _tutorialText;
    self.tutorialTextView.selectable = NO;
}

-(void)setupUI
{
    switch (self.arrowDirection)
    {
        case ArrowDirectionNone:
        {
            [self.topArrowView setHidden:YES];
            [self.bottomArrowView setHidden:YES];
            
            self.topArrowLeftDistance.constant = 0;
            self.bottomArrowLeftDistance.constant = 0;
        }
            break;
            
        case ArrowDirectionUp:
        {
            [self.bottomArrowView setHidden:YES];
            self.bottomArrowLeftDistance.constant = 0;
            
            [self.topArrowView setPointsUp:YES];
            
            self.topArrowLeftDistance.constant = self.originOfArrow.x - self.topArrowView.frame.size.width / 2;
        }
            break;
            
        case ArrowDirectionDown:
        {
            [self.topArrowView setHidden:YES];
            self.topArrowLeftDistance.constant = 0;
            
            [self.bottomArrowView setPointsUp:NO];
            
            self.bottomArrowLeftDistance.constant = self.originOfArrow.x - self.bottomArrowView.frame.size.width / 2;
        }
            break;
            
        default:
            break;
    }
    
    self.textViewFont = [UIFont latoLightFontOfSize:14];
    
    [self.tutorialTextView setText:self.tutorialText];
    
    if (self.leftButtonTitle)
    {
        [self.leftButton setTitle:self.leftButtonTitle forState:UIControlStateNormal];
    }
    else
    {
        [self.leftButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
        [self.leftButton setEnabled:NO];
        [self.lookAndFeel applyDisabledButtonStyleTo:self.leftButton];
    }
    
    if (self.rightButtonTitle)
    {
        [self.rightButton setTitle:self.rightButtonTitle forState:UIControlStateNormal];
    }
    else
    {
        [self.rightButton setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
        [self.rightButton setEnabled:NO];
        [self.lookAndFeel applyDisabledButtonStyleTo:self.rightButton];
    }
    
    self.bubbleView.layer.cornerRadius = 3.0f;
    [self.bubbleView setBackgroundColor:[UIColor colorWithRed:116.0f/255 green:191.0f/255 blue:81.0f/255 alpha:1]];
    
    self.leftButton.layer.cornerRadius = 2.0f;
    self.rightButton.layer.cornerRadius = 2.0f;
    
    self.closeButton.layer.cornerRadius = self.closeButton.frame.size.height / 2;
    self.closeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.closeButton.layer.borderWidth = 3.0f;
    self.closeButton.clipsToBounds = YES;
    
    // calculate the text height and
    CGFloat fixedWidth = self.tutorialTextView.frame.size.width;
    CGSize newSize = [self.tutorialTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.tutorialTextView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    
    // set the correct textViewHeightBar and bubbleViewHeightBar
    [self.textViewHeightBar setConstant:newFrame.size.height];
    [self.bubbleViewHeightBar setConstant:newFrame.size.height + 80];
    
    if (self.originOfArrow.x || self.originOfArrow.y)
    {
        if (self.arrowDirection == ArrowDirectionUp)
        {
            self.topArrowTopDistance.constant = self.originOfArrow.y;
        }
        else
        {
            self.topArrowTopDistance.constant = self.originOfArrow.y - self.bubbleViewHeightBar.constant - self.topArrowView.frame.size.height * 2;
        }
    }
    else
    {
        //Center the view
        self.topArrowTopDistance.constant = (self.frame.size.height - self.bubbleViewHeightBar.constant - self.topArrowView.frame.size.height * 2) / 2;
    }
    
    [self setNeedsUpdateConstraints];
}

@end
