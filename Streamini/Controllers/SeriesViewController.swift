//
//  SeriesViewController.swift
//  BEINIT
//
//  Created by Dominic on 2/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeriesViewController: UIViewController
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var pageControl:UIPageControl!
    @IBOutlet var scrollView:UIScrollView!
    
    override func viewDidLoad()
    {
        scrollView.contentSize=CGSizeMake(view.frame.size.width*2, 276)
        
        let playlistView=PlaylistView.instanceFromNib()
        playlistView.frame=CGRectMake(0, 0, view.frame.size.width, 276)
        scrollView.addSubview(playlistView)
        
        let playlistDetailView=PlaylistDetailView.instanceFromNib()
        playlistDetailView.frame=CGRectMake(view.frame.size.width, 0, view.frame.size.width, 276)
        scrollView.addSubview(playlistDetailView)
        
        navigationController?.navigationBarHidden=true
        
        tableView.contentOffset=CGPointMake(0, 64)
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 80
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, view.frame.size.width, 80))
        headerView.backgroundColor=UIColor.darkGrayColor()
        
        let shuffle=UIButton(frame:CGRectMake(40, 0, view.frame.size.width-80, 50))
        shuffle.setTitle("SHUFFLE PLAY", forState:.Normal)
        shuffle.backgroundColor=UIColor.greenColor()
        
        let headerTitle=UILabel(frame:CGRectMake(10, 55, view.frame.size.width-20, 20))
        headerTitle.text="INCLUDES"
        headerTitle.textColor=UIColor.whiteColor()
        
        headerView.addSubview(shuffle)
        headerView.addSubview(headerTitle)
        
        return headerView
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 10
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        return UITableViewCell()
    }
    
    func scrollViewDidEndDecelerating(scrollView:UIScrollView)
    {
        let pageNumber=scrollView.contentOffset.x/scrollView.frame.size.width
        pageControl.currentPage=Int(pageNumber)
    }
}
