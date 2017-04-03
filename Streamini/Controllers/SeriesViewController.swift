//
//  SeriesViewController.swift
//  BEINIT
//
//  Created by Dominic on 2/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeriesViewController: UIViewController, UIScrollViewDelegate
{
    let scrollView=UIScrollView(frame:CGRectMake(0, 0, 320, 300))
    var colors=[UIColor.redColor(), UIColor.blueColor()]
    var frame=CGRectMake(0, 0, 0, 0)
    
    @IBOutlet var tableHeader:UIView!
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var topViewTopSpaceConstraint:NSLayoutConstraint!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var pageControl:UIPageControl!
    var blockingView:UIView!
    
    override func viewDidLoad()
    {
        configurePageControl()
        
        scrollView.delegate = self
        // view.addSubview(scrollView)
        tableHeader.addSubview(scrollView)
        for index in 0..<2
        {
            
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            scrollView.pagingEnabled = true
            
            let subView = UIView(frame: frame)
            subView.backgroundColor = colors[index]
            scrollView.addSubview(subView)
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 2, scrollView.frame.size.height)
        pageControl.addTarget(self, action:#selector(changePage), forControlEvents:.ValueChanged)
        
        tableHeader.clipsToBounds = true
        navigationController!.navigationBar.backgroundColor = UIColor.clearColor()
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController!.navigationBar.shadowImage! = UIImage()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        // Starting with the table view a bit scrolled down to hide the search bar
        tableView.contentOffset = CGPointMake(0, 64)
        // This blocking view is used to hide the tableview cells when they scroll too far up
        // you can comment this view to see what happens
        blockingView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
        blockingView.backgroundColor = UIColor.blackColor()
        blockingView.hidden = true
        view!.addSubview(blockingView)
    }
    
    func configurePageControl()
    {
        pageControl.tintColor=UIColor.redColor()
        pageControl.pageIndicatorTintColor=UIColor.blackColor()
        pageControl.currentPageIndicatorTintColor=UIColor.greenColor()
        view.addSubview(pageControl)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> ()
    {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 80
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 80))
        headerView.backgroundColor=UIColor(white: 0.2, alpha: 1)
        let shuffle=UIButton(frame:CGRectMake(40, 0, UIScreen.mainScreen().bounds.size.width-80, 30))
        shuffle.setTitle("Shuffle Play", forState:.Normal)
        shuffle.backgroundColor=UIColor.greenColor()
        headerView.addSubview(shuffle)
        let headerTitle=UILabel(frame:CGRectMake(10, 40, UIScreen.mainScreen().bounds.size.width - 20, 30))
        headerTitle.text="Section Title"
        headerTitle.textColor=UIColor.whiteColor()
        headerTitle.backgroundColor=UIColor.clearColor()
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
        // This weird 44 - 64 is basically to mean:
        // Past 44 pixels (assuming the tableview starts at -64, which it does because of some automatic padding related to the status and nav bar)
        if scrollView.contentOffset.y > 44 - 64
        {
            // Hide the search bar, and show the blocking view so when the content goes behind the nav bar, you dont see it
            if searchBar.alpha == 1
            {
                UIView.animateWithDuration(0.3, animations: {() -> Void in
                    self.searchBar.alpha = 0
                    }, completion: {(finished: Bool) -> Void in
                        self.blockingView.hidden = false
                })
            }
            // we move the top view down at the same pace we scroll up, to give the effect of it being always in the same place on the screen
            self.topViewTopSpaceConstraint.constant = max(0, scrollView.contentOffset.y - (44 - 64))
        }
        else
        {
            // showing the search bar again, and hiding the no longer needed blocking view (which would block the search bar)
            if searchBar.alpha == 0
            {
                self.blockingView.hidden = true
                UIView.animateWithDuration(0.3, animations: {() -> Void in
                    self.searchBar.alpha = 1
                })
            }
            self.topViewTopSpaceConstraint.constant = 0
        }
    }
}
