//
//  SearchViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    var word: String = ""
    
    var searchAcro:String = ""
    var mainColor:String = ""
    var notFound = ""
    
    var histAcronyms = [NSManagedObject]()
    var favAcronyms = [NSManagedObject]()
    var background = [NSManagedObject]()
    
    var cachedAcronyms:[AFAcronym] = []
    
    var foundAcronyms:[AFAcronym] = []
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        
        // Core Data Load
        
        fetchHistoryData()
        
        if(acroHist.histories.isEmpty){
            for(var i = 0; i < histAcronyms.count; ++i){
                let item = histAcronyms[i]
                acroHist.addAcronym((item.valueForKey("acronym") as? String)!)
            }
            println("History Loaded")
        }
        
        fetchFavoriteData()
        
        if(acroFav.favorites.isEmpty){
            for(var i = 0; i < favAcronyms.count; ++i){
                let item = favAcronyms[i]
                acroFav.addAcronym((item.valueForKey("acronym") as? String)!)
            }
            println("Favorites Loaded")
        }
        
        fetchBackgroundData()
        
        if(!background.isEmpty){
            let item = background[background.count - 1]
            let value: Int = (item.valueForKey("key") as? Int)!
            setUpColor(value)
            println("Background Loaded")
        }else{
            saveBackground(0)
            setUpColor(0)
            println("Background is empty: set to default")
        }
        
        
        settingsButton.enabled = true
        searchTextField.autocorrectionType = UITextAutocorrectionType.No
        
        loadAllCachedAcronyms()
    }
    
    //MARK: More TableView Functions
    
    override func viewWillAppear(animated: Bool) {
        self.searchView.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        navigationController?.navigationBar.barTintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        
        self.restartArrays()
    }
    
    override func viewDidDisappear(animated: Bool) {
        searchDidStopLoading(self.searchView)
        self.foundAcronyms.removeAll(keepCapacity: false)
    }
    
    //MARK: CoreData Functions
    
    func saveHistoryAcronym(acronym: String){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("History", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        item.setValue(acronym, forKey: "acronym")
        
        var error: NSError?
        if !managedContext.save(&error){
            println("Inside error: Could not save \(error), \(error?.userInfo)")
        }
        histAcronyms.insert(item, atIndex: 0)
    }
    
    func removeHistoryAcronym(index:NSIndexPath){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        
        context.deleteObject(histAcronyms[histAcronyms.count - (index.row+1)])
        
        var error: NSError? = nil
        if !context.save(&error){
            println("Inside error: \(error)")
            abort()
        }else{
            fetchHistoryData()
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
    
    func fetchBackgroundData(){
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
    //END: CoreData functions
    
    func setUpColor(key: Int){
        var index:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if(key == 0){
            index = NSIndexPath(forRow: key, inSection: 0)
            navigationController?.navigationBar.barTintColor = UIColorFromHex(0x254B95)
            tabBarController?.tabBar.barTintColor = UIColorFromHex(0xFFFFFF)
            tabBarController?.tabBar.tintColor = UIColorFromHex(0x254B95)
            self.searchView.backgroundColor = UIColorFromHex(0xFFFFFF)
            acroBack.changeColor(0x254B95, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: index, colorWhite: 0xFFFFFF)
        }else if(key == 1){
            index = NSIndexPath(forRow: key, inSection: 0)
            navigationController?.navigationBar.barTintColor = UIColorFromHex(0x006EB8)
            tabBarController?.tabBar.barTintColor = UIColorFromHex(0xFFFFFF)
            self.searchView.backgroundColor = UIColorFromHex(0xFFFFFF)
            tabBarController?.tabBar.tintColor = UIColorFromHex(0x006EB8)
            acroBack.changeColor(0x006EB8, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: index, colorWhite: 0xFFFFFF)
        }else if(key == 2){
            index = NSIndexPath(forRow: key, inSection: 0)
            navigationController?.navigationBar.barTintColor = UIColorFromHex(0x838383)
            tabBarController?.tabBar.barTintColor = UIColorFromHex(0xFFFFFF)
            self.searchView.backgroundColor = UIColorFromHex(0xFFFFFF)
            tabBarController?.tabBar.tintColor = UIColorFromHex(0x838383)
            acroBack.changeColor(0x838383, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: index, colorWhite: 0xFFFFFF)
        }else{
            index = NSIndexPath(forRow: key, inSection: 0)
            navigationController?.navigationBar.barTintColor = UIColorFromHex(0x000000)
            tabBarController?.tabBar.barTintColor = UIColorFromHex(0xFFFFFF)
            self.searchView.backgroundColor = UIColorFromHex(0xFFFFFF)
            tabBarController?.tabBar.tintColor = UIColorFromHex(0x000000)
            acroBack.changeColor(0x000000, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: index, colorWhite: 0xFFFFFF)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 12 // Bool
    }
    
    func searchDidStartLoading(searchView: UIView!){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func searchDidStopLoading(searchView: UIView!){
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    @IBAction func searchAction(textField: UITextField) {
        searchDidStartLoading(self.searchView)
        
        //Stores input from textField into searchAcro
        loadAllCachedAcronyms()
        
        searchAcro = textField.text.uppercaseString
        self.searchTextField.resignFirstResponder()
        
        //Gets rid of leading whitespace in textfield
        var trimmedAcro = searchAcro.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        self.word = trimmedAcro
        
        if (textField.text.isEmpty || trimmedAcro == "") {
            
            let alert = UIAlertView()
            alert.title = "No Text Entered"
            alert.message = "Please try again"
            alert.addButtonWithTitle("Dismiss")
            alert.show()
            textField.text = ""
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
        }
        else{
            println("----------------------------Cached acronyms total: \(cachedAcronyms.count)----------------------------")
            //This just adds the acronym not the meanings
            if cachedAcronyms.count > 0 {
                println("Cached Acronyms available, search here")
                var filtered = self.cachedAcronyms.filter { $0.acronym == self.word }
                if filtered.count > 0 {
                    println("Used fast search")
                    //We will not need this loop anymore
                    for meanings in filtered[0].meanings{
                        self.foundAcronyms.append(filtered[0])
                        println("-----------------------------------Meaning:\(meanings.name)---------------------------")
                    }
                }
            }
            else{
                println("Cached Acronyms not available, search in db")
                if let url = NSURL(string: "http://acronymfinder.mybluemix.net/api/v1/acronyms/" + self.word) {
                    if let data = NSData(contentsOfURL: url, options: .allZeros, error: nil) {
                        let json = JSON(data: data)
                        
                        println("1)--------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX------------------")
                        println(json)
                        
                        println("2)--------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX------------------")
                        var meaningsArray:[AFMeaning] = []
                        for meaning in json[0]["value"]["meanings"].arrayValue {
                            if let meaningName = meaning["name"].string,
                                let meaningRelevance = meaning["key"].int,
                                let meaningHits = meaning["hits"].int {
                                    let meaning = AFMeaning(name: meaningName, relevance: meaningRelevance, hits: meaningHits)
                                    meaningsArray.append(meaning)
                            }
                            else
                            {
                                println(meaning["name"].error)
                                println(meaning["key"].error)
                                println(meaning["hits"].error)
                            }
                            let meanings = meaning["name"].stringValue
                            
                            println("-----------------------------------Meaning:\(meanings)---------------------------")
                        }
                        if let acronymName = json[0]["value"]["acronym"].string,
                            let id = json[0]["value"]["_id"].string,
                            let rev = json[0]["value"]["_rev"].string {
                                let acronym:AFAcronym = AFAcronym(id: id, rev: rev, acronym: acronymName, meanings: meaningsArray)
                        }
                    }
                }
            }
            //Reload
            self.searchDidStopLoading(self.searchView)
            
            //Transition to next viewController
            self.searchAcro(self.word)
        }
    }
    
    func searchAcro(acronymSearched: String){
        
        if(self.foundAcronyms.count > 0){
            addHistory(acronymSearched)
            
            self.view.endEditing(true)
            self.searchTextField.text = ""
            
            if(self.activityIndicator.hidden){
                var resultViewController = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as! SearchResultsViewController
                resultViewController.word = acronymSearched
                resultViewController.foundAcronyms.append(self.foundAcronyms[0])
                navigationController?.pushViewController(resultViewController, animated: true)
            }
        }else{
            self.view.endEditing(true)
            self.searchTextField.text = ""
            
            if(self.activityIndicator.hidden){
                var notFoundController = storyboard?.instantiateViewControllerWithIdentifier("NotFoundController") as! NotFoundController
                notFoundController.word = acronymSearched
                navigationController?.pushViewController(notFoundController, animated: true)
            }
        }
    }
    
    func addHistory(wordHist: String){
        //Search Results View Controllers stuff
        if(wordHist != " "){
            if(acroHist.histories.isEmpty){
                acroHist.addAcronym(wordHist)
                self.saveHistoryAcronym(wordHist)
            }
            else{
                var firstIndex:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                for(var i = (acroHist.histories.count - 1); i >= 0 ; --i){
                    if(acroHist.histories[i].name == wordHist){
                        firstIndex = NSIndexPath(forRow: i, inSection: 0)
                        acroHist.histories.removeAtIndex(i)
                        self.removeHistoryData()
                    }
                }
                acroHist.addAcronym(wordHist)
                if(histAcronyms.count == 0){
                    for(var i = acroHist.histories.count - 1; i >= 0; --i){
                        self.saveHistoryAcronym(acroHist.histories[i].name)
                    }
                }else{
                    self.saveHistoryAcronym(wordHist)
                }
            }
        }
    }
    
    func restartArrays(){
        if(!self.foundAcronyms.isEmpty){
            self.foundAcronyms.removeAll(keepCapacity: false)
        }
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func loadAllCachedAcronyms() {
        println("Loading cached acronyms")
        if (cachedAcronyms.count == 0)
        {
            println("Clearing existing array")
            cachedAcronyms = []
            
            if let objects = NSKeyedUnarchiver.unarchiveObjectWithFile("Library/Caches/acronyms.json") as? NSMutableArray {
                for savedItem in objects {
                    //println("Decoding acronym")
                    if let acronym = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? AFAcronym {
                        cachedAcronyms.append(acronym)
                    }
                    else {
                        println("Error decoding acronym")
                    }
                }
                println("Cached acronyms set")
            }
            else {
                println("problem reading from archive")
            }
        }
    }
}

