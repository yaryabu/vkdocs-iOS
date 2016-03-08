//
//  DocsService.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import Foundation

import Alamofire

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
                    return
                })
            }
            let parsedDocs = DocsParser.parseDocuments(json)
            Dispatch.mainQueue({ () -> () in
                completion(parsedDocs)
            })
        }) { (error) -> Void in
            failure(error: self.createError(error))
        }
    }
    
    func refreshDocument(document: Document, completion: (document: Document) -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.getById", parameters: self.refreshDocumentParameters(document), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                    return
                })
            }
            let parsedDocs = DocsParser.parseDocuments(json)
            Dispatch.mainQueue({ () -> () in
                completion(document: parsedDocs[0])
            })
            }) { (error) -> Void in
                failure(error: self.createError(error))
        }
    }
    
    func addDocumentToUser(document: Document, completion: (newDocumentId: String) -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.add", parameters: self.addDocumentToUserParameters(document), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                    return
                })
            }
            Dispatch.mainQueue({ () -> () in
                completion(newDocumentId: String(json["response"].int!))
            })
            }) { (error) -> Void in
                failure(error: self.createError(error))
        }
    }
    
    func deleteDocumentFromUser(document: Document, completion: () -> Void, failure: (error: Error) -> Void) {
        self.transport.getJSON(Const.Network.baseUrl + "/docs.delete", parameters: self.deleteDocumentFromUserParameters(document), completion: { (json) -> Void in
            if let error = self.checkError(json) {
                Dispatch.mainQueue({ () -> () in
                    failure(error: error)
                    return
                })
            }
            Dispatch.mainQueue({ () -> () in
                completion()
            })
            }) { (error) -> Void in
                failure(error: self.createError(error))
        }
    }
    
    func downloadDocument(document: Document, progress: (totalRead: UInt, bytesToRead: UInt) -> Void, completion: (document: Document) -> Void, failure: (error: Error) -> Void) {
        
        self.transport.downloadFile(document.urlString, fileDirectory: document.fileDirectory, fileExtension: document.ext, progress: { (totalRead, bytesToRead) -> Void in
            Dispatch.mainQueue({ () -> () in
                progress(totalRead: totalRead, bytesToRead: bytesToRead)
            })
            }, completion: { (fileName, filePath) -> Void in
                Dispatch.mainQueue({ () -> () in
                    document.fileName = fileName
                    document.filePath = filePath
                    completion(document: document)
                })
            }) { (error) -> Void in
                failure(error: self.createError(error))
        }
    }
    
    func cancelDownload(document: Document) {
        self.transport.cancelFileDownload(document.urlString)
    }
    
    
    //MARK: Parameters builders
    func getDocumentsParameters() -> [String:String] {
        let token = self.authService.token!
        return ["access_token":token]
    }
    
    func refreshDocumentParameters(document: Document) -> [String:String] {
        let token = self.authService.token!
        return [
            "access_token":token,
            "docs": document.ownerId + "_" + document.id
        ]
    }
    
    func addDocumentToUserParameters(document: Document) -> [String:String] {
        let token = self.authService.token!
        return [
            "access_token":token,
            "owner_id":document.ownerId,
            "doc_id":document.id,
            "access_key":document.accessKey ?? ""
        ]
    }
    
    func deleteDocumentFromUserParameters(document: Document) -> [String:String] {
        let token = self.authService.token!
        return [
            "access_token":token,
            "owner_id":document.ownerId,
            "doc_id":document.id
        ]
    }
}
