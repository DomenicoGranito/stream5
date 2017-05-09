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
    
    var t:String!
    var q:String!
    var users:[User]=[]
    var streams:[Stream]=[]
    
    override func viewDidLoad()
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
}
