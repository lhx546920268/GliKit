//
//  RootListCell.swift
//  GliKitDemo
//
//  Created by 罗海雄 on 2021/3/4.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

import UIKit

class RootListCell: GKTableViewSwipeCell {
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (make) in
            make?.leading.equalTo()(15)
            make?.centerX.equalTo()
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print("发送")
        NotificationCenter.default.post(name: Notification.Name("xxxxx你好"), object: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
