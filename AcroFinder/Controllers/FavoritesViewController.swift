//
//  FavoritesViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UITableViewController, UITableViewDelegate {
    
    @IBOutlet var favoriteAcronyms: UITableView!
    
    var favAcronyms = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        
        //Set favoriteView with color
        self.favoriteAcronyms.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        
        self.favoriteAcronyms.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellFav")
        self.favoriteAcronyms.dataSource = self
        self.favoriteAcronyms.delegate = self
        self.favoriteAcronyms.reloadData()
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchData()
        favoriteAcronyms.reloadData();
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        self.favoriteAcronyms.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        navigationController?.navigationBar.barTintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    func removeAcronym(index:NSIndexPath){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!

        context.deleteObject(favAcronyms[favAcronyms.count - (index.row+1)])
        
        var error: NSError? = nil
        if !context.save(&error){
            println("Inside error: \(error)")
            abort()
        }else{
            fetchData()
        }
    }
    
    func fetchData(){
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acroFav.favorites.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:FavoritesTableViewCell = self.favoriteAcronyms.dequeueReusableCellWithIdentifier("FavoritesResult", forIndexPath: indexPath) as! FavoritesTableViewCell
        
        cell.setCell(acroFav.favorites[indexPath.row].name)
        cell.favLabel.hidden = false
        cell.favLabel.text = acroFav.favorites[indexPath.row].name
        cell.favLabel.sizeToFit()
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        //Set cells with color
        cell.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            acroFav.favorites.removeAtIndex(indexPath.row)
            self.removeAcronym(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        })
        
        //removeFav(acroFav.favorites[indexPath.row].name)
        return [deleteAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        var acronymMeaning = acroFav.favorites[indexPath.row].name
        
        var url = urlForAcronyms(acronymMeaning)
        
        var webViewController = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        webViewController.url = url
        navigationController?.pushViewController(webViewController, animated: true)
        
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func urlForAcronyms(acronym: String)-> NSURL{
        //Replaces spaces with "_"
        var safeString = acronym.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        return NSURL(string: "http://en.wikipedia.org/wiki/" + safeString)!
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func preferredContentSizeChanged(notification: NSNotification) {
        var favView: FavoritesTableViewCell = FavoritesTableViewCell()
        var favoritesLabel = favView.favLabel
        if(favoritesLabel != nil){
            favoritesLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
    }
}
