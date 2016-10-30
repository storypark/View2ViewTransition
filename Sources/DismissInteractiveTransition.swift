//
//  DismissInteractiveTransition.swift
//  CustomTransition
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public class DismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    // MARK: Elements
    
    public var interactionInProgress: Bool = false
    
    public weak var transitionController: TransitionController?
    
    public weak var animationController: DismissAnimationController?
    
    public var initialPanPoint: CGPoint! = CGPoint.zero
    
    private(set) var transitionContext: UIViewControllerContextTransitioning!
    
    // MARK: Gesture
    
    public override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    public func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        guard let transitionController = transitionController else { return }

        if panGestureRecognizer.state == .Began {
            
            interactionInProgress = true
            initialPanPoint = panGestureRecognizer.locationInView(panGestureRecognizer.view)
            
            switch transitionController.type {
            case .Presenting:
                transitionController.presentedViewController.dismissViewControllerAnimated(true, completion: nil)
            case .Pushing:
                transitionController.presentedViewController.navigationController!.popViewControllerAnimated(true)
            }
            
            return
        }
        
        guard let animationController = animationController,
                  destinationTransitionView = animationController.destinationTransitionView,
                  initialTransitionView = animationController.initialTransitionView else { return }
        
        // Get Progress
        let range: Float = Float(UIScreen.mainScreen().bounds.size.width)
        let location: CGPoint = panGestureRecognizer.locationInView(panGestureRecognizer.view)
        let distance: Float = sqrt(powf(Float(initialPanPoint.x - location.x), 2.0) + powf(Float(initialPanPoint.y - location.y), 2.0))
        let progress: CGFloat = CGFloat(fminf(fmaxf((distance / range), 0.0), 1.0))
        
        // Get Translation
        let translation: CGPoint = panGestureRecognizer.translationInView(panGestureRecognizer.view)
        
        switch panGestureRecognizer.state {
            
        case .Changed:
            
            updateInteractiveTransition(progress)
            
            destinationTransitionView.alpha = 1.0
            initialTransitionView.alpha = 0.0
            
            // Affine Transform
            let scale: CGFloat = (1000.0 - CGFloat(distance))/1000.0
            var transform = CGAffineTransformIdentity
            //            transform = CGAffineTransformScale(transform, scale, scale)
            transform = CGAffineTransformTranslate(transform, translation.x/scale, translation.y/scale)
            
            destinationTransitionView.transform = transform
            initialTransitionView.transform = transform
            
        case .Cancelled:
            
            interactionInProgress = false
            transitionContext.cancelInteractiveTransition()
            
        case .Ended:
            
            interactionInProgress = false
            panGestureRecognizer.setTranslation(CGPoint.zero, inView: panGestureRecognizer.view)
            
            if progress < 0.2 {
                
                cancelInteractiveTransition()
                
                let duration: Double = Double(self.duration)*Double(progress)
                UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
                    
                    destinationTransitionView.frame = animationController.destinationFrame
                    initialTransitionView.frame = animationController.destinationFrame
                    
                    }, completion: { _ in
                        
                        // Cancel Transition
                        destinationTransitionView.removeFromSuperview()
                        initialTransitionView.removeFromSuperview()
                        
                        animationController.destinationView.hidden = false
                        animationController.initialView.hidden = false
//                    transitionController.presentingViewController.view.removeFromSuperview()
                        
                        self.transitionContext.completeTransition(false)
                })
                
            } else {
                
                finishInteractiveTransition()
                transitionController.presentingViewController.view.userInteractionEnabled = false
                
                let duration: Double = animationController.transitionDuration
                UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
                    
                    destinationTransitionView.alpha = 0.0
                    initialTransitionView.alpha = 1.0
                    
                    destinationTransitionView.frame = animationController.initialFrame
                    initialTransitionView.frame = animationController.initialFrame
                    
                    }, completion: { _ in
                        
                        if transitionController.type == .Pushing {
                            
                            destinationTransitionView.removeFromSuperview()
                            initialTransitionView.removeFromSuperview()
                            
                            animationController.initialView.hidden = false
                            animationController.destinationView.hidden = false
                        }
                        
                        transitionController.presentingViewController.view.userInteractionEnabled = true
                        animationController.initialView.hidden = false
                        self.transitionContext.completeTransition(true)
                })
            }
            
        default:
            break
        }
    }
}
