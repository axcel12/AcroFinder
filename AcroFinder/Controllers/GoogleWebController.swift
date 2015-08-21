//
//  GoogleWebController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

class GoogleWebController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var url: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Google"
        
        webView.loadRequest(NSURLRequest(URL: url))
        self.webView.delegate = self
        
      self.tabBarController?.tabBar.hidden = true
    }
    
    //Activity Indicator
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    //Toolbar Actions
    
    @IBAction func doRefresh(sender: AnyObject) {
        webView.reload()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func goForward(sender: AnyObject) {
        webView.goForward()
    }
    
    @IBAction func openInSafari(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Open in Safari?", preferredStyle: .ActionSheet)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (alert) -> Void in
            UIApplication.sharedApplication().openURL(self.url)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        optionMenu.addAction(yesAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

}
