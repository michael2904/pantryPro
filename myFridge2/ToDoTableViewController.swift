// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import UIKit

class ToDoTableViewController: UITableViewController {
    
    var records = [NSDictionary]()
    var apps = [AppModel]()
    var table : MSTable?
    var user : String?
    var counter = 0
    var Categ :String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            user = prefs.valueForKey("USERNAME") as NSString
        }
        println("Information: retrieved  records" + user!)
        
        
        let client = MSClient(applicationURLString: "https://mhacksvfridge.azure-mobile.net/", applicationKey:"uamhNvTvdRVSDpHRdpQLJkRuasIiad28")
        self.table = client.tableWithName("Profiles")!
        self.refreshControl?.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl?.beginRefreshing()
        self.onRefresh(self.refreshControl)
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the selected object to the new view controller.
    }
    
    func onRefresh(sender: UIRefreshControl!) {
        println(NSUserDefaults.standardUserDefaults().stringForKey("user"))
        let predicate = NSPredicate(format: "username = %@", NSUserDefaults.standardUserDefaults().stringForKey("user")!)
        println(predicate)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.table!.readWithPredicate(predicate) {
            result, totalCount, error  in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                println("Error: " + error.description)
                return
            }

            self.records = result as [NSDictionary]
            println("Information: retrieved %d records", result.count)
            
            let item = self.records[0]
            
            var invent = item["personalinventory"] as? NSString
            //println(invent)
            var inventNSDat = invent?.dataUsingEncoding(NSUTF8StringEncoding)
            // Get #1 app name using SwiftyJSON
            let json = JSON(data: inventNSDat!)
            //println(inventNSDat)
            
            if let appName = json["Category"][self.Categ].array {
                for appDict in appName {
                    var appName: String? = appDict["Ingredient"].string
                    var appURL: String? = appDict["Quantity"].string
                    
                    var app = AppModel(name: appName, appStoreURL: appURL)
                    self.apps.append(app)
                    
                }
                
                //4
                println(self.apps)
                println(self.apps[3])
                println(appName[3])
                
            }
            
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Table
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!
    {
        return "Complete"
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        let record = self.records[indexPath.row]
        let completedItem = record.mutableCopy() as NSMutableDictionary
        completedItem["complete"] = true
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.table!.update(completedItem) {
            (result, error) in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                println("Error: " + error.description)
                return
            }
            
            self.records.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.apps.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let item = self.apps[indexPath.row]
        
                cell.textLabel?.text = item.description

        //cell.textLabel?.text = "Nothing"
        cell.textLabel?.textColor = UIColor.blackColor ()

    return cell
    }
    

    
    
    // ToDoItemDelegate
    
    func didSaveItem(text: String)
    {
        if text.isEmpty {
            return
        }
        
        let itemToInsert = ["text": text, "complete": false]
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.table!.insert(itemToInsert) {
            (item, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                println("Error: " + error.description)
            } else {
                self.records.append(item)
                self.tableView.reloadData()
            }
        }
    }
}
