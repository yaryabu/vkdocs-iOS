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
    
    @IBOutlet weak var loadingViewSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    lazy var optionsButton: UIBarButtonItem = {
        let btn = UIBarButtonItem()
        btn.target = self
        btn.action = #selector(DocumentPreviewViewController.optionsButtonPressed(_:))
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
    
    var previewController: QLPreviewController? = QLPreviewController()
    let documentInteractionsController = UIDocumentInteractionController()
    var tapGestureRecogniser: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.document.tempPath != nil || self.document.filePath != nil {
            navigationItem.rightBarButtonItem = nil
            navigationItem.setRightBarButtonItem(optionsButton, animated: false)
        }
        self.navigationItem.title = self.document.title
        
        self.addChildViewController(previewController!)
        previewController!.dataSource = self
        previewController!.delegate = self
        
        self.previewController!.view.frame = CGRect(
            x: 0,
            y: navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height,
            width: self.view.frame.width,
            height: self.view.frame.height - navigationController!.navigationBar.frame.height - UIApplication.sharedApplication().statusBarFrame.height
        )
        
        Analytics.logDocumentPreview(document)

        self.previewDocument()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            // на iOS 8 QLPreviewController любит крашится, если сразу не покажет файл
            previewController = nil
        }
    }

    //FIXME: нужно позволять использовать лэндскейп на этом экране
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.All
//    }

    
    func previewDocument() {
        
        if document.filePath != nil || document.tempPath != nil {
            if document.tempPath != nil &&
                serviceLayer.userSettingsService.deleteDocumentsAfterPreview == false {
                document.saveFromTempDir()
            }
            loadingView.removeFromSuperview()
            if previewController != nil {
                self.view.addSubview(previewController!.view)
                self.previewController!.reloadData()
            }
        } else {
            self.serviceLayer.docsService.downloadDocument(self.document, progress: {(totalRead, totalSize) -> Void in
                self.loadingViewSpinner.stopAnimating()
                let percent10k = Double(totalRead)/Double(totalSize)
                self.percentLabel.text = String(Int(percent10k*100)) + " %"
                self.kbytesLabel.text = "\(totalRead/1024) \("KB".localized)/\(totalSize/1024) \("KB".localized)"
                self.progressBar.progress = Float(percent10k)
                }, completion: { (document) -> Void in
                    self.document = document
                    if self.serviceLayer.userSettingsService.deleteDocumentsAfterPreview || self.document.isSearchResult {
                        self.document.moveToTempDir()
                    }
                    self.navigationItem.rightBarButtonItem = self.optionsButton
                    self.loadingView.removeFromSuperview()
                    
                    if self.previewController != nil {
                        self.view.addSubview(self.previewController!.view)
                        self.previewController!.reloadData()
                    }
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
    
    func optionsButtonPressed(sender: AnyObject) {
        if self.document.filePath == nil && self.document.tempPath == nil {
            return
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let saveAction = UIAlertAction(title: "DOCUMENTS_PREVIEW_VIEW_CONTROLLER_SAVE_OPTION".localized, style: .Default) { (action) -> Void in
            self.document.saveFromTempDir()
            let realm = try! Realm()
            if realm.objects(Document).filter("id == \"\(self.document.id)\"").first == nil {
                self.serviceLayer.docsService.addDocumentToUser(self.document, completion: { [unowned self] (newDocumentId) -> Void in
                    try! realm.write({ () -> Void in
                        realm.add(self.document)
                    })
                    self.document.isSearchResult = false
                    ToastManager.sharedInstance.presentInfo("DOCUMENTS_PREVIEW_VIEW_CONTROLLER_ADDED_SUCCESS".localized)
                    }, failure: { [unowned self] (error) -> Void in
                        self.handleError(error)
                })
            } else {
                ToastManager.sharedInstance.presentInfo("DOCUMENTS_PREVIEW_VIEW_CONTROLLER_SAVED_SUCCESS".localized)
            }
        }
        
        let addToFolderAction = UIAlertAction(title: "DOCUMENTS_PREVIEW_VIEW_CONTROLLER_ADD_TO_FOLDER_OPTION".localized, style: .Default) { (action) -> Void in
            let navControllerVc = self.storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewControllerNavigationController) as! NavigationController
            let moveCopyVc = navControllerVc.viewControllers[0] as! MoveCopyViewController
            
            let name = self.document.fileDirectory.componentsSeparatedByString("/").last!
            moveCopyVc.fileNames = [name]
            
            self.presentViewController(navControllerVc, animated: true, completion: nil)
        }
        let shareAction = UIAlertAction(title: "DOCUMENTS_PREVIEW_VIEW_CONTROLLER_SHARE_DOCUMENT_OPTION".localized, style: .Default) { (action) -> Void in
            actionSheet.dismissViewControllerAnimated(false, completion: nil)
            self.documentInteractionsController.URL = NSURL(fileURLWithPath: self.document.filePath ?? self.document.tempPath!)
            self.documentInteractionsController.presentOptionsMenuFromBarButtonItem(self.optionsButton, animated: true)
            Analytics.logDocumentShareOpened()
        }
        let copyLinkAction = UIAlertAction(title: "DOCUMENTS_PREVIEW_VIEW_CONTROLLER_COPY_LINK_OPTION".localized, style: .Default) { (action) -> Void in
            UIPasteboard.generalPasteboard().string = self.document.urlString
            ToastManager.sharedInstance.presentInfo("DOCUMENTS_PREVIEW_VIEW_CONTROLLER_LINK_COPIED_SUCCESS".localized)
            Analytics.logDocumentLinkCopied()
        }
        let deleteAction = UIAlertAction(title: "DOCUMENTS_PREVIEW_VIEW_CONTROLLER_DELETE_OPTION".localized, style: .Destructive) { (action) -> Void in
            self.presentDeleteAlert()
        }
        let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .Cancel, handler: nil)
        
        
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .Cancel, handler: nil)
        let deleteCompletelyAction = UIAlertAction(title: "DOCUMENTS_PREVIEW_VIEW_CONTROLLER_DELETE_FROM_VK_ALERT_ACTION".localized, style: .Default) { (action) -> Void in
            self.serviceLayer.docsService.deleteDocumentFromUser(self.document, completion: { () -> Void in
                self.document.deleteDocument()
                self.navigationController!.popViewControllerAnimated(true)
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
            
        }
        let deleteOnlyFileAction = UIAlertAction(title: "DOCUMENTS_PREVIEW_VIEW_CONTROLLER_DELETE_FROM_DEVICE_ALERT_ACTION".localized, style: .Default) { (action) -> Void in
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
        ToastManager.sharedInstance.presentError(Error(code: 0, message: "DOCUMENTS_PREVIEW_VIEW_CONTROLLER_LOADING_CANCELED_MESSAGE".localized))
        navigationController!.popToRootViewControllerAnimated(true)
    }
    
    
    
}
