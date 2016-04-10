//
//  AuthWebViewController.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 05/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

class AuthWebViewController: ViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            navigationItem.title = "WEBVIEW_AUTH_TITLE".localized
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadWebView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    func loadWebView() {
        let urlRequest = NSURLRequest(URL: NSURL(string: Const.Network.authUrlString)!)
        self.webView.loadRequest(urlRequest)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URL!.absoluteString
        
        if urlString.containsString("access_token") {
            let paramsString = urlString.componentsSeparatedByString("#")[1]
            self.authSuccessful(paramsString)
            return false
        } else if urlString.containsString("error_reason=user_denied") {
            self.userDeniedAuth()
            return false
        }
        
        return true
    }
    
    func authSuccessful(paramsString: String) {
        self.serviceLayer.authService.saveAuthData(paramsString)
        let storyboard = UIStoryboard(name: Const.Common.mainStoryboardName, bundle: NSBundle.mainBundle())
        let window = UIApplication.sharedApplication().windows[0]
        window.rootViewController = storyboard.instantiateViewControllerWithIdentifier(Const.StoryboardIDs.tabBarController)
        Analytics.logUserAuthorized()
    }
    
    func userDeniedAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        self.webView.reload()
    }
    
}
