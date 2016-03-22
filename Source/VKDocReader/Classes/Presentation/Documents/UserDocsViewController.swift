//
//  UserDocsViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

class UserDocsViewController: ViewController, UITableViewDelegate, UISearchBarDelegate {
    
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

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellButtonPressed:", name: Const.Notifications.cellButtonPressed, object: nil)

        pullToRefreshControl.addTarget(self, action: "pullToRefreshActivated", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(self.pullToRefreshControl)
//        tableView.registerNib(UINib(nibName: "UserDocsTableViewCell", bundle: nil), forCellReuseIdentifier: UserDocsTableViewCell.cellIdentifier)
        
        if isRootViewController {
            
            searchDataSource = SearchDataSource()
            vkDocumentsDataSource = UserDocsDataSource()
            currentDataSource = vkDocumentsDataSource
            
            navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)
            navigationItem.titleView = searchBar
            searchBar.delegate = self
            searchBar.addSubview(searchBarSpinner)
            
            refresh { () -> Void in}
        } else {
            folderDataSource = FolderDataSource()
            currentDataSource = folderDataSource
            
            navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.title = currentPath.componentsSeparatedByString("/").last
        }
        
        
        print("token", self.serviceLayer.authService.token)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Bash.cd(currentPath)
        
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
    
    func refresh(refreshEnded: () -> Void) {
        currentDataSource.refresh({ () -> Void in
            refreshEnded()
            self.tableView.reloadData()
            }, refreshFailed: { (error) -> Void in
                refreshEnded()
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
                height: navBarFrame.height
            )
            docPickerNavBarOverlay.presentAnimated(newFrame, view: self.navigationController!.navigationBar)
            
            let tabBarFrame = self.tabBarController!.tabBar.frame
            if isRootViewController {
                docPickerTabBarOverlay.moveButton.hidden = true
            }
            docPickerTabBarOverlay.presentAnimated(tabBarFrame, view: self.tabBarController!.view)
        } else {
            docPickerNavBarOverlay.dismissAnimated()
            docPickerTabBarOverlay.dismissAnimated()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            self.docPickerNavBarOverlay.titleLabel.text = "Выбрано: \(tableView.indexPathsForSelectedRows!.count)"
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
            self.docPickerNavBarOverlay.titleLabel.text = "Выбрано: \(tableView.indexPathsForSelectedRows?.count ?? 0)"
            tableView.style
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
        self.refresh { () -> Void in
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
        currentDataSource = vkDocumentsDataSource
        refresh { () -> Void in}
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.navigationItem.leftBarButtonItem = self.navigationBarButtons.0
        self.navigationItem.rightBarButtonItem = self.navigationBarButtons.1
    }
    
//    func cellButtonPressed(notification: NSNotification) {
//        let button = notification.object as! UIButton
//        
//        let buttonPosition = button.convertPoint(CGPointZero, toView: self.tableView)
//        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
//    }
    
    @IBAction func loadButtonPressed(sender: AnyObject) {
        
        let buttonPosition = (sender as! UIButton).convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        
        if let _ = currentDataSource as? SearchDataSource {
            self.serviceLayer.docsService.addDocumentToUser(searchDataSource.vkSearchResults[indexPath.row], completion: { (newDocumentId) -> Void in
                //code
                }, failure: { (error) -> Void in
                    print(error)
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
        }
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        print("buttPressed", doc.title)
    }
    
    @IBAction func optionsButtonPressed(sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in}
        let sortByNameAction = UIAlertAction(title: "Сортировать по имени", style: .Default) { (action) -> Void in
            
        }
        let sortByDateAction = UIAlertAction(title: "Сортировать по дате", style: .Default) { (action) -> Void in
            
        }
        let sortBySizeAction = UIAlertAction(title: "Сортировать по размеру", style: .Default) { (action) -> Void in
            
        }
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
        actionSheet.addAction(sortByNameAction)
        actionSheet.addAction(sortByDateAction)
        actionSheet.addAction(sortBySizeAction)
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
            //TODO: добавить проверку и блокировкать кнопку, если ничего не выбрано
            
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
    
}
