//
//  SeeMoreViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/9/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeeMoreViewController: UIViewController
{
    @IBOutlet var tableView:UITableView!
    
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    var TBVC:TabBarViewController!
    var t:String!
    var q:String!
    var users:[User]=[]
    var streams:[Stream]=[]
    
    override func viewWillAppear(animated:Bool)
    {
        self.title = t.capitalizedString
        navigationController?.navigationBarHidden=false
        
        if t=="streams"
        {
            StreamConnector().searchMoreStreams(q, success:searchMoreStreamsSuccess, failure:searchFailure)
        }
        else
        {
            StreamConnector().searchMoreOthers(q, identifier:t, success:searchMoreOthersSuccess, failure:searchFailure)
        }
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if t=="streams"
        {
            return 80
        }
        else
        {
            return 70
        }
    }

    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if t=="streams"
        {
            return streams.count
        }
        else
        {
            return users.count
        }
    }

    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if t=="streams"
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("StreamCell", forIndexPath:indexPath) as! SearchStreamCell
            let stream=streams[indexPath.row]
            cell.update(stream)
            
            cell.dotsButton?.tag=indexPath.row
            cell.dotsButton?.addTarget(self, action:#selector(dotsButtonTapped), forControlEvents:.TouchUpInside)
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("PeopleCell", forIndexPath:indexPath) as! PeopleCell
            
            let user=users[indexPath.row]
            
            cell.userImageView.sd_setImageWithURL(user.avatarURL())
            cell.usernameLabel.text=user.name
            cell.likesLabel.text="\(user.likes)"
            
            return cell
        }
    }

    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if t=="streams"
        {
            let modalVC=storyBoard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
            
            let streamsArray=NSMutableArray()
            streamsArray.addObject(streams[indexPath.row])
            
            modalVC.streamsArray=streamsArray
            modalVC.TBVC=TBVC
            
            TBVC.modalVC=modalVC
            TBVC.configure(streams[indexPath.row])
        }
        else
        {
            let vc=storyBoard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
            vc.user=users[indexPath.row]
            vc.TBVC=TBVC
            navigationController?.pushViewController(vc, animated:true)
        }
    }

    func searchMoreStreamsSuccess(streams:[Stream])
    {
        self.streams=streams
        
        tableView.reloadData()
    }
    
    func searchMoreOthersSuccess(users:[User])
    {
        self.users=users
        
        tableView.reloadData()
    }
    
    func searchFailure(error:NSError)
    {
        
    }
    
    func dotsButtonTapped(sender:UIButton)
    {
        let vc=storyBoard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        vc.stream=streams[sender.tag]
        presentViewController(vc, animated:true, completion:nil)
    }
}
