//
//  UserDocsViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import Photos

import RealmSwift

/**
 Основной ViewController приложения, который слишком много на себя берет
 */
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
        let gr = UILongPressGestureRecognizer(target: self, action: #selector(UserDocsViewController.cellLongTapped(_:)))
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
    
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.sizeToFit()
        bar.placeholder = "SEARCH_BAR_PLACEHOLDER".localized
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
        
        bar.delegate = self
        return bar
    }()
    
    var docPickerNavBarOverlay: DocumentsPickerNavBarOverlay!
    var docPickerTabBarOverlay: DocumentsPickerTabBarOverlay!
    
    //MARK: ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureEditingMode()
        
        tableView.addGestureRecognizer(longTapGestureRecognizer)
        
        tableView.registerNib(UINib(nibName: "UserDocsTableViewCell", bundle: nil), forCellReuseIdentifier: UserDocsTableViewCell.cellIdentifier)
        tableView.registerNib(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: FolderCell.cellIdentifier)
        tableView.registerNib(UINib(nibName: "CreateFolderCell", bundle: nil), forCellReuseIdentifier: CreateFolderCell.cellIdentifier)
        
        navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)

        
        if isRootViewController {
            
            searchDataSource = SearchDataSource()
            vkDocumentsDataSource = UserDocsDataSource()
            currentDataSource = vkDocumentsDataSource
            
            navigationItem.titleView = searchBar
            
            pullToRefreshControl.addTarget(self, action: #selector(UserDocsViewController.pullToRefreshActivated), forControlEvents: UIControlEvents.ValueChanged)
            tableView.addSubview(self.pullToRefreshControl)
            
            refreshTableViewData()
            
        } else {
            folderDataSource = FolderDataSource()
            currentDataSource = folderDataSource
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.title = currentPath.componentsSeparatedByString("/").last
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
    
    // поскольку эти VC появляются постоянно и остаются в памяти нужно переставить ловить уведомления
    // т.к. неизвестно, кто именно их поймает
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDocsViewController.cellButtonPressed(_:)), name: Const.Notifications.cellButtonPressed, object: nil)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Const.Notifications.cellButtonPressed, object: nil)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            Bash.cd("..")
        }
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let _ = currentDataSource as? UserDocsDataSource {
            return 30
        }
        
        if let _ = currentDataSource as? FolderDataSource {
            return 0
        }
        
        if let ds = currentDataSource as? SearchDataSource {
            if section == 0 && ds.savedDocumentsResult.count == 0 {
                return 0
            }
            if section == 1 && ds.vkSearchResults.count == 0 {
                return 0
            }
            return 30
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let _ = currentDataSource as? FolderDataSource {
            return nil
        }
        
        let view = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: tableView.frame.width,
            height: 30
            ))
        view.backgroundColor = UIColor.vkGrayColor()
        
        let label = SectionHeaderLabel()
        label.frame = CGRect(
            x: 14,
            y: 2,
            width: view.frame.width,
            height: 24
        )
        
        if let _ = currentDataSource as? SearchDataSource {
            if section == 0 {
                label.text = "PERCONAL_DOCUMENTS_SEARCH_RESULTS".localized
            } else {
                label.text = "VK_DOCUMENTS_SEARCH_RESULTS".localized
            }

        } else if let _ = currentDataSource as? UserDocsDataSource {
            if section == 0 {
                label.text = "FOLDERS_SECTION_NAME".localized
            } else {
                label.text = "DOCUMENTS_SECTION_NAME".localized
            }
        }
        
        view.addSubview(label)
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.editing {
            
            if let ds = currentDataSource as? UserDocsDataSource {
                if ds.folders[0] == ds.createFolderCell &&
                    indexPath.row == 0 &&
                    indexPath.section == 0 {
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    return
                }
            }
            
            let itemsCount = tableView.indexPathsForSelectedRows!.count
            docPickerNavBarOverlay.titleLabel.text = String(format: docPickerNavBarOverlay.titleTemplate, itemsCount)
            docPickerTabBarOverlay.changeButtonsState(itemsCount, isRootViewController: isRootViewController)
            return
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let ds = currentDataSource as? UserDocsDataSource {
            switch indexPath.section {
            case 0:
                if ds.folders[0] == ds.createFolderCell {
                    performSegueWithIdentifier(Const.StoryboardSegues.createFolder, sender: nil)
                } else {
                    let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.userDocsTableViewController) as! UserDocsViewController
                    let newPath = Bash.pwd() + "/" + ds.folders[indexPath.row]
                    vc.currentPath = newPath
                    navigationController!.pushViewController(vc, animated: true)
                }
            case 1:
                self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath)
            default:
                break
            }
            
        } else if let _ = currentDataSource as? SearchDataSource {
            self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath)
            
        } else if let ds = currentDataSource as? FolderDataSource {
            if ds.isDirectory(indexPath) {
                let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.userDocsTableViewController) as! UserDocsViewController
                let newPath = Bash.pwd() + "/" + ds.elements[indexPath.row]
                vc.currentPath = newPath
                navigationController!.pushViewController(vc, animated: true)
            } else {
                self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath)
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            let itemsCount = tableView.indexPathsForSelectedRows?.count ?? 0
            docPickerNavBarOverlay.titleLabel.text = String(format: docPickerNavBarOverlay.titleTemplate, itemsCount)
            docPickerTabBarOverlay.changeButtonsState(itemsCount, isRootViewController: isRootViewController)
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "EDIT_CELL_DELETE_ACTION".localized) { (action, indexPath) in
            tableView.dataSource!.tableView!(tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
        }
        deleteAction.backgroundColor = UIColor.vkGrapefruitColor()
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "EDIT_CELL_EDIT_ACTION".localized) { (action, indexPath) in
            self.setEditing(false, animated: true)
            self.tableView.setEditing(false, animated: true)
            let editViewControllerNavController = self.storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.editViewControllerNavigationController) as! NavigationController
            let editViewController = editViewControllerNavController.viewControllers[0] as! EditViewController
            
            if let ds = self.currentDataSource as? UserDocsDataSource {
                switch indexPath.section {
                case 0:
                    editViewController.actionType = .EditFolder
                    editViewController.folderPathToEdit = ds.folderPath(indexPath)
                case 1:
                    editViewController.actionType = .EditDocument
                    editViewController.documentToEdit = ds.document(indexPath)
                default:
                    break
                }
            } else if let ds = self.currentDataSource as? SearchDataSource {
                switch indexPath.section {
                case 0:
                    editViewController.actionType = .EditDocument
                    editViewController.documentToEdit = ds.document(indexPath)
                default:
                    break
                }
            } else if let ds = self.currentDataSource as? FolderDataSource {
                if ds.isDirectory(indexPath) {
                    editViewController.actionType = .EditFolder
                    editViewController.folderPathToEdit = ds.elementPath(indexPath)
                } else {
                    editViewController.actionType = .EditDocument
                    editViewController.documentToEdit = ds.document(indexPath)
                }
            }
            self.presentViewController(editViewControllerNavController, animated: true, completion: nil)
        }
        editAction.backgroundColor = UIColor.vkEmeraldColor()
        
        return [deleteAction, editAction]
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //ищем новые документы за 10 ячеек до окончания
        if let ds = currentDataSource as? SearchDataSource {
            if indexPath.row == ds.vkSearchResults.count - 10 {
                search()
            }
        }
    }
    
    //MARK: EditingMode. Выбор нескольких элементов.
    
    func cellLongTapped(gestureRecognizer: UILongPressGestureRecognizer) {
        if tableView.editing == false && editing == false {
            
            if let _ = currentDataSource as? SearchDataSource {
                return
            }
            
            let tapPoint = gestureRecognizer.locationInView(self.tableView)
            let indexPath = tableView.indexPathForRowAtPoint(tapPoint)!
            
            if let ds = currentDataSource as? UserDocsDataSource {
                if indexPath.section == 0 && ds.folders[0] == ds.createFolderCell {
                    return
                }
            }
            tableView.setEditing(true, animated: true)
            setEditing(true, animated: true)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
        
    }
    
    func configureEditingMode() {
        docPickerNavBarOverlay = DocumentsPickerNavBarOverlay.loadFromNibNamed("DocumentsPickerNavBarOverlay")
        docPickerNavBarOverlay.exitButton.addTarget(self, action: #selector(UserDocsViewController.docPickerExitButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        docPickerTabBarOverlay = DocumentsPickerTabBarOverlay.loadFromNibNamed("DocumentsPickerTabBarOverlay")
        docPickerTabBarOverlay.deleteButton.addTarget(self, action: #selector(UserDocsViewController.docPickerDeleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        docPickerTabBarOverlay.moveButton.addTarget(self, action: #selector(UserDocsViewController.docPickerMoveButtonPressed(_:)), forControlEvents: .TouchUpInside)
        docPickerTabBarOverlay.copyButton.addTarget(self, action: #selector(UserDocsViewController.docPickerCopyButtonPressed(_:)), forControlEvents: .TouchUpInside)
    }
    
    func docPickerExitButtonPressed(sender: AnyObject?) {
        tableView.setEditing(false, animated: true)
        setEditing(false, animated: true)
    }
    
    func docPickerDeleteButtonPressed(sender: AnyObject?) {
        let indexPaths = self.tableView.indexPathsForSelectedRows!
        
        if let ds = currentDataSource as? FolderDataSource {
            ds.deleteElements(indexPaths, completion: { () -> Void in
                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.setEditing(false, animated: true)
                self.setEditing(false, animated: true)
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
            return
        }
        
        let alert = UIAlertController(title: "EDITING_MODE_DELETE_ALERT_TITLE".localized, message: "EDITING_MODE_DELETE_ALERT_MESSAGE".localized, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "YES".localized, style: .Destructive) { (action) -> Void in
            
            //FIXME: тут обязательно нужен спиннер
            self.currentDataSource.deleteElements(indexPaths, completion: { () -> Void in
                //FIXME: анимация удаления
//                if self.currentDataSource as? UserDocsDataSource != nil &&
//                    indexPaths.contains(NSIndexPath(forRow: 0, inSection: 0)) {
//                    // workaround для ячейки создания папки
//                    
//                } else {
//                    self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
//                }
                self.tableView.setEditing(false, animated: true)
                self.setEditing(false, animated: true)
                self.tableView.reloadData()
                }, failure: { (error) -> Void in
                    self.handleError(error)
            })
        }
        let noAction = UIAlertAction(title: "NO".localized, style: .Cancel, handler: nil)
        
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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
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
            
            docPickerNavBarOverlay.titleLabel.text = String(format: docPickerNavBarOverlay.titleTemplate, itemsCount)
            docPickerTabBarOverlay.changeButtonsState(itemsCount, isRootViewController: isRootViewController)
            
            docPickerNavBarOverlay.presentAnimated(newFrame, superview: self.navigationController!.navigationBar)
            docPickerTabBarOverlay.presentAnimated(tabBarFrame, superview: self.tabBarController!.view)
        } else {
            if isRootViewController == false {
                navigationItem.hidesBackButton = false
            }
            docPickerNavBarOverlay.dismissAnimated()
            docPickerTabBarOverlay.dismissAnimated()
            docPickerNavBarOverlay.titleLabel.text = String(format: docPickerNavBarOverlay.titleTemplate, 0)
        }
    }
    
    //MARK: Refresh
    
    func refreshTableViewData(refreshEnded: (() -> Void)? = nil) {
        currentDataSource.refresh({ () -> Void in
            refreshEnded?()
            self.tableView.reloadData()
            }, refreshFailed: { (error) -> Void in
                refreshEnded?()
                self.handleError(error)
        })
    }
    
    func pullToRefreshActivated() {
        self.refreshTableViewData() { () -> Void in
            self.pullToRefreshControl.endRefreshing()
        }
    }
    
    //MARK: Поиск и UISearchBarDelegate
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        currentDataSource = searchDataSource
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.searchBar.showsCancelButton = true
        return true
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(UserDocsViewController.search), object: nil)
        performSelector(#selector(UserDocsViewController.search), withObject: nil, afterDelay: 0.5) //ВК не позволяет больше 3 запросов в секунду. С таким delay все ОК
    }
    
    func search() {
        let query = searchBar.text!
        Analytics.logSearchQuery(query)
        if let ds = currentDataSource as? SearchDataSource {
            ds.startSearch(query, completion: { () -> Void in
                self.tableView.reloadData()
                }) { (error) -> Void in
                    self.handleError(error)
            }
        } else {
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if let ds = currentDataSource as? SearchDataSource {
            ds.vkSearchResults = []
            ds.savedDocumentsResult = []
        }
        tableView.scrollEnabled = false
        tableView.scrollEnabled = true
        currentDataSource = vkDocumentsDataSource
        refreshTableViewData()
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.navigationItem.leftBarButtonItem = self.navigationBarButtons.0
        self.navigationItem.rightBarButtonItem = self.navigationBarButtons.1
    }
    
    //MARK: Загрузка файла в ВК
    
    @IBAction func addDocumentButtonPressed(sender: AnyObject) {
        if serviceLayer.uploadDocsService.isUploadingNow() {
            ToastManager.sharedInstance.presentError(Error(code: 0, message: "UPLOAD_IN_PROGRESS_ERROR_MESSAGE".localized))
            return
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .Authorized:
            presentViewController(imagePicker, animated: true, completion: nil)
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                Dispatch.mainQueue({ 
                    if status == .Authorized {
                        self.presentViewController(self.imagePicker, animated: true, completion: nil)
                    } else {
                        ToastManager.sharedInstance.presentError(Error(code: 0, message: ":c"))
                    }
                })
            })
        default:
            ToastManager.sharedInstance.presentError(Error(code: 0, message: "PHOTO_ACCESS_FORBIDDEN_ERROR_MESSAGE".localized))
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //FIXME: во время обработки файла нужно поставить спиннер
        picker.dismissViewControllerAnimated(true, completion: nil)
        ToastManager.sharedInstance.presentInfo("UPLOAD_BEGAN_TOAST_MESSAGE".localized, duration: 3.0)
        Dispatch.defaultQueue { () -> () in
            let referenceUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
            
            let asset = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl], options: nil).firstObject
            let fileName = asset?.filename! ?? "VK_Docs_file"
            print(fileName)
            let path = NSTemporaryDirectory() + fileName
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let data = UIImagePNGRepresentation(image) ?? UIImageJPEGRepresentation(image, 1.0)!
                data.writeToFile(path, atomically: false)
                self.uploadMediaFile(path, fileName: fileName)
                
            } else if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
                let urlString = videoUrl.absoluteString.componentsSeparatedByString("file://").last!
                let data = NSData(contentsOfFile: urlString)!
                data.writeToFile(path, atomically: false)
                self.uploadMediaFile(path, fileName: fileName)
            }
        }
    }
    
    func uploadMediaFile(path: String, fileName: String) {
        self.serviceLayer.uploadDocsService.uploadDocument(path, documentName: fileName, completion: { () -> Void in
            ToastManager.sharedInstance.presentInfo("DOCUMENT_UPLOAD_SUCCESS_TOAST_MESSAGE".localized)
            self.refreshTableViewData()
            }, progress: { (totalUploaded, bytesToUpload) -> Void in
                //прогресс ловится в NavigationController
        }) { (error) -> Void in
            self.handleError(error)
        }
    }
    
    //MARK: Other
    
    func cellButtonPressed(notification: NSNotification) {
        let button = notification.object as! UIButton
        let buttonPosition = button.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        
        buttonPressedAt(indexPath)
    }
    
    func buttonPressedAt(indexPath: NSIndexPath) {
        if let ds = currentDataSource as? SearchDataSource {
            if indexPath.section == 1 {
                self.serviceLayer.docsService.addDocumentToUser(searchDataSource.vkSearchResults[indexPath.row], completion: { (newDocumentId) -> Void in
                    ds.removeVkSearchElement(indexPath, from: self.tableView)
                    ToastManager.sharedInstance.presentInfo("DOCUMENT_ADDED_TOAST_MESSAGE".localized)
                    }, failure: { (error) -> Void in
                        self.handleError(error)
                })
                return
            }
        }
        
        
        let doc = currentDataSource.document(indexPath)
        
        if doc.tempPath != nil {
            doc.saveFromTempDir()
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            return
        }
        
        if serviceLayer.docsService.downloadExists(doc) {
            serviceLayer.docsService.cancelDownload(doc)
            ToastManager.sharedInstance.presentError(Error(code: 0, message: "LOADING_CANCELLED_ERROR_MESSAGE".localized))
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
        self.tableView.setEditing(false, animated: true)
        self.setEditing(false, animated: true)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        
        let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .Cancel, handler: nil)
        
        let createFolderAction = UIAlertAction(title: "CREATE_FOLDER_OPTION".localized, style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier(Const.StoryboardSegues.createFolder, sender: nil)
        }
        
        let chooseElementsAction = UIAlertAction(title: "CHOOSE_ELEMENTS_OPTION".localized, style: .Default) { (action) -> Void in
            self.tableView.setEditing(true, animated: true)
            self.setEditing(true, animated: true)
        }
        
        let addFileToFolderAction = UIAlertAction(title: "ADD_FILE_TO_FOLDER_OPTION".localized, style: .Default) { (action) -> Void in
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchBar.resignFirstResponder()
        
        if segue.identifier == Const.StoryboardSegues.previewDocument {
            let vc = segue.destinationViewController as! DocumentPreviewViewController
            vc.document = currentDataSource.document(sender as! NSIndexPath)
        }
        
        setEditing(false, animated: true)
        tableView.setEditing(false, animated: true)
    }
}
