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
    
    var documents: [Document]
    var folders: [String]
    
    override init() {
        self.documents = try! Array(Realm().objects(Document))
        self.folders = Bash.ls(Const.Directories.fileSystemDir)
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
                self.folders.removeAtIndex(indexPath.row)
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