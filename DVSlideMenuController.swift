//
//  DVSlideMenuController.swift
//  DVSlideMenuExample
//
//  Created by Đặng Vinh on 3/15/15.
//  Copyright (c) 2015 DVISoft. All rights reserved.
//

import UIKit

@objc protocol DVSlideMenuControllerDelegate {
    optional func dvSlideMenuControllerWillShowLeftPanel()
    optional func dvSlideMenuControllerDidShowLeftPanel()
    optional func dvSlideMenuControllerWillHideLeftPanel()
    optional func dvSlideMenuControllerDidHideLeftPanel()
    
    optional func dvSlideMenuControllerWillShowRightPanel()
    optional func dvSlideMenuControllerDidShowRightPanel()
    optional func dvSlideMenuControllerWillHideRightPanel()
    optional func dvSlideMenuControllerDidHideRightPanel()
}

class DVSlideMenuController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Setting Values
    
    enum SlidePanelCurrentState {
        case Left
        case Right
        case None
    }
    
    var centerViewController: UIViewController!
    var leftViewController: UIViewController?
    var rightViewController: UIViewController?    
    var slidePanelCurrentState: SlidePanelCurrentState = .None
    var delegate: DVSlideMenuControllerDelegate?
    let distanceOffset: CGFloat = 70
    let shadowOpacity: Float = 0.8
    let timeSliding = 0.5
    let originDarkValue: CGFloat = 0.01
    var darkValue: CGFloat! { didSet { if (darkView != nil) { darkView?.alpha = darkValue! } } }
    var darkView: UIView?
    var allowPanGesture: Bool = true
    var existingPanelOnScreen = false
    
    // MARK: - Init Methods
    
    init(centerViewController centerVC:UIViewController, leftViewController leftVC:UIViewController, rightViewController rightVC:UIViewController) {
        super.init(nibName: nil, bundle: nil)
        centerViewController = centerVC
        leftViewController = leftVC
        rightViewController = rightVC
        
        addCenterViewController()
        addLeftPanelViewController()
        addRightPanelViewController()
    }
    
    init(centerViewController centerVC:UIViewController, leftViewController leftVC:UIViewController) {
        super.init(nibName: nil, bundle: nil)
        centerViewController = centerVC
        leftViewController = leftVC
        rightViewController = nil
        
        addCenterViewController()
        addLeftPanelViewController()
    }
    
    init(centerViewController centerVC:UIViewController, rightViewController rightVC:UIViewController) {
        super.init(nibName: nil, bundle: nil)
        centerViewController = centerVC
        leftViewController = nil
        rightViewController = rightVC
        
        addCenterViewController()
        addRightPanelViewController()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge.None
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if toInterfaceOrientation.isLandscape {
            rightViewController?.view.frame.origin.x = view.bounds.height
        } else if toInterfaceOrientation.isPortrait {
            rightViewController?.view.frame.origin.x = view.bounds.width
        }
    }
    
    // MARK: - PanelViewController Methods
    
    func addCenterViewController() {
        centerViewController.view.frame = view.frame
        centerViewController.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        view.addSubview(centerViewController.view)
        addChildViewController(centerViewController)
        centerViewController.didMoveToParentViewController(self)
        addPanGestureForSliding()
    }
    
    func addLeftPanelViewController() {
        if leftViewController != nil {
            leftViewController?.view.frame = CGRectMake(0, 0, view.bounds.width - distanceOffset, view.bounds.height)
            leftViewController?.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            leftViewController?.view.center = CGPoint(x: -(view.bounds.width - distanceOffset)/2, y: view.bounds.height/2)
            addChildPanelViewController(leftViewController!)
        }
    }
    
    func addRightPanelViewController() {
        if rightViewController != nil {
            rightViewController?.view.frame = CGRectMake(0, 0, view.bounds.width - distanceOffset, view.bounds.height)
            rightViewController?.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            rightViewController?.view.center = CGPoint(x: view.bounds.width + (view.bounds.width - distanceOffset)/2, y: view.bounds.height/2)
            addChildPanelViewController(rightViewController!)
        }
    }
    
    func addChildPanelViewController(panelVC: UIViewController) {
        view.addSubview(panelVC.view)
        addChildViewController(panelVC)
        panelVC.didMoveToParentViewController(self)
    }
    
    func setCenterViewController(centerVC: UIViewController) {
        if centerViewController != nil {
            centerViewController.willMoveToParentViewController(nil)
            centerViewController.view.removeFromSuperview()
            centerViewController.removeFromParentViewController()
            
            if let recognizers = view.gestureRecognizers {
                for recognizer in recognizers {
                    view.removeGestureRecognizer(recognizer as UIGestureRecognizer)
                }
            }
        }
        centerViewController = centerVC
        addCenterViewController()
    }
    
    // MARK: - Animation Methods
    
    func animatePanelWithCondition(condition: Bool) {
        if(condition) {
            switch(slidePanelCurrentState) {
            case .Left:
                animateToTargetWithNewPositionX(newPositionX: 0, showPanel: true)
            case .Right:
                if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                    animateToTargetWithNewPositionX(newPositionX: distanceOffset + view.bounds.width - view.bounds.height, showPanel: true)
                } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                    animateToTargetWithNewPositionX(newPositionX: distanceOffset, showPanel: true)
                }
            default:
                break
            }
        } else {
            switch(slidePanelCurrentState) {
            case .Left:
                delegate?.dvSlideMenuControllerWillHideLeftPanel?()
                animateToTargetWithNewPositionX(newPositionX: -leftViewController!.view.bounds.width, showPanel: false)
                removeShadowOpacityToView(viewToRemove: leftViewController!.view)
            case .Right:
                delegate?.dvSlideMenuControllerWillHideRightPanel?()
                animateToTargetWithNewPositionX(newPositionX: view.bounds.width, showPanel: false)
                removeShadowOpacityToView(viewToRemove: rightViewController!.view)
            default:
                break
            }

        }
    }
    
    func animateToTargetWithNewPositionX(#newPositionX: CGFloat, showPanel: Bool, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(timeSliding, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            if self.slidePanelCurrentState == .Left {
                self.view.bringSubviewToFront(self.leftViewController!.view)
                self.leftViewController?.view.frame.origin.x = newPositionX
                self.darkValue = 0.5
                if !showPanel {
                    self.darkValue = 0
                }
            } else if self.slidePanelCurrentState == .Right {
                self.view.bringSubviewToFront(self.rightViewController!.view)
                self.rightViewController?.view.frame.origin.x = newPositionX
                self.darkValue = 0.5
                if !showPanel {
                    self.darkValue = 0
                }
            }
            }, completion: { finished in
                if !showPanel {
                    if self.darkView != nil {
                        self.darkView?.removeFromSuperview()
                        self.darkView = nil
                    }
                    
                    if self.slidePanelCurrentState == .Left {
                        self.delegate?.dvSlideMenuControllerDidHideLeftPanel?()
                    } else if self.slidePanelCurrentState == .Right {
                        self.delegate?.dvSlideMenuControllerDidHideRightPanel?()
                    }
                    
                    self.darkValue = self.originDarkValue
                    self.slidePanelCurrentState = .None
                    self.existingPanelOnScreen = false
                    
                } else {
                    if !self.existingPanelOnScreen {
                        self.existingPanelOnScreen = true
                        if self.slidePanelCurrentState == .Left {
                            self.delegate?.dvSlideMenuControllerDidShowLeftPanel?()
                        } else if self.slidePanelCurrentState == .Right {
                            self.delegate?.dvSlideMenuControllerDidShowRightPanel?()
                        }
                    }
                }
        })
        
    }
    
    // MARK: - CenterViewControllerDelegate Methods //
    
    func toggleLeft() {
        delegate?.dvSlideMenuControllerWillShowLeftPanel?()
        slidePanelCurrentState = .Left
        addShadowOpacityToView(currentView: leftViewController!.view, shadowValue: shadowOpacity)
        addDarkView()
        animateToTargetWithNewPositionX(newPositionX: 0, showPanel: true)
    }
    
    func toggleRight() {
        delegate?.dvSlideMenuControllerWillShowRightPanel?()
        slidePanelCurrentState = .Right
        addShadowOpacityToView(currentView: rightViewController!.view, shadowValue: shadowOpacity)
        addDarkView()
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            animateToTargetWithNewPositionX(newPositionX: distanceOffset + view.bounds.width - view.bounds.height, showPanel: true)
        } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
            animateToTargetWithNewPositionX(newPositionX: distanceOffset, showPanel: true)
        }
    }
    
    func hidePanel() {
        if slidePanelCurrentState == .Left {
            delegate?.dvSlideMenuControllerWillHideLeftPanel?()
            animateToTargetWithNewPositionX(newPositionX: -view.bounds.width, showPanel: false)
            removeShadowOpacityToView(viewToRemove: leftViewController!.view)
        } else if slidePanelCurrentState == .Right {
            delegate?.dvSlideMenuControllerWillHideRightPanel?()
            animateToTargetWithNewPositionX(newPositionX: view.bounds.width, showPanel: false)
            removeShadowOpacityToView(viewToRemove: rightViewController!.view)
        }
    }
    
    // MARK: - UIPanGestureRecognizer Methods //
    
    func addPanGestureForSliding() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleSlidePanel:")
        centerViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func handleSlidePanel(panGesture: UIPanGestureRecognizer) {
        let dragFromLeftToRight = panGesture.velocityInView(view).x > 0
        
        switch(panGesture.state) {
        case .Began:
            if dragFromLeftToRight {
                if slidePanelCurrentState == .None && leftViewController != nil {
                    slidePanelCurrentState = .Left
                    addShadowOpacityToView(currentView: leftViewController!.view, shadowValue: shadowOpacity)
                    delegate?.dvSlideMenuControllerWillShowLeftPanel?()
                }
            } else {
                if slidePanelCurrentState == .None && rightViewController != nil {
                    slidePanelCurrentState = .Right
                    addShadowOpacityToView(currentView: rightViewController!.view, shadowValue: shadowOpacity)
                    delegate?.dvSlideMenuControllerWillShowRightPanel?()
                }
            }
            addDarkView()
            if darkValue == nil { darkValue = originDarkValue }
            
        case .Changed:
            if slidePanelCurrentState == .Left && CGRectGetMinX(leftViewController!.view.frame) <= 0 {
                leftViewController!.view.center.x = leftViewController!.view.center.x + panGesture.translationInView(view).x
            } else if slidePanelCurrentState == .Right && CGRectGetMaxX(rightViewController!.view.frame) >= view.frame.width {
                rightViewController!.view.center.x = rightViewController!.view.center.x + panGesture.translationInView(view).x
            }
            setDarkValue()
            panGesture.setTranslation(CGPointZero, inView: view)

        case .Ended:
            if slidePanelCurrentState == .Left {
                let isGreaterThanHalfScreen = leftViewController!.view.center.x > 0
                animatePanelWithCondition(isGreaterThanHalfScreen)
            } else if slidePanelCurrentState == .Right {
                let isGreaterThanHalfScreen = rightViewController!.view.center.x < view.bounds.width
                animatePanelWithCondition(isGreaterThanHalfScreen)
            }
        default:
            break
        }
        
    }
    
    // MARK: - Supporting Methods //
    
    func addDarkView() {
        if darkView == nil {
            darkView = UIView(frame: centerViewController.view.frame)
            darkView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
            darkView?.backgroundColor = UIColor.blackColor()
            darkView?.alpha = 0
            darkView?.userInteractionEnabled = false
            centerViewController.view.addSubview(darkView!)
        }
    }
    
    func addShadowOpacityToView(#currentView: UIView, shadowValue: Float) {
        currentView.layer.shadowOpacity = shadowOpacity
    }
    
    func removeShadowOpacityToView(#viewToRemove: UIView) {
        viewToRemove.layer.shadowOpacity = 0
    }
    
    func setDarkValue() {
        switch(slidePanelCurrentState) {
        case .Left:
            darkValue = CGRectGetMaxX(leftViewController!.view.frame)/(view.frame.width - distanceOffset)/2
        case .Right:
            darkValue = (distanceOffset/2)/CGRectGetMinX(rightViewController!.view.frame)
        default:
            break
        }
    }
    
    // MARK: - DVSlideMenuControllerDelegate Methods
