//
//  AboutTableViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/12/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class AboutTableViewController: UITableViewController
{
    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        if indexPath.section==2
        {
            performSegueWithIdentifier("Legal", sender:indexPath)
        }
    }
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        if segue.identifier=="Legal"
        {
            let controller=segue.destinationViewController as! LegalViewController
            let index=(sender as! NSIndexPath).row
            controller.type=LegalViewControllerType(rawValue:index)!
        }
    }
}
