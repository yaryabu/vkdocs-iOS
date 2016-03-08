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
    
    let vc = ViewController()

    var documents: [Document] = [] {
        didSet {
//            self.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serviceLayer.userService.getUserInfo({ (user) -> Void in
            print(user.id, user.firstName, user.lastName, user.photoUrlString)
            }) { (error) -> Void in
                print(error)
        }
        
        self.serviceLayer.docsService.getDocuments( { (documentsArray) -> Void in
            if self.documents != documentsArray {
                self.documents = documentsArray
                self.reloadData()
            }
            
        }, failure: { (error) -> Void in
            print(error)
        })
        print("token", self.serviceLayer.authService.token)
    }
    
    func reloadData() {
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
            //TODO: удаление файла из кеша, если он там есть
//            self.serviceLayer.docsService.deleteDocumentFromUser(self.documents[indexPath.row], completion: { () -> Void in
//                print("deleted")
//                }, failure: { (error) -> Void in
//                    print(error)
//            })
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
}
