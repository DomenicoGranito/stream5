//
//  ChannelsTableViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/23/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

protocol ProfileDelegate:class
{
    func reload()
    func close()
}

class ChannelsTableViewController: BaseViewController, ProfileDelegate
{
    @IBOutlet var followingValueLabel:UILabel!
    @IBOutlet var followersValueLabel:UILabel!
    @IBOutlet var blockedValueLabel:UILabel!
    
    override func viewDidLoad()
    {
        let activator=UIActivityIndicatorView(activityIndicatorStyle:.White)
        activator.startAnimating()
        
        navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
        UserConnector().get(nil, success:userSuccess, failure:userFailure)
    }
    
    func userSuccess(user:User)
    {
        followingValueLabel.text="\(user.following)"
        followersValueLabel.text="\(user.followers)"
        blockedValueLabel.text="\(user.blocked)"
        
        navigationItem.rightBarButtonItem=nil
    }
    
    func userFailure(error:NSError)
    {
        handleError(error)
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        performSegueWithIdentifier("GoToUsers", sender:indexPath)
    }

    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        let controller=segue.destinationViewController as! ProfileStatisticsViewController
        let index=(sender as! NSIndexPath).row
        controller.type=ProfileStatisticsType(rawValue:index)!
        controller.profileDelegate=self
    }
    
    func reload()
    {
        UserConnector().get(nil, success:userSuccess, failure:userFailure)
    }
    
    func close()
    {
        
    }
}
