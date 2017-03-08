//
//  MyLibViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 4/2/2017.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

class RecentlyPlayedCell:UITableViewCell
{
    @IBOutlet var videoTitleLbl:UILabel?
    @IBOutlet var artistNameLbl:UILabel?
    @IBOutlet var videoThumbnailImageView:UIImageView?
}

class MyLibViewController: UIViewController
{
    @IBOutlet var itemsTbl:UITableView?
    
    let menuItemTitlesArray=["Playlists", "Live Streams", "Videos", "Series", "Channels", "Upcoming Events"]
    let menuItemIconsArray=["playlist", "youtube", "internet", "Series", "channels", "time"]
    
    var recentlyPlayed:[NSManagedObject]?
    let (host, _, _, _, _)=Config.shared.wowza()
    
    override func viewWillAppear(animated:Bool)
    {
        recentlyPlayed=SongManager.getRecentlyPlayed()
        
        itemsTbl?.reloadData()
    }
    
    @IBAction func myaccount()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("myProfileViewControllerId") as! myProfileViewController
        vc.user=UserContainer.shared.logged()
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if indexPath.row<7
        {
            return 44
        }
        else
        {
            return 90
        }
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return recentlyPlayed!.count+7
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if indexPath.row<6
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row]
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row])
            
            return cell
        }
        else if indexPath.row==6
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Cell")!
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("RecentlyPlayedCell") as! RecentlyPlayedCell
            
            cell.videoTitleLbl?.text=recentlyPlayed![indexPath.row-7].valueForKey("streamTitle") as? String
            cell.videoThumbnailImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(recentlyPlayed![indexPath.row-7].valueForKey("streamID") as! Int).jpg"))
            
            return cell
        }
    }
    
    func tableView(tableView:UITableView, canEditRowAtIndexPath indexPath:NSIndexPath)->Bool
    {
        if indexPath.row<7
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func tableView(tableView:UITableView, editActionsForRowAtIndexPath indexPath:NSIndexPath)->[UITableViewRowAction]?
    {
        let clearButton=UITableViewRowAction(style:.Default, title:"Clear")
        {action, indexPath in
            SongManager.deleteRecentlyPlayed(self.recentlyPlayed![indexPath.row-7])
            self.recentlyPlayed?.removeAtIndex(indexPath.row-7)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
        }
        clearButton.backgroundColor=UIColor.darkGrayColor()
        
        return [clearButton]
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        
    }

    @IBAction func editButtonPressed()
    {
        if itemsTbl!.editing
        {
            itemsTbl?.setEditing(false, animated:true)
        }
        else
        {
            itemsTbl?.setEditing(true, animated:true)
        }
    }
    
    func makeStreamClassObject(row:Int)->Stream
    {
        let stream=Stream()
        
        return stream
    }
}
