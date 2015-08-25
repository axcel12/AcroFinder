//
//  MostViewedController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

class MostViewedController: UITableViewController, UITableViewDelegate {
    /*
    var userId:String!
    //Intialize some list items
    var acroPopList: [AcronymItem] = []
    
    
    // Cloud sync properties
    var dbName:String = "acrofinderdb"
    var datastore: CDTStore!
    var remoteStore: CDTStore!
    
    var replicatorFactory: CDTReplicatorFactory!
    
    var pullReplication: CDTPullReplication!
    var pullReplicator: CDTReplicator!
    
    var pushReplication: CDTPushReplication!
    var pushReplicator: CDTReplicator!
    
    var doingPullReplication: Bool!
    */
    
    //logger
    let logger = IMFLogger(forName: "AcroFinder")
    
    @IBOutlet var popularView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Start Loading Indicator for creation of index: don't needed after first load
        self.searchDidStartLoading(self.popularView)
        
        //Set tableView color
        self.popularView.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        
        /*
        // Setting up the refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("handleRefreshAction") , forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.tintColor = UIColor.blueColor()
        self.refreshControl?.beginRefreshing()
        */
        
        //DB Connection
        //self.setupIMFDatabase(self.dbName)
        
        //Logging
        self.logger.logInfoWithMessages("this is a info test log in MostPopularViewController:viewDidLoad")
        
        
        self.popularView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellPopular")
        self.popularView.reloadData()

        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        self.popularView.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        navigationController?.navigationBar.barTintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        
        self.popularView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.reloadData()
    }
    
    /*
    //NOTE: No needed in Node.js app
    //MARK: - Data Management
    
    func setupIMFDatabase(dbName: NSString) {
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
    }
    
    func listItems(cb:()->Void) {
        logger.logDebugWithMessages("listItems called")
        
        // The data type to use for the AcronymItem class
        let dataType:String = self.datastore.mapper.dataTypeForClassName(NSStringFromClass(AcronymItem.classForCoder()))
        
        //Create index for acronym
        self.datastore.createIndexWithDataType(dataType, fields: ["acronym","hits"]) { (error:NSError!) -> Void in
            if ((error) != nil) {
                self.logger.logErrorWithMessages("Error creating index for acronym with error \(error.description)")
            } else {
                self.logger.logErrorWithMessages("Index successfuly created")
            }
        }
        
        let queryPredicate: NSPredicate = NSPredicate(format:"hits > 0")

        var query:CDTCloudantQuery = CDTCloudantQuery(dataType: "AcronymItem", withPredicate: queryPredicate)
        
        self.datastore.performQuery(query, completionHandler: { (results, error) -> Void in
            if((error) != nil) {
                self.logger.logErrorWithMessages("listItems failed with error \(error.description)")
            }
            else{
                self.acroPopList = results as! [AcronymItem]
                
                // Sort the array acroPopList type AcronymItem with respect of its ranking
                self.acroPopList.sort { (item1: AcronymItem, item2: AcronymItem) -> Bool in
                return item1.hits.compare(item2.hits) == .OrderedDescending
                }
                
                self.reloadLocalTableData()
                self.searchDidStopLoading(self.popularView)
            }
            cb()
        })
    }
    //END: of db connection
    
    //Fetch and upload acronyms
    // MARK: - Cloud Sync
    
    func pullItems() {
        var error:NSError?
        self.pullReplicator = self.replicatorFactory.oneWay(self.pullReplication, error: &error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error creating oneWay pullReplicator \(error)")
        }
        
        self.pullReplicator.delegate = self
        self.doingPullReplication = true
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pulling Items from Cloudant")
        
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
        
        
    }
    
    // NOTE: No more use of replicators
    // MARK: - CDTReplicator delegate methods
    
    /**
    * Called when the replicator changes state.
    */
    func replicatorDidChangeState(replicator: CDTReplicator!) {
        self.logger.logInfoWithMessages("replicatorDidChangeState \(CDTReplicator.stringForReplicatorState(replicator.state))")
    }
    
    /**
    * Called whenever the replicator changes progress
    */
    func replicatorDidChangeProgress(replicator: CDTReplicator!) {
        self.logger.logInfoWithMessages("replicatorDidChangeProgress \(CDTReplicator.stringForReplicatorState(replicator.state))")
    }
    
    /**
    * Called when a state transition to COMPLETE or STOPPED is
    * completed.
    */
    func replicatorDidComplete(replicator: CDTReplicator!) {
        
        self.logger.logInfoWithMessages("replicatorDidComplete \(CDTReplicator.stringForReplicatorState(replicator.state))")
        
        if self.doingPullReplication! {
            //done doing pull, lets start push
            self.pushItems()
        } else {
            //doing push, push is done read items from local data store and end the refresh UI
            self.listItems({ () -> Void in
                self.logger.logDebugWithMessages("Done refreshing table after replication")
                self.refreshControl?.endRefreshing()
            })
        }
        
    }
    
    /**
    * Called when a state transition to ERROR is completed.
    */
    
    func replicatorDidError(replicator: CDTReplicator!, info: NSError!) {
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Error replicating with Cloudant")
        self.logger.logErrorWithMessages("replicatorDidError \(info)")
        self.listItems({ () -> Void in
            self.refreshControl?.endRefreshing()
        })
    }
    //END: of replicators
    */
    
    //MARK: TableView functions
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Use new array with content from db
        /*
        if(self.acroPopList.count < 21){
            return self.acroPopList.count
        }else{
            return 20
        }
        */
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: MostViewedTableViewCell = self.popularView.dequeueReusableCellWithIdentifier("MostPopularResult", forIndexPath: indexPath) as! MostViewedTableViewCell
        
        let acroPop = self.acroPopList[indexPath.row]
        cell.setCell(acroPop.meaning as String)
        cell.popularLabel.hidden = false
        cell.popularLabel.text = acroPop.meaning as String
        cell.popularLabel.sizeToFit()
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        //Set cells color
        cell.backgroundColor = UIColorFromHex(acroBack.colors[0].colorViewController)
        
        return cell
    }
    
    func urlForAcronyms(acronym: String)-> NSURL{
        //Replaces spaces with "_"
        var safeString = acronym.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        return NSURL(string: "http://en.wikipedia.org/wiki/" + safeString)!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var acronymMeaning = acroPopList[indexPath.row].meaning as String
        
        var url = urlForAcronyms(acronymMeaning)
        
        var webViewController = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        webViewController.url = url
        navigationController?.pushViewController(webViewController, animated: true)
        
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func reloadLocalTableData() {
        self.tableView.reloadData()
    }
    
    /*
    func handleRefreshAction(){
        if (IBM_SYNC_ENABLE) {
            self.pullItems()
            self.tableView.reloadData()
        } else {
            self.listItems({ () -> Void in
                self.logger.logDebugWithMessages("Done refreshing table in handleRefreshAction")
                self.refreshControl?.endRefreshing()
            })
        }
        self.tableView.reloadData()
    }
    */
    
    func searchDidStartLoading(myTableView: UITableView!){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func searchDidStopLoading(myTableView: UITableView!){
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func preferredContentSizeChanged(notification: NSNotification) {
        var mostViewed: MostViewedTableViewCell = MostViewedTableViewCell()
        var popularLabel = mostViewed.popularLabel
        if(popularLabel != nil){
            popularLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
    }
}

