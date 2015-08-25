//
//  SearchViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UITextFieldDelegate, CDTReplicatorDelegate {
    
    //var userId:String!
    //Intialize some list items
    var acronymList: [AcronymItem] = []
    var filteredAcronymItems = [AcronymItem]()
    
    //NEW
    var itemsAcro = NSMutableArray()
    var result: [JSON] = []
    var objects = [String]()
    
    
    // Cloud sync properties
    /*var dbName:String = "acrofinderdb"
    var datastore: CDTStore!
    var remoteStore: CDTStore!
    
    var replicatorFactory: CDTReplicatorFactory!
    
    var pullReplication: CDTPullReplication!
    var pullReplicator: CDTReplicator!
    
    var pushReplication: CDTPushReplication!
    var pushReplicator: CDTReplicator!
    
    var doingPullReplication: Bool!*/
    
    //logger
    let logger = IMFLogger(forName: "AcroFinder")
    
    var refreshControl = UIRefreshControl()
    
    var acronym = [String]()
    var word: String = ""
    
    var searchAcro:String = ""
    var mainColor:String = ""
    var notFound = ""
    
    var histAcronyms = [NSManagedObject]()
    var favAcronyms = [NSManagedObject]()
    var background = [NSManagedObject]()
    
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
        
        
        //Logging
        self.logger.logInfoWithMessages("this is a info test log in main search view controller: SearchViewController")
    }
    
    //MARK: More TableView Functions
    
    override func viewWillAppear(animated: Bool) {
        self.searchView.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        navigationController?.navigationBar.barTintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
    }
    
    override func viewDidDisappear(animated: Bool) {
        searchDidStopLoading(self.searchView)
        self.acronym.removeAll(keepCapacity: false)
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
        //Stores input from textField into searchAcro
        searchAcro = textField.text.uppercaseString
        self.searchTextField.resignFirstResponder()
        searchDidStartLoading(self.searchView)
        
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
            
            /*
            //Tried this one several and different ways but did not work
            let url = NSURL(string: "http://acronymfinder.mybluemix.net/api/v1/acronyms/" + self.word)
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                println("1)--------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX------------------")
                
            let results = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                
            println(results)
                
            let json = JSON(results)
                
            println("2)--------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX------------------")
                
                for meanings in json[0]["value"]["meanings"].arrayValue {
                    let name = meanings["name"].stringValue
                    
                    self.acronym.insert(name, atIndex: 0)
                    
                    println(name)
                }
            }
            
//Add the results to the datatype
            //self.acronym.insert(self.acronymList[i].meaning as String, atIndex: 0)
            
            task.resume()*/
            
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
                        let name = meaning["name"].stringValue
                        
                        self.acronym.insert(name, atIndex: 0)
                        acroSearched.addAcronym(name)
                        //println(name)
                    }
                    if let acronymName = json[0]["value"]["acronym"].string,
                        let id = json[0]["value"]["_id"].string,
                        let rev = json[0]["value"]["_rev"].string {
                            let acronym:AFAcronym = AFAcronym(id: id, rev: rev, acronym: acronymName, meanings: meaningsArray)
                    }
                }
            }
            
            // Setting up the refresh control
            /*refreshControl.addTarget(self, action: Selector("handleRefreshAction") , forControlEvents: UIControlEvents.ValueChanged)
            refreshControl.tintColor = UIColor.blueColor()
            refreshControl.beginRefreshing()*/
            
//Reload
            self.searchDidStopLoading(self.searchView)
            
