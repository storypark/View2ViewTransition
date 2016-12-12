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
    
    public var transitionDuration: TimeInterval = 0.5
    
    public var usingSpringWithDamping: CGFloat = 0.7
    
    public var initialSpringVelocity: CGFloat = 0.0
    
    public var animationOptions: UIViewAnimationOptions = .allowUserInteraction
    
    // MARK: Transition

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionController = transitionController else { return }
        
        // Get ViewControllers and Container View
        let from: String = UITransitionContextViewControllerKey.from.rawValue
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: from)) as? View2ViewTransitionPresenting, fromViewController is UIViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: from))))")
            }
            return
        }
        let to: String = UITransitionContextViewControllerKey.to.rawValue
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: to)) as? View2ViewTransitionPresented, toViewController is UIViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presented view controller (\(transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: to))))")
            }
            return
        }
        
        if transitionController.debuging {
            debugPrint("View2ViewTransition << Will Present")
            debugPrint(" Presenting view controller: \(fromViewController)")
            debugPrint(" Presented view controller: \(toViewController)")
        }
        
        let containerView = transitionContext.containerView

        fromViewController.prepareInitialView(userInfo: transitionController.userInfo, isPresenting: true)
        let initialView: UIView = fromViewController.initialView(userInfo: transitionController.userInfo, isPresenting: true)
        let initialFrame: CGRect = fromViewController.initialFrame(userInfo: transitionController.userInfo, isPresenting: true)
        
        toViewController.prepareDestinationView(userInfo: transitionController.userInfo, isPresenting: true)
        let destinationView: UIView = toViewController.destinationView(userInfo: transitionController.userInfo, isPresenting: true)
        let destinationFrame: CGRect = toViewController.destinationFrame(userInfo: transitionController.userInfo, isPresenting: true)
        
        let initialTransitionView: UIImageView = UIImageView(image: initialView.snapshotImage())
        initialTransitionView.clipsToBounds = true
        initialTransitionView.contentMode = .scaleAspectFill
        
        let destinationTransitionView: UIImageView = UIImageView(image: destinationView.snapshotImage())
        destinationTransitionView.clipsToBounds = true
        destinationTransitionView.contentMode = .scaleAspectFill
        
        // Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        // Add ToViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        toViewControllerView.alpha = CGFloat.leastNormalMagnitude
        containerView.addSubview(toViewControllerView)
        
        // Add Snapshot
        initialTransitionView.frame = initialFrame
        containerView.addSubview(initialTransitionView)
        
        destinationTransitionView.frame = initialFrame
        containerView.addSubview(destinationTransitionView)
        destinationTransitionView.alpha = 0.0
        
        // Animation
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
            
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
                
            initialView.isHidden = false
            destinationView.isHidden = false
                
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
