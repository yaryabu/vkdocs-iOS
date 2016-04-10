//
//  AuthWebViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 04/04/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class AuthWebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var authDelegate: ShareViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadWebView()
    }
    
    func loadWebView() {
        let urlRequest = NSURLRequest(URL: NSURL(string: Const.Network.authUrlString)!)
        self.webView.loadRequest(urlRequest)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URL!.absoluteString
        
        if urlString.containsString("access_token") {
            let paramsString = urlString.componentsSeparatedByString("#")[1]
            authSuccessful(paramsString)
            return false
        } else if urlString.containsString("error_reason=user_denied") {
            userDeniedAuth()
            return false
        }
        
        return true
    }
    
    func authSuccessful(paramsString: String) {
        authDelegate.saveAuthData(paramsString)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDeniedAuth() {
        let error = NSError(domain: Const.Common.errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "User cancelled upload"])
        authDelegate.extensionContext?.cancelRequestWithError(error)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        let error = NSError(domain: Const.Common.errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "User cancelled upload"])
        authDelegate.extensionContext?.cancelRequestWithError(error)
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        webView.reload()
    }
    
}

