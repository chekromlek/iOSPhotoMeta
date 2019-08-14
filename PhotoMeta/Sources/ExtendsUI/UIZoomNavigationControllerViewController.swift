//
//  UIZoomNavigationControllerViewController.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 8/6/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import UIKit

class UIZoomNavigationControllerViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.navigationBar.delegate = self
    }

}

extension UIZoomNavigationControllerViewController: UINavigationBarDelegate {
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let window = UIApplication.shared.delegate?.window {
            var curViewController = window!.rootViewController
            if let navCon = curViewController as? UINavigationController {
                curViewController = navCon.visibleViewController
            }

            if let fullPhotoController = curViewController as? FullPhotoViewController {
                if !fullPhotoController.shouldReturnToCollection() {
                    return false
                }
            }
        }
        DispatchQueue.main.async {
            self.popViewController(animated: true)
        }
        return true
    }
    
}

extension UIZoomNavigationControllerViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let srcDelegate = fromVC as! UIZoomImageViewComponentDelegate
        let destDelegate = toVC as! UIZoomImageViewComponentDelegate
        
        if operation == .push {
            return UIZoomTransitionAnimator(presenting: true, source: srcDelegate, destination: destDelegate)
        } else {
            return UIZoomTransitionAnimator(presenting: false, source: srcDelegate, destination: destDelegate)
        }
    }

}
