//
//  VideosTableViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/23/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class VideosTableViewController: UITableViewController, ProfileDelegate
{
    @IBOutlet var myLbl:UILabel!
    @IBOutlet var favouritesCountLbl:UILabel!
    @IBOutlet var myCountLbl:UILabel!
    
    var vType:Int!
    
    override func viewDidLoad()
    {
        if vType==1
        {
            self.title="Videos"
            myLbl.text="My Videos"
        }
        
        UserConnector().get(nil, success:userSuccess, failure:userFailure)
    }
    
    func userSuccess(user:User)
    {
        myCountLbl.text="\(user.streams)"
        favouritesCountLbl.text="\(SongManager.getFavourites(vType).count)"
    }
    
    func userFailure(error:NSError)
    {
        
    }

    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        let identifier=indexPath.row==0 ? "GoToFavourites" : "GoToMy"
        
        performSegueWithIdentifier(identifier, sender:nil)
    }
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        if segue.identifier=="GoToFavourites"
        {
            let controller=segue.destinationViewController as! VideosViewController
            controller.vType=vType
        }
        else
        {
            let controller=segue.destinationViewController as! ProfileStatisticsViewController
            controller.type=ProfileStatisticsType(rawValue:3)!
            controller.profileDelegate=self
            controller.vType=vType
        }
    }
    
    func reload()
    {
        UserConnector().get(nil, success:userSuccess, failure:userFailure)
    }
    
    func close()
    {
        
    }
}
