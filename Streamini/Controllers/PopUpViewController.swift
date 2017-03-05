//
//  PopUpViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/2/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PopUpViewController: UIViewController
{
    var stream:Stream?
    let (host, port, _, _, _)=Config.shared.wowza()
    var videoImage:UIImage!
    
    @IBAction func closeButtonPressed()
    {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 2
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
        if indexPath.row==1
        {

            let cell=tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
            
            cell.menuItemTitleLbl?.text="Share with friends"
            cell.menuItemIconImageView?.image=UIImage(named:"video.png")
            
            return cell
        }
        else
        {
                    let cell=tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
                    
                    cell.menuItemTitleLbl?.text="Share on timeline"
                    cell.menuItemIconImageView?.image=UIImage(named:"video.png")
                    
                    return cell
        }
        
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        
      //  let sceneID as Int
        if indexPath.row==1
        {
           // sceneID=0
            shareOnWeChat(0)
        }
        if indexPath.row==2
        {
           // sceneID=1
            shareOnWeChat(1)
        }

    }
    
    func shareOnWeChat(sceneID:UInt)
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
            if(sceneID == 0)
            {
            req.scene=0
            }
            else
            {
            req.scene=1
            }
            
            
            WXApi.sendReq(req)
        }
        else
        {
            SCLAlertView().showSuccess("MESSAGE", subTitle:"Please install WeChat application")
        }
    }
}
