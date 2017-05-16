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
    
    var sectionTitlesArray=NSMutableArray(array:["NOW PLAYING", "UP NEXT ON SHUFFLE"])
    let (host, _, _, _, _)=Config.shared.wowza()
    var selectedStreamsArray=NSMutableArray()
    var upNextStreamsArray=NSMutableArray()
    var streamsArray=NSMutableArray()
    var nowPlayingStream:Stream!
    var nowPlayingStreamIndex:Int!
    
    override func viewDidLoad()
    {
        nowPlayingStream=streamsArray.objectAtIndex(nowPlayingStreamIndex) as! Stream
        
        streamsArray.removeObjectAtIndex(nowPlayingStreamIndex)
        
        backgroundImageView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(nowPlayingStream.id).jpg"))
        
        headerTitleLbl.text=nowPlayingStream.title
        
        itemsTbl.editing=true
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return sectionTitlesArray.count
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 30
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, tableView.frame.size.width, 30))
        
        let titleLbl=UILabel(frame:CGRectMake(10, 0, 300, 20))
        titleLbl.text=sectionTitlesArray[section] as? String
        titleLbl.font=UIFont.systemFontOfSize(10)
        titleLbl.textColor=UIColor.whiteColor()
        
        let lineView=UIView(frame:CGRectMake(10, 29.5, tableView.frame.size.width-20, 0.5))
        lineView.backgroundColor=UIColor(colorLiteralRed:37/255, green:36/255, blue:41/255, alpha:1)
        
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
        if section==0
        {
            return 1
        }
        else if sectionTitlesArray.count==2&&section==1
        {
            return streamsArray.count
        }
        else if section==1
        {
            return upNextStreamsArray.count
        }
        else
        {
            return streamsArray.count
        }
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
            cell.playImageView.image=selectedStreamsArray.containsObject(indexPath.row) ? UIImage(named:"checkmark") : UIImage(named:"checkmarkblank")
            
            var stream:Stream!
            
            if sectionTitlesArray.count==2&&indexPath.section==1
            {
                stream=streamsArray[indexPath.row] as! Stream
            }
            else if indexPath.section==1
            {
                stream=upNextStreamsArray[indexPath.row] as! Stream
            }
            else
            {
                stream=streamsArray[indexPath.row] as! Stream
            }
            
            cell.streamNameLabel.text=stream.title
            cell.userLabel.text=stream.user.name
            
            return cell
        }
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if indexPath.section>0
        {
            let cell=tableView.cellForRowAtIndexPath(indexPath) as! RecentStreamCell
            
            if selectedStreamsArray.containsObject(indexPath.row)
            {
                selectedStreamsArray.removeObject(indexPath.row)
                cell.playImageView.image=UIImage(named:"checkmarkblank")
            }
            else
            {
                selectedStreamsArray.addObject(indexPath.row)
                cell.playImageView.image=UIImage(named:"checkmark")
            }
            
            var offset:CGFloat=0
            
            if selectedStreamsArray.count>0
            {
                offset=50
            }
            
            performAnimation(offset)
        }
    }
    
    func tableView(tableView:UITableView, editingStyleForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCellEditingStyle
    {
        return .None
    }
    
    func tableView(tableView:UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath:NSIndexPath)->Bool
    {
        return false
    }
    
    func tableView(tableView:UITableView, canMoveRowAtIndexPath indexPath:NSIndexPath)->Bool
    {
        return indexPath.section==0 ? false : true
    }
    
    func tableView(tableView:UITableView, moveRowAtIndexPath sourceIndexPath:NSIndexPath, toIndexPath destinationIndexPath:NSIndexPath)
    {
        streamsArray.exchangeObjectAtIndex(sourceIndexPath.row, withObjectAtIndex:destinationIndexPath.row)
        itemsTbl.reloadData()
    }
    
    @IBAction func addToUpNext()
    {
        if sectionTitlesArray.count==2
        {
            sectionTitlesArray.insertObject("UP NEXT", atIndex:1)
        }
        
        for i in 0 ..< selectedStreamsArray.count
        {
            let sourceIndex=selectedStreamsArray[i] as! Int
            let destinationIndex=nowPlayingStreamIndex+i
            
            streamsArray.exchangeObjectAtIndex(sourceIndex, withObjectAtIndex:destinationIndex)
            upNextStreamsArray.addObject(streamsArray.objectAtIndex(sourceIndex))
        }
        
        selectedStreamsArray.removeAllObjects()
        itemsTbl.reloadData()
        performAnimation(0)
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
