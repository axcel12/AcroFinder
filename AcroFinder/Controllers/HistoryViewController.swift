//
//  HistoryViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UITableViewController, UITableViewDelegate {

    @IBOutlet var historyAcronyms: UITableView!
    var wordHist: String = " "
    
    var histAcronyms = [NSManagedObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetchData()
        
        //Set historyView with color
        self.historyAcronyms.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        
        self.historyAcronyms.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellHist")
        self.historyAcronyms.dataSource = self
        self.historyAcronyms.delegate = self
        self.historyAcronyms.reloadData()
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        //fetchData()
        historyAcronyms.reloadData();
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        self.historyAcronyms.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        navigationController?.navigationBar.barTintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        //Re-save all history acronyms: in case any of them was deleted
        self.saveAllHistoryAFAcronyms()
    }
    
    /*
    func removeAcronym(index:NSIndexPath){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        
        context.deleteObject(histAcronyms[histAcronyms.count - (index.row+1)])
        
        var error: NSError? = nil
        if !context.save(&error){
            println("Inside error: \(error)")
            abort()
        }else{
            fetchData()
        }
    }
    */
    
    /*
    func fetchData(){
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
    */
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyAcronym.histories.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:HistoryTableViewCell = self.historyAcronyms.dequeueReusableCellWithIdentifier("HistoryResult", forIndexPath: indexPath) as! HistoryTableViewCell
        
        cell.setCell(historyAcronym.histories[indexPath.row].acronym)
        cell.histLabel.hidden = false
        cell.histLabel.text = historyAcronym.histories[indexPath.row].acronym
        cell.histLabel.sizeToFit()
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        //Set cells with color
        cell.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            historyAcronym.histories.removeAtIndex(indexPath.row)
            //self.removeAcronym(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        })

        
        return [deleteAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var acronymMeaning = historyAcronym.histories[indexPath.row].acronym
        
        var searchResultsViewController = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as! SearchResultsViewController
        searchResultsViewController.word = acronymMeaning
        //searchResultsViewController.foundAcronyms.removeAll(keepCapacity: false)
        //searchResultsViewController.foundAcronyms.append(historyAcronym.histories[indexPath.row])
        searchResultsViewController.searchedAcronym = historyAcronym.histories[indexPath.row]
        navigationController?.pushViewController(searchResultsViewController, animated: true)
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func preferredContentSizeChanged(notification: NSNotification) {
        var historyView: HistoryTableViewCell = HistoryTableViewCell()
        var historyLabel = historyView.histLabel
        if(historyLabel != nil){
            historyLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
    }
    
    func saveAllHistoryAFAcronyms() {
        var items = NSMutableArray()
        for acronym in historyAcronym.histories {
            let item = NSKeyedArchiver.archivedDataWithRootObject(acronym)
            items.addObject(item)
            println("Saving acronym \(acronym.id)")
        }
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if let path = paths[0] as? String {
            var fullPath = path + "/history.json"
            println("Current path: \(fullPath)")
            let success = NSKeyedArchiver.archiveRootObject(items, toFile: fullPath)

            if success {
                println("Saving cache successful")
            }
            else {
                println("Saving cache unsuccessful")
            }
        }
    }
}
