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
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var searchView:UIView!
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet var filterButton:UIButton!
    @IBOutlet var topViewTopSpaceConstraint:NSLayoutConstraint!
    @IBOutlet var shuffleButtonTopSpaceConstraint:NSLayoutConstraint!
    
    var blockingView:UIView!
    var navigationBarBackgroundImage:UIImage!
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    var shuffleButtonTopSpace:CGFloat!
    
    override func viewDidLoad()
    {
        shuffleButtonTopSpace=shuffleButtonTopSpaceConstraint.constant
        
        scrollView.contentSize=CGSizeMake(view.frame.size.width*2, 276)
        
        let playlistView=PlaylistView.instanceFromNib()
        playlistView.frame=CGRectMake(0, 0, view.frame.size.width, 276)
        scrollView.addSubview(playlistView)
        
        let playlistDetailView=PlaylistDetailView.instanceFromNib()
        playlistDetailView.frame=CGRectMake(view.frame.size.width, 0, view.frame.size.width, 276)
        scrollView.addSubview(playlistDetailView)
        
        navigationBarBackgroundImage=navigationController!.navigationBar.backgroundImageForBarMetrics(.Default)
        
        navigationController!.navigationBar.backgroundColor=UIColor.clearColor()
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics:.Default)
        
        tableView.contentOffset=CGPointMake(0, 64)
        
        blockingView=UIView(frame:CGRectMake(0, 0, view.frame.size.width, 64))
        blockingView.backgroundColor=UIColor.blackColor()
        view.addSubview(blockingView)
    }
    
    override func viewWillDisappear(animated:Bool)
    {
        navigationController!.navigationBar.setBackgroundImage(navigationBarBackgroundImage, forBarMetrics:.Default)
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
        let pageNumber=self.scrollView.contentOffset.x/scrollView.frame.size.width
        pageControl.currentPage=Int(pageNumber)
    }
    
    func scrollViewDidScroll(scrollView:UIScrollView)
    {
        if tableView.contentOffset.y > -20
        {
            if searchView.alpha==1
            {
                UIView.animateWithDuration(0.3, animations:{()->Void in
                    self.searchView.alpha=0
                    }, completion:{(finished:Bool)->Void in
                        self.blockingView.hidden=false
                })
            }
            
            topViewTopSpaceConstraint.constant=max(0, tableView.contentOffset.y+20)
        }
        else
        {
            if searchView.alpha==0
            {
                blockingView.hidden=true
                UIView.animateWithDuration(0.3, animations:{()->Void in
                    self.searchView.alpha=1
                })
            }
            
            topViewTopSpaceConstraint.constant=0
        }
        
        if tableView.contentOffset.y<=231
        {
            shuffleButtonTopSpaceConstraint.constant=shuffleButtonTopSpace-tableView.contentOffset.y
        }
    }
    
    func searchBarSearchButtonClicked(searchBar:UISearchBar)
    {
        searchBar.resignFirstResponder()
        filterButton?.hidden=false
        cancelButton?.hidden=true
    }
    
    func searchBarTextDidBeginEditing(searchBar:UISearchBar)
    {
        filterButton?.hidden=true
        cancelButton?.hidden=false
    }
    
    func searchBar(searchBar:UISearchBar, textDidChange searchText:String)
    {
        if searchText.characters.count>0
        {
            
        }
    }
    
    @IBAction func cancel()
    {
        searchBar.resignFirstResponder()
        filterButton?.hidden=false
        cancelButton?.hidden=true
    }
    
    @IBAction func filter()
    {
        let vc=storyBoard.instantiateViewControllerWithIdentifier("FiltersViewController") as! FiltersViewController
        vc.backgroundImage=renderImageFromView()
        presentViewController(vc, animated:true, completion:nil)
    }
    
    @IBAction func options()
    {
        let vc=storyBoard.instantiateViewControllerWithIdentifier("OptionsViewController") as! OptionsViewController
        vc.backgroundImage=renderImageFromView()
        presentViewController(vc, animated:true, completion:nil)
    }
    
    func renderImageFromView()->UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0)
        let context=UIGraphicsGetCurrentContext()
        
        view.layer.renderInContext(context!)
        
        let renderedImage=UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return renderedImage
    }
}
