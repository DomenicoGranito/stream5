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
    let (host, port, _, _, _) = Config.shared.wowza()
    var videoImage:UIImage!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
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
        if(indexPath.row==0)
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
        if(indexPath.row==0)
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
            
            cell.menuItemTitleLbl?.text="Share"
            cell.menuItemIconImageView?.image=UIImage(named:"video.png")
            
            return cell
        }
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if(indexPath.row==1)
        {
            shareOnWeChat()
        }
    }
    
    func shareOnWeChat()
    {
        let videoObject=WXVideoObject()
        videoObject.videoUrl="http://cedricm.tv/beta/index.php?a=track&id=\(stream!.id)"
        
        let message=WXMediaMessage()
        message.title=stream?.title
        message.description=stream?.user.name
        message.mediaObject=videoObject
        message.setThumbImage(videoImage)
        
        let req=SendMessageToWXReq()
        req.message=message
        req.scene=0
        
        WXApi.sendReq(req)
    }
}
