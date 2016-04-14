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
    
    private var latestQuery: String = ""
    
    func updateCache() {}
    
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
        
        //нельзя отсылать на сервер пустые строки в get запросе
        if query == "" {
            savedDocumentsResult = []
            vkSearchResults = []
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
        
        ServiceLayer.sharedServiceLayer.docsService.searchDocuments(query, offset: vkSearchResults.count, completion: { (documents) -> Void in
            for doc in documents {
                doc.isSearchResult = true
            }
            if query == self.latestQuery {
                self.vkSearchResults.appendContentsOf(documents)
            } else {
                self.vkSearchResults = documents
            }
            completion()
            self.latestQuery = query
            }) { (error) -> Void in
                failure(error: error)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if savedDocumentsResult.count > 0 {
                return "PERCONAL_DOCUMENTS_SEARCH_RESULTS".localized
            }
        } else {
            if vkSearchResults.count > 0 {
                return "VK_DOCUMENTS_SEARCH_RESULTS".localized
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.savedDocumentsResult.count
        } else {
            return self.vkSearchResults.count
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
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

