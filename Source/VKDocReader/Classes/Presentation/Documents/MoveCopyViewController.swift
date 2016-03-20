//
//  MoveCopyViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 20/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

enum MoveCopyActionType {
    case Move
    case Copy
    case AddToFolder
}

class MoveCopyViewController: ViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var exitButton: UIBarButtonItem!
    var currentPath: String! = Const.Directories.fileSystemDir
    
    var actionType: MoveCopyActionType = .AddToFolder
    var paths: [String] = []
    var fileNames: [String] = []
    
    let folderDataSource = FolderDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = folderDataSource
        
        if isRootViewController {
            saveButton.enabled = false
            var title: String!
            switch actionType {
            case .Copy:
                title = "Копировать"
            case .Move:
                title = "Переместить"
            case .AddToFolder:
                title = "Добавить в папку"
            }
            navigationItem.title = title
        } else {
            navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
            navigationItem.title = currentPath.componentsSeparatedByString("/").last!
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Bash.cd(currentPath)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            Bash.cd("..")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("TAP", indexPath.row)
        if folderDataSource.isDirectory(indexPath) {
            let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewController) as! MoveCopyViewController
            vc.actionType = self.actionType
            vc.paths = self.paths
            vc.fileNames = self.fileNames
            let newPath = Bash.pwd() + "/" + folderDataSource.elements[indexPath.row]
            vc.currentPath = newPath
            navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        print("saveButtonPressed")
        
        for path in paths {
            let name = path.componentsSeparatedByString("/").last!
            let newPath = currentPath + "/" + name
            if actionType == .Copy {
                Bash.cp(path, to: newPath)
            } else {
                Bash.mv(path, to: newPath)
            }
        }
        
        for name in fileNames {
            Bash.touch(currentPath + "/" + name)
        }
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
}