//
//  VideosViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/9/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class VideosViewController: UIViewController
{
    var savedStreams:[NSManagedObject]?
    let (host, _, _, _, _)=Config.shared.wowza()
    
    override func viewDidLoad()
    {
        savedStreams=SongManager.getSavedStreams()
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return savedStreams!.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("RecentStreamCell") as! RecentStreamCell
        
        cell.streamNameLabel?.text=savedStreams![indexPath.row].valueForKey("streamTitle") as? String
        cell.userLabel?.text=savedStreams![indexPath.row].valueForKey("streamUserName") as? String
        cell.playImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(savedStreams![indexPath.row].valueForKey("streamID") as! Int).jpg"))
        
        return cell
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        let root=UIApplication.sharedApplication().delegate!.window!?.rootViewController as! UINavigationController
        
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
        modalVC.stream=makeStreamClassObject(indexPath.row)
        
        root.presentViewController(modalVC, animated:true, completion:nil)
    }
    
    func makeStreamClassObject(row:Int)->Stream
    {
        let user=User()
        
        user.name=savedStreams![row].valueForKey("streamUserName") as! String
        
        let stream=Stream()
        
        stream.id=savedStreams![row].valueForKey("streamID") as! UInt
        stream.title=savedStreams![row].valueForKey("streamTitle") as! String
        stream.streamHash=savedStreams![row].valueForKey("streamHash") as! String
        stream.user=user
        
        return stream
    }
}
