//
//  UserDocsDataSource.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

class UserDocsDataSource: NSObject, DataSource {
    
    var folders: [String] {
        return Bash.ls(Const.Directories.fileSystemDir)
    }
    var documents: [Document]
    
    override init() {
        self.documents = try! Array(Realm().objects(Document))
    }
    
    func document(indexPath: NSIndexPath) -> Document {
        return documents[indexPath.row]
    }
    
    func folderPath(indexPath: NSIndexPath) -> String? {
        if indexPath.section == 0 {
            return Const.Directories.fileSystemDir + "/" + folders[indexPath.row]
        } else {
            return nil
        }
    }
    
    func updateCache() {
        let docs = try! Array(Realm().objects(Document))
        self.documents = docs.sort({ (doc1, doc2) -> Bool in
            if doc1.order < doc2.order {
                return true
            } else {
                return false
            }
        })
    }
    
    func deleteElements(indexPaths: [NSIndexPath], completion: () -> Void, failure: (error: Error) -> Void) {
        for indexPath in indexPaths {
            if indexPath.section == 0 {
                Bash.rm(folderPath(indexPath)!)
            } else {
                let doc = document(indexPath)
                // задержка, чтобы не превышать ограничения ВК
                Dispatch.mainQueueAfter(0.7, closure: { () -> () in
                    ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(doc, completion: { () -> Void in
                        }, failure: { (error) -> Void in
                            doc.deleteDocument()
                            failure(error: error)
                            print(error)
                    })
                })
                documents.removeAtIndex(indexPath.row)
            }
        }
        completion()
    }
    
    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void) {
        ServiceLayer.sharedServiceLayer.docsService.getDocuments( { (documentsArray) -> Void in
            if self.documents != documentsArray {
                print("NOT EQUAL")
                
                let realm = try! Realm()
                try! realm.write({ () -> Void in
                    //удаление для того, чтобы сохранялся порядок
                    //обычно при добавлении элементы падают в самый конец таблицы базы
                    realm.delete(self.documents)
                    realm.add(documentsArray, update: true)
                    
                })
                self.documents = documentsArray
            }
            refreshEnded()
            }, failure: { (error) -> Void in
                print(error)
                refreshFailed(error: error)
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return folders.count
        } else {
            return documents.count
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
            let cell = tableView.dequeueReusableCellWithIdentifier(FolderCell.cellIdentifier, forIndexPath: indexPath) as! FolderCell
            cell.folderNameLabel.text = folders[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
            let document = self.documents[indexPath.row]
            cell.configureCell(document, isSearchResult: false)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                Bash.rm(Const.Directories.fileSystemDir + "/" + folders[indexPath.row])
            } else {}
        } else {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                print("delete", indexPath.row)
                let document = self.documents[indexPath.row]
                ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(document, completion: { () -> Void in
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
            }
        }
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
    }
}