//
//  DocumentCellButton.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 15/05/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class DocumentCellButton: UIButton {
    
    var progress: Int = 0 {
        didSet {
            setImage(nil, forState: .Normal)
            switch progress {
            case 0:
                spinner.startAnimating()
            case 100:
                spinner.stopAnimating()
                setDownloadedFileIcon()
            default:
                spinner.stopAnimating()
                setTitle("\(progress) %", forState: .Normal)
            }
        }
    }
    
    lazy var spinner: UIActivityIndicatorView = {
        let s =  UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        s.hidesWhenStopped = true
        s.frame = self.frame
        s.userInteractionEnabled = false
        
        s.stopAnimating()
        self.addSubview(s)
        return s
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.font = UIFont.loadingPercentFont()
        titleLabel?.textColor = UIColor.vkDuskBlueColor()
        titleLabel?.tintColor = UIColor.vkDuskBlueColor()
        setTitleColor(UIColor.vkDuskBlueColor(), forState: .Normal)
    }
    
    func setDownloadedFileIcon() {
        spinner.stopAnimating()
        setTitle("", forState: .Normal)
        setImage(UIImage(named: "downloaded_file_icon"), forState: UIControlState.Normal)
    }
    
    func setNotDownloadedFileIcon() {
        spinner.stopAnimating()
        setTitle("", forState: .Normal)
        setImage(UIImage(named: "not_downloaded_file_icon"), forState: UIControlState.Normal)
    }
    
    func setAddDocumentIcon() {
        spinner.stopAnimating()
        setTitle("", forState: .Normal)
        setImage(UIImage(named: "plus_icon"), forState: UIControlState.Normal)
    }
    
}