//
//  PlaylistViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PlaylistViewController: ARNModalImageTransitionViewController, ARNImageTransitionZoomable
{
    @IBOutlet var backgroundImageView:UIImageView!
    @IBOutlet var headerTitleLbl:UILabel!
    @IBOutlet var bottomView:UIView!
    @IBOutlet var itemsTbl:UITableView!
    
    let (host, _, _, _, _)=Config.shared.wowza()
    var selectedStreamsArray=NSMutableArray()
    var streamsArray=NSMutableArray()
    var nowPlayingStream:Stream!
    var nowPlayingStreamIndex:Int!
    
    override func viewDidLoad()
    {
        nowPlayingStream=streamsArray.objectAtIndex(nowPlayingStreamIndex) as! Stream
        
        streamsArray.removeObjectAtIndex(nowPlayingStreamIndex)
        
        backgroundImageView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(nowPlayingStream.id).jpg"))
        
        headerTitleLbl.text=nowPlayingStream.title
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 2
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 30
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, 30, tableView.frame.size.width))
        
        let titleLbl=UILabel(frame:CGRectMake(10, 0, 300, 20))
        titleLbl.text=section==0 ? "NOW PLAYING" : "UP NEXT ON SHUFFLE"
        titleLbl.font=UIFont.systemFontOfSize(10)
        titleLbl.textColor=UIColor.whiteColor()
        
        let lineView=UIView(frame:CGRectMake(10, 29, tableView.frame.size.width-20, 1))
        lineView.backgroundColor=UIColor.darkGrayColor()
        
        headerView.addSubview(titleLbl)
        headerView.addSubview(lineView)
        
        return headerView
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        return indexPath.section==0 ? 80 : 50
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return section==0 ? 1 : streamsArray.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if indexPath.section==0
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("NowPlayingCell") as! RecentStreamCell
            
            cell.streamNameLabel.text=nowPlayingStream.title
            cell.userLabel.text=nowPlayingStream.user.name
            cell.playImageView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(nowPlayingStream.id).jpg"))
            cell.dotsButton?.addTarget(self, action:#selector(dotsButtonTapped), forControlEvents:.TouchUpInside)
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("UpNextCell") as! RecentStreamCell
            
            cell.playImageView.backgroundColor=selectedStreamsArray.containsObject(indexPath.row) ? UIColor.greenColor() : UIColor.redColor()
            
            let stream=streamsArray[indexPath.row] as! Stream
            
            cell.streamNameLabel.text=stream.title
            cell.userLabel.text=stream.user.name
            
            return cell
        }
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if indexPath.section==1
        {
            let cell=tableView.cellForRowAtIndexPath(indexPath) as! RecentStreamCell
            
            if selectedStreamsArray.containsObject(indexPath.row)
            {
                selectedStreamsArray.removeObject(indexPath.row)
                
                cell.playImageView.backgroundColor=UIColor.redColor()
            }
            else
            {
                selectedStreamsArray.addObject(indexPath.row)
                
                cell.playImageView.backgroundColor=UIColor.greenColor()
            }
            
            var offset:CGFloat=0
            
            if selectedStreamsArray.count>0
            {
                offset=50
            }
            
            performAnimation(offset)
        }
    }
    
    func dotsButtonTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        vc.stream=nowPlayingStream
        presentViewController(vc, animated:true, completion:nil)
    }
    
    @IBAction func removeSelectedStreams()
    {
        let indexSet=NSMutableIndexSet()
        
        let selectedStreamIndex=nowPlayingStreamIndex
        
        for i in 0 ..< selectedStreamsArray.count
        {
            let index=selectedStreamsArray[i] as! Int
            
            if (index<selectedStreamIndex)
            {
                nowPlayingStreamIndex=nowPlayingStreamIndex-1
            }
            
            indexSet.addIndex(index)
        }
        
        streamsArray.removeObjectsAtIndexes(indexSet)
        selectedStreamsArray.removeAllObjects()
        itemsTbl.reloadData()
        performAnimation(0)
    }
    
    func performAnimation(offset:CGFloat)
    {
        UIView.animateWithDuration(0.5, animations:{
            self.itemsTbl.frame=CGRectMake(0, 48, self.view.frame.size.width, self.view.frame.size.height-48-offset)
            self.bottomView.frame=CGRectMake(0, self.view.frame.size.height-offset, self.view.frame.size.width, 50)
        })
    }
    
    @IBAction func closePlaylist()
    {
        streamsArray.insertObject(nowPlayingStream, atIndex:nowPlayingStreamIndex)
        
        NSNotificationCenter.defaultCenter().postNotificationName("updatePlayer", object:nowPlayingStreamIndex)
        
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func closePlayer()
    {
        streamsArray.insertObject(nowPlayingStream, atIndex:nowPlayingStreamIndex)
        
        NSNotificationCenter.defaultCenter().postNotificationName("updatePlayer", object:nowPlayingStreamIndex)
        
        view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func createTransitionImageView()->UIImageView
    {
        return UIImageView()
    }
}
