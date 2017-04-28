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

class DiscoverViewController:BaseTableViewController
{
    var allCategoriesArray=NSMutableArray()
    var featuredStreamsArray=NSMutableArray()
    
    var menuItemTitlesArray=["Channels"]
    var menuItemIconsArray=["user.png"]
    
    override func viewDidLoad()
    {
        ActivityIndicatorView.addActivityIndictorView(view)
        StreamConnector().discover(discoverSuccess, failure:discoverFailure)
    }
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=false
    }
    
    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if indexPath.section==1&&indexPath.row==0
        {
            performSegueWithIdentifier("Channels", sender:nil)
        }
    }
    
    override func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 3
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if allCategoriesArray.count>0&&featuredStreamsArray.count>0
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
        else
        {
            return 0
        }
    }
    
    override func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if indexPath.section==0
        {
            return 270
        }
        else if indexPath.section==1
        {
            return 50
        }
        else
        {
            return 160
        }
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
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
    
    override func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        if cell is AllCategoryRow
        {
            (cell as! AllCategoryRow).reloadCollectionView()
        }
    }
    
    func discoverSuccess(data:NSDictionary)
    {
        ActivityIndicatorView.removeActivityIndicatorView()
        
        let videos=data["data"]!["feat"] as! NSArray
        let categories=data["data"]!["cat"] as! NSArray
        
        parseFeaturedStreams(videos)
        parseCategories(categories)
        
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
        ActivityIndicatorView.removeActivityIndicatorView()
        ErrorView.addErrorView(view)
    }
}
