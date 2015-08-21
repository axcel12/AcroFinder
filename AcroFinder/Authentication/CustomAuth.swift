//
//  CustomAuth.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//


import Foundation

var currentContext:IMFAuthenticationContext?

class CustomAuth:NSObject, IMFAuthenticationDelegate {
    
    let logger = IMFLogger(forName: "AcroFinder")
    
    func authenticationContext(context: IMFAuthenticationContext!, didReceiveAuthenticationChallenge challenge: [NSObject : AnyObject]!) {
        currentContext = context
        logger.logInfoWithMessages("didReceiveAuthenticationChallenge")
        showSecureTextEntryAlert()
    }
    
    func authenticationContext(context: IMFAuthenticationContext!, didReceiveAuthenticationFailure userInfo: [NSObject : AnyObject]!) {
        logger.logErrorWithMessages("custom authentication context failure")
    }
    
    
    func authenticationContext(context: IMFAuthenticationContext!, didReceiveAuthenticationSuccess userInfo: [NSObject : AnyObject]!) {
        logger.logInfoWithMessages("Custom authentication context sucess")
    }
    
    func showSecureTextEntryAlert() {
        var usernameTextField:UITextField?
        var passwordTextField:UITextField?
        let window:UIWindow?? = UIApplication.sharedApplication().delegate?.window
        let vc:UIViewController = (window!!.rootViewController as! UINavigationController).visibleViewController
        
        let title = NSLocalizedString("MobileFirst", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        let otherButtonTitle = NSLocalizedString("OK", comment: "")
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        
        // Add the text field for the secure text entry.
        alertController.addTextFieldWithConfigurationHandler { textField in
            usernameTextField = textField
            usernameTextField!.placeholder = NSLocalizedString("username", comment: "")
            usernameTextField!.secureTextEntry = false
        }
        
        // Add the text field for the secure text entry.
        alertController.addTextFieldWithConfigurationHandler { textField in
            passwordTextField = textField
            passwordTextField?.placeholder = NSLocalizedString("password", comment: "")
            passwordTextField?.secureTextEntry = true
        }
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            self.logger.logInfoWithMessages("The \"Secure Text Entry\" alert's cancel action occured.")
            self.showSecureTextEntryAlert()
        }
        
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { action in
            self.logger.logInfoWithMessages("Submitting auth...")
            self.logger.logInfoWithMessages("u:\(usernameTextField!.text)")
            currentContext?.submitAuthenticationChallengeAnswer(["userName":usernameTextField!.text, "password":passwordTextField!.text])
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        vc.presentViewController(alertController, animated: true, completion: nil)
    }
}