class UILoadingView : UIView {
    
    init(frame rect: CGRect, text: NSString = "Loading...") {
        super.init(frame: rect)
        self.backgroundColor = UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        self.label.text = text as String
        self.label.textColor = self.spinner.color
        self.spinner.startAnimating()
        
        self.addSubview(self.label)
        self.addSubview(self.spinner)
        
        //self.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        
        self.setNeedsLayout()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    lazy var label : UILabel = {
        var l = UILabel()
        l.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        return l
    }()
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func layoutSubviews() {
        var labelString:NSString = self.label.text!
        var labelSize: CGSize = labelString.sizeWithAttributes([NSFontAttributeName: self.label.font])
        var labelFrame: CGRect = CGRect()
        labelFrame.size = labelSize
        self.label.frame = labelFrame
        
        // center label and spinner
        self.label.center = self.center
        self.spinner.center = self.center
        
        // horizontally align
        labelFrame = self.label.frame
        var spinnerFrame: CGRect = self.spinner.frame
        var totalWidth: CGFloat = spinnerFrame.size.width + 5 + labelSize.width
        spinnerFrame.origin.x = self.bounds.origin.x + (self.bounds.size.width - totalWidth) / 2
        labelFrame.origin.x = spinnerFrame.origin.x + spinnerFrame.size.width + 5
        self.label.frame = labelFrame
        self.spinner.frame = spinnerFrame
    }
    
}

class MenuCell: UITableViewCell
{
    @IBOutlet var menuItemTitleLbl:UILabel?
    @IBOutlet var menuItemIconImageView:UIImageView?
}

//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class DiscoverViewController:BaseTableViewController
{
    var allCategoriesArray=NSMutableArray()
    var recentStreamsArray=NSMutableArray()
    
    var menuItemTitlesArray=[]
    var menuItemIconsArray=[]
    var timer:NSTimer?
    var loadingView:UIView?
    
    override func viewDidLoad()
    {
        loadingView=UILoadingView(frame:view.bounds)
        view.addSubview(loadingView!)
        
        self.title=NSLocalizedString("Discover", comment:"")
        
        StreamConnector().categories(categoriesSuccess, failure:categoriesFailure)
        StreamConnector().homeStreams(successStreams, failure:categoriesFailure)
        
        timer=NSTimer(timeInterval:NSTimeInterval(2.0), target:self, selector:#selector(reload), userInfo:nil, repeats:true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode:NSRunLoopCommonModes)
    }
  
    override func viewWillAppear(animated:Bool)
    {
        self.tabBarController!.navigationItem.hidesBackButton=true
        navigationController?.navigationBarHidden=false
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 1 && indexPath.row == 0 { // following, followers, blocked, streams
            self.performSegueWithIdentifier("charts", sender: indexPath)
        }
        if indexPath.section == 1 && indexPath.row == 1 { // following, followers, blocked, streams
            self.performSegueWithIdentifier("channels", sender: indexPath)
        }
        if indexPath.section == 1 && indexPath.row == 2 { // following, followers, blocked, streams
            self.performSegueWithIdentifier("series", sender: indexPath)
        }
        if indexPath.section == 1 && indexPath.row == 3 { // following, followers, blocked, streams
            self.performSegueWithIdentifier("channels", sender: indexPath)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "charts" {
                let controller = segue.destinationViewController as! ChartsViewController
                let index = (sender as! NSIndexPath).row
               // controller.type = (index == 2) ? LegalViewControllerType.TermsOfService : LegalViewControllerType.PrivacyPolicy
            }
            if sid == "channels" {
                let controller = segue.destinationViewController as! PeopleViewController
                
                let index = (sender as! NSIndexPath).row
                // controller.type = (index == 2) ? LegalViewControllerType.TermsOfService : LegalViewControllerType.PrivacyPolicy
            }
            if sid == "series" {
                let controller = segue.destinationViewController as! SeriesViewController
                let index = (sender as! NSIndexPath).row
                // controller.type = (index == 2) ? LegalViewControllerType.TermsOfService : LegalViewControllerType.PrivacyPolicy
            }

        }
    }

    func reload()
    {
        if allCategoriesArray.count>0&&recentStreamsArray.count>0
        {
            menuItemTitlesArray=["Charts", "New Releases", "Videos", "Podcasts", "Discover", "Concerts"]
            menuItemIconsArray=["user.png", "time.png", "video.png", "user.png", "user.png", "user.png"]
            
            tableView.reloadData()
            
            timer!.invalidate()
            
            loadingView?.removeFromSuperview()
        }
    }
    
    override func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 3
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if section==0
        {
            return 1
        }
        else if section==1
        {
            return 6
        }
        else
        {
            return allCategoriesArray.count
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
            return 210
        }
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if indexPath.section==0&&recentStreamsArray.count>0
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Recent") as! CategoryRow
            
            cell.oneCategoryItemsArray=recentStreamsArray[1] as! NSArray
            
            return cell
        }
        if indexPath.section==1&&menuItemTitlesArray.count>0
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Menu") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row] as? String
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row] as! String)
            
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
    
    func successStreams(data:NSDictionary)
    {
        let data=data["data"]!
        
        for i in 0 ..< data.count
        {
            let videos=data[i]["videos"] as! NSArray
            
            let oneCategoryItemsArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let videoID=videos[j]["id"] as! String
                let videoTitle=videos[j]["title"] as! String
                let videoHash=videos[j]["hash"] as! String
                let lon=videos[j]["lon"]!.doubleValue
                let lat=videos[j]["lat"]!.doubleValue
                let city=videos[j]["city"] as! String
                let ended=videos[j]["ended"] as? String
                let viewers=videos[j]["viewers"] as! String
                let tviewers=videos[j]["tviewers"] as! String
                let rviewers=videos[j]["rviewers"] as! String
                let likes=videos[j]["likes"] as! String
                let rlikes=videos[j]["rlikes"] as! String
                let userID=videos[j]["user"]!["id"] as! String
                let userName=videos[j]["user"]!["name"] as! String
                let userAvatar=videos[j]["user"]!["avatar"] as? String
                
                let user=User()
                user.id=UInt(userID)!
                user.name=userName
                user.avatar=userAvatar
                
                let video=Stream()
                video.id=UInt(videoID)!
                video.title=videoTitle
                video.streamHash=videoHash
                video.lon=lon
                video.lat=lat
                video.city=city
                
                if let e=ended
                {
                    video.ended=NSDate(timeIntervalSince1970:Double(e)!)
                }
                
                video.viewers=UInt(viewers)!
                video.tviewers=UInt(tviewers)!
                video.rviewers=UInt(rviewers)!
                video.likes=UInt(likes)!
                video.rlikes=UInt(rlikes)!
                video.user=user
                
                oneCategoryItemsArray.addObject(video)
            }
            
            recentStreamsArray.addObject(oneCategoryItemsArray)
        }
    }
    
    func categoriesSuccess(cats:[Category])
    {
        var sectionItemsArray=NSMutableArray()
        var count=0
        
        for i in 0 ..< cats.count
        {
            sectionItemsArray.addObject(cats[i])
            
            count+=1
            
            if count==2||(count==1&&i==cats.count-1)
            {
                count=0
                allCategoriesArray.addObject(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
    }
    
    func categoriesFailure(error:NSError)
    {
        handleError(error)
    }
}