//    optional func dvSlideMenuControllerWillShowLeftPanel()
//    optional func dvSlideMenuControllerWillShowRightPanel()
//    optional func dvSlideMenuControllerDidShowLeftPanel()
//    optional func dvSlideMenuControllerDidShowRightPanel()
//    optional func dvSlideMenuControllerWillHideLeftPanel()
//    optional func dvSlideMenuControllerWillHideRightPanel()
//    optional func dvSlideMenuControllerDidHideLeftPanel()
//    optional func dvSlideMenuControllerDidHideRightPanel()
    
    func delegateWillShowLeftPanel() {
        
    }
    
    func delegateWillShowRightPanel() {
        
    }
    
    func delegateDidShowLeftPanel() {
        
    }
    
    func delegateDidShowRightPanel() {
        
    }
    
    func delegateWillHideLeftPanel() {
        
    }
    
    func delegateWillHideRightPanel() {
        
    }
    
    func delegateDidHideLeftPanel() {
        
    }
    
    func delegateDidHideRightPanel() {
        
    }
    
    // MARK: - UIBarButtonItem Methods //
    
    func leftBarButtonAction() {
        if slidePanelCurrentState == .None { toggleLeft() }
        else { hidePanel() }
    }
    
    func rightBarButtonAction() {
        if slidePanelCurrentState == .None { toggleRight() }
        else { hidePanel() }
    }
}

