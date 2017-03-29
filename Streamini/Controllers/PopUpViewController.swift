//
//  PopUpViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/2/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PopUpViewController: BaseViewController
{
    @IBOutlet var backgroundImageView:UIImageView?
    
    let menuItemTitlesArray:NSMutableArray=["Share to friends", "Share on timeline", "Go to channels", "Report this video", "Add to favourite", "Block content from this channel"]
    let menuItemIconsArray:NSMutableArray=["user.png", "time.png", "video.png", "user.png", "user.png", "user.png"]
    
    var stream:Stream?
    let (host, _, _, _, _)=Config.shared.wowza()
    var videoImage:UIImage!
    
    override func viewDidLoad()
    {
        if SongManager.isAlreadyFavourited(stream!.id)
        {
            menuItemTitlesArray.replaceObjectAtIndex(4, withObject:"Remove from favourite")
            menuItemIconsArray.replaceObjectAtIndex(4, withObject:"time.png")
        }
        
        backgroundImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(stream!.id).jpg"))
    }
    
    @IBAction func closeButtonPressed()
    {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 7
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if indexPath.row==0
        {
            return 80
        }
        else
        {
            return 44
        }
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if indexPath.row==0
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("RecentlyPlayedCell") as! RecentlyPlayedCell
            
            cell.videoTitleLbl?.text=stream?.title
            cell.artistNameLbl?.text=stream?.user.name
            cell.videoThumbnailImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(stream!.id).jpg"))
            
            videoImage=cell.videoThumbnailImageView?.image
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row-1] as? String
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row-1] as! String)
            
            return cell
        }
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if indexPath.row==1
        {
            shareOnWeChat(0)
        }
        if indexPath.row==2
        {
            shareOnWeChat(1)
        }
        if indexPath.row==3
        {
            view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:nil)
            
            NSNotificationCenter.defaultCenter().postNotificationName("goToChannels", object:stream?.user)
        }
        if indexPath.row==4
        {
            StreamConnector().report(stream!.id, success:reportSuccess, failure:failureWithoutAction)
        }
        if indexPath.row==5
        {
            dismissViewControllerAnimated(true, completion:nil)
            
            if SongManager.isAlreadyFavourited(stream!.id)
            {
                SongManager.removeFromFavourite(stream!.id)
            }
            else
            {
                SongManager.addToFavourite(stream!.title, streamHash:stream!.streamHash, streamID:stream!.id, streamUserName:stream!.user.name, vType:1, streamKey:stream!.videoID)
            }
        }
        if indexPath.row==6
        {
            SocialConnector().block(stream!.user.id, success:blockSuccess, failure:failureWithoutAction)
        }
    }
    
    func reportSuccess()
    {
        SCLAlertView().showSuccess("MESSAGE", subTitle:"Video has been reported")
    }
    
    func blockSuccess()
    {
        SCLAlertView().showSuccess("MESSAGE", subTitle:"Channel has been blocked")
    }
    
    func failureWithoutAction(error:NSError)
    {
        handleError(error)
    }
    
    func shareOnWeChat(sceneID:Int32)
    {
        if WXApi.isWXAppInstalled()
        {
            let videoObject=WXVideoObject()
            videoObject.videoUrl="http://conf.cedricm.com/\(stream!.streamHash)/\(stream!.id)"
            
            let message=WXMediaMessage()
            message.title=stream?.title
            message.description=stream?.user.name
            message.mediaObject=videoObject
            message.setThumbImage(videoImage)
            
            let req=SendMessageToWXReq()
            req.message=message
            req.scene=sceneID
            
            WXApi.sendReq(req)
        }
        else
        {
            SCLAlertView().showSuccess("MESSAGE", subTitle:"Please install WeChat application")
        }
    }
}
