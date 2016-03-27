//
//  DocumentPreviewViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 08/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import QuickLook

import RealmSwift

class DocumentPreviewViewController: ViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIDocumentInteractionControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var kbytesLabel: UILabel! {
        didSet {
            kbytesLabel.text = ""
        }
    }
    
    @IBOutlet var loadingView: UIView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    lazy var optionsButton: UIBarButtonItem = {
        let btn = UIBarButtonItem()
        btn.target = self
        btn.action = "optionsButtonPressed:"
        btn.image = UIImage(named: "options_button.pdf")
        return btn
    }()
    
    @IBOutlet weak var progressBar: UIProgressView! {
        didSet {
            progressBar.layer.masksToBounds = true
            progressBar.layer.cornerRadius = 3
            progressBar.progress = 0.0
        }
    }
    var document: Document!
    
    let previewController = QLPreviewController()
    let documentInteractionsController = UIDocumentInteractionController()
    var tapGestureRecogniser: UITapGestureRecognizer!

    var navigationBarTapView: UIView!
    
    //если ссылаться на self.navigationController во viewDidDisappear, то при втором
    //переходе на экран МП падает т.к. при распаковке возвращается nil
    //Переменная weakNC решает эту проблему
    weak var weakNC: NavigationController!
    
    
//    let activityViewController: UIActivityViewController!
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTouched:", name: Const.Notifications.statusBarTouched, object: nil)
        super.viewDidLoad()
        if self.document.tempPath != nil || self.document.filePath != nil {
            navigationItem.rightBarButtonItem = nil
            navigationItem.setRightBarButtonItem(optionsButton, animated: false)
//            navigationItem.rightBarButtonItem = optionsButton
        }
        self.navigationItem.title = self.document.title
        self.weakNC = self.navigationController as! NavigationController
//        print("TETETE.txt", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.txt")))
//        print("TETETE.xlsx", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.xlsx")))
//        print("TETETE.png", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.png")))
//        print("TETETE.flac", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.flac")))
//        print("TETETE.rar", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.rar")))
//        print("TETETE", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE")))
        
        
        self.addChildViewController(previewController)
        previewController.dataSource = self
        previewController.delegate = self
//        self.previewController.view.frame = CGRect(
//            x: 0,
//            y: 0, //self.weakNC.navigationBar.frame.height,
//            width: self.view.frame.width,
//            height: self.view.frame.height
//        )

        self.previewDocument()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tapGestureRecogniser = UITapGestureRecognizer(target: self, action: "navigationBarTitleTapped:")
        self.tapGestureRecogniser.delegate = self
        self.navigationBarTapView = UIView(frame: CGRect(
            x: self.weakNC.navigationBar.frame.width/4,
            y: 0,
            width: self.weakNC.navigationBar.frame.width/2,
            height: self.weakNC.navigationBar.frame.height
            )
        )
