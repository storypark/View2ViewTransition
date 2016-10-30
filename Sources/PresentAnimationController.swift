//
//  PresentAnimationController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Elements
    
    public weak var transitionController: TransitionController?
    
    public var transitionDuration: NSTimeInterval = 0.5
    
    public var usingSpringWithDamping: CGFloat = 0.7
    
    public var initialSpringVelocity: CGFloat = 0.0
    
    public var animationOptions: UIViewAnimationOptions = [.CurveEaseInOut, .AllowUserInteraction]
    
    // MARK: Transition

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionController = transitionController else { return }
        
        // Get ViewControllers and Container View
        let from: String = UITransitionContextFromViewControllerKey
        guard let fromViewController = transitionContext.viewControllerForKey(from) as? View2ViewTransitionPresenting where fromViewController is UIViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewControllerForKey(from)))")
            }
            return
        }
        let to: String = UITransitionContextToViewControllerKey
        guard let toViewController = transitionContext.viewControllerForKey(to) as? View2ViewTransitionPresented where toViewController is UIViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presented view controller (\(transitionContext.viewControllerForKey(to)))")
            }
            return
        }
        
        if transitionController.debuging {
            debugPrint("View2ViewTransition << Will Present")
            debugPrint(" Presenting view controller: \(fromViewController)")
            debugPrint(" Presented view controller: \(toViewController)")
        }
        
        let containerView = transitionContext.containerView()

        fromViewController.prepareInitialView(transitionController.userInfo, isPresenting: true)
        let initialView: UIView = fromViewController.initialView(transitionController.userInfo, isPresenting: true)
        let initialFrame: CGRect = fromViewController.initialFrame(transitionController.userInfo, isPresenting: true)
        
        toViewController.prepareDestinationView(transitionController.userInfo, isPresenting: true)
        let destinationView: UIView = toViewController.destinationView(transitionController.userInfo, isPresenting: true)
        let destinationFrame: CGRect = toViewController.destinationFrame(transitionController.userInfo, isPresenting: true)
        
        let initialTransitionView: UIImageView = UIImageView(image: initialView.snapshotImage())
        initialTransitionView.clipsToBounds = true
        initialTransitionView.contentMode = .ScaleAspectFill
        
        let destinationTransitionView: UIImageView = UIImageView(image: destinationView.snapshotImage())
        destinationTransitionView.clipsToBounds = true
        destinationTransitionView.contentMode = .ScaleAspectFill
        
        // Hide Transisioning Views
        initialView.hidden = true
        destinationView.hidden = true
        
        // Add ToViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        toViewControllerView.alpha = CGFloat.min
        containerView.addSubview(toViewControllerView)
        
        // Add Snapshot
        initialTransitionView.frame = initialFrame
        containerView.addSubview(initialTransitionView)
        
        destinationTransitionView.frame = initialFrame
        containerView.addSubview(destinationTransitionView)
        destinationTransitionView.alpha = 0.0
        
        // Animation
        let duration: NSTimeInterval = transitionDuration(transitionContext)
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
            
            destinationTransitionView.frame = destinationFrame
            destinationTransitionView.alpha = 1.0
            if initialTransitionView.frame.width < destinationFrame.width &&
                initialTransitionView.frame.height < destinationFrame.height {
                initialTransitionView.frame = destinationFrame
            } else {
                initialTransitionView.center = destinationTransitionView.center
            }
            initialTransitionView.alpha = 0.0
            toViewControllerView.alpha = 1.0
            
        }, completion: { _ in
                
            initialTransitionView.removeFromSuperview()
            destinationTransitionView.removeFromSuperview()
                
            initialView.hidden = false
            destinationView.hidden = false
                
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}
