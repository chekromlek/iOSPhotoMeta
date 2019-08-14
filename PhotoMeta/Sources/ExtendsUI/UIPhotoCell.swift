//
//  PhotoCell.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 7/27/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import Foundation
import UIKit
import Photos

class UIPhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var highlight: UIView!
    @IBOutlet weak var selecticon: UIImageView!
    @IBOutlet weak var sizeInfoBg: UIView!
    @IBOutlet weak var sizeInfo: UILabel!
    
    override var isSelected: Bool {
        didSet {
            self.highlight.isHidden = !self.isSelected
            self.selecticon.isHidden = self.highlight.isHidden
            self.sizeInfo.isHidden = self.highlight.isHidden
            self.sizeInfoBg.isHidden = self.highlight.isHidden
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor(red: 22, green: 130, blue: 98, alpha: 1)
        self.sizeInfoBg.layer.borderColor = color.cgColor
        self.sizeInfoBg.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func setMeta(asset: PHAsset) {
        self.sizeInfo.text = "\(asset.pixelWidth)x\(asset.pixelHeight)"
    }

}
