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
    
    let mainDataSource = UserDocsDataSource()
    let searchDataSource = SearchDataSource()
    
    var currentDataSource: DataSource! {
        didSet {
            tableView.dataSource = currentDataSource
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var addDocumentButton: UIBarButtonItem!
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    var navigationBarButtons: (leftButton: UIBarButtonItem, rightButton: UIBarButtonItem)!
    
    @IBOutlet weak var tableView: UITableView!
    
    let pullToRefreshControl = UIRefreshControl()
    
    let searchBar = UISearchBar()
    let searchBarSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellButtonPressed:", name: Const.Notifications.cellButtonPressed, object: nil)

        print(self.navigationController!.viewControllers)
        print(self.navigationController!.viewControllers[0] == self)
        
        currentDataSource = mainDataSource
        self.pullToRefreshControl.addTarget(self, action: "pullToRefreshActivated", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.pullToRefreshControl)
//        tableView.registerNib(UINib(nibName: "UserDocsTableViewCell", bundle: nil), forCellReuseIdentifier: UserDocsTableViewCell.cellIdentifier)
        
        if self.navigationController!.viewControllers[0] == self {
            self.navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)
            searchBar.sizeToFit()
            navigationItem.titleView = searchBar
            searchBar.delegate = self
            searchBar.backgroundColor = UIColor.clearColor()
            searchBar.addSubview(searchBarSpinner)
            searchBarSpinner.hidesWhenStopped = true
            searchBarSpinner.stopAnimating()
            refresh { () -> Void in}
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.title = Bash.pwd().componentsSeparatedByString("/").last
        }
        
        print("token", self.serviceLayer.authService.token)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        currentDataSource.updateCache()
        self.tableView.reloadData()
        
        if searchBar.text != "" {
            searchBar.becomeFirstResponder()
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController == nil && Bash.pwd() != Const.Directories.fileSystemDir {
            print("back")
            Bash.cd("..")
        }
    }
//
//    override func didMoveToParentViewController(parent: UIViewController?) {
//        print("back")
//        if Bash.pwd() != Const.Directories.fileSystemDir {
//            Bash.cd("..")
//        }
//    }
    
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let _ = currentDataSource as? SearchDataSource {
            self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath)
            return
        }
        
        if indexPath.section == 0 {
            let ds = currentDataSource as! UserDocsDataSource
            Bash.cd(ds.folders[indexPath.row])
            let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.userDocsTableViewController)
            navigationController!.pushViewController(vc, animated: true)
        } else {
            self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchBar.resignFirstResponder()
        if segue.identifier == Const.StoryboardSegues.previewDocument {
            let vc = segue.destinationViewController as! DocumentPreviewViewController
            if let ds = currentDataSource as? UserDocsDataSource {
                vc.document = ds.document(sender as! NSIndexPath)
            } else if let ds = currentDataSource as? SearchDataSource {
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
        performSelector("search", withObject: nil, afterDelay: 0.4) //ВК не позволяет больше 3 запросов в секунду. С таким delay все ОК
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
        currentDataSource = mainDataSource
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
        
        if let _ = currentDataSource as? UserDocsDataSource {
            let doc = mainDataSource.documents[indexPath.row]
            
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
        } else {
            self.serviceLayer.docsService.addDocumentToUser(searchDataSource.vkSearchResults[indexPath.row], completion: { (newDocumentId) -> Void in
                //code
                }, failure: { (error) -> Void in
                    print(error)
            })
        }
    }
}
