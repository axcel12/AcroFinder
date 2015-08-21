//
//  SettingsResultsControllerViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit
import CoreData

class BackgroundColorController: UITableViewController {

    var selectedCell:String? = nil
    var lastSelected:NSIndexPath? = nil
    var selectedRow:Int = 0
    var lastRow:NSIndexPath? = nil
    
    @IBOutlet var defaultColor: UITableViewCell!
    @IBOutlet var lightBlue: UITableViewCell!
    @IBOutlet var gray: UITableViewCell!
    @IBOutlet var black: UITableViewCell!
    
    @IBOutlet var defaultColorLabel: UILabel!
    @IBOutlet var lightBlueLabel: UILabel!
    @IBOutlet var grayLabel: UILabel!
    @IBOutlet var blackLabel: UILabel!
    
    var background = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        
        fetchBackground()
        
        self.title = "Background Color"

        if(!acroBack.colors.isEmpty){ // Not empty case
            //Set up background and cells color from last selected row
            updateColors(acroBack.colors[0].colorSettings, colorCell: acroBack.colors[0].colorViewController)
            //Set up checkmark on the last selected row
            self.tableView.selectRowAtIndexPath(acroBack.colors[0].backKey!, animated: true, scrollPosition: UITableViewScrollPosition.None)
            self.tableView.cellForRowAtIndexPath(acroBack.colors[0].backKey!)?.accessoryType = .Checkmark
        }else{ // If empty case --> just to prevent
            var index:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.None)
            self.tableView.cellForRowAtIndexPath(index)?.accessoryType = .Checkmark
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row != lastSelected {
            if acroBack.colors.isEmpty == false {
                let lastCell = tableView.cellForRowAtIndexPath(acroBack.colors[0].backKey!)
                lastCell?.accessoryType = .None
            }
            if let lastSelectedIndexPath = lastSelected {
                let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
                oldCell?.accessoryType = .None
            }
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = .Checkmark
            
            lastSelected = indexPath
        }
        
        if(indexPath.item == 0){
            navigationController?.navigationBar.barTintColor = UIColorFromHex(0x254B95)
            tabBarController?.tabBar.barTintColor = UIColorFromHex(0xFFFFFF)
            tabBarController?.tabBar.tintColor = UIColorFromHex(0x254B95)
            updateColors(0xF1F1F7, colorCell: 0xFFFFFF)
            acroBack.changeColor(0x254B95, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: indexPath, colorWhite: 0xFFFFFF)
            saveBackground(indexPath.item)
        }else if(indexPath.item == 1){
            navigationController?.navigationBar.barTintColor = UIColorFromHex(0x006EB8)
            tabBarController?.tabBar.barTintColor = UIColorFromHex(0xFFFFFF)
            tabBarController?.tabBar.tintColor = UIColorFromHex(0x006EB8)
            updateColors(0xF1F1F7, colorCell: 0xFFFFFF)
            acroBack.changeColor(0x006EB8, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: indexPath, colorWhite: 0xFFFFFF)
            saveBackground(indexPath.item)
        }else if(indexPath.item == 2){
            navigationController?.navigationBar.barTintColor = UIColorFromHex(0x838383)
            tabBarController?.tabBar.barTintColor = UIColorFromHex(0xFFFFFF)
            tabBarController?.tabBar.tintColor = UIColorFromHex(0x838383)
            updateColors(0xF1F1F7, colorCell: 0xFFFFFF)
            acroBack.changeColor(0x838383, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: indexPath, colorWhite: 0xFFFFFF)
            saveBackground(indexPath.item)
        }else{
            navigationController?.navigationBar.barTintColor = UIColorFromHex(0x000000)
            tabBarController?.tabBar.barTintColor = UIColorFromHex(0xFFFFFF)
            tabBarController?.tabBar.tintColor = UIColorFromHex(0x000000)
            updateColors(0xF1F1F7, colorCell: 0xFFFFFF)
            acroBack.changeColor(0x000000, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: indexPath, colorWhite: 0xFFFFFF)
            saveBackground(indexPath.item)
        }
        
        selectedRow = indexPath.item
    }
    
    func updateColors(colorSettings: UInt32, colorCell: UInt32){
        self.tableView.backgroundColor = UIColorFromHex(colorSettings)
        self.defaultColor.backgroundColor = UIColorFromHex(colorCell)
        self.lightBlue.backgroundColor = UIColorFromHex(colorCell)
        self.gray.backgroundColor = UIColorFromHex(colorCell)
        self.black.backgroundColor = UIColorFromHex(colorCell)
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func saveBackground(key: Int){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Background", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        item.setValue(key, forKey: "key")
        
        var error: NSError?
        if !managedContext.save(&error){
            println("Inside error: Could not save \(error), \(error?.userInfo)")
        }
        background.insert(item, atIndex: 0)
    }
    
    func removeBackground(){ // Won't be needed due to inset method used instead of append
        var index:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        
        context.deleteObject(background[index.row])
        
        var error: NSError? = nil
        if !context.save(&error){
            println("Inside error: \(error)")
            abort()
        }else{
            fetchBackground()
        }
    }
    
    func fetchBackground(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Background")
        
        var error: NSError?
        
        if let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?{
            background = fetchedResults
        }else{
            println("Inside error: Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    
    func preferredContentSizeChanged(notification: NSNotification) {
        defaultColorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        lightBlueLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        grayLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        blackLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
}
