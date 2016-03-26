//
//  UserDocsViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import AssetsLibrary

import RealmSwift

class UserDocsViewController: ViewController, UITableViewDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var currentPath: String! = Const.Directories.fileSystemDir
    
    var vkDocumentsDataSource: UserDocsDataSource!
    var searchDataSource: SearchDataSource!
    var folderDataSource: FolderDataSource!
    
    var currentDataSource: DataSource! {
        didSet {
            tableView.dataSource = currentDataSource
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var addDocumentButton: UIBarButtonItem!
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    
    var navigationBarButtons: (leftButton: UIBarButtonItem?, rightButton: UIBarButtonItem)!
    
    @IBOutlet weak var tableView: UITableView!
    
    let pullToRefreshControl = UIRefreshControl()
    
    lazy var longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let gr = UILongPressGestureRecognizer(target: self, action: "cellLongTapped:")
        gr.delegate = self
        return gr
    }()
    
    lazy var imagePicker: UIImagePickerController  = {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(picker.sourceType) ?? []
        picker.delegate = self
        return picker
    }()
    
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.sizeToFit()
        bar.placeholder = "Поиск"
        bar.barTintColor = UIColor.vkWhiteColor()
        
        for view in bar.subviews {
            for view2 in view.subviews {
                if let tf = view as? UITextField {
                    tf.backgroundColor = UIColor.vkCloudyBlueColor()
                }
                if let tf = view2 as? UITextField {
                    tf.backgroundColor = UIColor.vkCloudyBlueColor()
                }
            }
        }
        return bar
    }()
    
    let searchBarSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
        return spinner
    }()
    
    var docPickerNavBarOverlay: DocumentsPickerNavBarOverlay!
    var docPickerTabBarOverlay: DocumentsPickerTabBarOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureEditingMode()
        
        tableView.addGestureRecognizer(longTapGestureRecognizer)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellButtonPressed:", name: Const.Notifications.cellButtonPressed, object: nil)

        pullToRefreshControl.addTarget(self, action: "pullToRefreshActivated", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(self.pullToRefreshControl)
        tableView.registerNib(UINib(nibName: "UserDocsTableViewCell", bundle: nil), forCellReuseIdentifier: UserDocsTableViewCell.cellIdentifier)
        tableView.registerNib(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: FolderCell.cellIdentifier)

        if isRootViewController {
            
            searchDataSource = SearchDataSource()
            vkDocumentsDataSource = UserDocsDataSource()
            currentDataSource = vkDocumentsDataSource
            
            navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)
            navigationItem.titleView = searchBar
            searchBar.delegate = self
            searchBar.addSubview(searchBarSpinner)
            
            refreshTableViewData()
        } else {
            folderDataSource = FolderDataSource()
            currentDataSource = folderDataSource
            
            navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.title = currentPath.componentsSeparatedByString("/").last
        }
        
        
        print("token", self.serviceLayer.authService.token)
    }
    
    func cellLongTapped(gestureRecognizer: UILongPressGestureRecognizer) {
        let tapPoint = gestureRecognizer.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(tapPoint)
        
        if tableView.editing == false && editing == false {
            tableView.setEditing(true, animated: true)
            setEditing(true, animated: true)
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        }
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        ToastManager.sharedInstance.presentInfo("Загружаем документ в ВК")
        Dispatch.defaultQueue { () -> () in
            let referenceUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
            ALAssetsLibrary().assetForURL(referenceUrl, resultBlock: { (asset) in
                let fileName = asset.defaultRepresentation().filename()
                let path = NSTemporaryDirectory() + fileName
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    let data = UIImagePNGRepresentation(image)!
                    data.writeToFile(path, atomically: false)
                    self.uploadMediaFile(path, fileName: fileName)

                } else if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
                    let urlString = videoUrl.absoluteString.componentsSeparatedByString("file://").last!
                    let data = NSData(contentsOfFile: urlString)!
                    data.writeToFile(path, atomically: false)
                    self.uploadMediaFile(path, fileName: fileName)
                }
                }, failureBlock: { (error) in
                    if let newError = self.serviceLayer.uploadDocsService.createError(error) {
                        self.handleError(newError)
                    }
            })
        }
    }
    
    func uploadMediaFile(path: String, fileName: String) {
        self.serviceLayer.uploadDocsService.uploadDocument(path, documentName: fileName, completion: { () -> Void in
            ToastManager.sharedInstance.presentInfo("Документ загружен")
            self.refreshTableViewData()
            }, progress: { (totalUploaded, bytesToUpload) -> Void in
                print("PROGRESS", totalUploaded, bytesToUpload)
        }) { (error) -> Void in
            self.handleError(error)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Bash.cd(currentPath)
        
        //фиксит проблему, когда pull-to-refresh залезает под tableView
        pullToRefreshControl.beginRefreshing()
        pullToRefreshControl.endRefreshing()
        
        currentDataSource.updateCache()
        self.tableView.reloadData()
        
        if searchBar.text != "" {
            searchBar.becomeFirstResponder()
        }
    }

    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            Bash.cd("..")
        }
    }
    
    func refreshTableViewData(refreshEnded: (() -> Void)? = nil) {
        currentDataSource.refresh({ () -> Void in
            refreshEnded?()
            self.tableView.reloadData()
            }, refreshFailed: { (error) -> Void in
                refreshEnded?()
                self.handleError(error)
        })
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let ds = currentDataSource as? SearchDataSource {
            if indexPath.row == ds.vkSearchResults.count - 10 {
                search()
            }
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    
        print("setEditing")
        if editing {
            let navBarFrame = self.navigationController!.navigationBar.frame
            let newFrame = CGRect(
                x: navBarFrame.origin.x,
                y: navBarFrame.origin.y - UIApplication.sharedApplication().statusBarFrame.height,
                width: navBarFrame.width,
                height: navBarFrame.height - 2 // -2 для прогресс бара загрузки
            )
            
            let tabBarFrame = self.tabBarController!.tabBar.frame
            if !isRootViewController {
                navigationItem.hidesBackButton = true
            }
            
            let itemsCount = tableView.indexPathsForSelectedRows?.count ?? 0
            
            docPickerNavBarOverlay.titleLabel.text = "Выбрано: \(itemsCount)"
            docPickerTabBarOverlay.changeButtonsState(itemsCount, isRootViewController: isRootViewController)

            docPickerNavBarOverlay.presentAnimated(newFrame, view: self.navigationController!.navigationBar)
            docPickerTabBarOverlay.presentAnimated(tabBarFrame, view: self.tabBarController!.view)
        } else {
            if isRootViewController == false {
                navigationItem.hidesBackButton = false
            }
            docPickerNavBarOverlay.dismissAnimated()
            docPickerTabBarOverlay.dismissAnimated()
            docPickerNavBarOverlay.titleLabel.text = "Выбрано: 0"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            let itemsCount = tableView.indexPathsForSelectedRows!.count
            docPickerNavBarOverlay.titleLabel.text = "Выбрано: \(itemsCount)"
            docPickerTabBarOverlay.changeButtonsState(itemsCount, isRootViewController: isRootViewController)
            return
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let _ = currentDataSource as? SearchDataSource {
            self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath)
            return
        }
        
        if let ds = currentDataSource as? FolderDataSource {
            if ds.isDirectory(indexPath) {
                let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.userDocsTableViewController)
                let newPath = Bash.pwd() + "/" + ds.elements[indexPath.row]
                (vc as! UserDocsViewController).currentPath = newPath
                navigationController!.pushViewController(vc, animated: true)
            } else {
                self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath)
            }
            return
        }
        
        if indexPath.section == 0 {
            let ds = currentDataSource as! UserDocsDataSource
            let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.userDocsTableViewController)
            let newPath = Bash.pwd() + "/" + ds.folders[indexPath.row]
            (vc as! UserDocsViewController).currentPath = newPath
            navigationController!.pushViewController(vc, animated: true)
        } else {
            self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            let itemsCount = tableView.indexPathsForSelectedRows?.count ?? 0
            docPickerNavBarOverlay.titleLabel.text = "Выбрано: \(itemsCount)"
            docPickerTabBarOverlay.changeButtonsState(itemsCount, isRootViewController: isRootViewController)
        }
    }
    
