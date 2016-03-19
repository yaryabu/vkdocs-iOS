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
    
    let searchBar = UISearchBar()
    let searchBarSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var docPickerNavBarOverlay: DocumentsPickerNavBarOverlay!
    var docPickerTabBarOverlay: DocumentsPickerTabBarOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        docPickerNavBarOverlay = DocumentsPickerNavBarOverlay.loadFromNibNamed("DocumentsPickerNavBarOverlay")
        docPickerNavBarOverlay.exitButton.addTarget(self, action: "docPickerExitButtonPressed:", forControlEvents: .TouchUpInside)
        
        docPickerTabBarOverlay = DocumentsPickerTabBarOverlay.loadFromNibNamed("DocumentsPickerTabBarOverlay")
        docPickerTabBarOverlay.deleteButton.addTarget(self, action: "docPickerDeleteButtonPressed:", forControlEvents: .TouchUpInside)
        docPickerTabBarOverlay.moveButton.addTarget(self, action: "docPickerMoveButtonPressed:", forControlEvents: .TouchUpInside)
        docPickerTabBarOverlay.copyButton.addTarget(self, action: "docPickerCopyButtonPressed:", forControlEvents: .TouchUpInside)

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellButtonPressed:", name: Const.Notifications.cellButtonPressed, object: nil)

        self.pullToRefreshControl.addTarget(self, action: "pullToRefreshActivated", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.pullToRefreshControl)
//        tableView.registerNib(UINib(nibName: "UserDocsTableViewCell", bundle: nil), forCellReuseIdentifier: UserDocsTableViewCell.cellIdentifier)
        
        if self.navigationController!.viewControllers[0] == self {
            
            searchDataSource = SearchDataSource()
            vkDocumentsDataSource = UserDocsDataSource()
            currentDataSource = vkDocumentsDataSource
            
            navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)
            searchBar.sizeToFit()
            navigationItem.titleView = searchBar
            searchBar.delegate = self
            searchBar.backgroundColor = UIColor.clearColor()
            searchBar.addSubview(searchBarSpinner)
            searchBarSpinner.hidesWhenStopped = true
            searchBarSpinner.stopAnimating()
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

    
    func refresh(refreshEnded: () -> Void) {
        currentDataSource.refresh({ () -> Void in
            refreshEnded()
            self.tableView.reloadData()
            }, refreshFailed: { (error) -> Void in
                print(error)
                refreshEnded()
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
            let tabBarFrame = self.tabBarController!.tabBar.frame
            docPickerTabBarOverlay.presentAnimated(tabBarFrame)
            
            let navBarFrame = self.navigationController!.navigationBar.frame
            docPickerNavBarOverlay.presentAnimated(navBarFrame)
            
        } else {
            docPickerTabBarOverlay.dismissAnimated()
            docPickerNavBarOverlay.dismissAnimated()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO: не забыть про deselect
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
            print("end")
            self.pullToRefreshControl.endRefreshing()
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        print("sb")
        currentDataSource = searchDataSource
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        print("se")
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
                    print(error)
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
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(sortByNameAction)
        actionSheet.addAction(sortByDateAction)
        actionSheet.addAction(sortBySizeAction)
        actionSheet.addAction(createFolderAction)
        actionSheet.addAction(chooseElementsAction)

        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            Bash.cd("..")
        }
    }
    
    func docPickerExitButtonPressed(sender: AnyObject?) {
        tableView.setEditing(false, animated: true)
        setEditing(false, animated: true)
    }
    
    func docPickerDeleteButtonPressed(sender: AnyObject?) {
        tableView.setEditing(false, animated: true)
        setEditing(false, animated: true)
    }
    
    func docPickerMoveButtonPressed(sender: AnyObject?) {
        tableView.setEditing(false, animated: true)
        setEditing(false, animated: true)
    }
    
    func docPickerCopyButtonPressed(sender: AnyObject?) {
        tableView.setEditing(false, animated: true)
        setEditing(false, animated: true)
    }
    
}
