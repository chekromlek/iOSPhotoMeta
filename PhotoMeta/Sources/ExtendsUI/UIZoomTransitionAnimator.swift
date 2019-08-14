//
//  UIZoomTransitionAnimator.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 8/3/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import UIKit

protocol UIZoomImageViewComponentDelegate {
    
    func referenceImageView() -> UIImageView?
    
    func referenceImageViewFrame() -> CGRect?
    
}

class UIZoomTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let presenting: Bool
    
    private let sourceControllerDelegate: UIZoomImageViewComponentDelegate!
    private let destinationControllerDelegate: UIZoomImageViewComponentDelegate!
    
    private var animateImageView: UIImageView?
    
    init(presenting: Bool, source srcDelegate: UIZoomImageViewComponentDelegate, destination destDelegate: UIZoomImageViewComponentDelegate) {
        
        self.presenting = presenting
        self.sourceControllerDelegate = srcDelegate
        self.destinationControllerDelegate = destDelegate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.presenting ? 0.4 : 0.55
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let fromImageView = self.sourceControllerDelegate.referenceImageView(),
            let fromImageViewFrame = self.sourceControllerDelegate.referenceImageViewFrame(),
            let toImageView = self.destinationControllerDelegate.referenceImageView(),
            var toImageViewFrame = self.destinationControllerDelegate.referenceImageViewFrame()
            else {
                return
        }
        
        let container = transitionContext.containerView
        if self.animateImageView == nil {
            self.animateImageView = UIImageView(image: fromImageView.image)
            self.animateImageView!.clipsToBounds = true
        }
        
        toImageView.isHidden = true
        fromImageView.isHidden = true
        
        var fadeOutView: UIView!
        var fadeInView: UIView!
        
        var animateOpts: UIView.AnimationOptions
        
        if presenting {
            
            // Zoom in
            self.animateImageView!.contentMode = .scaleAspectFit
            container.insertSubview(toView, belowSubview: fromView)
            container.addSubview(self.animateImageView!)
            
            self.animateImageView!.frame = fromImageViewFrame
            
            fadeOutView = fromView
            fadeInView = toView
            
            animateOpts = [UIView.AnimationOptions.transitionCrossDissolve]
            
            let viewHeight = toView.frame.size.height - toView.safeAreaInsets.top
            let viewRatio = toView.frame.size.width / viewHeight
            let imageRatio = fromImageView.image!.size.width / fromImageView.image!.size.height
            let touchesSides = (imageRatio > viewRatio)
            
            if touchesSides {
                let height = toView.frame.width / imageRatio
                let yPoint = toView.frame.minY + toView.safeAreaInsets.top + (viewHeight - height) / 2
                toImageViewFrame = CGRect(x: 0, y: yPoint, width: toView.frame.width, height: height)
            } else {
                let width = viewHeight * imageRatio
                let xPoint = toView.frame.minX + (toView.frame.width - width) / 2
                toImageViewFrame = CGRect(x: xPoint, y: toView.safeAreaInsets.top, width: width, height: viewHeight)
            }
            
        } else {
            
            // Zoom out
            
            // calculate initial imageview frame
            let viewHeight = toView.frame.size.height - toView.safeAreaInsets.top
            let viewRatio = toView.frame.size.width / viewHeight
            let imageRatio = fromImageView.image!.size.width / fromImageView.image!.size.height
            
            if viewRatio < imageRatio {
                
                // height adjustment
                let actualHeight = toView.frame.size.width / imageRatio
                self.animateImageView!.frame = CGRect(x: fromImageView.frame.minX,
                                                      y: toView.safeAreaInsets.top + (viewHeight - actualHeight)/2,
                                                      width: fromImageView.frame.width,
                                                      height: actualHeight)
                
            } else if (fromImageView.image?.size.height)! > viewHeight {
                
                // width adjustment
                let actualWidth = imageRatio * viewHeight
                self.animateImageView!.frame = CGRect(x: (toView.frame.size.width - actualWidth)/2,
                                                      y: fromImageView.frame.minY,
                                                      width: actualWidth,
                                                      height: fromImageView.frame.height)
                
            } else {
                self.animateImageView!.frame = fromImageViewFrame
            }
            
            self.animateImageView!.contentMode = .scaleAspectFill
            container.addSubview(self.animateImageView!)
            container.insertSubview(toView, belowSubview: fromView)
            
            fadeOutView = fromView
            fadeInView = toView
            
            animateOpts = []
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: animateOpts,
                       animations: {
                        
                        fadeInView.alpha = 1
                        fadeOutView.alpha = 0
                        
                        self.animateImageView?.frame = toImageViewFrame
                        
        }, completion: { (Bool) in
            
            self.animateImageView?.removeFromSuperview()
            toImageView.isHidden = false
            fromImageView.isHidden = false
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}
