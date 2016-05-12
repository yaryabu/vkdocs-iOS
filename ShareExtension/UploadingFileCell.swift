//
//  UploadingFileCell.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 03/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class UploadingFileCell: UITableViewCell {
    static let cellIdentifier = "UploadingFileCell"
    
    @IBOutlet weak var fileNameLabel: UILabel!
    
    @IBOutlet weak var progressLabel: UILabel!
}
