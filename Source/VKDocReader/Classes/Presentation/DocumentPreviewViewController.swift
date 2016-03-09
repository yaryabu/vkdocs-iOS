//
//  DocumentPreviewViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 08/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import QuickLook

class DocumentPreviewViewController: ViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIDocumentInteractionControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var document: Document?
    
    let previewController = QLPreviewController()
    let documentInteractionsController = UIDocumentInteractionController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.document!.title
        print("TETETE.txt", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.txt")))
        print("TETETE.xlsx", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.xlsx")))
        print("TETETE.png", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.png")))
        print("TETETE.flac", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.flac")))
        print("TETETE.rar", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE.rar")))
        print("TETETE", QLPreviewController.canPreviewItem(NSURL(fileURLWithPath: "TETETE")))
        
        self.addChildViewController(previewController)
        previewController.dataSource = self
        previewController.delegate = self

        self.previewDocument()
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        print("tap")
    }
    
    
    func previewDocument() {
        
        if self.document!.filePath != nil {
            self.loadingView.removeFromSuperview()
            self.view.addSubview(previewController.view)
            self.previewController.reloadData()
        } else {
            self.serviceLayer.docsService.downloadDocument(self.document!, progress: {(totalRead, totalSize) -> Void in
//                    progress(percent: Int((Double(totalRead)/Double(totalSize))*100))
                let percent = Int((Double(totalRead)/Double(totalSize))*100)
                self.loadingLabel.text = "\(percent) %\n \(totalRead/1024) КБ/\(totalSize/1024) КБ"
                }, completion: { (document) -> Void in
                    self.document = document
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
//        print("preview")
        print("111")
        return NSURL(fileURLWithPath: self.document!.filePath ?? "")
    }
    
    func canPreviewCurrentDocument() {
        
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        
        if self.document!.filePath == nil {
            return
        }
        self.documentInteractionsController.URL = NSURL(fileURLWithPath: self.document!.filePath ?? "")
        self.documentInteractionsController.presentOptionsMenuFromBarButtonItem(self.shareButton, animated: true)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.serviceLayer.docsService.cancelDownload(self.document!)
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("began", touches.count)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touches", touches.count)
//        let touch = touches.first
//        let touchLocation = touch!.locationInView(self.view)
//        if touchLocation
    }
}
