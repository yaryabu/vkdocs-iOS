//
//  UserDocsViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

class UserDocsViewController: ViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let pullToRefreshControl = UIRefreshControl()
    
    let vc = ViewController()

    var documents: [Document] = [] {
        didSet {
//            self.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pullToRefreshControl.addTarget(self, action: "pullToRefreshActivated", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.pullToRefreshControl)
        
        self.serviceLayer.userService.getUserInfo({ (user) -> Void in
            print(user.id, user.firstName, user.lastName, user.photoUrlString)
            }) { (error) -> Void in
                print(error)
        }
        
        self.presentCachedDocuments()
        
        self.refresh { () -> Void in}
        
        print("token", self.serviceLayer.authService.token)
    }
    
    func presentCachedDocuments() {
        let realm = try! Realm()
        let documents = Array(realm.objects(Document))
        if documents.isEmpty == false {
            self.documents = documents
            self.reloadTableViewData()
        }
    }
    
    func refresh(refreshEnded: () -> Void) {
        self.serviceLayer.docsService.getDocuments( { (documentsArray) -> Void in
            if self.documents != documentsArray {
                let realm = try! Realm()
                try! realm.write({ () -> Void in
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
        let document = self.documents[indexPath.row]
        cell.configureCell(document)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier(Const.StoryboardSegues.previewDocument, sender: indexPath.row)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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
}
