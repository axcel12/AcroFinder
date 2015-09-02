//
//  NotFoundController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit
import MessageUI

class NotFoundController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet var oopsLabel: UILabel!
    @IBOutlet var googleSearchButton: UIButton!
    @IBOutlet var suggestionButton: UIButton!
    @IBOutlet var notFoundLabel: UILabel!
    @IBOutlet var notFoundRedLabel: UILabel!
    
    let robotoRegular = UIFont(name: "Roboto-Regular.ttf", size: 33)
    var word = ""
    var flag: String = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notFoundRedLabel.hidden = false
        notFoundRedLabel.text = "Acronym Not Found"
        
        notFoundLabel.text = " \"\(word)\" Not Found"
        notFoundLabel.font = UIFont(name: "Roboto-Regular.ttf", size: 20.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.reloadInputViews()

    /*
        if(!acroFlags.flags.isEmpty){
            flag = acroFlags.flags[0].value
        }
        
        if(flag == "true"){
            navigationController?.popViewControllerAnimated(true)
        }
        
        acroFlags.removeFlag()
        flag = "false"
    */
    }
    
    @IBAction func googleSearchAction(sender: UIButton) {
        var url = urlForAcronyms()
        
        var googleWebController = storyboard?.instantiateViewControllerWithIdentifier("GoogleWebController") as! GoogleWebController
        googleWebController.url = url
        navigationController?.pushViewController(googleWebController, animated: true)
    }

    func urlForAcronyms()-> NSURL{
        //Replaces spaces with "_"
        var safeString: String = self.word.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        var urlString: String = "https://www.google.com/#q=" + safeString + "+acronym+meaning"
        var url:NSURL? = NSURL(string: urlString)
        return url!
    }

    @IBAction func suggestionAction(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message:
            "Would you like to suggest \(word)?", preferredStyle: UIAlertControllerStyle.Alert)
        
        var dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        
        var yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.sendEmail()
        }
        
        alertController.addAction(dismissAction)
        alertController.addAction(yesAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            var emailTitle = "Suggesting \(word)"
            var messageBody = "Acronym/Abbreviation meaning:"
            var toRecipients = ["uconnibm@gmail.com"]
            var mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setToRecipients(toRecipients)
            
            self.presentViewController(mc, animated: true, completion: nil)
        }
        else {
            var alertView:UIAlertView = UIAlertView(title: "Email Not Available", message: nil, delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
        
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Mail cancelled")
        case MFMailComposeResultSaved.value:
            println("Mail saved")
        case MFMailComposeResultSent.value:
            println("Mail sent")
        case MFMailComposeResultFailed.value:
            println("Mail sent failure: %@", [error.localizedDescription])
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func segueToAdAcro(sender: AnyObject) {
        var newAcroController = storyboard?.instantiateViewControllerWithIdentifier("NewAcroController") as! NewAcroController
        newAcroController.controllerTitle = word
        navigationController?.pushViewController(newAcroController, animated: true)
    }
    
}