extension UIViewController {
    func dvSlideMenuController() -> DVSlideMenuController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is DVSlideMenuController {
                return viewController as? DVSlideMenuController
            }
            viewController = viewController?.parentViewController
        }
        return nil
    }
    
    func addLeftToggleButtonWithImage(#imageName: String) {
        var leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        leftButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        leftButton.addTarget(self, action: Selector("toggleLeftPanel"), forControlEvents: UIControlEvents.TouchUpInside)
        var leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
    }
    
    func addRightToggleButtonWithImage(#imageName: String) {
        var rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        rightButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        rightButton.addTarget(self, action: Selector("toggleRightPanel"), forControlEvents: UIControlEvents.TouchUpInside)
        var rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: true)
    }
    
    func addLeftToggleButtonWithTitle(#title: String) {
        var leftBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("toggleLeftPanel"))
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
    }
    
    func addRightToggleButtonWithTitle(#title: String) {
        var rightBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("toggleRightPanel"))
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: true)
    }
    
    func toggleLeftPanel() {
        dvSlideMenuController()?.leftBarButtonAction()
    }
    
    func toggleRightPanel() {
        dvSlideMenuController()?.rightBarButtonAction()
    }
    
    func hideThisPanel() {
        dvSlideMenuController()?.hidePanel()
    }
}


