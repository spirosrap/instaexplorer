//
//  TMDBAuthViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

class InstaAuthViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var urlRequest: NSURLRequest? = nil
    var accessToken: String? = nil
    var completionHandler : ((success: Bool, accessToken: String?, errorString: String?) -> Void)? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        self.navigationItem.title = "Instagram Auth"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if urlRequest != nil {
            self.webView.loadRequest(urlRequest!)
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        //        if(webView.request!.URL!.absoluteString! == "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)/allow") {
        //
        //            self.dismissViewControllerAnimated(true, completion: { () -> Void in
        //                self.completionHandler!(success: true, errorString: nil)
        //            })
        //        }
           println(webView.request!.URL!.absoluteString!)
        if (urlRequest!.URL!.scheme == "instaplaces"){
            println(webView.request!.URL!.absoluteString!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    //http://technet.weblineindia.com/mobile/instagram-api-integration-in-ios-application/2/
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (request.URL!.scheme == "instaplaces"){
            var urlString = request.URL?.absoluteString
            var accessToken = urlString!.rangeOfString("#access_token=")
            if(accessToken != nil){
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.completionHandler!(success: true,accessToken: urlString!.substringFromIndex(accessToken!.endIndex),errorString: nil)
                })
            }else{
                completionHandler!(success: false,accessToken: nil,errorString: "Couldn't get Access Token")
            }
        }
        
        return true
    }
    
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}