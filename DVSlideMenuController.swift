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
    
    weak var centerViewController: UIViewController!
    weak var leftViewController: UIViewController?
    weak var rightViewController: UIViewController?
    weak var darkView: UIView?
    weak var delegate: DVSlideMenuControllerDelegate?
    weak var panGesture: UIPanGestureRecognizer?
    weak var darkViewTapGesture: UITapGestureRecognizer?
    
    var slidePanelCurrentState: SlidePanelCurrentState = .None
    
    let deviceWidth = UIScreen.mainScreen().bounds.width
    let deviceHeight = UIScreen.mainScreen().bounds.height
    let distanceOffset: CGFloat = 70
    let shadowOpacity: Float = 0.8
    let timeSliding = 0.3
    let originDarkValue: CGFloat = 0.01
    var darkValue: CGFloat! { didSet { if (darkView != nil) { darkView?.alpha = darkValue! } } }
    
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
            if(slidePanelCurrentState == .Right) {
                rightViewController?.view.frame.origin.x = view.bounds.height - rightViewController!.view.bounds.width
            } else {
                rightViewController?.view.frame.origin.x = view.bounds.height
            }
        } else if toInterfaceOrientation.isPortrait {
            if(slidePanelCurrentState == .Right) {
                rightViewController?.view.frame.origin.x = distanceOffset
            } else {
                rightViewController?.view.frame.origin.x = view.bounds.width
            }
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
    
    func setTheCenterViewController(centerVC: UIViewController) {
        if centerViewController != nil {
            centerViewController.willMoveToParentViewController(nil)
            centerViewController.view.removeFromSuperview()
            centerViewController.removeFromParentViewController()
            centerViewController = nil
            
            if let recognizers = view.gestureRecognizers {
                for recognizer in recognizers {
                    view.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
                }
            }
            
            if self.panGesture != nil { panGesture = nil }
        }
        centerViewController = centerVC
        addCenterViewController()
    }
    
    // MARK: - Animation Methods
    
    func animatePanelByCheckingPositionOfCenterView(canSlide: Bool) {
        if(canSlide) {
            switch(slidePanelCurrentState) {
            case .Left:
                animatePanelWithNewPositionX(newPositionX: 0, showPanel: true)
            case .Right:
                if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                    animatePanelWithNewPositionX(newPositionX: distanceOffset + view.bounds.width - view.bounds.height, showPanel: true)
                } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                    animatePanelWithNewPositionX(newPositionX: distanceOffset, showPanel: true)
                }
            default:
                break
            }
        } else {
            hidePanel()
        }

    }
    
    func animatePanelWithNewPositionX(#newPositionX: CGFloat, showPanel: Bool, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(timeSliding, animations: {
            
            if self.slidePanelCurrentState == .Left {
                var distanceOfCenterToGo = abs(Int(CGRectGetMinX(self.leftViewController!.view.frame))/2)
                //self.view.bringSubviewToFront(self.leftViewController!.view)
                self.leftViewController?.view.frame.origin.x = newPositionX
                self.centerViewController.view.center = CGPoint(x: self.centerViewController.view.center.x + CGFloat(distanceOfCenterToGo), y: self.centerViewController.view.center.y)
            } else if self.slidePanelCurrentState == .Right {
                var distanceOfCenterToGo: Int = 0
                if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                    distanceOfCenterToGo = abs(Int((self.distanceOffset + self.view.bounds.width - self.view.bounds.height) - CGRectGetMinX(self.rightViewController!.view.frame))/2)
                } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                    distanceOfCenterToGo = abs(Int(self.distanceOffset - CGRectGetMinX(self.rightViewController!.view.frame))/2)
                }
                //self.view.bringSubviewToFront(self.rightViewController!.view)
                self.rightViewController?.view.frame.origin.x = newPositionX
                self.centerViewController.view.center = CGPoint(x: self.centerViewController.view.center.x - CGFloat(distanceOfCenterToGo), y: self.centerViewController.view.center.y)
            }
            
            if showPanel { self.darkValue = 0.5 }
            else {
                self.darkValue = 0
                if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                    self.centerViewController!.view.center.x = self.deviceHeight/2
                } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                    self.centerViewController!.view.center.x = self.deviceWidth/2
                }
                
            }
            
            }, completion: { finished in
                if !showPanel {
                    if self.darkView != nil {
                        if let recognizers = self.darkView!.gestureRecognizers {
                            for recognizer in recognizers {
                                self.darkView!.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
                            }
                        }
                        if self.darkViewTapGesture != nil { self.darkViewTapGesture = nil }
                        self.darkView?.removeFromSuperview()
                        self.darkView = nil
                    }
                    
                    if self.delegate != nil {
                        if self.slidePanelCurrentState == .Left {
                            self.delegate?.dvSlideMenuControllerDidHideLeftPanel?()
                        } else if self.slidePanelCurrentState == .Right {
                            self.delegate?.dvSlideMenuControllerDidHideRightPanel?()
                        }
                    }
                    
                    self.darkValue = self.originDarkValue
                    self.slidePanelCurrentState = .None
                    
                } else {
                    if self.delegate != nil {
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
        self.view.bringSubviewToFront(self.leftViewController!.view)
        addShadowOpacityToView(currentView: leftViewController!.view, shadowValue: shadowOpacity)
        addDarkView()
        animatePanelWithNewPositionX(newPositionX: 0, showPanel: true)
    }
    
    func toggleRight() {
        delegate?.dvSlideMenuControllerWillShowRightPanel?()
        slidePanelCurrentState = .Right
        self.view.bringSubviewToFront(self.rightViewController!.view)
        addShadowOpacityToView(currentView: rightViewController!.view, shadowValue: shadowOpacity)
        addDarkView()
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            animatePanelWithNewPositionX(newPositionX: distanceOffset + view.bounds.width - view.bounds.height, showPanel: true)
        } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
            animatePanelWithNewPositionX(newPositionX: distanceOffset, showPanel: true)
        }
    }
    
    func hidePanel() {
        if slidePanelCurrentState == .Left {
            delegate?.dvSlideMenuControllerWillHideLeftPanel?()
            animatePanelWithNewPositionX(newPositionX: -leftViewController!.view.bounds.width, showPanel: false)
            removeShadowOpacityToView(viewToRemove: leftViewController!.view)
        } else if slidePanelCurrentState == .Right {
            delegate?.dvSlideMenuControllerWillHideRightPanel?()
            animatePanelWithNewPositionX(newPositionX: view.bounds.width, showPanel: false)
            removeShadowOpacityToView(viewToRemove: rightViewController!.view)
        }
    }
    
    // MARK: - UIPanGestureRecognizer Methods //
    
    func addPanGestureForSliding() {
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleSlidePanel:")
        centerViewController.view.addGestureRecognizer(panGestureRecognizer)
        self.panGesture = panGestureRecognizer
    }
    
    func handleSlidePanel(panGesture: UIPanGestureRecognizer) {
        let dragFromLeftToRight = panGesture.velocityInView(view).x > 0

        switch(panGesture.state) {
        case .Began:
            if slidePanelCurrentState == .None {
                if dragFromLeftToRight {
                    if leftViewController != nil {
                        delegate?.dvSlideMenuControllerWillShowLeftPanel?()
                        slidePanelCurrentState = .Left
                        self.view.bringSubviewToFront(self.leftViewController!.view)
                        addShadowOpacityToView(currentView: leftViewController!.view, shadowValue: shadowOpacity)
                    }
                } else {
                    if rightViewController != nil {
                        delegate?.dvSlideMenuControllerWillShowRightPanel?()
                        slidePanelCurrentState = .Right
                        self.view.bringSubviewToFront(self.rightViewController!.view)
                        addShadowOpacityToView(currentView: rightViewController!.view, shadowValue: shadowOpacity)
                    }
                }
                addDarkView()
                if darkValue == nil { darkValue = originDarkValue }
            }
            
        case .Changed:
            if slidePanelCurrentState != .None {
                if slidePanelCurrentState == .Left && CGRectGetMinX(leftViewController!.view.frame) <= 0 {
                    if(CGRectGetMinX(leftViewController!.view.frame) >= 0 && dragFromLeftToRight) {
                        return
                    }
                    leftViewController!.view.center.x += panGesture.translationInView(view).x
                    centerViewController!.view.center.x += panGesture.translationInView(view).x/2
                } else if slidePanelCurrentState == .Right && CGRectGetMaxX(rightViewController!.view.frame) >= view.frame.width {
                    if(CGRectGetMaxX(rightViewController!.view.frame) <= view.frame.width && !dragFromLeftToRight) {
                        return
                    }
                    rightViewController!.view.center.x += panGesture.translationInView(view).x
                    centerViewController!.view.center.x += panGesture.translationInView(view).x/2
                }
                panGesture.setTranslation(CGPointZero, inView: view)
                setDarkValue()
            }

        case .Ended:
            if slidePanelCurrentState == .Left {
                let isGreaterThanHalfScreen = leftViewController!.view.center.x > 0
                animatePanelByCheckingPositionOfCenterView(isGreaterThanHalfScreen)
            } else if slidePanelCurrentState == .Right {
                let isGreaterThanHalfScreen = rightViewController!.view.center.x < view.bounds.width
                animatePanelByCheckingPositionOfCenterView(isGreaterThanHalfScreen)
            }
        default:
            break
        }
        
    }
    
    // MARK: - UITapGestureRecognizer Methods
    
    func handleTapGestureOnDarkView(tapGesture: UITapGestureRecognizer) {
        hidePanel()
    }
    
    // MARK: - Supporting Methods //
    
    func addDarkView() {
        if darkView == nil {
            var dView = UIView(frame: centerViewController.view.frame)
            dView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
            dView.backgroundColor = UIColor.blackColor()
            dView.alpha = 0
            dView.userInteractionEnabled = true
            
            var tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGestureOnDarkView:")
            dView.addGestureRecognizer(tapGesture)
            centerViewController.view.addSubview(dView)
            darkViewTapGesture = tapGesture
            darkView = dView
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
        var leftBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("toggleLeftPanel"))
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
    }
    
    func addRightToggleButtonWithTitle(#title: String) {
        var rightBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("toggleRightPanel"))
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


