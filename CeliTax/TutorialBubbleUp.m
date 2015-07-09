//
//  TutorialBubbleUp.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TutorialBubbleUp.h"
#import "LookAndFeel.h"
#import "Triangle.h"

@interface TutorialBubbleUp ()

@property (weak, nonatomic) IBOutlet Triangle *arrowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowLeftDistance;

@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleLeftDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleHeightBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleWidthBar;

@property (weak, nonatomic) IBOutlet UITextView *tutorialTextView;

@end

@implementation TutorialBubbleUp
{
    TutorialBubbleUp *customView;
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
    [self.arrowView setLookAndFeel:self.lookAndFeel];
    [self.arrowView setPointsUp:YES];
    
    self.arrowLeftDistance.constant = self.xOriginOfArrow - self.arrowView.frame.size.width / 2;
    
    if (self.arrowLeftDistance.constant < 0)
    {
        [self.arrowView setHidden:YES];
        
        self.bubbleLeftDistance.constant = (self.frame.size.width - self.bubbleWidth) / 2;
    }
    else
    {
        [self.arrowView setHidden:NO];
        
        self.bubbleLeftDistance.constant = self.leftMarginOfBubble;
    }
    
    self.bubbleHeightBar.constant = self.bubbleHeight;
    
    self.bubbleWidthBar.constant = self.bubbleWidth;
    
    [self.tutorialTextView setText:self.tutorialText];
    
    [self.tutorialTextView setBackgroundColor:self.lookAndFeel.appGreenColor];
    
    [self.bubbleView setBackgroundColor:self.lookAndFeel.appGreenColor];
    
    [self.lookAndFeel applyHollowGreenButtonStyleTo:self.skipButton];
    
    [self.lookAndFeel applySolidGreenButtonStyleTo:self.continueButton];
    
     self.bubbleView.layer.cornerRadius = 10.0f;
    
    [self setNeedsUpdateConstraints];
}

- (IBAction)skipPressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate exitTutorialPressed];
    }
}

- (IBAction)continuePressed:(id)sender
{
    if (self.delegate)
    {
        [self.delegate nextTutorialPressed];
    }
}

@end
