//
//  SearchResultsViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//


import UIKit
import MessageUI
import CoreData

class SearchResultsViewController: UITableViewController, UITableViewDataSource, MFMailComposeViewControllerDelegate, CDTReplicatorDelegate {
    
    //var userId:String!
    //Intialize some list items
    var acronymList: [AcronymItem] = []
    
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

    
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var labelCounter: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var acronym = [String]()
    var flag: String = "false"
    var word: String = " "
    var wordHist: String = " "
    var duplicate: Int = 0
    var acro: String = " "
    var arrayOfAcronyms: [acroMain] = [acroMain]()
    let lowImage = "favStarBlank.png"
    let mediumImage = "favStarYellow.png"
    var currentKey = 0
    
    var favAcronyms = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Start Loading Indicator for creation of index: don't needed after first load
        //self.searchDidStartLoading(self.myTableView
        
        
        // Setting up the refresh control
        /*self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("handleRefreshAction") , forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.tintColor = UIColor.blueColor()
        self.refreshControl?.beginRefreshing()*/
        
        //NOTE: No need to connect to the db this way
        //self.setupIMFDatabase(self.dbName)
        
        
        fetchFavoriteData()
        
        //Set tableView color
        self.myTableView.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        self.labelCounter.backgroundColor = UIColorFromHex(acroBack.colors[0].colorLabel)
        
        wordHist = word
        
        self.title = word
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if(!acroSearched.acronyms.isEmpty){
            for(var i = 0; i < acroSearched.acronyms.count; ++i){
                self.acronym.append(acroSearched.acronyms[i].name as String)
            }
        }
        self.setUpAcronym()
        self.labelCounterRefresh()
        
