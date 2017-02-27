//
//  MyLibViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 4/2/2017.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

class RecentlyPlayedCell:UITableViewCell
{
    @IBOutlet var videoTitleLbl:UILabel?
    @IBOutlet var artistNameLbl:UILabel?
    @IBOutlet var videoThumbnailImageView:UIImageView?
}

class MyLibViewController: UIViewController
{
    @IBOutlet var itemsTbl:UITableView?
    
    let menuItemTitlesArray=["Playlists", "Live Streams", "Videos", "Series", "Channels", "Upcoming Events"]
    let menuItemIconsArray=["playlist", "youtube", "internet", "Series", "channels", "time"]
    
    var recentlyPlayed:[NSManagedObject]?
    var user: User?
    var profileDelegate: ProfileDelegate?
    var selectedImage: UIImage?

   // var dataSource: UserStatisticsDataSource?
    var dataSource: UserSelecting?
    var type: ProfileStatisticsType = .Following
   

   // override func viewDidLoad()
   // {
       // super.viewDidLoad()
       // self.configureView()
        
       // let activator=UIActivityIndicatorView(activityIndicatorStyle:.White)
       // activator.startAnimating()
        
       // self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
     //   UserConnector().get(nil, success:successGetUser, failure:successFailure)
   // }

    override func viewDidLoad()
    {
        recentlyPlayed=SongManager.getRecentlyPlayed()
        
        self.tabBarController!.navigationItem.hidesBackButton=true
        navigationController?.navigationBarHidden=false
        self.navigationController!.setNavigationBarHidden(false, animated:true)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
    }

   // @IBOutlet var MyProfile : UIButton!
   // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
     //   if (segue.identifier == "MyProfile") {
         //   let playlistName = sender as! String
       //     let playlistVC = (segue.destinationViewController as? UserViewController)!
           // playlistVC.playlistName = playlistName
            //UserProfileViewController
        //}
    //}
    
   // @IBAction func MyProfilePressed(sender:AnyObject)
    //{
     //   self.performSegueWithIdentifier("MyProfile", sender:self)
   // }
    
    override func viewWillAppear(animated:Bool)
    {
        self.tabBarController!.navigationItem.hidesBackButton = true
        navigationController?.navigationBarHidden=false
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
    }
    
    @IBAction func myaccount(user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("myProfileViewControllerId") as! myProfileViewController
        vc.user=UserContainer.shared.logged()
        navigationController?.pushViewController(vc, animated:true)
    }

    func successGetUser(user:User)
    {
        self.user=user
    }
    
    func successFailure(error:NSError)
    {
      //  handleError(error)
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if(indexPath.row<6)
        {
            return 44
        }
        else
        {
            return 90
        }
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return recentlyPlayed!.count+6
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if(indexPath.row<6)
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row]
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row])
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("RecentlyPlayedCell") as! RecentlyPlayedCell
            
            cell.videoTitleLbl?.text=recentlyPlayed![indexPath.row-6].valueForKey("songName") as? String
            
            return cell
        }
        
        return UITableViewCell()
    }
}
