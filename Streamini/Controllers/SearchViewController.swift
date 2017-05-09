//
//  SearchViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/8/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SearchViewController: UIViewController
{
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var tableView:UITableView!
    
    let sectionTitlesArray=["brands", "agencies", "venues", "talents", "profiles", "streams"]
    
    var brands:[User]=[]
    var agencies:[User]=[]
    var venues:[User]=[]
    var talents:[User]=[]
    var profiles:[User]=[]
    var streams:[Stream]=[]
    
    override func viewDidLoad()
    {
        
    }
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=true
    }
    
    func searchBarSearchButtonClicked(searchBar:UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar:UISearchBar)
    {
        searchBar.showsCancelButton=false
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar:UISearchBar)
    {
        searchBar.showsCancelButton=true
    }
    
    func searchBar(searchBar:UISearchBar, textDidChange searchText:String)
    {
        StreamConnector().search(searchText, success:searchSuccess, failure:searchFailure)
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 30
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if indexPath.section>4
        {
            return 80
        }
        else
        {
            return 70
        }
    }
    
    func tableView(tableView:UITableView, viewForFooterInSection section:Int)->UIView?
    {
        let footerView=UIView(frame:CGRectMake(0, 0, tableView.frame.size.width, 30))
        footerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRectMake(15, 5, 285, 20))
        titleLbl.text="See all \(sectionTitlesArray[section])"
        titleLbl.font=UIFont.systemFontOfSize(16)
        titleLbl.textColor=UIColor.whiteColor()
        
        let lineView=UIView(frame:CGRectMake(0, 29.5, tableView.frame.size.width, 0.5))
        lineView.backgroundColor=UIColor(colorLiteralRed:37/255, green:36/255, blue:41/255, alpha:1)
        
        let tapGesture=UITapGestureRecognizer(target:self, action:#selector(footerTapped))
        footerView.addGestureRecognizer(tapGesture)
        footerView.tag=section

        footerView.addSubview(titleLbl)
        footerView.addSubview(lineView)
        
        return footerView
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, tableView.frame.size.width, 30))
        headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRectMake(15, 5, 285, 20))
        titleLbl.text=sectionTitlesArray[section].uppercaseString
        titleLbl.font=UIFont.systemFontOfSize(16)
        titleLbl.textColor=UIColor.darkGrayColor()
        
        headerView.addSubview(titleLbl)
        
        return headerView
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 6
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if section==0
        {
            return brands.count
        }
        else if section==1
        {
            return agencies.count
        }
        else if section==2
        {
            return venues.count
        }
        else if section==3
        {
            return talents.count
        }
        else if section==4
        {
            return profiles.count
        }
        else
        {
            return streams.count
        }
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if indexPath.section>4
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("StreamCell", forIndexPath:indexPath) as! SearchStreamCell
            let stream=streams[indexPath.row]
            cell.update(stream)
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("PeopleCell", forIndexPath:indexPath) as! PeopleCell
            
            let user:User
            
            if indexPath.section==0
            {
                user=brands[indexPath.row]
            }
            else if indexPath.section==1
            {
                user=agencies[indexPath.row]
            }
            else if indexPath.section==2
            {
                user=venues[indexPath.row]
            }
            else if indexPath.section==3
            {
                user=talents[indexPath.row]
            }
            else
            {
                user=profiles[indexPath.row]
            }
            
            cell.userImageView.sd_setImageWithURL(user.avatarURL())
            cell.usernameLabel.text=user.name
            cell.likesLabel.text="\(user.likes)"
            
            return cell
        }
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        
    }
    
    func searchSuccess(brands:[User], agencies:[User], venues:[User], talents:[User], profiles:[User], streams:[Stream])
    {
        self.brands=brands
        self.agencies=agencies
        self.venues=venues
        self.talents=talents
        self.profiles=profiles
        self.streams=streams
        
        tableView.hidden=false
        tableView.reloadData()
    }
    
    func searchFailure(error:NSError)
    {
        
    }
    
    func footerTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("SeeMoreViewController") as! SeeMoreViewController
        navigationController?.pushViewController(vc, animated:true)
    }
}
