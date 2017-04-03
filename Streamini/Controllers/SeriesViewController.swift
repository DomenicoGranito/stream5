//
//  SeriesViewController.swift
//  BEINIT
//
//  Created by Dominic on 2/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeriesViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var tableHeader:UIView!
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var topViewTopSpaceConstraint:NSLayoutConstraint!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var pageControl:UIPageControl!
    
    let scrollView=UIScrollView(frame:CGRectMake(0, 0, 320, 300))
    var frame=CGRectMake(0, 0, 0, 0)
    var blockingView:UIView!

    override func viewDidLoad()
    {
        scrollView.delegate=self
        tableHeader.addSubview(scrollView)
        
        for index in 0..<2
        {
            frame.origin.x=scrollView.frame.size.width*CGFloat(index)
            frame.size=scrollView.frame.size
            scrollView.pagingEnabled=true
            
            let subView=UIView(frame:frame)
            scrollView.addSubview(subView)
        }
        
        scrollView.contentSize=CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height)
        pageControl.addTarget(self, action:#selector(changePage), forControlEvents:.ValueChanged)
        
        tableHeader.clipsToBounds=true
        navigationController!.navigationBar.backgroundColor=UIColor.clearColor()
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics:.Default)
        navigationController!.navigationBar.shadowImage!=UIImage()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        tableView.contentOffset=CGPointMake(0, 64)
        
        blockingView=UIView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
        blockingView.backgroundColor=UIColor.blackColor()
        blockingView.hidden=true
        view!.addSubview(blockingView)
    }
    
    func changePage(sender:AnyObject)->()
    {
        let x=CGFloat(pageControl.currentPage)*scrollView.frame.size.width
        scrollView.setContentOffset(CGPointMake(x, 0), animated:true)
    }
    
    func scrollViewDidEndDecelerating(scrollView:UIScrollView)
    {
        let pageNumber=round(scrollView.contentOffset.x/scrollView.frame.size.width)
        pageControl.currentPage=Int(pageNumber)
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 80
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 80))
        headerView.backgroundColor=UIColor(white:0.2, alpha:1)
        
        let shuffle=UIButton(frame:CGRectMake(40, 0, UIScreen.mainScreen().bounds.size.width-80, 30))
        shuffle.setTitle("SHUFFLE PLAY", forState:.Normal)
        shuffle.backgroundColor=UIColor.greenColor()
        
        let headerTitle=UILabel(frame:CGRectMake(10, 40, UIScreen.mainScreen().bounds.size.width-20, 30))
        headerTitle.text="INCLUDES"
        headerTitle.textColor=UIColor.whiteColor()
        headerTitle.backgroundColor=UIColor.clearColor()
        
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
    
    func scrollViewDidScroll(scrollView:UIScrollView)
    {
        if scrollView.contentOffset.y > 44 - 64
        {
            if searchBar.alpha==1
            {
                UIView.animateWithDuration(0.3, animations:{()->Void in
                    self.searchBar.alpha=0
                    }, completion:{(finished:Bool)->Void in
                        self.blockingView.hidden=false
                })
            }
            
            topViewTopSpaceConstraint.constant=max(0, scrollView.contentOffset.y-(44-64))
        }
        else
        {
            if searchBar.alpha==0
            {
                blockingView.hidden=true
                UIView.animateWithDuration(0.3, animations:{()->Void in
                    self.searchBar.alpha=1
                })
            }
            topViewTopSpaceConstraint.constant=0
        }
    }
}
