//
//  SettingsResultsControllerViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var aboutView: UITableView!
    @IBOutlet var versionCell: UITableViewCell!
    @IBOutlet var legalCell: UITableViewCell!
    
    
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var legalLabel: UILabel!
    @IBOutlet var versionNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About"
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        //Set aboutView with color
        self.aboutView.backgroundColor = UIColorFromHex(acroBack.colors[0].colorSettings)
        self.versionCell.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        self.legalCell.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        // Do any additional setup after loading the view.
    }
    
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row{
    
        case 0:
            
            var aboutAcroFinderController = storyboard?.instantiateViewControllerWithIdentifier("AboutAcroFinderController") as! AboutAcroFinderController
            navigationController?.pushViewController(aboutAcroFinderController, animated: true)
            
            break
            
        case 1:
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            break
            
        case 2:
            
            var legalViewController = storyboard?.instantiateViewControllerWithIdentifier("LegalViewController") as! LegalViewController
            navigationController?.pushViewController(legalViewController, animated: true)
            break
            
        default:
            break
        }
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func preferredContentSizeChanged(notification: NSNotification) {
        versionLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        versionNumberLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        legalLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
    }
}