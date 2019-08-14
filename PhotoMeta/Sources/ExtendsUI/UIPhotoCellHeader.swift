//
//  PhotoHeader.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 7/29/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//


import UIKit



class UIPhotoCellHeader: UICollectionReusableView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var deselectAllBtn: UIButton!
    
    var indexPath: IndexPath!
    
    var isSelectEnabled: Bool = false {
        didSet {
            self.selectAllBtn.isHidden = !self.isSelectEnabled
            self.deselectAllBtn.isHidden = self.selectAllBtn.isHidden
            self.updateSelectButtonVisibility()
        }
    }
    
    var isShowSelectAll: Bool = true {
        didSet {
            self.updateSelectButtonVisibility()
        }
    }
    
    private func updateSelectButtonVisibility() {
        if (self.isSelectEnabled) {
            self.selectAllBtn.isHidden = !self.isShowSelectAll
            self.deselectAllBtn.isHidden = self.isShowSelectAll
        }
    }

}
