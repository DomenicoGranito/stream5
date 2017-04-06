//
//  OptionsViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/5/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class OptionsViewController: UIViewController
{
    @IBOutlet var backgroundImageView:UIImageView?
    
    let menuItemTitlesArray:NSMutableArray=["Custom", "Title", "Artist", "Recently Added"]
    
    override func viewDidLoad()
    {
        
    }
    
    @IBAction func closeButtonPressed()
    {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 4
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
        
        cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row] as? String
        
        return cell
    }
}
