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

class EditCell:UITableViewCell
{
    @IBOutlet var editButton:UIButton?
}

class MyLibViewController: UIViewController
{
    @IBOutlet var messageLbl:UILabel!
    @IBOutlet var itemsTbl:UITableView?
    
    let menuItemTitlesArray=["Playlists", "Live Streams", "Videos", "Channels"]
    let menuItemIconsArray=["videolist", "rec-off", "youtube", "videochannel"]
    
    var recentlyPlayed:[NSManagedObject]?
    var TBVC:TabBarViewController!
    let (host, _, _, _, _)=Config.shared.wowza()
    
    override func viewWillAppear(animated:Bool)
    {
        TBVC=tabBarController as! TabBarViewController
        
        navigationController?.navigationBarHidden=false
        
        recentlyPlayed=SongManager.getRecentlyPlayed()
        
        messageLbl.hidden=recentlyPlayed!.count==0 ? false : true
        
        itemsTbl?.reloadData()
    }
    
    @IBAction func myaccount()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=UserContainer.shared.logged()
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if indexPath.row<4
        {
            return 44
        }
        else if indexPath.row==4
        {
            return 60
        }
        else
        {
            return 80
        }
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return recentlyPlayed!.count+5
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if indexPath.row<4
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row]
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row])
            
            return cell
        }
        else if indexPath.row==4
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("EditCell") as! EditCell
            
            cell.editButton?.hidden=recentlyPlayed!.count==0 ? true : false
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("RecentlyPlayedCell") as! RecentlyPlayedCell
            
            cell.videoTitleLbl?.text=recentlyPlayed![indexPath.row-5].valueForKey("streamTitle") as? String
            cell.artistNameLbl?.text=recentlyPlayed![indexPath.row-5].valueForKey("streamUserName") as? String
            cell.videoThumbnailImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(recentlyPlayed![indexPath.row-5].valueForKey("streamID") as! Int).jpg"))
            
            return cell
        }
    }
    
    func tableView(tableView:UITableView, canEditRowAtIndexPath indexPath:NSIndexPath)->Bool
    {
        return indexPath.row<5 ? false : true
    }
    
    func tableView(tableView:UITableView, editActionsForRowAtIndexPath indexPath:NSIndexPath)->[UITableViewRowAction]?
    {
        let clearButton=UITableViewRowAction(style:.Default, title:"Clear")
        {action, indexPath in
            SongManager.deleteRecentlyPlayed(self.recentlyPlayed![indexPath.row-5])
            self.recentlyPlayed?.removeAtIndex(indexPath.row-5)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
            
            if self.recentlyPlayed!.count==0
            {
                let editCellIndexPath=NSIndexPath(forRow:4, inSection:0)
                let editCell=tableView.cellForRowAtIndexPath(editCellIndexPath) as! EditCell
                tableView.editing=false
                editCell.editButton?.setTitle("Edit", forState:.Normal)
                editCell.editButton?.hidden=true
                self.messageLbl.hidden=false
            }
        }
        clearButton.backgroundColor=UIColor.darkGrayColor()
        
        return [clearButton]
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if indexPath.row>4
        {
            let storyboard=UIStoryboard(name:"Main", bundle:nil)
            let modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
            
            let streamsArray=NSMutableArray()
            streamsArray.addObject(makeStreamClassObject(indexPath.row-5))
            
            modalVC.streamsArray=streamsArray
            modalVC.TBVC=TBVC
            
            TBVC.modalVC=modalVC
            TBVC.configure(makeStreamClassObject(indexPath.row-5))
        }
        else if indexPath.row<4
        {
            if indexPath.row==0
            {
                performSegueWithIdentifier("Playlists", sender:nil)
            }
            if indexPath.row==2||indexPath.row==1
            {
                performSegueWithIdentifier("Videos", sender:indexPath)
            }
            if indexPath.row==3
            {
                performSegueWithIdentifier("Channels", sender:nil)
            }
        }
    }
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        if segue.identifier=="Videos"
        {
            let controller=segue.destinationViewController as! VideosTableViewController
            controller.vType=(sender as! NSIndexPath).row-1
        }
    }
    
    @IBAction func editButtonPressed(_ sender:UIButton)
    {
        if itemsTbl!.editing
        {
            sender.setTitle("Edit", forState:.Normal)
            itemsTbl?.setEditing(false, animated:true)
        }
        else
        {
            sender.setTitle("Done", forState:.Normal)
            itemsTbl?.setEditing(true, animated:true)
        }
    }
    
    func makeStreamClassObject(row:Int)->Stream
    {
        let user=User()
        
        user.name=recentlyPlayed![row].valueForKey("streamUserName") as! String
        user.id=recentlyPlayed![row].valueForKey("streamUserID") as! UInt
        
        let stream=Stream()
        
        stream.id=recentlyPlayed![row].valueForKey("streamID") as! UInt
        stream.title=recentlyPlayed![row].valueForKey("streamTitle") as! String
        stream.streamHash=recentlyPlayed![row].valueForKey("streamHash") as! String
        stream.videoID=recentlyPlayed![row].valueForKey("streamKey") as! String
        
        stream.user=user
        
        return stream
    }
}
