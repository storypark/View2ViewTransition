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

    public weak var transitionController: TransitionController!
    
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
    
    private(set) var initialTransitionView: UIView?
    
    private(set) var destinationTransitionView: UIView?

    // MARK: Transition
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Get ViewControllers and Container View
        let from: String = UITransitionContextFromViewControllerKey
        guard let fromViewController = transitionContext.viewControllerForKey(from) as? View2ViewTransitionPresented where fromViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewControllerForKey(from)))")
            }
            return
        }
        let to: String = UITransitionContextToViewControllerKey
        guard let toViewController = transitionContext.viewControllerForKey(to) as? View2ViewTransitionPresenting where toViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewControllerForKey(from)))")
            }
            return
        }
        
        if self.transitionController.debuging {
            debugPrint("View2ViewTransition << Will Dismiss")
            debugPrint(" Presented view controller: \(fromViewController)")
            debugPrint(" Presenting view controller: \(toViewController)")
        }
        
        let containerView = transitionContext.containerView()
        
        fromViewController.prepareDestinationView(self.transitionController.userInfo, isPresenting: false)
        self.destinationView = fromViewController.destinationView(self.transitionController.userInfo, isPresenting: false)
        self.destinationFrame = fromViewController.destinationFrame(self.transitionController.userInfo, isPresenting: false)
        
        toViewController.prepareInitialView(self.transitionController.userInfo, isPresenting: false)
        self.initialView = toViewController.initialView(self.transitionController.userInfo, isPresenting: false)
        self.initialFrame = toViewController.initialFrame(self.transitionController.userInfo, isPresenting: false)
        
        // Create Snapshot from Destination View
        self.destinationTransitionView = UIImageView(image: destinationView.snapshotImage())
        self.destinationTransitionView!.clipsToBounds = true
        self.destinationTransitionView!.contentMode = .ScaleAspectFill
        
        self.initialTransitionView = UIImageView(image: initialView.snapshotImage())
        self.initialTransitionView!.clipsToBounds = true
        self.initialTransitionView!.contentMode = .ScaleAspectFill
                
        // Hide Transisioning Views
        initialView.hidden = true
        destinationView.hidden = true
        
        // Add To,FromViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        let fromViewControllerView: UIView = (fromViewController as! UIViewController).view
        containerView.addSubview(fromViewControllerView)
        
        // This condition is to prevent getting white screen at dismissing when multiple view controller are presented.
        let isNeedToControlToViewController: Bool = toViewControllerView.superview == nil
        if isNeedToControlToViewController {
            containerView.addSubview(toViewControllerView)
            containerView.sendSubviewToBack(toViewControllerView)
        }
        
        // Add Snapshot
        self.destinationTransitionView!.frame = destinationFrame
        containerView.addSubview(self.destinationTransitionView!)
        
        self.initialTransitionView!.frame = destinationFrame
        containerView.addSubview(self.initialTransitionView!)
        self.initialTransitionView!.alpha = 0.0
        
        // Animation
        let duration: NSTimeInterval = transitionDuration(transitionContext)
        
        if transitionContext.isInteractive() {
            
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDampingCancelling, initialSpringVelocity: self.initialSpringVelocityCancelling, options: self.animationOptionsCancelling, animations: {
                
                fromViewControllerView.alpha = CGFloat.min
         
            }, completion: nil)
            
        } else {
            
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDamping, initialSpringVelocity: self.initialSpringVelocity, options: self.animationOptions, animations: {
                
                self.destinationTransitionView!.frame = self.initialFrame
                self.initialTransitionView!.frame = self.initialFrame
                self.initialTransitionView!.alpha = 1.0
                fromViewControllerView.alpha = CGFloat.min
                
            }, completion: { _ in
                    
                self.destinationTransitionView!.removeFromSuperview()
                self.initialTransitionView!.removeFromSuperview()
                
                if isNeedToControlToViewController && self.transitionController.type == .Presenting {
                    toViewControllerView.removeFromSuperview()
                }
                
                self.initialView.hidden = false
                self.destinationView.hidden = false
                    
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}
