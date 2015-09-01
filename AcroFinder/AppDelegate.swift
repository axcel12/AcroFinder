//
//  AppDelegate.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit
import CoreData
import Security

//let IBM_SYNC_ENABLE = true
let kSavedAcronymsKey = "savedAcronyms"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //var logger:IMFLogger?
    var tags = [String]()
    //var isUserAuthenticated = false
    
    var firstIndex = NSIndexPath(forRow: 0, inSection: 0)
    var navigationBarAppearace = UINavigationBar.appearance()
    var tabBarAppearance = UITabBar.appearance()
    var acronyms: [AFAcronym] = []
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //MQA setup
        MQALogger.settings().mode = MQAMode.QA
        MQALogger.settings().defaultUser = MQAAnonymousUser
        MQALogger.startNewSessionWithApplicationKey("1ga0a6615b4fe41ea6bf49e2e1242bf556744dd6c8g0g1g3e570d4f")
        NSSetUncaughtExceptionHandler(exceptionHandlerPointer)
        
        //Request to get all acronyms:
        let url = NSURL(string: "http://acronymfinder.mybluemix.net/api/v1/acronyms/")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            
            //let results = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            
            //Request will have a lot of data... not going to print that out yet.
            //println(results)
            MQALogger.log("Saving cached acronyms from request")
            let json = JSON(data: data)
            /*
            for (index, object) in json {
                let name = object["id"].stringValue
                println(name)
            }
            */
            //let json = JSON(data)
            //println(json[0]["id"].error)
            //let acronym = json[0]
            if let acronymsArray = json.array {
                for acronym in acronymsArray {
                    if let acronymID: String = acronym["id"].string,
                        let acronymRev: String = acronym["doc"]["_rev"].string,
                        let acronymAbbreviation: String = acronym["doc"]["acronym"].string,
                        let meaningsArray = acronym["doc"]["meanings"].array {
                            var acronymMeanings:[AFMeaning] = []
                            for meaning in meaningsArray {
                                if let meaningName = meaning["name"].string,
                                    let meaningRelevance = meaning["key"].int,
                                    let meaningHits = meaning["hits"].int {
                                        let meaning = AFMeaning(name: meaningName, relevance: meaningRelevance, hits: meaningHits)
                                        acronymMeanings.append(meaning)
                                }
                                else
                                {
                                    MQALogger.log("Error getting meaning info")
                                    println("Error getting meaning info")
                                    println(meaning["name"].error)
                                    println(meaning["key"].error)
                                    println(meaning["hits"].error)
                                }
                            }
                            let currentAcronym:AFAcronym = AFAcronym(id: acronymID, rev: acronymRev, acronym: acronymAbbreviation, meanings: acronymMeanings)
                            self.acronyms.append(currentAcronym)
                            println("Add acronym: \(currentAcronym.id)")
                    }
                    else
                    {
                        MQALogger.log("Error getting acronym info")
                        println("Error getting acronym info")
                        println(acronym["id"].error)
                        println(acronym["doc"]["_rev"].error)
                        println(acronym["doc"]["acronym"].error)
                        println(acronym["doc"]["meanings"].error)
                    }
                }
                self.saveAllAFAcronyms()
            }
            else
            {
                MQALogger.log("Error getting json array")
                println("Error getting json array")
                println(json.error)
            }
            
        }
        
        var checkValidation = NSFileManager.defaultManager()
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if let path = paths[0] as? String {
            var fullPath = path + "/acronyms.json"
            if (checkValidation.fileExistsAtPath(fullPath)){
                //TODO: Implement update system in the future.
                //We have the file, no need to send request.
                println("Cached acronyms file exists. Not pulling in acronyms.")
                MQALogger.log("Cached acronyms file exists. Not pulling in acronyms.")
            }
            else {
                MQALogger.log("Sending request to pull in cached acronyms")
                task.resume()
            }
        }
        
        
        //Assign values to colorMessenger
        if(acroBack.colors.isEmpty){
            acroBack.changeColor(0x254B95, colorViewController: 0xFFFFFF, colorLabel: 0x00CFA6, colorSettings: 0xF1F1F7, backKey: firstIndex, colorWhite: 0xFFFFFF)
        }
        
        //Navigation bar color
        navigationBarAppearace.tintColor = UIColorFromHex(acroBack.colors[0].colorWhite)
        navigationBarAppearace.barTintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        
        // change navigation item title color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        //Status bar color
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        //Changing tab bar controller color
        tabBarAppearance.tintColor = UIColorFromHex(acroBack.colors[0].colorNavigator)
        tabBarAppearance.barTintColor = UIColor.whiteColor()
    
        return true
    }
    
    func UIColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Consider if these calls should be in applicationDidEnterBackground and/or other application lifecycle event.
        // Perhaps [IMFLogger send]; should only happen when the end-user presses a button to do so, for example.
        // CAUTION: the URL receiving the uploaded log and analytics payload is auth-protected, so these calls
        // should only be made after authentication, otherwise your end-user will receive a random auth prompt!
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // helper functions for debuging
    func deleteAllKeysForSecClass(secClass: CFTypeRef) {
        let dict = NSMutableDictionary()
        let kSecAttrAccessGroupSwift = NSString(format: kSecClass)
        dict.setObject(secClass, forKey: kSecAttrAccessGroupSwift)
        SecItemDelete(dict)
    }
    
    func clearKeychain () {
        deleteAllKeysForSecClass(kSecClassIdentity)
        deleteAllKeysForSecClass(kSecClassGenericPassword)
        deleteAllKeysForSecClass(kSecClassInternetPassword)
        deleteAllKeysForSecClass(kSecClassCertificate)
        deleteAllKeysForSecClass(kSecClassKey)
    }

    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "AcroFinder.Test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("AcroFinder", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("AcroFinder.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func saveAllAFAcronyms() {
        var items = NSMutableArray()
        for acronym in acronyms {
            let item = NSKeyedArchiver.archivedDataWithRootObject(acronym)
            items.addObject(item)
            println("Saving acronym \(acronym.id)")
        }
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if let path = paths[0] as? String {
            var fullPath = path + "/acronyms.json"
            println("Current path: \(fullPath)")
            let success = NSKeyedArchiver.archiveRootObject(items, toFile: fullPath)
            //let success = NSKeyedArchiver.archiveRootObject(items, toFile: "Library/Caches/acronyms.json")
            if success {
                println("Saving cache successful")
            }
            else {
                println("Saving cache unsuccessful")
            }
        }
    }
    
}