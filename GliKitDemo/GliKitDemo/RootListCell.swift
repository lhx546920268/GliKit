//
//  RootListCell.swift
//  GliKitDemo
//
//  Created by 罗海雄 on 2021/3/4.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

import UIKit

class RootListCell: GKTableViewSwipeCell {
    var abc = false
    @objc
    public let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (make) in
            make?.leading.equalTo()(15)
            make?.centerY.equalTo()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc enum UserType: Int {
    
    case member
    case normal
}
