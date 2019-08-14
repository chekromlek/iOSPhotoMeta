//
//  PhotoMetadata.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 8/1/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import Photos

class PhotoDataCollection {
    
    var headerTitle: String?
    var assets: [PHAsset]
    var selectAll: Bool = true
    
    init(header: String, asset: PHAsset) {
        self.headerTitle = header
        self.assets = [asset]
    }
    
}