//        self.navigationBarTapView.backgroundColor = UIColor.greenColor()
        self.navigationBarTapView.addGestureRecognizer(self.tapGestureRecogniser)
        self.weakNC.navigationBar.addSubview(self.navigationBarTapView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        self.showNavigationBar()
        self.navigationBarTapView.removeFromSuperview()
    }
    
    func previewDocument() {
        
        if self.document.filePath != nil || self.document.tempPath != nil {
            if let tempPath = self.document.tempPath {
                if serviceLayer.userSettingsService.deleteDocumentsAfterPreview == false {
                    let name = tempPath.componentsSeparatedByString("/").last!
                    Bash.mv(tempPath, to: self.document.fileDirectory + "/" + name)
                }
            }
            self.loadingView.removeFromSuperview()
            self.view.addSubview(previewController.view)
            self.previewController.reloadData()
        } else {
            self.serviceLayer.docsService.downloadDocument(self.document, progress: {(totalRead, totalSize) -> Void in
                let percent10k = Double(totalRead)/Double(totalSize)
                self.percentLabel.text = String(Int(percent10k*100)) + " %"
                self.kbytesLabel.text = "\(totalRead/1024) КБ/\(totalSize/1024) КБ"
                self.progressBar.progress = Float(percent10k)
                }, completion: { (document) -> Void in
                    self.document = document
                    if self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview || self.document.isSearchResult {
                        self.document.moveToTempDir()
                    }
                    self.navigationItem.rightBarButtonItem = self.optionsButton
                    self.loadingView.removeFromSuperview()
                    self.view.addSubview(self.previewController.view)
                    self.previewController.reloadData()
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
        }
    }

    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return NSURL(fileURLWithPath: self.document.filePath ?? self.document.tempPath ?? "")
    }
    
    func canPreviewCurrentDocument() {
        
    }
    
    func navigationBarTitleTapped(sender: UITapGestureRecognizer) {
//        self.hideNavigationBar()
    }
    
    func statusBarTouched(notification: NSNotification) {
//        self.showNavigationBar()
    }
    
    func hideNavigationBar() {
        self.weakNC.hideNavigationBarFrame(nil) { () -> () in
//            self.previewController.view.frame = CGRect(
//                x: 0,
//                y: 0,
//                width: self.view.frame.width,
//                height: self.view.frame.height
//            )
        }
    }
    
//    func showNavigationBar() {
//        self.weakNC.showNavigationBarFrame(nil) { () -> () in
////            self.previewController.view.frame = CGRect(
////                x: 0,
////                y: self.weakNC.navigationBar.frame.height, //self.weakNC.navBarAndStatusBarHeight,
////                width: self.view.frame.width,
////                height: self.loadingView.frame.height
////            )
//        }
//    }
    
    func optionsButtonPressed(sender: AnyObject) {
        if self.document.filePath == nil && self.document.tempPath == nil {
            return
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .Default) { (action) -> Void in
            let name = self.document.tempPath!.componentsSeparatedByString("/").last!
            Bash.mv(self.document.tempPath!, to: self.document.fileDirectory + "/" + name)
            let realm = try! Realm()
            if realm.objects(Document).filter("id == \"\(self.document.id)\"").first == nil {
                self.serviceLayer.docsService.addDocumentToUser(self.document, completion: { (newDocumentId) -> Void in
                    try! realm.write({ () -> Void in
                        realm.add(self.document)
                    })
                    self.document.isSearchResult = false
                    ToastManager.sharedInstance.presentInfo("Документ добавлен")
                    }, failure: { (error) -> Void in
                        self.handleError(error)
                })
            } else {
                ToastManager.sharedInstance.presentInfo("Сохранено")
            }
        }
        let addToFolderAction = UIAlertAction(title: "Добавить в папку", style: .Default) { (action) -> Void in
            let navControllerVc = self.storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewControllerNavigationController) as! NavigationController
            let moveCopyVc = navControllerVc.viewControllers[0] as! MoveCopyViewController
            
            let name = self.document.fileDirectory.componentsSeparatedByString("/").last!
            moveCopyVc.fileNames = [name]
            
            self.presentViewController(navControllerVc, animated: true, completion: nil)
        }
        let shareAction = UIAlertAction(title: "Отправить", style: .Default) { (action) -> Void in
            actionSheet.dismissViewControllerAnimated(false, completion: nil)
            self.documentInteractionsController.URL = NSURL(fileURLWithPath: self.document.filePath ?? "")
            self.documentInteractionsController.presentOptionsMenuFromBarButtonItem(self.optionsButton, animated: true)
        }
        let copyLinkAction = UIAlertAction(title: "Копировать ссылку", style: .Default) { (action) -> Void in
            UIPasteboard.generalPasteboard().string = self.document.urlString
            ToastManager.sharedInstance.presentInfo("Ссылка скопирована")
        }
        let deleteAction = UIAlertAction(title: "Удалить", style: .Destructive) { (action) -> Void in
            self.presentDeleteAlert()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
        
        if self.document.tempPath != nil {
            actionSheet.addAction(saveAction)
        }
        if document.isSearchResult == false {
            actionSheet.addAction(addToFolderAction)
        }
        actionSheet.addAction(copyLinkAction)
        actionSheet.addAction(shareAction)
        if document.isSearchResult == false {
            actionSheet.addAction(deleteAction)
        }
        
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func presentDeleteAlert() {
        let alert = UIAlertController(title: "Удалить", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
        let deleteCompletelyAction = UIAlertAction(title: "Удалить из ВК", style: .Default) { (action) -> Void in
            ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(self.document, completion: { () -> Void in
                self.document.deleteDocument()
                self.navigationController!.popViewControllerAnimated(true)
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
            
        }
        let deleteOnlyFileAction = UIAlertAction(title: "Удалить файл", style: .Default) { (action) -> Void in
            self.document.deleteFile()
            self.navigationController!.popViewControllerAnimated(true)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteCompletelyAction)
        alert.addAction(deleteOnlyFileAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.serviceLayer.docsService.cancelDownload(self.document)
        ToastManager.sharedInstance.presentError(Error(code: 0, message: "Загрузка отменена"))
        self.weakNC.popToRootViewControllerAnimated(true)
    }
    
    
    
}