        //Logging
        self.logger.logInfoWithMessages("this is a info test log in SearchResultsViewController:viewDidLoad")
        
        
        self.myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellFound")
        self.myTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        /*if(!acroFlags.flags.isEmpty){
            flag = acroFlags.flags[0].value
        }
        
        if(flag == "true"){
            self.restartArrays()
        
            // Setting up the refresh control
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: Selector("handleRefreshAction") , forControlEvents: UIControlEvents.ValueChanged)
            self.refreshControl?.tintColor = UIColor.blueColor()
            self.refreshControl?.beginRefreshing()
        
            //Do not need to change the name of the database.
            //self.dbName = self.dbName + "_" + self.userId
        
            //self.setupIMFDatabase(self.dbName)
        }
        
        acroFlags.removeFlag()
        flag = "false"*/
        tableView.reloadData()
    }
    
    //NOTE: Will connect to the Node.js app instead
    //MARK: - Data Management
    
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
                self.refreshControl?.endRefreshing()
            })
            return
        }
        manager.remoteStore(dbName as String, completionHandler: { (store, error) -> Void in
            if (error != nil) {
                self.logger.logErrorWithMessages("Error creating remote data store \(error)")
            } else {
                self.remoteStore = store
                manager.setCurrentUserPermissions(DB_ACCESS_GROUP_MEMBERS, forStoreName: dbName as String, completionHander: { (success, error) -> Void in
                    if (error != nil) {
                        self.logger.logErrorWithMessages("Error setting permissions for user with error \(error)")
                    }
                    self.replicatorFactory = manager.replicatorFactory
                    self.pullReplication = manager.pullReplicationForStore(dbName as String)
                    self.pushReplication = manager.pushReplicationForStore(dbName as String)
                    self.pullItems()
                })
            }
            
        })
    }*/
    /*
    func listItems(cb:()->Void) {
        logger.logDebugWithMessages("listItems called")
        
        //Create query for search in database
        var queryPredicate: NSPredicate = NSPredicate(format: "acronym = %@", word)
        
        //Perform query
        var query:CDTCloudantQuery = CDTCloudantQuery(dataType: "AcronymItem", withPredicate: queryPredicate)
        self.datastore.performQuery(query, completionHandler: { (results, error) -> Void in
            if((error) != nil) {
                self.logger.logErrorWithMessages("AcronymItems failed with error \(error.description)")
            }
            else{
// POPULATES THE acronymList array.
                self.acronymList = results as! [AcronymItem]
                
                // Sort the array acronymList type AcronymItem with respect of its ranking
                self.acronymList.sort { (item1: AcronymItem, item2: AcronymItem) -> Bool in
                    return item1.key.compare(item2.key) == .OrderedDescending
                }
                
                // Appending all acronyms found to temporary array for coredata storing
// POPULATES acronym with acronymList objects
                if(!self.acronymList.isEmpty){
                    for(var i = 0; i < self.acronymList.count; ++i){
                        self.acronym.append(self.acronymList[i].meaning as String)
                    }
                }
//NOTE: NEED
                self.setUpAcronym()
                self.labelCounterRefresh()
    
                
                self.reloadLocalTableData()
            
//NOTE: NEED ONCE EVERYTHING HAS LOADED
                self.searchDidStopLoading(self.myTableView)
            }
            cb()
        })
    }*/
    
    //Most Popular
    /*func updateItem(item: AcronymItem) {
        self.datastore.save(item, completionHandler: { (object, error) -> Void in
            if(error != nil){
                self.logger.logErrorWithMessages("updateItem failed with error \(error)")
            } else {
                self.listItems({ () -> Void in
                    self.logger.logInfoWithMessages("Item succesfuly update")
                })
            }
        })
    }*/
    //END: of db connection
    
    //NOTE: Use functions from Node.js app to fetch and update
    // MARK: - Cloud Sync
    
    /*func pullItems() {
        var error:NSError?
        self.pullReplicator = self.replicatorFactory.oneWay(self.pullReplication, error: &error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error creating oneWay pullReplicator \(error)")
        }
        
        self.pullReplicator.delegate = self
        self.doingPullReplication = true
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull Items from Cloudant")
        
        error = nil
        println("Replicating data with NoSQL Database on the cloud")
        self.pullReplicator.startWithError(&error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error starting pullReplicator \(error)")
        }
    }
    
    func pushItems() {
        var error:NSError?
        self.pushReplicator = self.replicatorFactory.oneWay(self.pushReplication, error: &error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error creating oneWay pullReplicator \(error)")
        }
        
        self.pushReplicator.delegate = self
        self.doingPullReplication = false
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pushing Items to Cloudant")
        
        error = nil
        self.pushReplicator.startWithError(&error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error starting pushReplicator \(error)")
        }
    }*/
    //END: Cloud Sync
    
    
    //NOTE: No need of replicators
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
                self.refreshControl?.endRefreshing()
                self.myTableView.reloadData()
                self.tableView.reloadData()
            })
        }
    }*/
    
    /**
    * Called when a state transition to ERROR is completed.
    */
    
    /*func replicatorDidError(replicator: CDTReplicator!, info: NSError!) {
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Error replicating with Cloudant")
        self.logger.logErrorWithMessages("replicatorDidError \(info)")
        self.listItems({ () -> Void in
            self.refreshControl?.endRefreshing()
        })
    }*/
    //END: of replicators
    
    
    //MARK: CoreData and tableView functions
    
    override func viewDidDisappear(animated: Bool) {
        self.restartArrays()
    }
    
    func restartArrays(){
        //Set every array to 0 and reload again
        if(self.arrayOfAcronyms.count > 0){
            self.arrayOfAcronyms.removeAll(keepCapacity: false)
        }
        
        if(self.acronym.count > 0){
            self.acronym.removeAll(keepCapacity: false)
        }
        
        if(!acroSearched.acronyms.isEmpty){
            acroSearched.acronyms.removeAll(keepCapacity: false)
        }
//Won't need this one anymore
        if(self.acronymList.count > 0){
            self.acronymList.removeAll(keepCapacity: false)
        }
    }
    
    func saveFavoriteAcronym(acronym: String){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Favorite", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        item.setValue(acronym, forKey: "acronym")
        
        var error: NSError?
        if !managedContext.save(&error){
            println("Inside error: Could not save \(error), \(error?.userInfo)")
        }
        
        favAcronyms.append(item)
    }
    
    func removeFavoriteAcronym(index:NSIndexPath){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        
        context.deleteObject(favAcronyms[favAcronyms.count - (index.row+1)])
        
        var error: NSError? = nil
        if !context.save(&error){
            println("Inside error: \(error)")
            abort()
        }else{
            fetchFavoriteData()
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
    
    func sendEmail() {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//Will need to change
        return self.acronym.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ResultsTableViewCell = self.myTableView.dequeueReusableCellWithIdentifier("AcronymResult", forIndexPath: indexPath) as! ResultsTableViewCell
        
        
        let acroResult = self.arrayOfAcronyms[indexPath.row] as acroMain
        cell.setCell(acroResult.acroName, acroImage: self.getPriorityImage(acroResult.acroKey))
        cell.acroLabel.hidden = false
        cell.acroLabel.text = acroResult.acroName
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        //Set cells color
        cell.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        
        return cell
    }
    
    func urlForAcronyms(index: Int)-> NSURL{
        //Replaces spaces with "_"
        var safeString: String = self.acronym[index].stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        var urlString: String = "http://en.wikipedia.org/wiki/" + safeString
        var url:NSURL? = NSURL(string: urlString)
        return url!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        acro = acronym[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ResultsTableViewCell
        self.changePriorityForCell(cell)
    }
    
    //Wikipedia
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath){
        
        // Update keyVal for acronym at indexPath by 1
        let item = self.arrayOfAcronyms[indexPath.row] as acroMain
        //self.updateItemFromWikiSearch(item.acroName, pos: indexPath.row)
        
        // Push to Wikipedia
        var url = urlForAcronyms(indexPath.row)
        var webViewController = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        webViewController.url = url
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func changePriorityForCell(cell: ResultsTableViewCell){
        let indexPath = self.tableView.indexPathForCell(cell)
        let item = self.arrayOfAcronyms[indexPath!.row] as acroMain
        let selectedPriority = item.acroKey
        let newPriority = self.getNextPriority(selectedPriority)
        item.acroKey = newPriority
        cell.setCell(item.acroName, acroImage: self.getPriorityImage(item.acroKey))
        
        // Update keyVal counter
        //self.updateItemFromFavorites(item.acroName, pos: indexPath!.row)
        
        
        favoriteAcro(newPriority)
    }
    
    func getNextPriority(currentPriority: Int) -> Int {
        
        var newPriority: Int
        
        switch currentPriority {
        case 1:
            newPriority = 0
        default:
            newPriority = 1
        }
        return newPriority
    }
    
    func getPriorityImage (priority: Int) -> String {
        
        var resultImage : String
        
        switch priority {
        case 1:
            resultImage = self.mediumImage
        default:
            resultImage = self.lowImage
        }
        return resultImage
    }
    
    //Update favorites array
    func setUpAcronym(){
        if(acroFav.favorites.isEmpty){
            for(var i = 0; i < acronym.count; i++){
                var acronym = acroMain(acroName: self.acronym[i], acroKey: 0, acroImage: lowImage)
                arrayOfAcronyms.append(acronym)
            }
        }
        else{
            for(var i = 0; i < self.acronym.count; i++){
                for(var j = (acroFav.favorites.count - 1); j >= 0 ; --j){
                    if(self.acronym[i] == acroFav.favorites[j].name){
                        var acronymFound = acroMain(acroName: self.acronym[i], acroKey: 1, acroImage: mediumImage)
                        arrayOfAcronyms.append(acronymFound)
                        break
                    }
                    else{
                        if(j == 0){
                            var acronymNotFound = acroMain(acroName: self.acronym[i], acroKey: 0, acroImage: lowImage)
                            arrayOfAcronyms.append(acronymNotFound)
                        }
                    }
                }
            }
        }
    }
    
    func favoriteAcro(newKey: Int){
        var firstIndex:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if(newKey == 1){
            if(acroFav.favorites.isEmpty){
                acroFav.addAcronym(acro)
                self.saveFavoriteAcronym(acro)
            }
            else{
                for(var i = (acroFav.favorites.count - 1); i >= 0 ; --i){
                    if(acroFav.favorites[i].name == acro){
                        acroFav.favorites.removeAtIndex(i)
                    }
                }
                acroFav.addAcronym(acro)
                for(var i = (favAcronyms.count - 1); i >= 0; --i){
                    if(favAcronyms[i] == acro){
                        firstIndex = NSIndexPath(forRow: i, inSection: 0)
                        self.removeFavoriteAcronym(firstIndex)
                    }
                }
                self.saveFavoriteAcronym(acro)
            }

        }
        else{
            for(var j = (acroFav.favorites.count - 1); j >= 0 ; --j){
                if(acroFav.favorites[j].name == acro){
                    acroFav.favorites.removeAtIndex(j)
                    firstIndex = NSIndexPath(forRow: j, inSection: 0)
                    self.removeFavoriteAcronym(firstIndex)

                }
            }
        }
        self.tableView.reloadData()
    }
    
    //Most Popular
    /*func updateItemFromFavorites(acronym: String, pos: Int){
        var item = self.acronymList[pos]
        var hitVal = item.hits.integerValue + 2
        item.hits = hitVal
        
        self.updateItem(item)
    }
    
    func updateItemFromWikiSearch(acronym: String, pos: Int){
        var item = self.acronymList[pos]
        var hitVal = item.hits.integerValue + 1
        item.hits = hitVal
        
        self.updateItem(item)
    }
    
    func reloadLocalTableData() {
        if self.tableView != nil {
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
    }*/
    
    //Refresh sync with cloud
    /*func handleRefreshAction(){
        if (IBM_SYNC_ENABLE) {
            self.acronymList.removeAll(keepCapacity: false)
            acronym.removeAll(keepCapacity: false)
            
            labelCounter.text = "Loading..."
            
            arrayOfAcronyms = []
            
            self.pullItems()
        } else {
            self.listItems({ () -> Void in
                self.logger.logDebugWithMessages("Done refreshing table in handleRefreshAction")
                self.refreshControl?.endRefreshing()
                self.myTableView.reloadData()
                self.tableView.reloadData()
            })
        }
        self.myTableView.reloadData()
    }*/
    
    //New Acronym Segue
    @IBAction func segueToAddAcro(sender: AnyObject) {
        var newAcroController = storyboard?.instantiateViewControllerWithIdentifier("NewAcroController") as! NewAcroController
        newAcroController.controllerTitle = word
        navigationController?.pushViewController(newAcroController, animated: true)
    }
    
    func searchDidStartLoading(myTableView: UITableView!){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func searchDidStopLoading(myTableView: UITableView!){
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    func labelCounterRefresh(){
        //Label Counter
        if(acronym.count == 1){
            labelCounter.text = "\(self.acronym.count) acronym found"
        }else{
            labelCounter.text = "\(self.acronym.count) acronyms found"
        }
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}