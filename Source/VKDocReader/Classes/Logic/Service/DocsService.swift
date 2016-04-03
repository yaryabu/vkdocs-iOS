//
//  DocsService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

import Alamofire
import RealmSwift

class DocsService: Service {
    
    let authService: AuthService
    let userSettingsSerivce: UserSettingsSerivce
    
    init(authService: AuthService, userSettingsSerivce: UserSettingsSerivce) {
        self.authService = authService
        self.userSettingsSerivce = userSettingsSerivce
    }
    
    
    func getDocuments(completion: ([Document]) -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.get", parameters: self.getDocumentsParameters(), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            let parsedDocs = DocsParser.parseDocuments(json)
            Dispatch.mainQueue({ () -> () in
                completion(parsedDocs)
            })
        }) { (error) -> Void in
            if let error = self.createError(error) {
                failure(error: error)
            }
        }
    }
    
    func refreshDocument(document: Document, completion: (document: Document) -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.getById", parameters: self.refreshDocumentParameters(document), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            let parsedDocs = DocsParser.parseDocuments(json)
            Dispatch.mainQueue({ () -> () in
                completion(document: parsedDocs[0])
            })
            }) { (error) -> Void in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        }
    }
    
    func addDocumentToUser(document: Document, completion: (newDocumentId: String) -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.add", parameters: self.addDocumentToUserParameters(document), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            Dispatch.mainQueue({ () -> () in
                completion(newDocumentId: String(json["response"].int!))
            })
            }) { (error) -> Void in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        }
    }
    
    func editDocument(document: Document, newDocumentName: String, completion: () -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.edit", parameters: self.editDocumentParameters(document, newDocumentName: newDocumentName), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            Dispatch.mainQueue({ () -> () in
                completion()
            })
        }) { (error) -> Void in
            if let error = self.createError(error) {
                failure(error: error)
            }
        }
    }
    
    func deleteDocumentFromUser(document: Document, completion: () -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.delete", parameters: self.deleteDocumentFromUserParameters(document), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            Dispatch.mainQueue({ () -> () in
                completion()
            })
            }) { (error) -> Void in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        }
    }
    
    func downloadDocument(document: Document, progress: (totalRead: UInt, bytesToRead: UInt) -> Void, completion: (document: Document) -> Void, failure: (error: Error) -> Void) {
        
        if document.fileName != nil {
            return
        }
        
        if try! Reachability.reachabilityForInternetConnection().isReachable() == false {
            Dispatch.mainQueue({ () -> () in
                failure(error: Error(code: 0, message: "Не удалось подключиться к интернету"))
            })
            return
        }
        
        if userSettingsSerivce.useWifiOnly && userSettingsSerivce.isCurrentConnectionCellular {
            Dispatch.mainQueue({ () -> () in
                failure(error: Error(code: 0, message: "Загрузка через мобильный интернет запрещена в настройках"))
            })
            return
        }
        
        self.loadTaskManager.downloadFile(document.urlString, fileDirectory: document.fileDirectory, fileExtension: document.ext, fileId: document.id, progress: { (totalRead, bytesToRead) -> Void in
            Dispatch.mainQueue({ () -> () in
                progress(totalRead: totalRead, bytesToRead: bytesToRead)
            })
            }, completion: { (fileName, filePath) -> Void in
                Dispatch.mainQueue({ () -> () in
                    completion(document: document)
                })
            }) { (error) -> Void in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        }
    }
    
    func downloadExists(document: Document) -> Bool {
        return self.loadTaskManager.requestForIdExists(document.id)
    }
    
    func cancelDownload(document: Document) {
        self.loadTaskManager.cancelFileDownload(document.id)
    }
    
    func searchDocuments(query: String, offset: Int, completion: ([Document]) -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.search", parameters: self.searchDocumentsParameters(query, offset: String(offset)), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                })
                return
            }
            let parsedDocs = DocsParser.parseDocuments(json)
            Dispatch.mainQueue({ () -> () in
                completion(parsedDocs)
            })
            }) { (error) -> Void in
                if let error = self.createError(error) {
                    failure(error: error)
                }
        }
    }
    
    
    //MARK: Parameters builders
    private func getDocumentsParameters() -> [String:String] {
        let token = self.authService.token!
        return ["access_token":token]
    }
    
    private func searchDocumentsParameters(query: String, offset: String) -> [String:String] {
        let token = self.authService.token!
        return [
            "access_token":token,
            "q": query,
            "count": "50",
            "offset": offset
        ]
    }
    
    private func refreshDocumentParameters(document: Document) -> [String:String] {
        let token = self.authService.token!
        return [
            "access_token":token,
            "docs": document.ownerId + "_" + document.id
        ]
    }
    
    private func addDocumentToUserParameters(document: Document) -> [String:String] {
        let token = self.authService.token!
        return [
            "access_token":token,
            "owner_id":document.ownerId,
            "doc_id":document.id,
            "access_key":document.accessKey ?? ""
        ]
    }
    
    private func editDocumentParameters(document: Document, newDocumentName: String) -> [String:String] {
        let token = self.authService.token!
        return [
            "access_token":token,
            "owner_id":document.ownerId,
            "doc_id":document.id,
            "title": newDocumentName
        ]
    }
    
    private func deleteDocumentFromUserParameters(document: Document) -> [String:String] {
        let token = self.authService.token!
        return [
            "access_token":token,
            "owner_id":document.ownerId,
            "doc_id":document.id
        ]
    }
}