//Transition to next viewController
            self.searchAcro(self.word)
            
            // NOTE: No needed for new version: not direct connection to the db
            //self.setupIMFDatabase(self.dbName)
        }
    }
    
    func searchAcro(word: String){
        if(self.acronym.count > 0){
                notFound = "Found"
        }else{
            notFound = ""
        }
        
        if(notFound == "Found"){
            addHistory(word)
            
            self.view.endEditing(true)
            self.searchTextField.text = ""
            
            if(self.activityIndicator.hidden){
                var resultViewController = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as! SearchResultsViewController
                resultViewController.word = self.word
                navigationController?.pushViewController(resultViewController, animated: true)
            }
            
            notFound = ""
        }else{
            self.view.endEditing(true)
            self.searchTextField.text = ""
            
            if(self.activityIndicator.hidden){
                var notFoundController = storyboard?.instantiateViewControllerWithIdentifier("NotFoundController") as! NotFoundController
                notFoundController.word = self.word
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
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    //NOTE: Will not need all of this -> Will use Node.js app to connect to the server and then interact with the DB
    //MARK: - Data Management
    
    //DB Connection
    /*func setupIMFDatabase(dbName: NSString) {
        var dbError:NSError?
        let manager = IMFDataManager.sharedInstance() as IMFDataManager
        
        self.datastore = manager.localStore(dbName as String, error: &dbError)
        
        if ((dbError) != nil) {
            self.logger.logErrorWithMessages("Error creating local data store \(dbError)")
        }
        
        self.datastore.mapper.setDataType("AcronymItem", forClassName: NSStringFromClass(AcronymItem.classForCoder()))
        
        if (!IBM_SYNC_ENABLE) {
            self.listItems({ () -> Void in
                self.logger.logDebugWithMessages("Done refreshing we are not using cloud")
                self.refreshControl.endRefreshing()
                self.searchDidStopLoading(self.searchView)
            })
            return
        }
        manager.remoteStore(dbName as String, completionHandler: { (store:CDTStore!, error:NSError!) -> Void in
            if (error != nil) {
                self.logger.logErrorWithMessages("Error creating remote data store \(error)")
            } else {
                var createdStore:CDTStore = store
                println("Successfully created store: \(createdStore.name)")
                
                self.remoteStore = store
                manager.setCurrentUserPermissions(DB_ACCESS_GROUP_MEMBERS, forStoreName: dbName as String, completionHander: { (success, error) -> Void in
                    if (error != nil) {
                        self.logger.logErrorWithMessages("Error setting permissions for user with error \(error)")
                    }else{
                        //New: Just sends a log to the AMA
                        self.logger.logInfoWithMessages("Setting permissions was succesful")
                    }
                    
                    self.replicatorFactory = manager.replicatorFactory
                    self.pullReplication = manager.pullReplicationForStore(dbName as String)
                    self.pushReplication = manager.pushReplicationForStore(dbName as String)
                    self.pullItems()
                })
            }
            
        })
    }*/
    
    //Retrieving data: Create index and perform query
    /*func listItems(cb:()->Void) {
        logger.logDebugWithMessages("acronymsItems called")
        
        // The data type to use for the AcronymItem class
        let dataType:String = self.datastore.mapper.dataTypeForClassName(NSStringFromClass(AcronymItem.classForCoder()))
        
        
        //Create index for acronym
        self.datastore.createIndexWithDataType(dataType, fields: ["acronym","hits"]) { (error:NSError!) -> Void in
            if ((error) != nil) {
                self.logger.logErrorWithMessages("Error creating index for acronym with error \(error.description)")
            } else{
                self.logger.logErrorWithMessages("Index successfuly created")
            }
        }
        
        //Create query for search in database
        var queryPredicate: NSPredicate = NSPredicate(format: "acronym = %@", word)
        
        //Perform query
        var query:CDTCloudantQuery = CDTCloudantQuery(dataType: "AcronymItem", withPredicate: queryPredicate)
        self.datastore.performQuery(query, completionHandler: { (results, error) -> Void in
            if((error) != nil) {
                self.logger.logErrorWithMessages("acronymItems failed with error \(error.description)")
            }
            else{
                //println(results)
//NOTE
                self.acronymList = results as! [AcronymItem]

                if(!self.acronymList.isEmpty){
                    for(var i = 0; i < self.acronymList.count; ++i){
//NOTE
                        self.acronym.insert(self.acronymList[i].meaning as String, atIndex: 0)
                    }
                    println("---------------------------------ACRONYM FOUND-----------------------------")
                }else{
                    println("---------------------------------ACRONYM NOT FOUND-----------------------------")
                }
    
//NOTE
                self.reloadLocalTableData()
                self.searchDidStopLoading(self.searchView)
                
                // Add new function to find if acronym is in the
    
//NOTE
                self.searchAcro(self.word)
            }
            cb()
        })
    }*/
    //END: DB Connection
    
    //NOTE: Method will change and will connect to Node.js app through routes
    // MARK: - Cloud Sync
    
    //Fetch
    /*func pullItems() {
        var error:NSError?
        self.pullReplicator = self.replicatorFactory.oneWay(self.pullReplication, error: &error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error creating oneWay pullReplicator \(error)")
        }
        
        self.pullReplicator.delegate = self
        self.doingPullReplication = true
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pulling Items from Cloudant")
        
        error = nil
        println("Replicating data with NoSQL Database on the cloud")
        self.pullReplicator.startWithError(&error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error starting pullReplicator \(error)")
        }
    }*/
    
    //Update
    /*func pushItems() {
        var error:NSError?
        self.pushReplicator = self.replicatorFactory.oneWay(self.pushReplication, error: &error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error creating oneWay pullReplicator \(error)")
        }
        
        self.pushReplicator.delegate = self
        self.doingPullReplication = false
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pushing Items to Cloudant")
        
        error = nil
        self.pushReplicator.startWithError(&error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error starting pushReplicator \(error)")
        }
    }*/
    //END: of cloud sync
    
    
    //NOTE: Will not need of replicators
    // MARK: - CDTReplicator delegate methods
    
    /**
    * Called when the replicator changes state.
    */
    /*func replicatorDidChangeState(replicator: CDTReplicator!) {
        self.logger.logInfoWithMessages("replicatorDidChangeState \(CDTReplicator.stringForReplicatorState(replicator.state))")
    }*/
    
    /**
    * Called whenever the replicator changes progress
    */
    /*func replicatorDidChangeProgress(replicator: CDTReplicator!) {
        self.logger.logInfoWithMessages("replicatorDidChangeProgress \(CDTReplicator.stringForReplicatorState(replicator.state))")
        
    }*/
    
    /**
    * Called when a state transition to COMPLETE or STOPPED is
    * completed.
    */
    /*func replicatorDidComplete(replicator: CDTReplicator!) {
        self.logger.logInfoWithMessages("replicatorDidComplete \(CDTReplicator.stringForReplicatorState(replicator.state))")
        
        if self.doingPullReplication! {
            //done doing pull, lets start push
            self.pushItems()
        } else {
            //doing push, push is done read items from local data store and end the refresh UI
            self.listItems({ () -> Void in
                self.logger.logDebugWithMessages("Done refreshing table after replication")
                self.refreshControl.endRefreshing()
                self.searchDidStopLoading(self.searchView)
            })
        }
    }*/
    
    /**
    * Called when a state transition to ERROR is completed.
    */
    
    /*func replicatorDidError(replicator: CDTReplicator!, info: NSError!) {
        self.refreshControl.attributedTitle = NSAttributedString(string: "Error replicating with Cloudant")
        self.logger.logErrorWithMessages("replicatorDidError \(info)")
        self.listItems({ () -> Void in
            self.refreshControl.endRefreshing()
            self.searchDidStopLoading(self.searchView)
        })
    }*/
    //END: of replicators
    
    //Sort listItems
    /*func reloadLocalTableData() {
        self.filteredAcronymItems.sort { (item1: AcronymItem, item2: AcronymItem) -> Bool in
            return item1.meaning.localizedCaseInsensitiveCompare(item2.meaning as String) == .OrderedAscending
        }
    }*/
    
    //Refresh: pulls or stop searching
    /*func handleRefreshAction(){
        if (IBM_SYNC_ENABLE) {
            acronym.removeAll(keepCapacity: false)
            
            self.pullItems()
        } else {
            self.listItems({ () -> Void in
                self.logger.logDebugWithMessages("Done refreshing table in handleRefreshAction")
                self.refreshControl.endRefreshing()
                self.searchDidStopLoading(self.searchView)
            })
        }
    }*/

}

