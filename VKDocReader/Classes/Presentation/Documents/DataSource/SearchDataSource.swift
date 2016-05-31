//
//  SearchDataSource.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit
import RealmSwift

class SearchDataSource: NSObject, DataSource {
    var savedDocumentsResult: [Document] = []
    var vkSearchResults: [Document] = []
    var vkSearchResultsCount = 0
    
    private var latestQuery: String = ""
    
    func updateCache() {
        for (i, document) in savedDocumentsResult.enumerate() {
            if document.invalidated {
                self.savedDocumentsResult.removeAtIndex(i)
            }
        }
    }
    
    func document(indexPath: NSIndexPath) -> Document {
        if indexPath.section == 0 {
            return savedDocumentsResult[indexPath.row]
        } else {
            return vkSearchResults[indexPath.row]
        }
    }
    
    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void) {
        refreshEnded()
    }
    
    func deleteElements(indexPaths: [NSIndexPath], completion: () -> Void, failure: (error: Error) -> Void) {}
    
    func removeVkSearchElement(indexPath: NSIndexPath, from tableView: UITableView) {
        if indexPath.section == 0 {
            
        } else {
            vkSearchResults.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        }
    }
    
    func startSearch(query: String, completion: () -> Void, failure: (error: Error) -> Void) {
        
        //нельзя отсылать на сервер пустые строки в GET запросе
        if query == "" {
            savedDocumentsResult = []
            vkSearchResults = []
            vkSearchResultsCount = 0
            completion()
            return
        }
        
        let savedDocs = try! Array(Realm().objects(Document))
        savedDocumentsResult = savedDocs.filter { (doc) -> Bool in
            if doc.title.lowercaseString.containsString(query.lowercaseString) {
                return true
            } else {
                return false
            }
        }
        
        ServiceLayer.sharedServiceLayer.docsService.searchDocuments(query, offset: vkSearchResults.count, completion: { (documents, count) -> Void in
            for doc in documents {
                doc.isSearchResult = true
            }
            if query == self.latestQuery {
                self.vkSearchResults.appendContentsOf(documents)
            } else {
                self.vkSearchResults = documents
            }
            
            self.vkSearchResultsCount = count
            completion()
            self.latestQuery = query
            }) { (error) -> Void in
                failure(error: error)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.savedDocumentsResult.count
        } else {
            return self.vkSearchResults.count
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete &&
           indexPath.section == 0 {
            let document = self.savedDocumentsResult[indexPath.row]

            // dummy-объект, чтобы можно было сразу удалить doc из Realm
            let dummyDoc = Document()
            dummyDoc.id = document.id
            dummyDoc.ownerId = document.ownerId
            
            //FIXME: пришлось вынести удаление документа из файловой системы
            // ДО его удаления из ВК
            document.deleteDocument()
            
            
            ServiceLayer.sharedServiceLayer.docsService.deleteDocumentFromUser(dummyDoc, completion: { () -> Void in
//                document.deleteDocument()
                }, failure: { (error) -> Void in
                    (tableView.delegate as! ViewController).handleError(error)
            })
            self.savedDocumentsResult.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
            cell.configureCell(savedDocumentsResult[indexPath.row], isSearchResult: false, hideButton: false)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
            cell.configureCell(vkSearchResults[indexPath.row], isSearchResult: true, hideButton: false)
            return cell
        }
    }
}

