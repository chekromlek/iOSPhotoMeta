//
//  UIImageView.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 8/1/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import UIKit
import Photos

enum TransitionMode {
    case fromFitToFill
    case fromFillToFit
}

extension UIImageView {
  
    func fetchImage(asset: PHAsset, targetSize: CGSize?, contentMode: PHImageContentMode) {
        let options = PHImageRequestOptions()
        options.version = .original
        
        var requestTargetSize = targetSize
        if targetSize == nil {
            options.resizeMode = .exact
            requestTargetSize = PHImageManagerMaximumSize
        }
        
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: requestTargetSize!,
                                              contentMode: contentMode,
                                              options: options) { (image, _) in
            guard let image = image else { return }
            switch contentMode {
            case .aspectFill:
                self.contentMode = .scaleAspectFill
                
            case .aspectFit:
                self.contentMode = .scaleAspectFit
                
            @unknown default:
                fatalError()
            }
            self.image = image
        }
    }
    
}

