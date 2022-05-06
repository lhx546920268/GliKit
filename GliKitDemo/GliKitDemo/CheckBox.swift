//
//  CheckBox.swift
//  GliKitDemo
//
//  Created by 罗海雄 on 2021/3/4.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    
    var value: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitle("", for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
