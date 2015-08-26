//
//  TutorialManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TutorialManager.h"
#import "TutorialStep.h"
#import "LookAndFeel.h"
#import "ViewControllerFactory.h"
#import "TutorialBubble.h"

#define kTutorialsShownKey              @"TutorialsShown"

@interface TutorialManager ()

@property (nonatomic, weak) ViewControllerFactory *factory;
@property (nonatomic, weak) LookAndFeel *lookAndFeel;

// Mask views consist of one large piece, or a top piece, left piece, right piece, and bottom piece
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *maskViewTop;
@property (nonatomic, strong) UIView *maskViewLeft;
@property (nonatomic, strong) UIView *maskViewRight;
@property (nonatomic, strong) UIView *maskViewBottom;

@property (nonatomic, strong) TutorialBubble *tutorialBubbleView;

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) TutorialStep *currentTutorial;

@property (nonatomic,strong) NSUserDefaults *defaults;

@property (nonatomic) BOOL automaticallyShowTutorial;

@end

@implementation TutorialManager

- (instancetype) initWithViewControllerFactory: (ViewControllerFactory *)factory
                                andLookAndFeel: (LookAndFeel *)lookAndFeel;
{
    if (self = [super init])
    {
        _factory = factory;
        _lookAndFeel = lookAndFeel;
        
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

-(void)setCurrentTutorial:(TutorialStep *)currentTutorial
{
    _currentTutorial = currentTutorial;
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    
    float yOrigin = _currentTutorial.highlightedItemRect.origin.y;
    
    self.tutorialBubbleView = [[TutorialBubble alloc] initWithFrame: currentWindow.frame];
    
    self.tutorialBubbleView.lookAndFeel = self.lookAndFeel;
    self.tutorialBubbleView.tutorialText = _currentTutorial.text;
    
    CGPoint originOfArrow = _currentTutorial.highlightedItemRect.origin;
    originOfArrow.x += _currentTutorial.highlightedItemRect.size.width / 2;
    
    self.tutorialBubbleView.originOfArrow = originOfArrow;
    self.tutorialBubbleView.leftButtonTitle = _currentTutorial.leftButtonTitle;
    self.tutorialBubbleView.rightButtonTitle =_currentTutorial.rightButtonTitle;
    
    [self.tutorialBubbleView.closeButton addTarget:self action:@selector(exitTutorialPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.tutorialBubbleView.leftButton addTarget:self action:@selector(leftSideButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.tutorialBubbleView.rightButton addTarget:self action:@selector(rightSideButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (currentTutorial.pointsUp)
    {
        self.tutorialBubbleView.arrowDirection = ArrowDirectionUp;
        
        originOfArrow.y += _currentTutorial.highlightedItemRect.size.height;
        
        self.tutorialBubbleView.originOfArrow = originOfArrow;
    }
    else
    {
        self.tutorialBubbleView.arrowDirection = ArrowDirectionDown;
    }
    
    if (!yOrigin)
    {
        self.tutorialBubbleView.arrowDirection = ArrowDirectionNone;
    }
    
    [self.tutorialBubbleView setupUI];
    
    [currentWindow addSubview:self.tutorialBubbleView];
    
    [UIView animateWithDuration: 0.3f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tutorialBubbleView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished)
     {
         
     }];
}

-(void)displayTutorialInViewController: (UIViewController *) viewController andTutorial:(TutorialStep *)tutorial
{
    if ( !tutorial || viewController == nil)
    {
        return;
    }
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    
    if (self.viewController && self.viewController != viewController)
    {
        self.maskViewTop = nil;
        self.maskViewLeft = nil;
        self.maskViewRight = nil;
        self.maskViewBottom = nil;
        self.maskView = nil;
    }
    
    if (self.tutorialBubbleView)
    {
        [self.tutorialBubbleView removeFromSuperview];
        
        self.tutorialBubbleView = nil;
    }
    
    self.viewController = viewController;
    
    //this Tutorial is pointing to something, we have to use the pieces of MaskViews to leave a hole for the highlighted item
    if (tutorial.highlightedItemRect.origin.x || tutorial.highlightedItemRect.origin.y)
    {
        [self.maskView removeFromSuperview];
        [self.maskViewTop removeFromSuperview];
        [self.maskViewLeft removeFromSuperview];
        [self.maskViewRight removeFromSuperview];
        [self.maskViewBottom removeFromSuperview];
        
        CGFloat previousAlpha = self.maskViewTop.alpha;
        
        self.maskViewTop = [[UIView alloc] init];
        [self.maskViewTop setFrame: CGRectMake(0, 0, currentWindow.frame.size.width, tutorial.highlightedItemRect.origin.y)];
        
        [self.maskViewTop setUserInteractionEnabled: YES]; //blocks out interactions on self.viewController
        self.maskViewTop.backgroundColor = [UIColor whiteColor];
        [self.maskViewTop setOpaque: NO];
        
        if (self.maskView)
        {
            [self.maskViewTop setAlpha: self.maskView.alpha];
        }
        else if (self.maskViewTop)
        {
            [self.maskViewTop setAlpha: previousAlpha];
        }
        else
        {
            [self.maskViewTop setAlpha: 0];
        }
        
        [currentWindow addSubview:self.maskViewTop];
        
        self.maskViewLeft = [[UIView alloc] init];
        [self.maskViewLeft setFrame: CGRectMake(0, tutorial.highlightedItemRect.origin.y, tutorial.highlightedItemRect.origin.x, tutorial.highlightedItemRect.size.height)];
        
        [self.maskViewLeft setUserInteractionEnabled:YES]; //blocks out interactions on self.viewController
        self.maskViewLeft.backgroundColor = [UIColor whiteColor];
        [self.maskViewLeft setOpaque:NO];
        if (self.maskView)
        {
            [self.maskViewLeft setAlpha: self.maskView.alpha];
        }
        else if (self.maskViewLeft)
        {
            [self.maskViewLeft setAlpha: previousAlpha];
        }
        else
        {
            [self.maskViewLeft setAlpha: 0];
        }
        
        [currentWindow addSubview:self.maskViewLeft];
        
        self.maskViewRight = [[UIView alloc] init];
        [self.maskViewRight setFrame: CGRectMake(tutorial.highlightedItemRect.origin.x + tutorial.highlightedItemRect.size.width, tutorial.highlightedItemRect.origin.y, currentWindow.frame.size.width - tutorial.highlightedItemRect.origin.x + tutorial.highlightedItemRect.size.width, tutorial.highlightedItemRect.size.height)];
        
        [self.maskViewRight setUserInteractionEnabled:YES]; //blocks out interactions on self.viewController
        self.maskViewRight.backgroundColor = [UIColor whiteColor];
        [self.maskViewRight setOpaque:NO];
        if (self.maskView)
        {
            [self.maskViewRight setAlpha: self.maskView.alpha];
        }
        else if (self.maskViewRight)
        {
            [self.maskViewRight setAlpha: previousAlpha];
        }
        else
        {
            [self.maskViewRight setAlpha: 0];
        }
        
        [currentWindow addSubview:self.maskViewRight];
        
        self.maskViewBottom = [[UIView alloc] init];
        [self.maskViewBottom setFrame: CGRectMake(0, tutorial.highlightedItemRect.origin.y + tutorial.highlightedItemRect.size.height, currentWindow.frame.size.width, currentWindow.frame.size.height - tutorial.highlightedItemRect.origin.y - tutorial.highlightedItemRect.size.height)];
        
        [self.maskViewBottom setUserInteractionEnabled:YES]; //blocks out interactions on self.viewController
        self.maskViewBottom.backgroundColor = [UIColor whiteColor];
        [self.maskViewBottom setOpaque:NO];
        if (self.maskView)
        {
            [self.maskViewBottom setAlpha: self.maskView.alpha];
        }
        else if (self.maskViewBottom)
        {
            [self.maskViewBottom setAlpha: previousAlpha];
        }
        else
        {
            [self.maskViewBottom setAlpha: 0];
        }
        
        [currentWindow addSubview:self.maskViewBottom];
        
        self.maskView = nil;
    }
    else
    {
        [self.maskViewTop removeFromSuperview];
        [self.maskViewLeft removeFromSuperview];
        [self.maskViewRight removeFromSuperview];
        [self.maskViewBottom removeFromSuperview];
        
        if (!self.maskView)
        {
            self.maskView = [[UIView alloc] init];
            [self.maskView setFrame: currentWindow.frame];
            
            [self.maskView setUserInteractionEnabled:YES]; //blocks out interactions on self.viewController
            self.maskView.backgroundColor = [UIColor whiteColor];
            [self.maskView setOpaque:NO];
            [self.maskView setAlpha:self.maskViewTop.alpha]; //fade to 0.8 later
            
            [currentWindow addSubview:self.maskView];
        }
        
        self.maskViewTop = nil;
        self.maskViewLeft = nil;
        self.maskViewRight = nil;
        self.maskViewBottom = nil;
    }
    
    self.currentTutorial = tutorial;
    
    [UIView animateWithDuration: 0.3f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (self.currentTutorial.highlightedItemRect.origin.x || self.currentTutorial.highlightedItemRect.origin.y)
                         {
                             [self.maskViewBottom setAlpha:0.8];
                             [self.maskViewLeft setAlpha:0.8];
                             [self.maskViewRight setAlpha:0.8];
                             [self.maskViewTop setAlpha:0.8];
                         }
                         else
                         {
                             [self.maskView setAlpha:0.8];
                         }
                     }
                     completion:^(BOOL finished)
     {
         
     }];
}

-(void)setTutorialsAsShown
{
    [self.defaults setValue:[NSNumber numberWithBool:YES] forKey:kTutorialsShownKey];
    
    [self.defaults synchronize];
}

-(void)setTutorialsAsNotShown
{
    [self.defaults removeObjectForKey:kTutorialsShownKey];
    
    [self.defaults synchronize];
}

-(BOOL)hasTutorialBeenShown
{
    if ([self.defaults objectForKey:kTutorialsShownKey])
    {
        return YES;
    }
    
    return NO;
}

-(void)setAutomaticallyShowTutorialNextTime
{
    self.automaticallyShowTutorial = YES;
}

-(BOOL)automaticallyShowTutorialNextTime
{
    if (self.automaticallyShowTutorial)
    {
        self.automaticallyShowTutorial = NO;
        
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)dismissTutorial:(TutorialDismissedBlock) dismissBlock
{
    [UIView animateWithDuration: 0.3f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tutorialBubbleView.alpha = 0.0f;
                         self.maskView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished)
     {
         [self.tutorialBubbleView removeFromSuperview];
         self.tutorialBubbleView = nil;
         
         [self.maskViewBottom removeFromSuperview];
         self.maskViewBottom = nil;
         
         [self.maskViewLeft removeFromSuperview];
         self.maskViewLeft = nil;
         
         [self.maskViewRight removeFromSuperview];
         self.maskViewRight = nil;
         
         [self.maskViewTop removeFromSuperview];
         self.maskViewTop = nil;
         
         [self.maskView removeFromSuperview];
         self.maskView = nil;
         
         if (dismissBlock)
         {
             dismissBlock();
         }
     }];
}

-(void)exitTutorialPressed
{
    [self setTutorialsAsShown];
    
    [self dismissTutorial:nil];
}

- (void) leftSideButtonPressed
{
    if (self.delegate)
    {
        [self.delegate tutorialLeftSideButtonPressed];
    }
}

- (void) rightSideButtonPressed
{
    if (self.delegate)
    {
        [self.delegate tutorialRightSideButtonPressed];
    }
}


@end
