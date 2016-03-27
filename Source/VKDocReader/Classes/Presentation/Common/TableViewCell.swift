//
//  TableViewCell.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 27/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

/**
 Базовый класс для всех ячеек таблиц в МП
 */
class TableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectionView = UIView(frame: self.frame)
        selectionView.backgroundColor = UIColor.vkPaleGreyColor()
        selectedBackgroundView = selectionView
    }
}
