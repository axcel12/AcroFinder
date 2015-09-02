//
//  SettingsViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class SettingsViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate{
    
    @IBOutlet var settingsView: UITableView!
    
    @IBOutlet var cellOne: UITableViewCell!
    @IBOutlet var cellTwo: UITableViewCell!
    @IBOutlet var cellThree: UITableViewCell!
    @IBOutlet var cellFour: UITableViewCell!
    @IBOutlet var cellFive: UITableViewCell!
    @IBOutlet var cellSix: UITableViewCell!
    @IBOutlet var cellSeven: UITableViewCell!
    
    @IBOutlet var aboutLabel: UILabel!
    @IBOutlet var helpLabel: UILabel!
    @IBOutlet var fontLabel: UILabel!
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet var clearHistoryLabel: UILabel!
    @IBOutlet var clearFavoritesLabel: UILabel!
    @IBOutlet var contactUsLabel: UILabel!
    
    var histAcronyms = [NSManagedObject]()
    var favAcronyms = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        fetchHistoryData()
        
        fetchFavoriteData()
        
        //Set settings view and cells with color
        updateColors(acroBack.colors[0].colorSettings, colorViewController: acroBack.colors[0].colorViewController)
    }
    
    override func viewWillAppear(animated: Bool) {
        updateColors(acroBack.colors[0].colorSettings, colorViewController: acroBack.colors[0].colorViewController)
        navigationController?.navigationBar.barTintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        switch indexPath.section{
            
        case 0:
            switch indexPath.row{
            
            case 0:
                var aboutView = storyboard?.instantiateViewControllerWithIdentifier("AboutViewController") as! AboutViewController
                navigationController?.pushViewController(aboutView, animated: true)
                break
                
            case 1:
               
                var helpView = storyboard?.instantiateViewControllerWithIdentifier("HelpViewController") as! HelpViewController
                navigationController?.pushViewController(helpView, animated: true)
               
                break
                
            default:
                break

            }
        case 1:
            switch indexPath.row{
            
            case 0:
                var settingsResults = storyboard?.instantiateViewControllerWithIdentifier("BackgroundColorController") as! BackgroundColorController
                navigationController?.pushViewController(settingsResults, animated: true)
                break
                
            default:
                break
    
            }
            
        case 2:
            switch indexPath.row{
            
            case 0:
                
                
                var alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                
                var defaultAction: UIAlertAction = UIAlertAction(title: "Clear Favorites", style: .Destructive) { (defaultAction) -> Void in
                    if(!acroFav.favorites.isEmpty){
                        acroFav.favorites.removeAll(keepCapacity: false)
                    }else if(!self.favAcronyms.isEmpty){
                        self.removeFavoriteData()
                    }
                    return
                }
                alert.addAction(defaultAction)
                
                var cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { (cancelAction) -> Void in
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
                alert.addAction(cancelAction)
                //alert.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem //Needed for iPad support?
                
                self.presentViewController(alert, animated: true, completion: nil)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
            case 1:
                
                var alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                
                var defaultAction: UIAlertAction = UIAlertAction(title: "Clear History", style: .Destructive) { (defaultAction) -> Void in
                    if(!acroFav.favorites.isEmpty){
                        acroFav.favorites.removeAll(keepCapacity: false)
                    }else if(!self.favAcronyms.isEmpty){
                        self.removeFavoriteData()
                    }
                    return
                }
                alert.addAction(defaultAction)
                
                var cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { (cancelAction) -> Void in
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
                alert.addAction(cancelAction)
                //alert.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem //Needed for iPad support?
                
                self.presentViewController(alert, animated: true, completion: nil)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

    
            default:
                break
            }
        case 3:
            self.sendEmail()
            break
        
        default:
            break
            
        }
    }
    
    func fetchHistoryData(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "History")
        
        var error: NSError?
        
        if let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?{
            histAcronyms = fetchedResults
        }else{
            println("Inside error: Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func removeHistoryData(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        
        for(var i = 0; i < histAcronyms.count; ++i){
            context.deleteObject(histAcronyms[i])
        }
        
        var error: NSError? = nil
        if !context.save(&error){
            println("Inside error: \(error)")
            abort()
        }else{
            fetchHistoryData()
        }
    }
    
    func fetchFavoriteData(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Favorite")
        
        var error: NSError?
        
        if let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?{
            favAcronyms = fetchedResults
        }else{
            println("Inside error: Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func removeFavoriteData(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        
        for(var i = 0; i < favAcronyms.count; ++i){
            context.deleteObject(favAcronyms[i])
        }
        
        var error: NSError? = nil
        if !context.save(&error){
            println("Inside error: \(error)")
            abort()
        }else{
            fetchFavoriteData()
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            var emailTitle = "Feedback"
            var messageBody = "Feature request or bug report?"
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
    
    func updateColors(colorSettings: UInt32, colorViewController: UInt32){
        self.settingsView.backgroundColor = UIColorFromHex(colorSettings)
        self.cellOne.backgroundColor = UIColorFromHex(colorViewController)
        self.cellTwo.backgroundColor = UIColorFromHex(colorViewController)
        self.cellFour.backgroundColor = UIColorFromHex(colorViewController)
        self.cellFive.backgroundColor = UIColorFromHex(colorViewController)
        self.cellSix.backgroundColor = UIColorFromHex(colorViewController)
        self.cellSeven.backgroundColor = UIColorFromHex(colorViewController)
    }

    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func saveAllHistoryAFAcronyms() {
        var items = NSMutableArray()
        for acronym in historyAcronym.histories {
            let item = NSKeyedArchiver.archivedDataWithRootObject(acronym)
            items.addObject(item)
            println("Saving acronym \(acronym.id)")
        }
        //Change path
        NSKeyedArchiver.archiveRootObject(items, toFile: "Library/Caches/history.json")
    }
    
    
    func preferredContentSizeChanged(notification: NSNotification) {
        aboutLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        helpLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        fontLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        backgroundLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        clearHistoryLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        clearFavoritesLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        contactUsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
}