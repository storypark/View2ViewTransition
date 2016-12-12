//
//  DismissInteractiveTransition.swift
//  CustomTransition
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

open class DismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    // MARK: Elements
    
    open var interactionInProgress: Bool = false
    
    open weak var transitionController: TransitionController?
    
    open weak var animationController: DismissAnimationController?
    
    open var initialPanPoint: CGPoint! = CGPoint.zero
    
    fileprivate(set) var transitionContext: UIViewControllerContextTransitioning!
    
    // MARK: Gesture
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    open func handlePanGesture(recognizer panGestureRecognizer: UIPanGestureRecognizer) {
        guard let transitionController = transitionController else { return }

        if panGestureRecognizer.state == .began {
            
            interactionInProgress = true
            initialPanPoint = panGestureRecognizer.location(in: panGestureRecognizer.view)
            
            switch transitionController.type {
            case .presenting:
                transitionController.presentedViewController.dismiss(animated: true, completion: nil)
            case .pushing:
                transitionController.presentedViewController.navigationController!.popViewController(animated: true)
            }
            
            return
        }
        
        guard let animationController = animationController,
                  let destinationTransitionView = animationController.destinationTransitionView,
                  let initialTransitionView = animationController.initialTransitionView else { return }
        
        // Get Progress
        let range: Float = Float(UIScreen.main.bounds.size.width)
        let location: CGPoint = panGestureRecognizer.location(in: panGestureRecognizer.view)
        let distance: Float = sqrt(powf(Float(initialPanPoint.x - location.x), 2.0) + powf(Float(initialPanPoint.y - location.y), 2.0))
        let progress: CGFloat = CGFloat(fminf(fmaxf((distance / range), 0.0), 1.0))
        
        // Get Translation
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        
        switch panGestureRecognizer.state {
            
        case .changed:
            
            update(progress)
            
            destinationTransitionView.alpha = 1.0
            initialTransitionView.alpha = 0.0
            
            // Affine Transform
            let scale: CGFloat = (1000.0 - CGFloat(distance))/1000.0
            var transform = CGAffineTransform.identity
            //            transform = CGAffineTransformScale(transform, scale, scale)
            transform = transform.translatedBy(x: translation.x/scale, y: translation.y/scale)
            
            destinationTransitionView.transform = transform
            initialTransitionView.transform = transform
            
        case .cancelled:
            
            interactionInProgress = false
            transitionContext.cancelInteractiveTransition()
            
        case .ended:
            
            interactionInProgress = false
            panGestureRecognizer.setTranslation(CGPoint.zero, in: panGestureRecognizer.view)
            
            if progress < 0.2 {
                
                cancel()
                
                let duration: Double = Double(self.duration)*Double(progress)
                UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: {
                    
                    destinationTransitionView.frame = animationController.destinationFrame
                    initialTransitionView.frame = animationController.destinationFrame
                    
                    }, completion: { _ in
                        
                        // Cancel Transition
                        destinationTransitionView.removeFromSuperview()
                        initialTransitionView.removeFromSuperview()
                        
                        animationController.destinationView.isHidden = false
                        animationController.initialView.isHidden = false
//                    transitionController.presentingViewController.view.removeFromSuperview()
                        
                        self.transitionContext.completeTransition(false)
                })
                
            } else {
                
                finish()
                transitionController.presentingViewController.view.isUserInteractionEnabled = false
                
                let duration: Double = animationController.transitionDuration
                UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: {
                    
                    destinationTransitionView.alpha = 0.0
                    initialTransitionView.alpha = 1.0
                    
                    destinationTransitionView.frame = animationController.initialFrame
                    initialTransitionView.frame = animationController.initialFrame
                    
                    }, completion: { _ in
                        
                        if transitionController.type == .pushing {
                            
                            destinationTransitionView.removeFromSuperview()
                            initialTransitionView.removeFromSuperview()
                            
                            animationController.initialView.isHidden = false
                            animationController.destinationView.isHidden = false
                        }
                        
                        transitionController.presentingViewController.view.isUserInteractionEnabled = true
                        animationController.initialView.isHidden = false
                        self.transitionContext.completeTransition(true)
                })
            }
            
        default:
            break
        }
    }
}
