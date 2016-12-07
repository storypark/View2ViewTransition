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
    
    public var transitionDuration: NSTimeInterval = 0.5
    
    public var usingSpringWithDamping: CGFloat = 0.7
    
    public var initialSpringVelocity: CGFloat = 0.0
    
    public var animationOptions: UIViewAnimationOptions = [.CurveEaseInOut, .AllowUserInteraction]
    
    public var usingSpringWithDampingCancelling: CGFloat = 1.0
    
    public var initialSpringVelocityCancelling: CGFloat = 0.0
    
    public var animationOptionsCancelling: UIViewAnimationOptions = [.CurveEaseInOut, .AllowUserInteraction]

    private(set) var initialView: UIView!
    
    private(set) var destinationView: UIView!
    
    private(set) var initialFrame: CGRect!
    
    private(set) var destinationFrame: CGRect!
    
    private(set) var initialTransitionView: UIView!
    
    private(set) var destinationTransitionView: UIView!

    // MARK: Transition
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionController = transitionController else { return }
        
        // Get ViewControllers and Container View
        let from: String = UITransitionContextFromViewControllerKey
        guard let fromViewController = transitionContext.viewControllerForKey(from) as? View2ViewTransitionPresented where fromViewController is UIViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewControllerForKey(from)))")
            }
            return
        }
        let to: String = UITransitionContextToViewControllerKey
        guard let toViewController = transitionContext.viewControllerForKey(to) as? View2ViewTransitionPresenting where toViewController is UIViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewControllerForKey(from)))")
            }
            return
        }
        
        if transitionController.debuging {
            debugPrint("View2ViewTransition << Will Dismiss")
            debugPrint(" Presented view controller: \(fromViewController)")
            debugPrint(" Presenting view controller: \(toViewController)")
        }
        
        let containerView = transitionContext.containerView()
        
        // Add To,FromViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        toViewControllerView.frame = transitionContext.finalFrameForViewController(toViewController as! UIViewController)
        toViewControllerView.layoutIfNeeded()
        let fromViewControllerView: UIView = (fromViewController as! UIViewController).view
        containerView.addSubview(fromViewControllerView)
        
        // This condition is to prevent getting white screen at dismissing when multiple view controller are presented.
        let isNeedToControlToViewController: Bool = toViewControllerView.superview == nil
        if isNeedToControlToViewController {
            containerView.addSubview(toViewControllerView)
            containerView.sendSubviewToBack(toViewControllerView)
        }
        
        fromViewController.prepareDestinationView(transitionController.userInfo, isPresenting: false)
        destinationView = fromViewController.destinationView(transitionController.userInfo, isPresenting: false)
        destinationFrame = fromViewController.destinationFrame(transitionController.userInfo, isPresenting: false)
        
        toViewController.prepareInitialView(transitionController.userInfo, isPresenting: false)
        initialView = toViewController.initialView(transitionController.userInfo, isPresenting: false)
        initialFrame = toViewController.initialFrame(transitionController.userInfo, isPresenting: false)

        // Create Snapshot from Destination View
        destinationTransitionView = UIImageView(image: destinationView.snapshotImage())
        destinationTransitionView.clipsToBounds = true
        destinationTransitionView.contentMode = .ScaleAspectFill
        
        initialTransitionView = UIImageView(image: initialView.snapshotImage())
        initialTransitionView.clipsToBounds = true
        initialTransitionView.contentMode = .ScaleAspectFill
                
        // Hide Transisioning Views
        initialView.hidden = true
        destinationView.hidden = true
        
        // Add Snapshot
        destinationTransitionView.frame = destinationFrame
        containerView.addSubview(destinationTransitionView)
        
        initialTransitionView.frame = destinationFrame
        containerView.addSubview(initialTransitionView)
        initialTransitionView.alpha = 0.0
        
        // Animation
        let duration: NSTimeInterval = transitionDuration(transitionContext)
        
        if transitionContext.isInteractive() {
            
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: usingSpringWithDampingCancelling, initialSpringVelocity: initialSpringVelocityCancelling, options: animationOptionsCancelling, animations: {
                
                fromViewControllerView.alpha = CGFloat.min
         
            }, completion: nil)
            
        } else {
            
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
                
                self.destinationTransitionView.frame = self.initialFrame
                self.initialTransitionView.frame = self.initialFrame
                self.initialTransitionView.alpha = 1.0
                fromViewControllerView.alpha = CGFloat.min
                
            }, completion: { _ in
                    
                self.destinationTransitionView.removeFromSuperview()
                self.initialTransitionView.removeFromSuperview()
                
                if isNeedToControlToViewController && transitionController.type == .Presenting {
                    toViewControllerView.removeFromSuperview()
                }
                
                self.initialView.hidden = false
                self.destinationView.hidden = false
                    
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}
