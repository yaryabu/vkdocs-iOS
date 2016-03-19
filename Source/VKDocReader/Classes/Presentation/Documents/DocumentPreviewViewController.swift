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
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    
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
        self.showNavigationBar()
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
                let percent = Int((Double(totalRead)/Double(totalSize))*100)
                self.loadingLabel.text = "\(percent) %\n \(totalRead/1024) КБ/\(totalSize/1024) КБ"
                }, completion: { (document) -> Void in
                    self.document = document
                    if self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview || self.document.isSearchResult {
                        self.document.moveToTempDir()
                    }
                    self.loadingView.removeFromSuperview()
                    self.view.addSubview(self.previewController.view)
                    self.previewController.reloadData()
                }, failure: { (error) -> Void in
                    print(error)
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
    
    func showNavigationBar() {
        self.weakNC.showNavigationBarFrame(nil) { () -> () in
//            self.previewController.view.frame = CGRect(
//                x: 0,
//                y: self.weakNC.navigationBar.frame.height, //self.weakNC.navBarAndStatusBarHeight,
//                width: self.view.frame.width,
//                height: self.loadingView.frame.height
//            )
        }
    }
    
    @IBAction func optionsButtonPressed(sender: AnyObject) {
        if self.document.filePath == nil && self.document.tempPath == nil {
            return
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .Default) { (action) -> Void in
            let name = self.document.tempPath!.componentsSeparatedByString("/").last!
            Bash.mv(self.document.tempPath!, to: self.document.fileDirectory + "/" + name)
        }
        let addToFolderAction = UIAlertAction(title: "Добавить в папку", style: .Default) { (action) -> Void in
//            TODO:
        }
        let shareAction = UIAlertAction(title: "Отправить", style: .Default) { (action) -> Void in
            let acVC = UIActivityViewController(activityItems: [NSData(contentsOfFile: self.document.filePath!)!], applicationActivities:nil)
            self.presentViewController(acVC, animated: true, completion: nil)
            //        self.weakNC.presentViewController(acVC, animated: true, completion: nil)
            
            //        self.documentInteractionsController.URL = NSURL(fileURLWithPath: self.document.filePath ?? "")
            //        self.documentInteractionsController.presentOptionsMenuFromBarButtonItem(self.shareButton, animated: true)
            //        self.documentInteractionsController
        }
        let deleteAction = UIAlertAction(title: "Удалить", style: .Destructive) { (action) -> Void in
            self.presentDeleteAlert()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in}
        if self.document.tempPath != nil {
            actionSheet.addAction(saveAction)
        }
        actionSheet.addAction(addToFolderAction)
        actionSheet.addAction(shareAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func presentDeleteAlert() {
        let alert = UIAlertController(title: "Удалить", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in}
        let deleteCompletelyAction = UIAlertAction(title: "Удалить из ВК", style: .Default) { (action) -> Void in
            ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(self.document, completion: { () -> Void in
                self.document.deleteFile()
                self.document.removeAllFromFileSystem()
                let realm = try! Realm()
                try! realm.write({ () -> Void in
                    realm.delete(self.document)
                })
                self.navigationController!.popViewControllerAnimated(true)
                }, failure: { (error) -> Void in
                    print(error)
            })
            
        }
        let deleteOnlyFileAction = UIAlertAction(title: "Удалить файл", style: .Default) { (action) -> Void in
            self.navigationController!.popViewControllerAnimated(true)
            self.document.deleteFile()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteCompletelyAction)
        alert.addAction(deleteOnlyFileAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.serviceLayer.docsService.cancelDownload(self.document)
        self.weakNC.popToRootViewControllerAnimated(true)
    }
    
    
    
}
