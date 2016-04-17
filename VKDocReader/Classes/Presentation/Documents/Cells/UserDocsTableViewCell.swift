//
//  UserDocsTableViewCell.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

import Alamofire
import AlamofireImage
import RealmSwift

class UserDocsTableViewCell: TableViewCell {
    
    static let cellIdentifier = "UserDocsTableViewCell"
    
    private let dateFormat = "dd MMMM yyyy в HH:mm"
    
    var document: Document?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sizeDateLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var extensionLabel: UILabel!
    
    //Поскольку кнопка загрузки является accessoryView, появляются самые интересные
    //проблемы реиспользования ячеек и вызова closure на них (к примеру, прогресс загрузки).
    //Поэтому при каждом появлении ячейки на экране ей выдается новая кнопка, а не старая.
    var newButton: UIButton {
        get {
            self.accessoryView = nil
            let button = UIButton(type: UIButtonType.Custom)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            button.addTarget(self, action: #selector(UserDocsTableViewCell.buttonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.accessoryView = button
            
            button.titleLabel?.font = UIFont.loadingPercentFont()
            button.titleLabel?.textColor = UIColor.vkDuskBlueColor()
            button.titleLabel?.tintColor = UIColor.vkDuskBlueColor()
            button.setTitleColor(UIColor.vkDuskBlueColor(), forState: .Normal)
            return button
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var accessoryFrame = accessoryView?.frame
        accessoryFrame?.origin.x += 10
        accessoryView?.frame = accessoryFrame!
    }
    
    func configureCell(document: Document, isSearchResult: Bool, hideButton: Bool) {
        self.document = document
        self.titleLabel.text = document.title
        let dateString = DateFormatter.stringFromTimestamp(Int(document.date)!, formatString: self.dateFormat)
        let sizeFormat = SizeFormatter.closestFormatFromBytes(Int(document.size)!)
        self.sizeDateLabel.text = "\(sizeFormat.number) \(sizeFormat.unitTypeName), \(dateString)"
        self.extensionLabel.text = document.ext
        
        if let urlString = document.thumbnailUrlString {
            
            let filter = AspectScaledToFillSizeFilter(size: thumbnailImageView.frame.size)
            
            thumbnailImageView.af_setImageWithURL(NSURL(string: urlString)!, filter: filter, completion: { (response) in
                switch response.result {
                case .Success:
                    self.extensionLabel.hidden = true
                    self.thumbnailImageView.hidden = false
                case .Failure(let error):
                    self.extensionLabel.text = document.ext
                    self.thumbnailImageView.hidden = true
                    self.extensionLabel.hidden = false
                    
                    let newError = ServiceLayer.sharedServiceLayer.userService.createError(error)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.errorOccured, object: Wrapper(theValue: newError))
                }
            })
        } else {
            self.thumbnailImageView.hidden = true
            self.extensionLabel.hidden = false
        }
        
        if isSearchResult {
            let loadButton = newButton
            loadButton.setTitle("", forState: .Normal)
            loadButton.setImage(UIImage(named: "plus_icon"), forState: UIControlState.Normal)
            return
        }
        
        if hideButton {
            accessoryView?.hidden = true
        } else {
            accessoryView?.hidden = false
            refreshDownloadState()
        }
    }
    
    func refreshDownloadState() {
        
        let loadButton = newButton
        
        if document!.tempPath != nil {
            loadButton.setTitle("", forState: .Normal)
            loadButton.setImage(UIImage(named: "not_downloaded_file_icon"), forState: UIControlState.Normal)
        } else if document!.fileName != nil {
            loadButton.setTitle("", forState: .Normal)
            loadButton.setImage(UIImage(named: "downloaded_file_icon"), forState: UIControlState.Normal)
        } else if ServiceLayer.sharedServiceLayer.docsService.downloadExists(document!) == false {
            loadButton.setTitle("", forState: .Normal)
            loadButton.setImage(UIImage(named: "not_downloaded_file_icon"), forState: UIControlState.Normal)
        } else {
            loadButton.setTitle("0 %", forState: .Normal)
            loadButton.setImage(nil, forState: .Normal)
            ServiceLayer.sharedServiceLayer.docsService.downloadDocument(document!, progress: { (totalRead, bytesToRead) -> Void in
                let percent = Int((Double(totalRead)/Double(bytesToRead))*100)
                loadButton.setTitle(String(percent) + " %", forState: .Normal)
                loadButton.setImage(nil, forState: .Normal)
                }, completion: { (document) -> Void in
                    loadButton.setTitle("", forState: .Normal)
                    loadButton.setImage(UIImage(named: "downloaded_file_icon"), forState: UIControlState.Normal)
                }, failure: { (error) -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.errorOccured, object: Wrapper(theValue: error))
                    loadButton.setTitle("", forState: .Normal)
                    loadButton.setImage(UIImage(named: "not_downloaded_file_icon"), forState: UIControlState.Normal)
            })
        }
    }
    
    
    func buttonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(Const.Notifications.cellButtonPressed, object: sender)
    }
}
