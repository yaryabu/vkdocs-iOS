//
//  FolderDataSource.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 19/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

class FolderDataSource: NSObject, DataSource {
    
    var elements: [String] {
        return Bash.ls(Bash.pwd())
    }
    
    override init() {
        super.init()
        print("FOLDER", Bash.pwd())
        print(elements)
    }
    
    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void) {
        
    }
    func document(indexPath: NSIndexPath) -> Document {
        let docName = elements[indexPath.row]
        return documentByFileName(docName)
    }
    func updateCache() {}
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if elements[indexPath.row].containsString(Const.Common.directoryConflictHelper) {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
            cell.configureCell(documentByFileName(elements[indexPath.row]), isSearchResult: false)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(FolderCell.cellIdentifier, forIndexPath: indexPath) as! FolderCell
            cell.folderNameLabel.text = elements[indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.section == 0 {
//            if editingStyle == UITableViewCellEditingStyle.Delete {
//                Bash.rm(Const.Directories.fileSystemDir + "/" + folders[indexPath.row])
//            } else {}
//        } else {
//            if editingStyle == UITableViewCellEditingStyle.Delete {
//                print("delete", indexPath.row)
//                let document = self.documents[indexPath.row]
//                ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(document, completion: { () -> Void in
//                    Bash.rm(document.fileDirectory)
//                    let realm = try! Realm()
//                    try! realm.write({ () -> Void in
//                        realm.delete(document)
//                    })
//                    print("deleted")
//                    }, failure: { (error) -> Void in
//                        print(error)
//                })
//                self.documents.removeAtIndex(indexPath.row)
//            }
//        }
//        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    func isDirectory(indexPath: NSIndexPath) -> Bool {
        let fileName = elements[indexPath.row]
        if fileName.containsString(Const.Common.directoryConflictHelper) {
            return false
        } else {
            return true
        }
    }

    private func documentByFileName(fileName: String) -> Document {
        let realm = try! Realm()
        let docId = fileName.componentsSeparatedByString(Const.Common.directoryConflictHelper)[0]
        return realm.objects(Document).filter("id == \"\(docId)\"").first!
    }
    
}