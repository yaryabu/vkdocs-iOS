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
    case ChooseFileToAdd
}

class MoveCopyViewController: ViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var exitButton: UIBarButtonItem!
    var currentPath: String! = Const.Directories.fileSystemDir
    
    var actionType: MoveCopyActionType = .AddToFolder
    var paths: [String] = []
    var fileNames: [String] = []
    
    var finalDirectory: String!

    let userDocsDataSource = UserDocsDataSource()
    let folderDataSource = FolderDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if actionType == .ChooseFileToAdd {
            if isRootViewController {
                tableView.dataSource = userDocsDataSource
            } else {
                tableView.dataSource = folderDataSource
            }
            navigationItem.rightBarButtonItem = nil
        } else {
            tableView.dataSource = folderDataSource
        }
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
            case .ChooseFileToAdd:
                title = "Выбрать файл"
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
        
        if let _ = tableView.dataSource as? UserDocsDataSource {
            if indexPath.section == 0 {
                let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewController) as! MoveCopyViewController
                vc.actionType = self.actionType
                vc.finalDirectory = self.finalDirectory
                let newPath = userDocsDataSource.folderPath(indexPath)!
                vc.currentPath = newPath
                navigationController!.pushViewController(vc, animated: true)
            } else {
                let docName = userDocsDataSource.document(indexPath).fileDirectory.componentsSeparatedByString("/").last!
                Bash.touch(finalDirectory + "/" + docName)
                dismissViewControllerAnimated(true, completion: nil)
            }
            return
        }
        
        if folderDataSource.isDirectory(indexPath) {
            let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewController) as! MoveCopyViewController
            vc.actionType = self.actionType
            vc.paths = self.paths
            vc.fileNames = self.fileNames
            vc.finalDirectory = self.finalDirectory
            let newPath = Bash.pwd() + "/" + folderDataSource.elements[indexPath.row]
            vc.currentPath = newPath
            navigationController!.pushViewController(vc, animated: true)
        } else {
            if actionType == .ChooseFileToAdd {
                let elementPath = folderDataSource.elementPath(indexPath)
                let elementName = elementPath.componentsSeparatedByString("/").last!
                Bash.cp(elementPath, to: finalDirectory + "/" + elementName)
                dismissViewControllerAnimated(true, completion: nil)
            }
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