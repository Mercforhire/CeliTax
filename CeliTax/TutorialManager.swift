//
//  TutorialManager.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-13.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
protocol TutorialManagerDelegate {
    
    func tutorialLeftSideButtonPressed()
    
    func tutorialRightSideButtonPressed()
    
}

@objc
class TutorialManager : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private let kTutorialsShownKey : String = "TutorialsShown"
    typealias TutorialDismissedBlock = () -> Void
    
    weak var delegate : TutorialManagerDelegate?
    
    private weak var factory : ViewControllerFactory!
    private weak var lookAndFeel : LookAndFeel!
    
    weak var navigationController : UINavigationController?
    var currentStep : Int = 1
    
    private var maskView : UIView?
    private var tutorialBubbleView : TutorialBubble?
    private weak var viewController : UIViewController?
    
    private var currentTutorial : TutorialStep? {
        didSet
        {
            if (currentTutorial != nil)
            {
                let currentWindow : UIWindow! = UIApplication.sharedApplication().keyWindow
                
                let yOrigin : CGFloat = currentTutorial!.highlightedItemRect.origin.y
                
                self.tutorialBubbleView = TutorialBubble.init(frame: currentWindow.frame)
                
                self.tutorialBubbleView!.lookAndFeel = self.lookAndFeel
                self.tutorialBubbleView!.tutorialText = currentTutorial!.text
                
                var originOfArrow : CGPoint = currentTutorial!.highlightedItemRect.origin
                originOfArrow.x += currentTutorial!.highlightedItemRect.size.width / 2
                
                self.tutorialBubbleView!.originOfArrow = originOfArrow
                self.tutorialBubbleView!.leftButtonTitle = currentTutorial!.leftButtonTitle
                self.tutorialBubbleView!.rightButtonTitle = currentTutorial!.rightButtonTitle
                
                self.tutorialBubbleView!.closeButton?.addTarget(self, action: Selector("endTutorial"), forControlEvents: UIControlEvents.TouchUpInside)
                self.tutorialBubbleView!.leftButton?.addTarget(self, action:Selector("leftSideButtonPressed"), forControlEvents:UIControlEvents.TouchUpInside)
                self.tutorialBubbleView!.rightButton?.addTarget(self, action:Selector("rightSideButtonPressed"), forControlEvents:UIControlEvents.TouchUpInside)
                
                if (currentTutorial!.pointsUp)
                {
                    self.tutorialBubbleView!.arrowDirection = ArrowDirection.Up.rawValue
                    
                    originOfArrow.y += currentTutorial!.highlightedItemRect.size.height
                    
                    self.tutorialBubbleView!.originOfArrow = originOfArrow
                }
                else
                {
                    self.tutorialBubbleView!.arrowDirection = ArrowDirection.Down.rawValue
                }
                
                if (yOrigin == 0)
                {
                    self.tutorialBubbleView!.arrowDirection = ArrowDirection.None.rawValue
                }
                
                self.tutorialBubbleView!.setupUI()
                
                currentWindow.addSubview(self.tutorialBubbleView!)
                
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    self.tutorialBubbleView!.alpha = 1.0
                    
                    }, completion: { (finished) -> Void in
                        
                })
            }
        }
    }
    
    private var defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    private var automaticallyShowTutorial : Bool = false
    
    override init()
    {
        super.init()
    }
    
    init(viewControllerFactory : ViewControllerFactory!, lookAndFeel : LookAndFeel!)
    {
        self.factory = viewControllerFactory
        self.lookAndFeel = lookAndFeel
    }
    
    func displayTutorialInViewController(viewController : UIViewController!, tutorial : TutorialStep!)
    {
        let currentWindow : UIWindow! = UIApplication.sharedApplication().keyWindow
        
        if (self.viewController != viewController)
        {
            self.maskView = nil;
        }
        
        if (self.tutorialBubbleView != nil)
        {
            self.tutorialBubbleView!.removeFromSuperview()
            
            self.tutorialBubbleView = nil
        }
        
        self.viewController = viewController;
        
        if (self.maskView == nil)
        {
            self.maskView = UIView()
            self.maskView!.frame = currentWindow!.frame
            
            self.maskView!.userInteractionEnabled = true //blocks out interactions on self.viewController
            self.maskView!.backgroundColor = UIColor.clearColor()
            
            currentWindow.addSubview(self.maskView!)
        }
        
        self.currentTutorial = tutorial
    }
    
    func setTutorialsAsShown()
    {
        self.defaults.setValue(true, forKey:kTutorialsShownKey)
        
        self.defaults.synchronize()
    }
    
    func setTutorialsAsNotShown()
    {
        self.defaults.removeObjectForKey(kTutorialsShownKey)
        
        self.defaults.synchronize()
        
        self.currentStep = 1
    }
    
    func hasTutorialBeenShown() -> Bool
    {
        if (self.defaults.objectForKey(kTutorialsShownKey) != nil)
        {
            return true
        }
        
        return false
    }
    
    func setAutomaticallyShowTutorialNextTime()
    {
        self.automaticallyShowTutorial = true
    }
    
    func automaticallyShowTutorialNextTime() -> Bool
    {
        if (self.automaticallyShowTutorial)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func dismissTutorial(dismissBlock : TutorialDismissedBlock?)
    {
        UIView.animateWithDuration( 0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.tutorialBubbleView!.alpha = 0.0
            
            }, completion: { (finished) in
                
                self.tutorialBubbleView!.removeFromSuperview()
                self.tutorialBubbleView = nil
                
                self.maskView!.removeFromSuperview()
                self.maskView = nil;
                
                if (dismissBlock != nil)
                {
                    dismissBlock!()
                }
        })
    }
    
    func endTutorial()
    {
        self.setTutorialsAsShown()
        
        self.currentStep = 1
        
        self.dismissTutorial(nil)
        
        let viewControllersStack : NSArray = self.navigationController!.viewControllers
        
        let lastViewController : AnyObject!  = viewControllersStack.lastObject
        
        // Already at Main View, do nothing
        if (lastViewController.isKindOfClass(MainViewController))
        {
            return
        }
        
        //Replace self.navigationController.viewControllers stack with a new MainViewController
        self.navigationController!.setViewControllers([self.factory.createMainViewController()], animated: true)
    }
    
    func leftSideButtonPressed()
    {
        if (self.delegate != nil)
        {
            self.delegate!.tutorialLeftSideButtonPressed()
        }
    }
    
    func rightSideButtonPressed()
    {
        if (self.delegate != nil)
        {
            self.delegate!.tutorialRightSideButtonPressed()
        }
    }
    
}