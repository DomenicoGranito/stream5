//
//  HomeViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class HomeViewController: BaseViewController
{
    @IBOutlet var itemsTbl:UITableView?
    
    var categoryNamesArray=NSMutableArray()
    var categoryIDsArray=NSMutableArray()
    var allCategoryItemsArray=NSMutableArray()
    var timer:NSTimer?
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(reload), name:"refreshAfterBlock", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(updateUI), name:"status", object:nil)
        
        reload()
    }
    
    func updateUI()
    {
        let appDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
        
        if appDelegate.reachability.isReachable()
        {
            print("Hide Offline View & Reload Table View")
        }
        else
        {
            print("Remove all other and Show offline View")
        }
    }
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=false
        
        timer=NSTimer.scheduledTimerWithTimeInterval(60, target:self, selector:#selector(reload), userInfo:nil, repeats:true)
    }
    
    func reload()
    {
        if ErrorView.errorView != nil
        {
            ErrorView.removeErrorView()
        }
        
        ActivityIndicatorView.addActivityIndictorView(view)
        StreamConnector().homeStreams(successStreams, failure:failureStream)
    }
    
    override func viewWillDisappear(animated:Bool)
    {
        timer!.invalidate()
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        let width=(view.frame.size.width-25)/2
        
        if indexPath.section==0
        {
            return width+20
        }
        else
        {
            return width+85
        }
    }

    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return section==0 ? 1 : 60
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        if section>0
        {
            let headerView=UIView(frame:CGRectMake(0, 0, tableView.frame.size.width, 60))
            headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
            
            let titleLbl=UILabel(frame:CGRectMake(10, 30, 285, 20))
            
            if(allCategoryItemsArray.count>0)
            {
                titleLbl.text=categoryNamesArray[section].uppercaseString
            }
            
            titleLbl.font=UIFont.systemFontOfSize(24)
            titleLbl.textColor=UIColor(colorLiteralRed:190/255, green:142/255, blue:64/255, alpha:1)
            
            let lineView=UIView(frame:CGRectMake(10, 59.5, tableView.frame.size.width-20, 0.5))
            lineView.backgroundColor=UIColor(colorLiteralRed:37/255, green:36/255, blue:41/255, alpha:1)
            
            let tapGesture=UITapGestureRecognizer(target:self, action:#selector(headerTapped))
            headerView.addGestureRecognizer(tapGesture)
            headerView.tag=section
            
            headerView.addSubview(lineView)
            headerView.addSubview(titleLbl)
            
            return headerView
        }
        else
        {
            return nil
        }
    }
    
    func headerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("CategoriesViewController") as! CategoriesViewController
        vc.categoryName=categoryNamesArray[gestureRecognizer.view!.tag] as? String
        vc.categoryID=categoryIDsArray[gestureRecognizer.view!.tag] as? Int
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return categoryNamesArray.count
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! CategoryRow
        
        if(allCategoryItemsArray.count>0)
        {
            cell.TBVC=tabBarController as! TabBarViewController
            cell.oneCategoryItemsArray=allCategoryItemsArray[indexPath.section] as! NSArray
            
            if indexPath.section==0
            {
                cell.cellIdentifier="weeklyCell"
            }
            else
            {
                cell.cellIdentifier="videoCell"
            }
        }
        
        return cell
    }
    
    func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        let cell=cell as! CategoryRow
        
        cell.reloadCollectionView()
    }
    
    func successStreams(data:NSDictionary)
    {
        ActivityIndicatorView.removeActivityIndicatorView()
        
        categoryNamesArray=NSMutableArray()
        categoryIDsArray=NSMutableArray()
        allCategoryItemsArray=NSMutableArray()
        
        let data=data["data"]!
        
        for i in 0 ..< data.count
        {
            let categoryName=data[i]["category_name"] as! String
            let categoryID=data[i]["category_id"]!.integerValue
            
            categoryNamesArray.addObject(categoryName)
            categoryIDsArray.addObject(categoryID)
            
            let videos=data[i]["videos"] as! NSArray
            
            let oneCategoryItemsArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let videoID=videos[j]["id"] as! Int
                let streamKey=videos[j]["streamkey"] as! String
                let vType=videos[j]["vtype"] as! Int
                let videoTitle=videos[j]["title"] as! String
                let videoHash=videos[j]["hash"] as! String
                let lon=videos[j]["lon"]!.doubleValue
                let lat=videos[j]["lat"]!.doubleValue
                let city=videos[j]["city"] as! String
                let ended=videos[j]["ended"] as? String
                let viewers=videos[j]["viewers"] as! Int
                let tviewers=videos[j]["tviewers"] as! Int
                let rviewers=videos[j]["rviewers"] as! Int
                let likes=videos[j]["likes"] as! Int
                let rlikes=videos[j]["rlikes"] as! Int
                let userID=videos[j]["user"]!["id"] as! Int
                let userName=videos[j]["user"]!["name"] as! String
                let userAvatar=videos[j]["user"]!["avatar"] as? String
                
                let user=User()
                user.id=UInt(userID)
                user.name=userName
                user.avatar=userAvatar
                
                let video=Stream()
                video.id=UInt(videoID)
                video.vType=vType
                video.videoID=streamKey
                video.title=videoTitle
                video.streamHash=videoHash
                video.lon=lon
                video.lat=lat
                video.city=city
                
                if let e=ended
                {
                    video.ended=NSDate(timeIntervalSince1970:Double(e)!)
                }
                
                video.viewers=UInt(viewers)
                video.tviewers=UInt(tviewers)
                video.rviewers=UInt(rviewers)
                video.likes=UInt(likes)
                video.rlikes=UInt(rlikes)
                video.user=user
                
                oneCategoryItemsArray.addObject(video)
            }
            
            allCategoryItemsArray.addObject(oneCategoryItemsArray)
        }
        
        itemsTbl!.reloadData()
    }
    
    func failureStream(error:NSError)
    {
        ActivityIndicatorView.removeActivityIndicatorView()
        ErrorView.addErrorView(view)
    }
}
