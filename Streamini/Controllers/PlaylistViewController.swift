//
//  PlaylistViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PlaylistViewController: ARNModalImageTransitionViewController, ARNImageTransitionZoomable
{
    @IBOutlet var bottomView:UIView!
    @IBOutlet var itemsTbl:UITableView!
    
    var selectedStreamsArray=NSMutableArray()
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 2
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, 30, tableView.frame.size.width))
        
        let titleLbl=UILabel(frame:CGRectMake(10, 0, 300, 20))
        
        if section==0
        {
            titleLbl.text="NOW PLAYING"
        }
        else
        {
            titleLbl.text="UP NEXT ON SHUFFLE"
        }
        
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
        if indexPath.section==0
        {
            return 60
        }
        else
        {
            return 50
        }
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if section==0
        {
            return 1
        }
        else
        {
            return 10
        }
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if indexPath.section==0
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("NowPlayingCell") as! RecentStreamCell
            
            cell.streamNameLabel.text="Now playing"
            cell.userLabel.text="Ankit"
            cell.dotsButton?.addTarget(self, action:#selector(dotsButtonTapped), forControlEvents:.TouchUpInside)
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("UpNextCell") as! RecentStreamCell
            
            cell.streamNameLabel.text="Up next"
            cell.userLabel.text="Ankit Garg"
            
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
            
            UIView.animateWithDuration(0.5, animations:{
                self.itemsTbl.frame=CGRectMake(0, 48, self.view.frame.size.width, self.view.frame.size.height-48-offset)
                self.bottomView.frame=CGRectMake(0, self.view.frame.size.height-offset, self.view.frame.size.width, 50)
            })
        }
    }
    
    func dotsButtonTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        vc.stream=Stream()
        presentViewController(vc, animated:true, completion:nil)
    }
    
    @IBAction func removeSelectedStreams()
    {
        
    }
    
    @IBAction func tapCloseButton()
    {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    func createTransitionImageView()->UIImageView
    {
        return UIImageView()
    }
}
