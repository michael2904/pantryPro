////
////  RecipeGenerator.swift
////  myFridge2
////
////  Created by Michael Abdallah-Minciotti on 2015-01-18.
////  Copyright (c) 2015 Michael Abdallah-Minciotti. All rights reserved.
////

import Foundation

class RecipeGenerator: UITableViewController {
    
    var records1 = [NSDictionary]()
    var records2 = [NSDictionary]()
    var table1 : MSTable?
    var table2 : MSTable?
    var user : String?
    
    
    override func viewDidLoad() {
        //FIRST PULL INVENTORY INFO
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            user = prefs.valueForKey("USERNAME") as NSString
        }
        println("Information: retrieved  records1" + user!)
        
        
        let client1 = MSClient(applicationURLString: "https://mhacksvfridge.azure-mobile.net/",applicationKey:"uamhNvTvdRVSDpHRdpQLJkRuasIiad28")
        self.table1 = client1.tableWithName("Users")!
        self.refreshControl?.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl?.beginRefreshing()
        self.onRefresh(self.refreshControl)
        
        //PULL INFO FROM RECIPE DATABASE
        
        let prefs2:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        println("Information: retrieved  records" + user!)
        
        
        let client2 = MSClient(applicationURLString: "https://mhacksvfridge.azure-mobile.net/", applicationKey:"uamhNvTvdRVSDpHRdpQLJkRuasIiad28")
        self.table2 = client2.tableWithName("Recipes")!
        self.refreshControl?.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl?.beginRefreshing()
        self.onRefresh(self.refreshControl)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var Categ = segue.identifier
        // Pass the selected object to the new view controller.
    }
    
    func onRefresh(sender: UIRefreshControl!) {
        //FIRST GET INVENTORY INFO
        println(NSUserDefaults.standardUserDefaults().stringForKey("user"))
        let predicate1 = NSPredicate(format: "username = %@", NSUserDefaults.standardUserDefaults().stringForKey("user")!)
        println(predicate1)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.table1!.readWithPredicate(predicate1) {
            result1, totalCount1, error  in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                println("Error: " + error.description)
                return
            }
            
            self.records1 = result1 as [NSDictionary]
            println("Information: retrieved %d records", result1.count)
            
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
            // GET Recipe INFO
            let predicate2 = NSPredicate(value: true)
            println(predicate2)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.table2!.readWithPredicate(predicate2) {
                result2, totalCount2, error2  in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if error2 != nil {
                    println("Error: " + error2.description)
                    return
                }
                
                self.records2 = result2 as [NSDictionary]
                println("Information: retrieved %d records", result1.count)
                
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                
            }
            
        }
        
        // Table
        
        func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
        {
            return true
        }
        
        func tableView1(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
        {
            return UITableViewCellEditingStyle.Delete
        }
        
        //    func tableView2(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!
        //    {
        //        return "Complete"
        //    }
        //
        func tableView3(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
        {
            let record = self.records1[indexPath.row]
            var bool = true
            let CellIdentifier = "Cell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            for var i = 0 ; i<self.records1.count ; ++i {
                //   for records1[indexPath.row] in self.records1 {
                if self.records1[indexPath.row] != self.records2[indexPath.row]{
                    cell.textLabel?.text = "You should really get some groceries"
                    cell.textLabel?.textColor = UIColor.blackColor ()
                    bool = false
                    break
                }
                else{
                    continue
                }
            }
            if bool == true {
                cell.textLabel?.text = "Yay, we found a recipe!"
                cell.textLabel?.textColor = UIColor.blackColor ()
                
            }
        }
    }
}
