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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDataSource = mainDataSource
        
        self.navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)
        
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.clearColor()
        
        self.pullToRefreshControl.addTarget(self, action: "pullToRefreshActivated", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.pullToRefreshControl)
        
        self.refresh { () -> Void in}
        
        print("token", self.serviceLayer.authService.token)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
            if indexPath.row == ds.searchResults.count - 10 {
                search()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            
        } else {
            self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath.row)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchBar.resignFirstResponder()
        if segue.identifier == Const.StoryboardSegues.previewDocument {
            let vc = segue.destinationViewController as! DocumentPreviewViewController
            vc.document = mainDataSource.documents[sender as! Int]
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
        if searchBar.text == "" {
            return
        }
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "search", object: nil)
        performSelector("search", withObject: nil, afterDelay: 0.4) //ВК не позволяет больше 3 запросов в секунду. С таким delay все ОК
    }
    
    func search() {
        let query = searchBar.text!
        let ds = currentDataSource as! SearchDataSource
        ds.startSearch(query, completion: { () -> Void in
            self.tableView.reloadData()
            }) { (error) -> Void in
                print(error)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        currentDataSource = mainDataSource
        currentDataSource.refresh({ () -> Void in}) { (error) -> Void in}
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.navigationItem.leftBarButtonItem = self.navigationBarButtons.0
        self.navigationItem.rightBarButtonItem = self.navigationBarButtons.1
    }
    
    @IBAction func loadButtonPressed(sender: AnyObject) {
        
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        
        if let _ = currentDataSource as? UserDocsDataSource {
            self.serviceLayer.docsService.downloadDocument(mainDataSource.documents[indexPath.row], progress: { (totalRead, bytesToRead) -> Void in
                }, completion: { (document) -> Void in
                }) { (error) -> Void in
            }
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            print("buttPressed", mainDataSource.documents[indexPath.row].title)
        } else {
            self.serviceLayer.docsService.addDocumentToUser(searchDataSource.searchResults[indexPath.row], completion: { (newDocumentId) -> Void in
                //code
                }, failure: { (error) -> Void in
                    print(error)
            })
        }
    }
}
