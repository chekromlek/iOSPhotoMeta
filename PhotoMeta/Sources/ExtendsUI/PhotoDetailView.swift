//
//  PhotoDetailView.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 8/7/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var metadataContainer: UIView!
    
    // metadata reference
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var photoSpec: UILabel!
    @IBOutlet weak var captureAt: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var coordinate: UILabel!
    @IBOutlet weak var model: UILabel!
    @IBOutlet weak var removeMetadataBtn: UIButton!
    
    @IBOutlet weak var constrainTop: NSLayoutConstraint!

    override func layoutSubviews() {
        super.layoutSubviews()
        if let image = self.imageView.image {
            let viewHeight = self.frame.size.height - self.safeAreaInsets.top
            let viewRatio = self.frame.size.width / viewHeight
            let imageRatio = image.size.width / image.size.height
            
            if viewRatio > imageRatio {
                // fill height, top frame is bottom view
                self.constrainTop.constant = self.frame.height - self.safeAreaInsets.top
                
            } else {
                // fill width
                let imageHeight = self.frame.width / imageRatio
                let top = imageHeight + (viewHeight - imageHeight)/2
                self.constrainTop.constant = top
            }
        }
    }
    
    func renderMetadata(asset: PHAsset, filesize: Int, photoMetadata metadata: PhotoMetadata) {
        self.coordinate.text = metadata.coordinate()
        self.captureAt.text = metadata.captureAt()
        self.photoSpec.text = metadata.spec(filesize: filesize)
        self.model.text = metadata.model()
        self.fileName.text = asset.originalFilename
        metadata.address(label: self.address)
        
        if asset.canPerform(PHAssetEditOperation.properties) && metadata.isSensitiveMetaAvailable() {
            self.removeMetadataBtn.isEnabled = true
            self.removeMetadataBtn.isHidden = false
        } else {
            self.removeMetadataBtn.isEnabled = false
            self.removeMetadataBtn.isHidden = true
        }
    }
    
}