//    func pushNewFolderViewController(indexPath: NSIndexPath) {
//        let ds = currentDataSource as? FolderDataSource
//        let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.userDocsTableViewController)
//        let newPath = Bash.pwd() + "/" + ds.elements[indexPath.row]
//        (vc as! UserDocsViewController).currentPath = newPath
//        Bash.cd(ds.elements[indexPath.row])
//        navigationController!.pushViewController(vc, animated: true)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchBar.resignFirstResponder()
        if segue.identifier == Const.StoryboardSegues.previewDocument {
            let vc = segue.destinationViewController as! DocumentPreviewViewController
            if let ds = currentDataSource as? UserDocsDataSource {
                vc.document = ds.document(sender as! NSIndexPath)
            } else if let ds = currentDataSource as? SearchDataSource {
                vc.document = ds.document(sender as! NSIndexPath)
            } else if let ds = currentDataSource as? FolderDataSource {
                vc.document = ds.document(sender as! NSIndexPath)
            }
        }
    }
    
    func pullToRefreshActivated() {
        self.refreshTableViewData() { () -> Void in
            self.pullToRefreshControl.endRefreshing()
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        currentDataSource = searchDataSource
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarSpinner.startAnimating()
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "search", object: nil)
        performSelector("search", withObject: nil, afterDelay: 0.5) //ВК не позволяет больше 3 запросов в секунду. С таким delay все ОК
    }
    
    func search() {
        let query = searchBar.text!
        if let ds = currentDataSource as? SearchDataSource {
            ds.startSearch(query, completion: { () -> Void in
                self.searchBarSpinner.stopAnimating()
                self.tableView.reloadData()
                }) { (error) -> Void in
                    self.handleError(error)
                    self.searchBarSpinner.stopAnimating()
            }
        } else {
            self.searchBarSpinner.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if let ds = currentDataSource as? SearchDataSource {
            ds.vkSearchResults = []
            ds.savedDocumentsResult = []
        }
        currentDataSource = vkDocumentsDataSource
        refreshTableViewData()
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.navigationItem.leftBarButtonItem = self.navigationBarButtons.0
        self.navigationItem.rightBarButtonItem = self.navigationBarButtons.1
    }
    
    func cellButtonPressed(notification: NSNotification) {
        let button = notification.object as! UIButton
        loadButtonPressed(button)
//        let buttonPosition = button.convertPoint(CGPointZero, toView: self.tableView)
//        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
    }
    
    @IBAction func loadButtonPressed(sender: AnyObject) {
        let buttonPosition = (sender as! UIButton).convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        
        if let ds = currentDataSource as? SearchDataSource {
            self.serviceLayer.docsService.addDocumentToUser(searchDataSource.vkSearchResults[indexPath.row], completion: { (newDocumentId) -> Void in
                ds.removeVkSearchElement(indexPath, from: self.tableView)
                ToastManager.sharedInstance.presentInfo("Документ добавлен")
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
            return
        }
        
        var doc: Document!
        
        if let _ = currentDataSource as? UserDocsDataSource {
            doc = vkDocumentsDataSource.document(indexPath)
        } else {
            doc = folderDataSource.document(indexPath)
        }
        
        if doc.tempPath != nil {
            doc.saveFromTempDir()
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            return
        }
        
        self.serviceLayer.docsService.downloadDocument(doc, progress: { (totalRead, bytesToRead) -> Void in
            }, completion: { (document) -> Void in
            }) { (error) -> Void in
                self.handleError(error)
        }
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    @IBAction func optionsButtonPressed(sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
        let createFolderAction = UIAlertAction(title: "Создать папку", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier(Const.StoryboardSegues.createFolder, sender: nil)
        }
        let chooseElementsAction = UIAlertAction(title: "Выбрать", style: .Default) { (action) -> Void in
            self.tableView.setEditing(true, animated: true)
            self.setEditing(true, animated: true)
        }
        let addFileToFolderAction = UIAlertAction(title: "Добавить файл", style: .Default) { (action) -> Void in
            self.docPickerChooseFileToAdd()
        }
        
        actionSheet.addAction(cancelAction)
        if !isRootViewController {
            actionSheet.addAction(addFileToFolderAction)
        }
        //TODO: если останется время
//        actionSheet.addAction(sortByNameAction)
//        actionSheet.addAction(sortByDateAction)
//        actionSheet.addAction(sortBySizeAction)
        actionSheet.addAction(createFolderAction)
        actionSheet.addAction(chooseElementsAction)

        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func configureEditingMode() {
        docPickerNavBarOverlay = DocumentsPickerNavBarOverlay.loadFromNibNamed("DocumentsPickerNavBarOverlay")
        docPickerNavBarOverlay.exitButton.addTarget(self, action: "docPickerExitButtonPressed:", forControlEvents: .TouchUpInside)
        
        docPickerTabBarOverlay = DocumentsPickerTabBarOverlay.loadFromNibNamed("DocumentsPickerTabBarOverlay")
        docPickerTabBarOverlay.deleteButton.addTarget(self, action: "docPickerDeleteButtonPressed:", forControlEvents: .TouchUpInside)
        docPickerTabBarOverlay.moveButton.addTarget(self, action: "docPickerMoveButtonPressed:", forControlEvents: .TouchUpInside)
        docPickerTabBarOverlay.copyButton.addTarget(self, action: "docPickerCopyButtonPressed:", forControlEvents: .TouchUpInside)
    }
    
    func docPickerExitButtonPressed(sender: AnyObject?) {
        tableView.setEditing(false, animated: true)
        setEditing(false, animated: true)
    }
    
    func docPickerDeleteButtonPressed(sender: AnyObject?) {
        let indexPaths = self.tableView.indexPathsForSelectedRows!

        if let ds = currentDataSource as? FolderDataSource {
            ds.deleteElements(indexPaths, completion: { () -> Void in
                }, failure: { (error) -> Void in
                    print(error)
            })
            return
        }
        
        let alert = UIAlertController(title: "Удалить из ВК?", message: "Вы точно хотите это удалить?", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Да", style: .Destructive) { (action) -> Void in
            
            //TODO: тут обязательно нужен спиннер
            self.currentDataSource.deleteElements(indexPaths, completion: { () -> Void in
                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.setEditing(false, animated: true)
                self.setEditing(false, animated: true)
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
        }
        let noAction = UIAlertAction(title: "Нет", style: .Cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Вызывается только с FolderDataSource
    func docPickerMoveButtonPressed(sender: AnyObject?) {
        let indexPaths = self.tableView.indexPathsForSelectedRows!
        
        let navControllerVc = self.storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewControllerNavigationController) as! NavigationController
        let moveCopyVc = navControllerVc.viewControllers[0] as! MoveCopyViewController
        moveCopyVc.actionType = MoveCopyActionType.Move
        
        var paths: [String] = []
        let ds = currentDataSource as! FolderDataSource
        for indexPath in indexPaths {
            paths.append(ds.elementPath(indexPath))
        }
        
        moveCopyVc.paths = paths

        self.presentViewController(navControllerVc, animated: true, completion: nil)
        
        tableView.setEditing(false, animated: true)
        setEditing(false, animated: true)
    }
    
    func docPickerCopyButtonPressed(sender: AnyObject?) {
        let indexPaths = self.tableView.indexPathsForSelectedRows!
        
        let navControllerVc = self.storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewControllerNavigationController) as! NavigationController
        let moveCopyVc = navControllerVc.viewControllers[0] as! MoveCopyViewController
        moveCopyVc.actionType = MoveCopyActionType.Copy
        
        var paths: [String] = []
        var names: [String] = []
        
        if let ds = currentDataSource as? UserDocsDataSource {
            for indexPath in indexPaths {
                if let path = ds.folderPath(indexPath) {
                    paths.append(path)
                } else {
                    let name = ds.document(indexPath).fileDirectory.componentsSeparatedByString("/").last!
                    names.append(name)
                }
            }
        } else if let ds = currentDataSource as? FolderDataSource {
            for indexPath in indexPaths {
                paths.append(ds.elementPath(indexPath))
            }
        }
        
        moveCopyVc.fileNames = names
        moveCopyVc.paths = paths
        
        self.presentViewController(navControllerVc, animated: true, completion: nil)
        
        tableView.setEditing(false, animated: true)
        setEditing(false, animated: true)
    }
    
    func docPickerChooseFileToAdd() {
        let navControllerVc = self.storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewControllerNavigationController) as! NavigationController
        let moveCopyVc = navControllerVc.viewControllers[0] as! MoveCopyViewController
        moveCopyVc.actionType = MoveCopyActionType.ChooseFileToAdd
        moveCopyVc.finalDirectory = currentPath
        
        self.presentViewController(navControllerVc, animated: true, completion: nil)
    }
    
    @IBAction func addDocumentButtonPressed(sender: AnyObject) {
        
        //TODO: добавить проверку, если сейчас уже что-то загружается
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
}
