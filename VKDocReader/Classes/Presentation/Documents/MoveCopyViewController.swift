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
    @IBOutlet weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.title = "MOVECOPY_VIEW_CONTROLLER_SAVE_BAR_BUTTON_TITLE".localized
        }
    }
    
    @IBOutlet weak var exitButton: UIBarButtonItem!
    var currentPath: String! = Const.Directories.fileSystemDir
    
    var actionType: MoveCopyActionType = .AddToFolder
    var paths: [String] = []
    var fileNames: [String] = []
    
    var finalDirectory: String!

    lazy var userDocsDataSource = UserDocsDataSource()
    lazy var folderDataSource = FolderDataSource()
    
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
                if Bash.ls(currentPath).isEmpty {
                    presentCreateFolderViewController()
                }
            }
            tableView.dataSource = folderDataSource
        }
        
        if let ds = tableView.dataSource as? DataSource {
            ds.updateCache()
        }
        
        if isRootViewController {
            var title: String!
            switch actionType {
            case .Copy:
                title = "MOVECOPY_VIEW_CONTROLLER_COPY_TITLE".localized
            case .Move:
                title = "MOVECOPY_VIEW_CONTROLLER_MOVE_TITLE".localized
            case .AddToFolder:
                title = "MOVECOPY_VIEW_CONTROLLER_ADD_TO_FOLDER_TITLE".localized
            case .ChooseFileToAdd:
                title = "MOVECOPY_VIEW_CONTROLLER_CHOOSE_FILE_TO_ADD_TITLE".localized
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
        tableView.reloadData()
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
                    let error = Error(code: 0, message: "MOVECOPY_VIEW_CONTROLLER_FILE_ADDED_ALREADY_ERROR".localized)
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
                let error = Error(code: 0, message: "MOVECOPY_VIEW_CONTROLLER_CANNOT_COPY_THYSELF_ERROR".localized)
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
            if currentDirectoryItems.contains(name) && name.containsString(Const.Common.directoryConflictHelper) == false {
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
            
            let alert = UIAlertController(title: "MOVECOPY_VIEW_CONTROLLER_REPLACE_FOLDERS_QUESTION".localized, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let yesAction = UIAlertAction(title: "YES".localized, style: .Default, handler: { (action) in
                self.performActionAndDismiss()
            })
            let noAction = UIAlertAction(title: "NO".localized, style: .Cancel, handler: nil)
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
                    ToastManager.sharedInstance.presentInfo("MOVECOPY_VIEW_CONTROLLER_FILES_COPIED_SUCCESS".localized)
                    shouldShowNotification = false
                }
            } else if actionType == .Move {
                Bash.mv(path, to: newPath)
                if shouldShowNotification {
                    ToastManager.sharedInstance.presentInfo("MOVECOPY_VIEW_CONTROLLER_FILES_MOVED_SUCCESS".localized)
                    shouldShowNotification = false
                }
            }
        }
        
        for name in fileNames {
            Bash.touch(currentPath + "/" + name)
            if shouldShowNotification {
                ToastManager.sharedInstance.presentInfo("MOVECOPY_VIEW_CONTROLLER_FILES_ADDED_TO_FOLDER_SUCCESS".localized)
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentCreateFolderViewController() {
        let createFolderVC = storyboard!.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.editViewControllerNavigationController)
        
        Dispatch.mainQueueAfter(0.5, closure: {
            ToastManager.sharedInstance.presentError(Error(code: 0, message: "MOVECOPY_VIEW_CONTROLLER_NO_FOLDERS_ERROR".localized))
            
            Dispatch.mainQueueAfter(0.5, closure: {
                self.presentViewController(createFolderVC, animated: true, completion: nil)
            })
        })
    }
    
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}