//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoriesViewController: BaseViewController
{
    @IBOutlet var itemsTbl:UITableView?
    @IBOutlet var headerLbl:UILabel?
    @IBOutlet var topImageView:UIImageView?
    @IBOutlet var headerHeightConstraint:NSLayoutConstraint!
    
    var allItemsArray=NSMutableArray()
    var streamsArray=NSMutableArray()
    var categoryName:String?
    var page=0
    var categoryID:Int?
    var TBVC:TabBarViewController!
    let maxHeaderHeight:CGFloat=220.0
    let minHeaderHeight:CGFloat=100.0
    var previousScrollOffset:CGFloat=0.0
    
    override func viewDidLoad()
    {
        TBVC=tabBarController as! TabBarViewController
        
        headerLbl?.text=categoryName?.uppercaseString
        navigationController?.navigationBarHidden=true
        itemsTbl?.addInfiniteScrollingWithActionHandler{()->Void in
            self.fetchMore()
        }
        
        StreamConnector().categoryStreams(categoryID!, pageID:page, success:successStreams, failure:failureStream)
    }
    
    func scrollViewDidScroll(scrollView:UIScrollView)
    {
        let scrollDiff=scrollView.contentOffset.y-previousScrollOffset
        
        let absoluteTop:CGFloat=0
        let absoluteBottom:CGFloat=scrollView.contentSize.height-scrollView.frame.size.height
        
        let isScrollingDown=scrollDiff>0&&scrollView.contentOffset.y>absoluteTop
        let isScrollingUp=scrollDiff<0&&scrollView.contentOffset.y<absoluteBottom
        
        var newHeight=headerHeightConstraint.constant
        
        if isScrollingDown
        {
            newHeight=max(minHeaderHeight, newHeight-abs(scrollDiff))
        }
        else if isScrollingUp
        {
            newHeight=min(maxHeaderHeight, newHeight+abs(scrollDiff))
        }
        
        if newHeight != headerHeightConstraint.constant
        {
            headerHeightConstraint.constant=newHeight
            updateHeader()
        }
        
        previousScrollOffset=scrollView.contentOffset.y
    }
    
    func updateHeader()
    {
        let range=maxHeaderHeight-minHeaderHeight
        let openAmount=headerHeightConstraint.constant-minHeaderHeight
        let percentage=openAmount/range
        
        topImageView?.alpha=percentage
    }
    
    func fetchMore()
    {
        page+=1
        StreamConnector().categoryStreams(categoryID!, pageID:page, success:fetchMoreSuccess, failure:failureStream)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return allItemsArray.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! AllCategoriesRow
        
        cell.sectionItemsArray=allItemsArray[indexPath.row] as! NSArray
        cell.TBVC=TBVC
        
        return cell
    }
    
    func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        let cell=cell as! AllCategoriesRow
        
        cell.reloadCollectionView()
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func successStreams(data:NSDictionary)
    {
        allItemsArray.addObjectsFromArray(getData(data) as [AnyObject])
        itemsTbl?.reloadData()
    }
    
    func fetchMoreSuccess(data:NSDictionary)
    {
        itemsTbl?.infiniteScrollingView.stopAnimating()
        allItemsArray.addObjectsFromArray(getData(data) as [AnyObject])
        itemsTbl?.reloadData()
    }
    
    func getData(data:NSDictionary)->NSMutableArray
    {
        let data=data["data"]!
        
        var sectionItemsArray=NSMutableArray()
        let allItemsArray=NSMutableArray()
        var count=0
        
        for i in 0 ..< data.count
        {
            let videoID=data[i]["id"] as! Int
            let streamKey=data[i]["streamkey"] as! String
            let videoTitle=data[i]["title"] as! String
            let videoHash=data[i]["hash"] as! String
            let lon=data[i]["lon"]!.doubleValue
            let lat=data[i]["lat"]!.doubleValue
            let city=data[i]["city"] as! String
            let ended=data[i]["ended"] as? String
            let viewers=data[i]["viewers"] as! Int
            let tviewers=data[i]["tviewers"] as! Int
            let rviewers=data[i]["rviewers"] as! Int
            let likes=data[i]["likes"] as! Int
            let rlikes=data[i]["rlikes"] as! Int
            let userID=data[i]["user"]!["id"] as! Int
            let userName=data[i]["user"]!["name"] as! String
            let userAvatar=data[i]["user"]!["avatar"] as? String
            
            let user=User()
            user.id=UInt(userID)
            user.name=userName
            user.avatar=userAvatar
            
            let video=Stream()
            video.id=UInt(videoID)
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
            
            sectionItemsArray.addObject(video)
            streamsArray.addObject(video)
            count+=1
            
            if(count==2||(count==1&&i==data.count-1))
            {
                count=0
                allItemsArray.addObject(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
        
        return allItemsArray
    }
    
    func failureStream(error:NSError)
    {
        handleError(error)
    }
    
    @IBAction func shufflePlay()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
        let random=Int(arc4random_uniform(UInt32(streamsArray.count)))
        let stream=streamsArray[random] as! Stream
        
        modalVC.stream=stream
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
}
