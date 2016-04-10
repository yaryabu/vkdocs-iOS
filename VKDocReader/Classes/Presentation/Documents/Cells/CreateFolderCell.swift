//
//  CreateFolderCell.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 27/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class CreateFolderCell: TableViewCell {
    static let cellIdentifier = "CreateFolderCell"
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "CREATE_FOLDERS".localized
        }
    }
}
