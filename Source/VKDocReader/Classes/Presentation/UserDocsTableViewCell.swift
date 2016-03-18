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
    
    private let loadButtonDefaultText = "Load"
    private let loadButtonSavedDocumentText = "Saved"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sizeDateLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var extensionLabel: UILabel!
    @IBOutlet weak var loadButton: UIButton!
    
    func configureCell(document: Document) {
        self.titleLabel.text = document.title
        let dateString = DateFormatter().stringFromTimestamp(Int(document.date)!, formatString: self.dateFormat)
        self.sizeDateLabel.text = "\(Int(document.size)!/1000/1000) МБ, \(dateString)"
        
        if document.thumbnailData != nil {
            self.thumbnailImageView.image = UIImage(data: document.thumbnailData!)
            self.thumbnailImageView.hidden = false
            self.extensionLabel.hidden = true
        } else if let url = document.thumbnailUrlString {
            ServiceLayer.sharedServiceLayer.imageService.getImage(url, completion: { (data) -> Void in
                self.thumbnailImageView.image = UIImage(data: data)
                self.thumbnailImageView.hidden = false
                self.extensionLabel.hidden = true
                try! Realm().write({ () -> Void in
                    document.thumbnailData = data
                })
                }, failure: { (error) -> Void in
                    print(error)
            })
        } else {
            self.extensionLabel.text = document.ext
            self.thumbnailImageView.hidden = true
            self.extensionLabel.hidden = false
        }
        
        if document.fileName != nil {
            self.loadButton.setTitle(loadButtonSavedDocumentText, forState: .Normal)
        } else if ServiceLayer.sharedServiceLayer.docsService.downloadExists(document) == false {
            self.loadButton.setTitle(loadButtonDefaultText, forState: .Normal)
        } else {
            ServiceLayer.sharedServiceLayer.docsService.downloadDocument(document, progress: { (totalRead, bytesToRead) -> Void in
                let percent = Int((Double(totalRead)/Double(bytesToRead))*100)
                self.loadButton.setTitle(String(percent), forState: .Normal)
                }, completion: { (document) -> Void in
                    self.loadButton.setTitle(self.loadButtonSavedDocumentText, forState: .Normal)
                }, failure: { (error) -> Void in
                    self.loadButton.setTitle(self.loadButtonDefaultText, forState: .Normal)
            })
        }
        
        
        
    }
    
}
