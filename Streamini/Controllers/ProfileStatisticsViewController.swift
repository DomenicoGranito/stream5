//
//  ProfileStatisticsViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 19/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

enum ProfileStatisticsType: Int
{
    case Following = 0
    case Followers
    case Blocked
    case Streams
}

class ProfileStatisticsViewController: UIViewController, UserSelecting, UserStatusDelegate
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var emptyLabel:UILabel!
    var dataSource:UserStatisticsDataSource?
    var type:ProfileStatisticsType = .Following
    var profileDelegate:ProfileDelegate?

    func configureView()
    {
        emptyLabel.text=NSLocalizedString("table_no_data", comment:"")
        
        switch type
        {
        case .Following:    title=NSLocalizedString("profile_following", comment:"")
        case .Followers:    title=NSLocalizedString("profile_followers", comment:"")
        case .Blocked:      title=NSLocalizedString("profile_blocked", comment:"")
        case .Streams:      title=NSLocalizedString("profile_streams", comment:"")
        }
        
        tableView.tableFooterView=UIView()
        
        tableView.addPullToRefreshWithActionHandler
            {()->Void in
            self.dataSource!.reload()
        }
        
        if type != .Streams
        {
            tableView.addInfiniteScrollingWithActionHandler
                {()->Void in
                self.dataSource!.fetchMore()
            }
        }
    }
    
    override func viewDidLoad()
    {
        configureView()
        
        let userId=UserContainer.shared.logged().id
        dataSource=UserStatisticsDataSource.create(type, userId:userId, tableView:tableView)
        dataSource!.profileDelegate=profileDelegate
        dataSource!.userSelectedDelegate=self
        dataSource!.reload()
    }
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=false
    }
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        if let sid=segue.identifier
        {
            if sid=="ProfileStatisticsToJoinStream"
            {
                let navigationController=segue.destinationViewController as! UINavigationController
                let controller=navigationController.viewControllers[0] as! JoinStreamViewController
                controller.stream=(sender as! StreamCell).stream
                controller.isRecent=true
            }
        }
    }
    
    func userDidSelected(user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController!.pushViewController(vc, animated:true)
    }
    
    func followStatusDidChange(status:Bool, user:User)
    {
        dataSource!.updateFollowedStatus(user, status:status)
        profileDelegate!.reload()
    }
    
    func blockStatusDidChange(status:Bool, user:User)
    {
        dataSource!.updateBlockedStatus(user, status:status)
        profileDelegate!.reload()
    }
}
