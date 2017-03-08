//
//  PopUpViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/2/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PopUpViewController: BaseViewController
{
    let menuItemTitlesArray=["Share to friends", "Share on timeline", "Go to channels", "Report this video", "Save video"]
    let menuItemIconsArray=["user.png", "time.png", "video.png", "user.png", "user.png"]
    
    var stream:Stream?
    let (host, port, _, _, _)=Config.shared.wowza()
    var videoImage:UIImage!
    
    @IBAction func closeButtonPressed()
    {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 6
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
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row-1]
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row-1])
            
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
            
            let storyboard=UIStoryboard(name:"Main", bundle:nil)
            let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
            vc.user=stream?.user
        }
        if indexPath.row==4
        {
            StreamConnector().report(stream!.id, success:successWithoutAction, failure:failureWithoutAction)
        }
        if indexPath.row==5
        {
            
        }
    }
    
    func successWithoutAction()
    {
        
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
