//
//  SearchDataSource.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class SearchDataSource: NSObject, DataSource {
    var searchResults: [Document] = []
    
    private var latestQuery: String = ""
    
    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void) {
        refreshEnded()
    }
    
    
    func startSearch(query: String, completion: () -> Void, failure: (error: Error) -> Void) {
        
        ServiceLayer.sharedServiceLayer.docsService.searchDocuments(query, offset: searchResults.count, completion: { (documents) -> Void in
            if query == self.latestQuery {
                self.searchResults.appendContentsOf(documents)
            } else {
                self.searchResults = documents
            }
            completion()
            self.latestQuery = query
            }) { (error) -> Void in
                print(error)
                failure(error: error)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCellWithIdentifier(UserDocsTableViewCell.cellIdentifier, forIndexPath: indexPath) as! UserDocsTableViewCell
        cell.configureCell(searchResults[indexPath.row], isSearchResult: true)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
}

