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
    var cached: String = ""
    
    var searchAcro:String = ""
    var mainColor:String = ""
    var notFound = ""
    
    var favAcronyms = [NSManagedObject]()
    var background = [NSManagedObject]()
    
    var cachedAcronyms:[AFAcronym] = []
    
    var foundAcronyms:[AFAcronym] = []
    
    var foundHistory: [AFAcronym] = []
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Core Data Load
        
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
        loadAllCachedHistory()
    }
    
    //MARK: More TableView Functions
    
    override func viewWillAppear(animated: Bool) {
        self.searchView.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        navigationController?.navigationBar.barTintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        
        self.restartArrays()
        
        self.tabBarController?.tabBar.hidden = false
        self.reloadInputViews()
    }
    
    override func viewDidDisappear(animated: Bool) {
        searchDidStopLoading(self.searchView)
        self.foundAcronyms.removeAll(keepCapacity: false)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        var frame: CGRect = self.view.frame
        frame.origin.y = 0 - keyboardFrame.size.height
        //self.view.frame = frame
        // convert label frame
        let comparisonFrame: CGRect = self.view.convertRect(searchTextField.frame, toView: self.view)
        // check if label is contained in self.view
        let isContainedInView:Bool = CGRectContainsRect(frame, comparisonFrame);
        println("Will Show - Is the view visible? \(isContainedInView)")
        //If the search text field is covered by the keyboard, move the frame up by the size of the search field.
        //This only works because I know the smallest sized screens only partially cover the screen.
        //A better solution would be to make the self.view.frame y match that of the searchTextField.
        //Not sure on the math
        if !isContainedInView {
            frame.origin.y = 0 - comparisonFrame.height
            self.view.frame = frame
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var frame: CGRect = self.view.frame
        frame.origin.y = 0
        //self.view.frame = frame
        let comparisonFrame: CGRect = self.view.convertRect(searchTextField.frame, toView: self.view)
        // check if label is contained in self.view
        let isContainedInView:Bool = CGRectContainsRect(frame, comparisonFrame);
        println("Will Hide - Is the view visible? \(isContainedInView)")
        if isContainedInView {
            self.view.frame = frame
        }
    }
    
    //MARK: CoreData Functions
    
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
    
    func searchAcronym(textField: UITextField!){
        searchDidStartLoading(self.searchView) //Shows spinner
        
        //Stores input from textField into searchAcro
        loadAllCachedAcronyms() //Reads from cached acronyms array
        
        searchAcro = textField.text.uppercaseString
        self.searchTextField.resignFirstResponder()
        
        //Gets rid of leading whitespace in textfield
        var trimmedAcro = searchAcro.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        self.word = trimmedAcro
        
        //Alert Sheet for when no text is entered
        /*
        * From the iOS Human Interface Guidelines I read that for this case we should use a simple Alert. I will change this from an Action Sheet to an Alert. Another option (that I think it's what you wanted) is to add a hidden label underneath the search box that could show an error message in red every time that something null is been searched (nothing in the search box) that disappears after 1 or 2 seconds. What do you think?
        */
        if (textField.text.isEmpty || trimmedAcro == "") {
            
            println("Search field is empty. Insert acronym please.")
            searchDidStopLoading(self.searchView)
            
            let actionSheetAlert: UIAlertController = UIAlertController(title: "AcroFinder Alert", message: "Search box is empty. Please, insert acronym.", preferredStyle: .ActionSheet)
            
            let dismissAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            
            actionSheetAlert.addAction(dismissAction)
            
            self.presentViewController(actionSheetAlert, animated: true, completion: nil)
        }
        else{
            var searchedAcronym:AFAcronym?
            println("----------------------------Cached acronyms total: \(cachedAcronyms.count)----------------------------")
            //This just adds the acronym not the meanings
            //Using the cached acronym array
            if cachedAcronyms.count > 0 {
                println("Cached Acronyms available, search here")
                //Filter the array to only the acronym matching the searched acronym
                var filtered = self.cachedAcronyms.filter { $0.acronym == self.word }
                //If one is found...
                if filtered.count > 0 {
                    searchedAcronym = filtered[0]
                }
            }
                //No cache, send a request to search
            else{
                println("Cached Acronyms not available, search in db")
                //self.cached = "not cached Acronyms"
                if let url = NSURL(string: "http://acronymfinder.mybluemix.net/api/v1/acronyms/" + self.word) {
                    if let data = NSData(contentsOfURL: url, options: .allZeros, error: nil) {
                        let json = JSON(data: data)
                        
                        println("1)--------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX------------------")
                        println(json)
                        println("2)--------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX------------------")
                        var meaningsArray:[AFMeaning] = []
                        //Construct the array of meanings
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
                        }
                        //Construct the acronym
                        if let acronymName = json[0]["value"]["acronym"].string,
                            let id = json[0]["value"]["_id"].string,
                            let rev = json[0]["value"]["_rev"].string {
                                searchedAcronym = AFAcronym(id: id, rev: rev, acronym: acronymName, meanings: meaningsArray)
                        }
                    }
                }
            }
            //Hide spinner
            self.searchDidStopLoading(self.searchView)
            
            //Transition to next viewController
            self.searchAcro(searchedAcronym)
        }
    }
    
    @IBAction func searchButton() {
        searchAcronym(self.searchTextField)
    }
    
    @IBAction func searchAction(textField: UITextField) {
        searchAcronym(textField)
    }
    
    //Changed this method to accept an optional since an acronym might not be found.
    //This needs to be cleaned up some more to support not found acronyms.
    //Current it does not transition to the next screen
    func searchAcro(foundAcro: AFAcronym?){
        if let foundAcronym = foundAcro{
            addHistory(foundAcronym)
            
            self.view.endEditing(true)
            self.searchTextField.text = ""
            
            if(self.activityIndicator.hidden){
                var resultViewController = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as! SearchResultsViewController
                resultViewController.word = foundAcronym.acronym
                resultViewController.searchedAcronym = foundAcronym //Saving the actual acronym
                //Set the AFAcronym var in resultViewController to be the found acronym in this controller
                navigationController?.pushViewController(resultViewController, animated: true)
            }
        }
        else {
            self.view.endEditing(true)
            self.searchTextField.text = ""
            
            if(self.activityIndicator.hidden){
                var notFoundController = storyboard?.instantiateViewControllerWithIdentifier("NotFoundController") as! NotFoundController
                notFoundController.word = self.word
                navigationController?.pushViewController(notFoundController, animated: true)
            }
        }
    }
    
    func addHistory(foundAcro: AFAcronym){
        
        var wordHist = foundAcro.acronym
        
        //If searched acronym is not null: This will never happen because now we are looking for an AFAcronym
        if(wordHist != " "){
            //Base case: if array is empty
            if(historyAcronym.histories.isEmpty){
                println("AFHISTORY ARRAY IS EMPTY")
                //Add acronym object to AFHistory
                historyAcronym.addAcronym(foundAcro)
            }
                //Otherwise: other cases > 1
            else{
                println("AFHISTORY IS NOT EMPTY")
                var firstIndex:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                for(var i = (historyAcronym.histories.count - 1); i >= 0 ; --i){
                    if(historyAcronym.histories[i].acronym == wordHist){
                        firstIndex = NSIndexPath(forRow: i, inSection: 0)
                        historyAcronym.histories.removeAtIndex(i)
                    }
                }
                historyAcronym.addAcronym(foundAcro)
                
                //Save back to file: override file
                println("Saving all history acronyms")
                self.saveAllHistoryAFAcronyms()
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
            MQALogger.log("Loading cached acronyms from file")
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            if let path = paths[0] as? String {
                var fullPath = path + "/acronyms.json"
            
                if let objects = NSKeyedUnarchiver.unarchiveObjectWithFile(fullPath) as? NSMutableArray {
                    MQALogger.log("Read file, decoding acronyms")
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
                    MQALogger.log("Problem reading from archive")
                    println("problem reading from archive")
                }
            }
        }
    }
    
    func loadAllCachedHistory() {
        println("Loading cached history acronyms")
        if (historyAcronym.histories.count == 0)
        {
            println("Clearing existing array")
            historyAcronym.histories.removeAll(keepCapacity: false)
            MQALogger.log("Loading cached history acronyms from file")
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            if let path = paths[0] as? String {
                var fullPath = path + "/history.json"
                
                if let objects = NSKeyedUnarchiver.unarchiveObjectWithFile(fullPath) as? NSMutableArray {
                    MQALogger.log("Read file, decoding history acronyms")
                    for savedItem in objects {
                        //println("Decoding acronym")
                        if let acronym = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? AFAcronym {
                            historyAcronym.histories.append(acronym)
                        }
                        else {
                            println("Error decoding acronym")
                        }
                    }
                    println("Cached acronyms set")
                }
                else {
                    MQALogger.log("Problem reading from archive")
                    println("problem reading from archive")
                }
            }
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

