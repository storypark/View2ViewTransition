//
//  DismissAnimationController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Elements

    public weak var transitionController: TransitionController?
    
    public var transitionDuration: TimeInterval = 0.5
    
    public var usingSpringWithDamping: CGFloat = 0.7
    
    public var initialSpringVelocity: CGFloat = 0.0
    
    public var animationOptions: UIViewAnimationOptions = .allowUserInteraction
    
    public var usingSpringWithDampingCancelling: CGFloat = 1.0
    
    public var initialSpringVelocityCancelling: CGFloat = 0.0
    
    public var animationOptionsCancelling: UIViewAnimationOptions = .allowUserInteraction

    fileprivate(set) var initialView: UIView!
    
    fileprivate(set) var destinationView: UIView!
    
    fileprivate(set) var initialFrame: CGRect!
    
    fileprivate(set) var destinationFrame: CGRect!
    
    fileprivate(set) var initialTransitionView: UIView!
    
    fileprivate(set) var destinationTransitionView: UIView!

    // MARK: Transition
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionController = transitionController else { return }
        
        // Get ViewControllers and Container View
        let from: String = UITransitionContextViewControllerKey.from.rawValue
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: from)) as? View2ViewTransitionPresented, fromViewController is UIViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: from))))")
            }
            return
        }
        let to: String = UITransitionContextViewControllerKey.to.rawValue
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: to)) as? View2ViewTransitionPresenting, toViewController is UIViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: from))))")
            }
            return
        }
        
        if transitionController.debuging {
            debugPrint("View2ViewTransition << Will Dismiss")
            debugPrint(" Presented view controller: \(fromViewController)")
            debugPrint(" Presenting view controller: \(toViewController)")
        }
        
        let containerView = transitionContext.containerView
        
        // Add To,FromViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        toViewControllerView.frame = transitionContext.finalFrame(for: toViewController as! UIViewController)
        toViewControllerView.layoutIfNeeded()
        let fromViewControllerView: UIView = (fromViewController as! UIViewController).view
        containerView.addSubview(fromViewControllerView)
        
        // This condition is to prevent getting white screen at dismissing when multiple view controller are presented.
        let isNeedToControlToViewController: Bool = toViewControllerView.superview == nil
        if isNeedToControlToViewController {
            containerView.addSubview(toViewControllerView)
            containerView.sendSubview(toBack: toViewControllerView)
        }
        
        fromViewController.prepareDestinationView(userInfo: transitionController.userInfo, isPresenting: false)
        destinationView = fromViewController.destinationView(userInfo: transitionController.userInfo, isPresenting: false)
        destinationFrame = fromViewController.destinationFrame(userInfo: transitionController.userInfo, isPresenting: false)
        
        toViewController.prepareInitialView(userInfo: transitionController.userInfo, isPresenting: false)
        initialView = toViewController.initialView(userInfo: transitionController.userInfo, isPresenting: false)
        initialFrame = toViewController.initialFrame(userInfo: transitionController.userInfo, isPresenting: false)

        // Create Snapshot from Destination View
        destinationTransitionView = UIImageView(image: destinationView.snapshotImage())
        destinationTransitionView.clipsToBounds = true
        destinationTransitionView.contentMode = .scaleAspectFill
        
        initialTransitionView = UIImageView(image: initialView.snapshotImage())
        initialTransitionView.clipsToBounds = true
        initialTransitionView.contentMode = .scaleAspectFill
                
        // Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        // Add Snapshot
        destinationTransitionView.frame = destinationFrame
        containerView.addSubview(destinationTransitionView)
        
        initialTransitionView.frame = destinationFrame
        containerView.addSubview(initialTransitionView)
        initialTransitionView.alpha = 0.0
        
        // Animation
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        
        if transitionContext.isInteractive {
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: usingSpringWithDampingCancelling, initialSpringVelocity: initialSpringVelocityCancelling, options: animationOptionsCancelling, animations: {
                
                fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
         
            }, completion: nil)
            
        } else {
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
                
                self.destinationTransitionView.frame = self.initialFrame
                self.initialTransitionView.frame = self.initialFrame
                self.initialTransitionView.alpha = 1.0
                fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
                
            }, completion: { _ in
                    
                self.destinationTransitionView.removeFromSuperview()
                self.initialTransitionView.removeFromSuperview()
                
                if isNeedToControlToViewController && transitionController.type == .presenting {
                    toViewControllerView.removeFromSuperview()
                }
                
                self.initialView.isHidden = false
                self.destinationView.isHidden = false
                    
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
