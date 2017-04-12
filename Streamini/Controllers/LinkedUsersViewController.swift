//
//  LinkedUsersViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 06/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class LinkedUsersViewController: UIViewController, UserStatisticsDelegate, StreamSelecting,UserSelecting {
    @IBOutlet weak var selectorView: SelectorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var dataSource: UserStatisticsDataSource?
    var profileDelegate: ProfileDelegate?
    var TBC:TabBarViewController!
    
    func userDidSelected(user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func configureView()
    {
        tableView.tableFooterView=UIView()
        emptyLabel.text=NSLocalizedString("table_no_data", comment:"")
        
        tableView.addPullToRefreshWithActionHandler
        {()->Void in
            self.dataSource!.reload()
        }

        tableView.addInfiniteScrollingWithActionHandler
        {()->Void in
            self.dataSource!.fetchMore()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
        
        TBC=tabBarController as! TabBarViewController
    }
    
    func streamDidSelected(stream:Stream)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
        let stream=sectionItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        modalVC.stream=stream
        modalVC.TBC=TBC
        
        TBC.stream=stream
        TBC.modalVC=modalVC
        
        TBC.setupAnimator()
        TBC.updateMiniPlayerWithStream()
        TBC.tapMiniPlayerButton()
    }
    
    func openPopUpForSelectedStream(stream:Stream)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        vc.stream=stream
        presentViewController(vc, animated:true, completion:nil)
    }

    func reload()
    {
        
    }

    func recentStreamsDidSelected(userId: UInt) {
        tableView.showsPullToRefresh     = false
        tableView.showsInfiniteScrolling = false
        selectorView.selectSection(0)
        self.dataSource = RecentStreamsDataSource(userId: userId, tableView: tableView)
        dataSource!.streamSelectedDelegate = self
        dataSource!.profileDelegate = profileDelegate
        dataSource!.clean()
        dataSource!.reload()
    }
    
    func followersDidSelected(userId: UInt) {
        tableView.showsPullToRefresh     = true
        tableView.showsInfiniteScrolling = true
        selectorView.selectSection(1)
        self.dataSource = FollowersDataSource(userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.userSelectedDelegate=self
        dataSource!.clean()
        dataSource!.reload()
    }
    
    func followingDidSelected(userId:UInt)
    {
        tableView.showsPullToRefresh     = true
        tableView.showsInfiniteScrolling = true
        selectorView.selectSection(2)
        self.dataSource = FollowingDataSource(userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.userSelectedDelegate=self
        dataSource!.clean()        
        dataSource!.reload()
    }
}
