//
//  CGFloat.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 8/12/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import UIKit

extension CGFloat {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : "\(self)"
    }
}
