//
//  OnboardingViewCell.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 27/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class OnboardingViewCell: UICollectionViewCell {
    static let identifier = "OnboardingViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var label: UILabel!
}