//
//  AuthViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import VK_ios_sdk

class AuthViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var enterButton: UIButton! {
        didSet {
            enterButton.setTitle("AUTH_BUTTON_TEXT".localized, forState: UIControlState.Normal)
            enterButton.setTitle("AUTH_BUTTON_TEXT".localized, forState: UIControlState.Highlighted)
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: collectionView.frame.height/2 + 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView.collectionViewLayout = layout
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = self.collectionView.frame.size.width
        pageControl.currentPage = Int(self.collectionView.contentOffset.x / pageWidth)
    }
    
    //MARK: CollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(OnboardingViewCell.identifier, forIndexPath: indexPath) as! OnboardingViewCell
        if indexPath.row == 0 {
            cell.label.text = "ONBOARDING_FIRST_SLIDE".localized
            cell.imageView.image = UIImage(named: "intro1")
        } else if indexPath.row == 1 {
            cell.label.text = "ONBOARDING_SECOND_SLIDE".localized
            cell.imageView.image = UIImage(named: "intro2")
        } else {
            cell.label.text = "ONBOARDING_THIRD_SLIDE".localized
            cell.imageView.image = UIImage(named: "intro3")
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    @IBAction func logInButtonPressed(sender: AnyObject) {
        serviceLayer.authService.beginAuth()
    }
}
