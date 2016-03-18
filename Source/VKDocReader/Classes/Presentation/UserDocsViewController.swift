//
//  UserDocsViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

class UserDocsViewController: ViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var addDocumentButton: UIBarButtonItem!
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    var navigationBarButtons: (leftButton: UIBarButtonItem, rightButton: UIBarButtonItem)!
    
    @IBOutlet weak var tableView: UITableView!
    
    let pullToRefreshControl = UIRefreshControl()
    
    let searchBar = UISearchBar()


    var documents: [Document] = [] {
        didSet {
//            self.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBarButtons = (leftButton: addDocumentButton, rightButton: optionsButton)
        
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.clearColor()
        
        self.pullToRefreshControl.addTarget(self, action: "pullToRefreshActivated", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.pullToRefreshControl)
        
        self.presentCachedDocuments()
        
        self.refresh { () -> Void in}
        
        print("token", self.serviceLayer.authService.token)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        print("sb")
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        print("se")
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.navigationItem.leftBarButtonItem = self.navigationBarButtons.0
        self.navigationItem.rightBarButtonItem = self.navigationBarButtons.1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableViewData()
        
        if searchBar.text != "" {
            searchBar.becomeFirstResponder()
        }
        
    }
    
    func presentCachedDocuments() {
        let realm = try! Realm()
        let documents = Array(realm.objects(Document))
        if documents.count > 0 {
            self.documents = documents
            self.reloadTableViewData()
        }
    }
    
    func refresh(refreshEnded: () -> Void) {
        self.serviceLayer.docsService.getDocuments( { (documentsArray) -> Void in
            if self.documents != documentsArray {
                print("NOT EQUAL")
//                
//                let loadedDocs = self.documents.filter({ (doc) -> Bool in
//                    if doc.fileName != nil {
//                        return true
//                    } else {
//                        return false
//                    }
//                })
//                
//                for newDoc in documentsArray {
//                    for oldDoc in loadedDocs {
//                        if newDoc.id == oldDoc.id {
//                            newDoc.fileName = oldDoc.fileName
//                        }
//                    }
//                }
                
                let realm = try! Realm()
                try! realm.write({ () -> Void in
                    realm.delete(self.documents)
                    realm.add(documentsArray, update: true)

                })
                self.documents = documentsArray
                self.reloadTableViewData()
            }
            refreshEnded()
            }, failure: { (error) -> Void in
                print(error)
                refreshEnded()
        })
    }
    
    func reloadTableViewData() {
        if self.documents.count > 0 {
            self.tableView.reloadData()
        } else {
            //TODO: зероскрин
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.documents.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Папки"
        } else {
            return "Документы"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
            cell.titleLabel.text = "azaza"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
            let document = self.documents[indexPath.row]
            cell.configureCell(document)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {

        } else {
            self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            print("delete", indexPath.row)
            let document = self.documents[indexPath.row]
            self.serviceLayer.docsService.deleteDocumentFromUser(document, completion: { () -> Void in
                Bash.rm(document.fileDirectory)
                let realm = try! Realm()
                try! realm.write({ () -> Void in
                    realm.delete(document)
                })
                print("deleted")
                }, failure: { (error) -> Void in
                    print(error)
            })
            self.documents.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchBar.resignFirstResponder()
        if segue.identifier == Const.StoryboardSegues.previewDocument {
            let vc = segue.destinationViewController as! DocumentPreviewViewController
            vc.document = self.documents[sender as! Int]
        }
    }
    
    func pullToRefreshActivated() {
        self.refresh { () -> Void in
            self.pullToRefreshControl.endRefreshing()
        }
    }
    
    @IBAction func loadButtonPressed(sender: AnyObject) {
        
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        
        //TODO: убрать
        if indexPath.section == 0 {
            return
        }
        
        self.serviceLayer.docsService.downloadDocument(documents[indexPath.row], progress: { (totalRead, bytesToRead) -> Void in
            }, completion: { (document) -> Void in
            }) { (error) -> Void in
        }
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        print("buttPressed", documents[indexPath.row].title)
    }
}
