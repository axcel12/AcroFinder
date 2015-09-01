//
//  NewAcroController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//
import UIKit

class NewAcroController: UIViewController {
    
    /*
    var userId:String!
    //Intialize some list items
    var acronymList: [AcronymItem] = []
    
    
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
    //let logger = IMFLogger(forName: "AcroFinder")
    
    var refreshControl = UIRefreshControl()
    
    
    var controllerTitle: String = "Add New Acronym"
    var acronym = [String]()
    var word: String = ""
    var repeated: String = ""
    @IBOutlet var acronymLabel: UILabel!
    @IBOutlet var meaningTextField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var newAcroView: UIView!
    @IBOutlet var savedLabel: UILabel!
    @IBOutlet var wrongNewAcro: UILabel!
    @IBOutlet var saveBarButton: UIBarButtonItem!


    override func viewDidLoad() {
        self.title = controllerTitle
        self.acronymLabel.text = controllerTitle
        self.activityIndicator.hidden = true
        self.savedLabel.hidden = true
        self.wrongNewAcro.hidden = true
        self.saveBarButton.enabled = false
        
        word = controllerTitle
        
        /*
        // Setting up the refresh control
        refreshControl.addTarget(self, action: Selector("handleRefreshAction") , forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.blueColor()
        refreshControl.beginRefreshing()
        */

        //DB Connection
        //self.setupIMFDatabase(self.dbName)
        
        //Logging
        //self.logger.logInfoWithMessages("this is a info test log in newAcroView:viewDidLoad")
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.savedLabel.hidden = true
        self.activityIndicator.hidden = true
        self.meaningTextField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Get new meaning
    @IBAction func newAcroMeaning(sender: AnyObject) {
        repeated = "New"
        self.wrongNewAcro.hidden = true
        searchDidStartLoading(self.newAcroView)
        var timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("checkNewMeaning"), userInfo: nil, repeats: false)
    }
    
    //Compare in db previous meanings
    func checkNewMeaning(){
        if(!self.acronym.isEmpty){
            for(var i = 0; i < self.acronym.count; ++i){
                if(meaningTextField.text!.uppercaseString == self.acronym[i].uppercaseString){
                    repeated = "Repeated"
                    break
                }
            }
        }
        
        if(repeated == "Repeated"){
            self.saveBarButton.enabled = false
            self.wrongNewAcro.text! = "This meaning is already used in \(controllerTitle)"
            self.wrongNewAcro.hidden = false
        }else if(repeated == "New"){
            self.saveBarButton.enabled = true
            self.wrongNewAcro.hidden = true
        }
        searchDidStopLoading(self.newAcroView)
    }
    
    //Save action
    @IBAction func saveAcronym(sender: AnyObject) {
        if(self.meaningTextField.text! != "" && count(self.meaningTextField.text!) > 4){
            searchDidStartLoading(self.newAcroView)
            self.saveBarButton.enabled = false
            //self.addItemFromtextField(word, meaning: meaningTextField.text!, keyVal: 0, hitVal: 0)
        }
    
        self.savedLabel.hidden = false
        self.savedLabel.text = "New Acronym Saved!"
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("updateLabel"), userInfo: nil, repeats: false)
        
    }
    
    func updateLabel(){
        if(self.savedLabel.text == "New Acronym Saved!"){
            self.savedLabel.hidden = true
            searchDidStopLoading(self.newAcroView)
            
            //acroFlags.addFlag("true")
            
            navigationController?.popViewControllerAnimated(true)
        }else{
            self.wrongNewAcro.hidden = true
        }
        searchDidStopLoading(self.newAcroView)
    }
    
    func searchDidStartLoading(newAcroView: UIView!){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func searchDidStopLoading(newAcroView: UIView!){
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    //NOTE: db connection
    //MARK: - Data Management
    /*
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
                self.refreshControl.endRefreshing()
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
        logger.logDebugWithMessages("acronymsItems called")
        
        //Create query for search in database
        var queryPredicate: NSPredicate = NSPredicate(format: "acronym = %@", word)
        
        //Perform query
        var query:CDTCloudantQuery = CDTCloudantQuery(dataType: "AcronymItem", withPredicate: queryPredicate)
        self.datastore.performQuery(query, completionHandler: { (results, error) -> Void in
            if((error) != nil) {
                self.logger.logErrorWithMessages("acronymItems failed with error \(error.description)")
            }
            else{
                self.acronymList = results as! [AcronymItem]
                if(!self.acronymList.isEmpty){
                    for(var i = 0; i < self.acronymList.count; ++i){
                        self.acronym.insert(self.acronymList[i].meaning as String, atIndex: 0)
                    }
                }
                self.reloadLocalTableData()
                self.searchDidStopLoading(self.newAcroView)
            }
            cb()
        })
    }
    
    //Add new acronym
    func createItem(item: AcronymItem) {
        self.datastore.save(item, completionHandler: { (object, error) -> Void in
            if(error != nil){
                self.logger.logErrorWithMessages("createItem failed with error \(error.description)")
            } else {
                self.listItems({ () -> Void in
                    self.logger.logInfoWithMessages("Item succesfuly created")
                })
            }
        })
    }
    //END: db connection and action
    
    
    //NOTE: Fetch and Update
    // MARK: - Cloud Sync
    
    func pullItems() {
        var error:NSError?
        self.pullReplicator = self.replicatorFactory.oneWay(self.pullReplication, error: &error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error creating oneWay pullReplicator \(error)")
        }
        
        self.pullReplicator.delegate = self
        self.doingPullReplication = true
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull Items from Cloudant")
        
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
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pushing Items to Cloudant")
        
        error = nil
        self.pushReplicator.startWithError(&error)
        if(error != nil){
            self.logger.logErrorWithMessages("Error starting pushReplicator \(error)")
        }
    }
    
    //NOTE: No use anymore with new Node.js app
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
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    /**
    * Called when a state transition to ERROR is completed.
    */
    
    func replicatorDidError(replicator: CDTReplicator!, info: NSError!) {
        self.refreshControl.attributedTitle = NSAttributedString(string: "Error replicating with Cloudant")
        self.logger.logErrorWithMessages("replicatorDidError \(info)")
        self.listItems({ () -> Void in
            self.refreshControl.endRefreshing()
        })
    }
    
    //Add item function
    func addItemFromtextField(acronym: String, meaning: String, keyVal: Int, hitVal: Int) {
        var item = AcronymItem()
        item.acronym = acronym
        item.meaning = meaning
        item.key = keyVal
        item.hits = hitVal
        self.createItem(item)
    }
    
    func reloadLocalTableData() {
        if self.newAcroView != nil {
            self.logger.logDebugWithMessages("View is null but there is not need to reloadData")
        }
    }
    
    //Refresh action for after item is saved
    func handleRefreshAction(){
        if (IBM_SYNC_ENABLE) {
            acronym.removeAll(keepCapacity: false)
            
            self.pullItems()
        } else {
            self.listItems({ () -> Void in
                self.logger.logDebugWithMessages("Done refreshing table in handleRefreshAction")
                self.refreshControl.endRefreshing()
            })
        }
    }
    */
}
