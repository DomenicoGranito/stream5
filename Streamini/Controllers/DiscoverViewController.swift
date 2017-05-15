//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class MenuCell: UITableViewCell
{
    @IBOutlet var menuItemTitleLbl:UILabel?
    @IBOutlet var menuItemIconImageView:UIImageView?
}

class DiscoverViewController: UIViewController
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var errorView:ErrorView!
    @IBOutlet var activityView:ActivityIndicatorView!
    
    var allCategoriesArray=NSMutableArray()
    var featuredStreamsArray=NSMutableArray()
    
    var menuItemTitlesArray=["Channels"]
    var menuItemIconsArray=["user.png"]
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(updateUI), name:"status", object:nil)
        
        updateUI()
    }
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=false
    }
    
    func updateUI()
    {
        let appDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
        
        if appDelegate.reachability.isReachable()
        {
            errorView.hidden=true
            
            activityView.hidden=false
            StreamConnector().discover(discoverSuccess, failure:discoverFailure)
        }
        else
        {
            tableView.hidden=true
            activityView.hidden=true
            errorView.update("No Internet Connection", icon:"user")
        }
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 3
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return section>1 ? 60 : 1
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        if section==2
        {
            let headerView=UIView(frame:CGRectMake(0, 0, tableView.frame.size.width, 60))
            headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
            
            let titleLbl=UILabel(frame:CGRectMake(10, 30, 285, 20))
            titleLbl.text="GENRES & MOODS"
            titleLbl.font=UIFont.systemFontOfSize(24)
            titleLbl.textColor=UIColor(colorLiteralRed:190/255, green:142/255, blue:64/255, alpha:1)
            
            let lineView=UIView(frame:CGRectMake(10, 59.5, tableView.frame.size.width-20, 0.5))
            lineView.backgroundColor=UIColor(colorLiteralRed:37/255, green:36/255, blue:41/255, alpha:1)
            
            headerView.addSubview(lineView)
            headerView.addSubview(titleLbl)
            
            return headerView
        }
        else
        {
            return nil
        }
    }

    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if section==0
        {
            return 1
        }
        else if section==1
        {
            return 1
        }
        else
        {
            return allCategoriesArray.count
        }
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if indexPath.section==0
        {
            return (view.frame.size.width-25)/2+125
        }
        else if indexPath.section==1
        {
            return 50
        }
        else
        {
            return (view.frame.size.width-30)/2
        }
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if indexPath.section==0&&featuredStreamsArray.count>0
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Recent") as! CategoryRow
            
            cell.oneCategoryItemsArray=featuredStreamsArray
            cell.TBVC=tabBarController as! TabBarViewController
            cell.cellIdentifier="videoCell"
            
            return cell
        }
        if indexPath.section==1
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Menu") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row]
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row])
            
            return cell
        }
        if indexPath.section==2
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Category") as! AllCategoryRow
            
            cell.sectionItemsArray=allCategoriesArray[indexPath.row] as! NSArray
            cell.navigationControllerReference=navigationController
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        if cell is AllCategoryRow
        {
            (cell as! AllCategoryRow).reloadCollectionView()
        }
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if indexPath.section==1&&indexPath.row==0
        {
            performSegueWithIdentifier("Channels", sender:nil)
        }
    }

    func discoverSuccess(data:NSDictionary)
    {
        activityView.hidden=true
        
        let videos=data["data"]!["feat"] as! NSArray
        let categories=data["data"]!["cat"] as! NSArray
        
        featuredStreamsArray.removeAllObjects()
        allCategoriesArray.removeAllObjects()
        
        parseFeaturedStreams(videos)
        parseCategories(categories)
        
        tableView.hidden=false
        tableView.reloadData()
    }
    
    func parseFeaturedStreams(videos:NSArray)
    {
        for j in 0 ..< videos.count
        {
            let videoID=videos[j]["id"] as! Int
            let vType=videos[j]["vtype"] as! Int
            let streamKey=videos[j]["streamkey"] as! String
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
            
            featuredStreamsArray.addObject(video)
        }
    }
    
    func parseCategories(cats:NSArray)
    {
        var sectionItemsArray=NSMutableArray()
        var count=0
        
        for i in 0 ..< cats.count
        {
            let categoryID=cats[i]["id"] as! Int
            let categoryName=cats[i]["name"] as! String
            
            let category=Category()
            category.id=UInt(categoryID)
            category.name=categoryName
            
            sectionItemsArray.addObject(category)
            
            count+=1
            
            if count==2||(count==1&&i==cats.count-1)
            {
                count=0
                allCategoriesArray.addObject(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
    }
    
    func discoverFailure(error:NSError)
    {
        activityView.hidden=true
        errorView.update("An error cccured", icon:"user")
    }
}
