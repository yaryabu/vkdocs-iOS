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
        var allElements = Bash.ls(Bash.pwd())
        
        if allElements.count < 1 {
            return []
        }
        
        var folders: [String] = []
        var files: [String] = []
        for (i, element) in allElements.enumerate() {
            if element.containsString(Const.Common.directoryConflictHelper) {
                files.append(allElements[i])
            } else {
                folders.append(allElements[i])
            }
        }
        
        return folders + files
    }
    
    override init() {
        super.init()
    }
    
    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void) {}
    
    func deleteElements(indexPaths: [NSIndexPath], completion: () -> Void, failure: (error: Error) -> Void) {
        for indexPath in indexPaths {
            Bash.rm(elementPath(indexPath))
        }
        completion()
    }
    
    func document(indexPath: NSIndexPath) -> Document {
        let docName = elements[indexPath.row]
        return documentByFileName(docName)
    }
    
    func elementPath(indexPath: NSIndexPath) -> String {
        let path = Bash.pwd() + "/" + elements[indexPath.row]
        return path
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
            
            let shouldHideButton = tableView.delegate as? MoveCopyViewController != nil
            
            cell.configureCell(documentByFileName(elements[indexPath.row]), isSearchResult: false, hideButton: shouldHideButton)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(FolderCell.cellIdentifier, forIndexPath: indexPath) as! FolderCell
            cell.folderNameLabel.text = elements[indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let _ = tableView.delegate as? MoveCopyViewController {
            return false
        } else {
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        Bash.rm(elementPath(indexPath))
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    func isDirectory(indexPath: NSIndexPath) -> Bool {
        let fileName = elements[indexPath.row]
        if fileName.containsString(Const.Common.directoryConflictHelper) {
            return false
        } else {
            return true
        }
    }
    
    //TODO: эта штука будет падать, если не чистить весь fileSystem после удаления из вк
    private func documentByFileName(fileName: String) -> Document {
        let realm = try! Realm()
        let docId = fileName.componentsSeparatedByString(Const.Common.directoryConflictHelper)[0]
        return realm.objects(Document).filter("id == \"\(docId)\"").first!
    }
    
}