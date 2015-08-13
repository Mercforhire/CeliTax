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
#import "TutorialBubbleUp.h"
#import "TutorialBubbleDown.h"
#import "TutorialBubbleProtocol.h"

#define kNumberOfViewsWithTutorials             6
#define kRemeberedTutorialStagesDefaultsKey     @"RemeberedTutorialStagesDefaultsKey"

@interface TutorialManager () <TutorialBubbleProtocol>

@property (nonatomic, weak) ViewControllerFactory *factory;
@property (nonatomic, weak) LookAndFeel *lookAndFeel;
@property (nonatomic, strong) NSMutableDictionary *rememberedTutorialStages;

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) id<TutorialBubbleInterface> tutorialBubbleView;

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) NSArray *tutorials;
@property (nonatomic, strong) TutorialStep *currentTutorial;

@property (nonatomic,strong) NSUserDefaults *defaults;

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
        
        _rememberedTutorialStages = [[_defaults valueForKey:kRemeberedTutorialStagesDefaultsKey] mutableCopy];
        
        if (!_rememberedTutorialStages)
        {
            _rememberedTutorialStages = [NSMutableDictionary new];
        }
    }
    
    return self;
}

-(void)setCurrentTutorial:(TutorialStep *)currentTutorial
{
    _currentTutorial = currentTutorial;
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    
    float yOrigin = 0;
    
    if (!_currentTutorial.origin.x && !_currentTutorial.origin.y)
    {
        yOrigin = (currentWindow.frame.size.height - _currentTutorial.size.height - TOP_BUBBLE_MARGIN - BOTTOM_BUBBLE_MARGIN) / 2;
    }
    else
    {
        yOrigin = _currentTutorial.origin.y;
    }
    
    float height = _currentTutorial.size.height + TOP_BUBBLE_MARGIN + BOTTOM_BUBBLE_MARGIN;
    
    if (_currentTutorial.pointsUp)
    {
        self.tutorialBubbleView = [[TutorialBubbleUp alloc] initWithFrame:CGRectMake(0, yOrigin, currentWindow.bounds.size.width, height)];
    }
    else
    {
        self.tutorialBubbleView = [[TutorialBubbleDown alloc] initWithFrame:CGRectMake(0, yOrigin - height, currentWindow.bounds.size.width, _currentTutorial.size.height + height)];
    }
    
    self.tutorialBubbleView.delegate = self;
    
    self.tutorialBubbleView.lookAndFeel = self.lookAndFeel;
    self.tutorialBubbleView.tutorialText = _currentTutorial.text;
    
    self.tutorialBubbleView.xOriginOfArrow = _currentTutorial.origin.x;
    self.tutorialBubbleView.bubbleWidth = _currentTutorial.size.width;
    self.tutorialBubbleView.bubbleHeight = _currentTutorial.size.height;
    self.tutorialBubbleView.leftMarginOfBubble = 15;
    
    [self.tutorialBubbleView setupUI];
    
    ((UIView *)self.tutorialBubbleView).alpha = 0.0f;
    
    [currentWindow addSubview:((UIView *)self.tutorialBubbleView)];
    
    [UIView animateWithDuration: 0.3f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         ((UIView *)self.tutorialBubbleView).alpha = 1.0f;
                     }
                     completion:^(BOOL finished)
     {
         
     }];
}

-(void)startTutorialInViewController: (UIViewController *) viewController andTutorials:(NSArray *)tutorials;
{
    if ( !tutorials.count || viewController == nil)
    {
        return;
    }
    
    [((UIView *)self.tutorialBubbleView) removeFromSuperview];
    [self.maskView removeFromSuperview];
    
    self.viewController = viewController;
    self.tutorials = tutorials;

    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    
    self.maskView = [[UIView alloc] init];
    [self.maskView setFrame: currentWindow.frame];
    
    [self.maskView setUserInteractionEnabled:YES]; //blocks out interactions on self.viewController
    self.maskView.backgroundColor = [UIColor blackColor];
    [self.maskView setOpaque:NO];
    [self.maskView setAlpha:0.0]; //fade to 0.5 later
    
    [currentWindow addSubview:self.maskView];
    
    [UIView animateWithDuration: 0.3f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.maskView setAlpha:0.5];
                     }
                     completion:^(BOOL finished)
     {
         
     }];
    
    self.currentTutorial = [self.tutorials firstObject];
}

-(void)exitTutorialPressed
{
    [UIView animateWithDuration: 0.3f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         ((UIView *)self.tutorialBubbleView).alpha = 0.0f;
                         self.maskView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished)
     {
         [((UIView *)self.tutorialBubbleView) removeFromSuperview];
         [self.maskView removeFromSuperview];
     }];
}

-(void)nextTutorialPressed
{
    if (!self.tutorials.count || self.currentTutorial == [self.tutorials lastObject])
    {
        [self exitTutorialPressed];
        
        return;
    }
    
    [UIView animateWithDuration: 0.3f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         ((UIView *)self.tutorialBubbleView).alpha = 0.0f;
                     }
                     completion:^(BOOL finished)
     {
         [((UIView *)self.tutorialBubbleView) removeFromSuperview];
         
         self.currentTutorial = [self.tutorials objectAtIndex:[self.tutorials indexOfObject:self.currentTutorial] + 1];
     }];
}

-(void)saveRememberedTutorialStagesToDefaults
{
    [self.defaults setValue:self.rememberedTutorialStages forKey:kRemeberedTutorialStagesDefaultsKey];
    
    [self.defaults synchronize];
}

-(void)setCurrentTutorialStageForViewController:(UIViewController *)viewController forStage:(NSInteger)stage
{
    NSString *className = NSStringFromClass([viewController class]);
    
    [self.rememberedTutorialStages setObject:[NSNumber numberWithInteger:stage] forKey:className];
    
    [self saveRememberedTutorialStagesToDefaults];
}

-(void)setTutorialDoneForViewController:(UIViewController *)viewController
{
    NSString *className = NSStringFromClass([viewController class]);
    
    [self.rememberedTutorialStages setObject:[NSNumber numberWithInteger: -1] forKey:className];
    
    [self saveRememberedTutorialStagesToDefaults];
}

-(NSInteger)getCurrentTutorialStageForViewController:(UIViewController *)viewController
{
    NSString *className = NSStringFromClass([viewController class]);
    
    if ([self.rememberedTutorialStages objectForKey:className])
    {
        return [[self.rememberedTutorialStages objectForKey:className] integerValue];
    }
    
    return 1;
}

-(BOOL)areAllTutorialsShown
{
    if (self.rememberedTutorialStages.count == 6)
    {
        for (NSNumber *step in self.rememberedTutorialStages.allValues)
        {
            if (step.integerValue != -1)
            {
                return NO;
            }
        }
    }
    else
    {
        return NO;
    }
    
    return YES;
}

-(void)resetTutorialStages
{
    [self.rememberedTutorialStages removeAllObjects];
    
    [self saveRememberedTutorialStagesToDefaults];
}

@end
