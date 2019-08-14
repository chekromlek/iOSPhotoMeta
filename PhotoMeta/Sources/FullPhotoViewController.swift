//
//  FullPhotoViewController.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 8/2/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import UIKit
import Photos

class FullPhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var metadataContainer: UIView!
    
    var asset: PHAsset!
    var contentEditingInput: PHContentEditingInput!
    
    private var imageCenterMaxY: CGFloat!
    private var imageCenterMinY: CGFloat!
    private var metadataCenterMaxY: CGFloat!
    private var metadataCenterMinY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.fetchImage(asset: self.asset, targetSize: nil, contentMode: .aspectFit)
        self.loadMetadata()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.dragged))
        self.imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.imageCenterMaxY = (self.imageView.frame.height/2) + self.imageView.frame.minY
        self.imageCenterMinY = self.imageCenterMaxY - self.metadataContainer.frame.height
        self.metadataCenterMaxY = self.metadataContainer.center.y
        self.metadataCenterMinY = self.metadataCenterMaxY - (self.imageCenterMaxY - self.imageCenterMinY)
    }
    
    func shouldReturnToCollection() -> Bool {
        if self.imageView.center.y == self.imageCenterMaxY {
            return true
        } else {
            self.showMetadata(show: false, velocity: nil)
            return false
        }
    }
    
    @IBAction func removeAllMetadata(_ sender: Any) {
        
        let title = Bundle.main.localizedString(forKey: "DELETE_METADATA_CONFIRM", value: nil, table: "lgn")
        let message = Bundle.main.localizedString(forKey: "DELETE_METADATA_MESSAGE", value: nil, table: "lgn")
        let yes = Bundle.main.localizedString(forKey: "YES", value: nil, table: "lgn")
        let no = Bundle.main.localizedString(forKey: "NO", value: nil, table: "lgn")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: yes, style: .default, handler: self.removeMetadataConfirmed))
        alert.addAction(UIAlertAction(title: no, style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension FullPhotoViewController {
    
    func loadMetadata() {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        self.asset.requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, _) in
            self.contentEditingInput = contentEditingInput
            let filesize = try? contentEditingInput!.fullSizeImageURL!.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize
            let fullImage = CIImage(contentsOf: contentEditingInput!.fullSizeImageURL!)
            let metadata = PhotoMetadata(metadata: fullImage!.properties)
            let photoDetail = self.view as! PhotoDetailView
            photoDetail.renderMetadata(asset: self.asset, filesize: filesize ?? 0, photoMetadata: metadata)
        }
    }
    
    @objc func removeMetadataConfirmed(_ sender: UIAlertAction) {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.init(for: self.asset)
            // remove all sensitive data
            assetRequest.location = CLLocation(latitude: 0, longitude: 0)
            //assetRequest.contentEditingOutput = PHContentEditingOutput(contentEditingInput: self.contentEditingInput)
        }) { (success: Bool, error: Error?) in
            print(success ? "Success" : "Failed")
        }
    }
    
}

extension FullPhotoViewController: UIZoomImageViewComponentDelegate {
    
    func referenceImageView() -> UIImageView? {
        return self.imageView
    }
    
    func referenceImageViewFrame() -> CGRect? {
        return self.imageView.frame
    }
    
}

// gesture & animation
extension FullPhotoViewController: UIGestureRecognizerDelegate {
    
    func showMetadata(show: Bool, velocity aVelocity: CGPoint?) {
        let imageMidY: CGFloat
        let metadataMidY: CGFloat
        if show {
            imageMidY = self.imageCenterMinY
            metadataMidY = self.metadataCenterMinY
        } else {
            imageMidY = self.imageCenterMaxY
            metadataMidY = self.metadataCenterMaxY
        }
        let duration = aVelocity == nil ? 0.3 : TimeInterval(abs(imageMidY/aVelocity!.y))

        UIView.animate(withDuration: duration) {
            self.imageView!.center.y = imageMidY
            self.metadataContainer.center.y = metadataMidY
        }
    }

    @objc func dragged(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:

            let translation = gesture.translation(in: self.imageView)
            let newCenterY = gesture.view!.center.y + translation.y
            
            gesture.view!.center.y = min(self.imageCenterMaxY, max(self.imageCenterMinY, newCenterY))
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.imageView)
            
            self.metadataContainer.center.y = min(self.metadataCenterMaxY, max(self.metadataCenterMinY, self.metadataContainer.center.y + translation.y))
        
        case .ended:
            let velocity = gesture.velocity(in: self.imageView)
            self.showMetadata(show: velocity.y < 0, velocity: velocity)
            
        case .cancelled, .failed:
            let velocity = gesture.velocity(in: self.imageView)
            self.showMetadata(show: velocity.y > 0, velocity: velocity)
 
        default: break
        }
    }
    
}
