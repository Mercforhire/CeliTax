//
//  TutorialManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewControllerFactory, LookAndFeel, TutorialStep;

@protocol TutorialManagerDelegate <NSObject>

- (void) tutorialLeftSideButtonPressed;

- (void) tutorialRightSideButtonPressed;

@end

@interface TutorialManager : NSObject

typedef void (^TutorialDismissedBlock) ();

@property (nonatomic, weak) id<TutorialManagerDelegate> delegate;

@property (nonatomic, weak) UINavigationController *navigationController;

@property (nonatomic) NSInteger currentStep;

- (instancetype) initWithViewControllerFactory: (ViewControllerFactory *)factory
                                andLookAndFeel: (LookAndFeel *)lookAndFeel NS_DESIGNATED_INITIALIZER;

-(void)displayTutorialInViewController: (UIViewController *) viewController andTutorial:(TutorialStep *)tutorial;

-(void)dismissTutorial:(TutorialDismissedBlock) dismissBlock;

-(void)endTutorial;

// after all Tutorials has been show, or skip was clicked, call this function
-(void)setTutorialsAsShown;

// unset the Tutorial Shown flag
-(void)setTutorialsAsNotShown;

// returns True if tutorials have been shown, false otherwise
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasTutorialBeenShown;

// before we push a new view to continue the tutorial, we want to set this,
// so when the next view is pushed, it will know to automatically start its tutorial
-(void)setAutomaticallyShowTutorialNextTime;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL automaticallyShowTutorialNextTime;

@end
