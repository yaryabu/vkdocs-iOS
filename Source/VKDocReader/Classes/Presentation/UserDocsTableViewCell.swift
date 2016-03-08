//
//  UserDocsTableViewCell.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

import RealmSwift

class UserDocsTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "UserDocsTableViewCell"
    
    private let dateFormat = "dd MMMM yyyy в HH:mm"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sizeDateLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var extensionLabel: UILabel!
    
    func configureCell(document: Document) {
        self.titleLabel.text = document.title
        let dateString = DateFormatter().stringFromTimestamp(Int(document.date)!, formatString: self.dateFormat)
        
        self.sizeDateLabel.text = "\(Int(document.size)!/1024/1024) мб, \(dateString)"
        if let url = document.smallThumbnailUrlString {
            ServiceLayer.sharedServiceLayer.imageService.getImage(url, completion: { (image) -> Void in
                self.thumbnailImageView.image = image
                self.thumbnailImageView.hidden = false
                self.extensionLabel.hidden = true
                }, failure: { (error) -> Void in
                    print(error)
            })
        } else {
            self.extensionLabel.text = document.ext
            self.thumbnailImageView.hidden = true
            self.extensionLabel.hidden = false
        }
    }
    
}
