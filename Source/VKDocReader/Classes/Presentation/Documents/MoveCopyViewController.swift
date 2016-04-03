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
        
        tableView.registerNib(UINib(nibName: "UserDocsTableViewCell", bundle: nil), forCellReuseIdentifier: UserDocsTableViewCell.cellIdentifier)
        tableView.registerNib(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: FolderCell.cellIdentifier)
        
        if actionType == .ChooseFileToAdd {
            if isRootViewController {
                tableView.dataSource = userDocsDataSource
            } else {
                tableView.dataSource = folderDataSource
            }
            navigationItem.rightBarButtonItem = nil
        } else {
            if isRootViewController {
                saveButton.enabled = false
            }
            tableView.dataSource = folderDataSource
        }
        
        if isRootViewController {
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
        
        //этот сценарий только для добавления файлов в папки
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
                if Bash.ls(finalDirectory).contains(docName) {
                    let error = Error(code: 0, message: "В папке уже есть этот файл")
                    ToastManager.sharedInstance.presentError(error)
                    return
                }
                Bash.touch(finalDirectory + "/" + docName)
                dismissViewControllerAnimated(true, completion: nil)
            }
            return
        }
        
        if folderDataSource.isDirectory(indexPath) {
            let newPath = Bash.pwd() + "/" + folderDataSource.elements[indexPath.row]
            if paths.contains(newPath) {
                let error = Error(code: 0, message: "Нельзя копировать папку в себя")
                ToastManager.sharedInstance.presentError(error)
                return
            }
            let vc = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.moveCopyViewController) as! MoveCopyViewController
            vc.actionType = self.actionType
            vc.paths = self.paths
            vc.fileNames = self.fileNames
            vc.finalDirectory = self.finalDirectory
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
        let currentDirectoryItems = Bash.ls(currentPath)
        var conflictingPaths: [String] = []
        for path in paths {
            let name = path.componentsSeparatedByString("/").last!
            if currentDirectoryItems.contains(name) {
                conflictingPaths.append(path)
            }
        }
        
        if conflictingPaths.count > 0 {
            var message = ""
            for path in conflictingPaths {
                let name = path.componentsSeparatedByString("/").last!
                message += "\(name)\n"
            }
            message = String(message.characters.dropLast())
            
            let alert = UIAlertController(title: "Заменить папки?", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let yesAction = UIAlertAction(title: "Да", style: .Default, handler: { (action) in
                self.performActionAndDismiss()
            })
            let noAction = UIAlertAction(title: "Нет", style: .Cancel, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            performActionAndDismiss()
        }
        
    }
    
    func performActionAndDismiss() {
        
        var shouldShowNotification = true
        
        for path in paths {
            let name = path.componentsSeparatedByString("/").last!
            let newPath = currentPath + "/" + name
            if actionType == .Copy {
                Bash.cp(path, to: newPath)
                if shouldShowNotification {
                    ToastManager.sharedInstance.presentInfo("Файлы скопированы")
                    shouldShowNotification = false
                }
            } else if actionType == .Move {
                Bash.mv(path, to: newPath)
                if shouldShowNotification {
                    ToastManager.sharedInstance.presentInfo("Файлы перемещены")
                    shouldShowNotification = false
                }
            }
        }
        
        for name in fileNames {
            Bash.touch(currentPath + "/" + name)
            if shouldShowNotification {
                ToastManager.sharedInstance.presentInfo("Файлы добавлены в папку")
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
}