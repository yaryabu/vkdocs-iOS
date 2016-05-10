//
//  UserDocsDataSource.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift


/// DataSource документов из ВК и корневых папок файловой системы.
class UserDocsDataSource: NSObject, DataSource {
    
    /// Название ячейки, которая создает папки
    let createFolderCell = Const.Common.bundleIdentifier + "CREATE_FOLDER_CELL_.m29voa721knv"
    
    var folders: [String] {
        let currentFolders = Bash.ls(Const.Directories.fileSystemDir)
        if currentFolders.count > 0 {
            return currentFolders
        } else {
            return [createFolderCell]
        }
    }
    var documents: [Document] {
        didSet {
            Analytics.logDocumentsCount(documents.count)
        }
    }
    
    private var documentsToDelete: [Document] = []
    
    override init() {
        self.documents = try! Array(Realm().objects(Document))
    }
    
    func document(indexPath: NSIndexPath) -> Document {
        return documents[indexPath.row]
    }
    
    func folderPath(indexPath: NSIndexPath) -> String? {
        if indexPath.section == 0 {
            if folders[indexPath.row] != createFolderCell {
                return Bash.pwd() + "/" + folders[indexPath.row]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func updateCache() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(self.documentsToDelete)
        }
        documentsToDelete = []
        
        let docs = Array(realm.objects(Document))
        self.documents = docs.sort({ (doc1, doc2) -> Bool in
            if doc1.order < doc2.order {
                return true
            } else {
                return false
            }
        })
    }
    
    func deleteElements(indexPaths: [NSIndexPath], completion: () -> Void, failure: (error: Error) -> Void) {
        
        // нужно перераспределить объекты по другим массивам т.к. при прямом
        // удалении из folders или documents меняется их порядок
        var folderPathsToDelete: [String] = []
        var docsToDelete: [Document] = []
        
        for indexPath in indexPaths {
            if indexPath.section == 0 {
                if let folderPath = folderPath(indexPath) {
                    folderPathsToDelete.append(folderPath)
                }
            } else {
                docsToDelete.append(document(indexPath))
            }
        }
        
        var dispatchDelayCounter = 0.3
        
        for path in folderPathsToDelete {
            Bash.rm(path)
        }
        for doc in docsToDelete {
            //FIXME: если ВК когда-нибудь сделает метод удаления нескольких объектов одновременно - нужно его встатвить сюда
            
            // dummy-объект, чтобы можно было сразу удалить doc из Realm
            let newDoc = Document()
            newDoc.id = doc.id
            newDoc.ownerId = doc.ownerId
            
            doc.deleteDocument()
            // задержка, чтобы не превышать ограничения ВК
            Dispatch.defaultQueueAfter(dispatchDelayCounter, closure: { () -> () in
                ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(newDoc, completion: { () -> Void in
                    }, failure: { (error) -> Void in
                        Dispatch.defaultQueueAfter(3.0, closure: { 
                            ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(newDoc, completion: {
                                }, failure: { (error) in
                                    failure(error: error)
                            })
                        })
                })
            })
            dispatchDelayCounter += 0.4
            
        }
        updateCache()
        completion()
    }
    
    
    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void) {
        ServiceLayer.sharedServiceLayer.docsService.getDocuments( { (documentsArray) -> Void in
            let realm = try! Realm()
            try! realm.write({ () -> Void in
                realm.add(documentsArray, update: true)
                
            })
            self.documents = documentsArray
            
            self.documentsToDelete = [Document]()
            
            for globalDoc in Array(realm.objects(Document)) {
                var shouldDeleteDocument = true
                for currentDoc in self.documents {
                    if currentDoc.id == globalDoc.id {
                        shouldDeleteDocument = false
                        break
                    }
                }
                if shouldDeleteDocument {
                    self.documentsToDelete.append(globalDoc)
                }
            }
            
            refreshEnded()
            }, failure: { (error) -> Void in
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if folders[indexPath.row] == createFolderCell {
                let cell = tableView.dequeueReusableCellWithIdentifier(CreateFolderCell.cellIdentifier, forIndexPath: indexPath) as! CreateFolderCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(FolderCell.cellIdentifier, forIndexPath: indexPath) as! FolderCell
                cell.folderNameLabel.text = folders[indexPath.row]
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
            let document = self.documents[indexPath.row]
            
            let shouldHideButton = tableView.delegate as? MoveCopyViewController != nil
            
            cell.configureCell(document, isSearchResult: false, hideButton: shouldHideButton)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.section == 0 && folders[0] == createFolderCell {
            return false
        }
        
        if let _ = tableView.delegate as? UserDocsViewController {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                Bash.rm(Const.Directories.fileSystemDir + "/" + folders[indexPath.row])
            } else {}
        } else {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                let document = self.documents[indexPath.row]
                ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(document, completion: { () -> Void in
                    document.deleteDocument()
                    }, failure: { (error) -> Void in
                        (tableView.delegate as! ViewController).handleError(error)
                })
                self.documents.removeAtIndex(indexPath.row)
            }
        }
        if folders.count == 1 && folders[0] == createFolderCell {
            tableView.reloadData()
        } else {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        }
    }
}