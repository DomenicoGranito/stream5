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
    @IBOutlet var historyTbl:UITableView!
    
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    var sectionTitlesArray=NSMutableArray()
    var TBVC:TabBarViewController!
    var searchHistroy:[NSManagedObject]!
    var brands:[User]=[]
    var agencies:[User]=[]
    var venues:[User]=[]
    var talents:[User]=[]
    var profiles:[User]=[]
    var streams:[Stream]=[]
    
    override func viewDidLoad()
    {
        TBVC=tabBarController as! TabBarViewController
        searchHistroy=SongManager.getSearchHistory()
        
        if searchHistroy.count>0
        {
            historyTbl.hidden=false
        }
    }
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=true
    }
    
    func searchBarSearchButtonClicked(searchBar:UISearchBar)
    {
        SongManager.addToSearchHistory(searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar:UISearchBar)
    {
        tableView.hidden=true
        
        searchHistroy=SongManager.getSearchHistory()
        
        if searchHistroy.count>0
        {
            historyTbl.hidden=false
            historyTbl.reloadData()
        }
        
        searchBar.showsCancelButton=false
        searchBar.text=""
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
        return tableView==historyTbl ? 1 : 40
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if tableView==historyTbl
        {
            return 40
        }
        else
        {
            let sectionTitle=sectionTitlesArray[indexPath.section] as! String
            
            if sectionTitle=="streams"
            {
                return indexPath.row<4 ? 80 : 40
            }
            else
            {
                return indexPath.row<4 ? 70 : 40
            }
        }
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        if tableView==historyTbl
        {
            return nil
        }
        else
        {
            let headerView=UIView(frame:CGRectMake(0, 0, tableView.frame.size.width, 40))
            headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
            
            let titleLbl=UILabel(frame:CGRectMake(15, 15, 285, 20))
            titleLbl.text=sectionTitlesArray[section].uppercaseString
            titleLbl.font=UIFont.systemFontOfSize(16)
            titleLbl.textColor=UIColor.darkGrayColor()
            
            headerView.addSubview(titleLbl)
            
            return headerView
        }
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return tableView==historyTbl ? 1 : sectionTitlesArray.count
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if tableView==historyTbl
        {
            return searchHistroy.count>0 ? searchHistroy.count+1 : 0
        }
        else
        {
            let sectionTitle=sectionTitlesArray[section] as! String
            
            if sectionTitle=="brands"
            {
                return brands.count<4 ? brands.count : 5
            }
            else if sectionTitle=="agencies"
            {
                return agencies.count<4 ? agencies.count : 5
            }
            else if sectionTitle=="venues"
            {
                return venues.count<4 ? venues.count : 5
            }
            else if sectionTitle=="talents"
            {
                return talents.count<4 ? talents.count : 5
            }
            else if sectionTitle=="profiles"
            {
                return profiles.count<4 ? profiles.count : 5
            }
            else
            {
                return streams.count<4 ? streams.count : 5
            }
        }
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if tableView==historyTbl
        {
            if indexPath.row<searchHistroy.count
            {
                let cell=tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath:indexPath)
                cell.textLabel?.text=searchHistroy[indexPath.row].valueForKey("title") as? String
                
                return cell
            }
            else
            {
                let cell=tableView.dequeueReusableCellWithIdentifier("ClearCell", forIndexPath:indexPath)
                
                return cell
            }
        }
        else
        {
            let sectionTitle=sectionTitlesArray[indexPath.section] as! String
            
            if sectionTitle=="streams"
            {
                if indexPath.row<4
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
                    let cell=tableView.dequeueReusableCellWithIdentifier("SeeMoreCell", forIndexPath:indexPath)
                    cell.textLabel?.text="See all \(sectionTitlesArray[indexPath.section])"
                    
                    return cell
                }
            }
            else
            {
                if indexPath.row<4
                {
                    let cell=tableView.dequeueReusableCellWithIdentifier("PeopleCell", forIndexPath:indexPath) as! PeopleCell
                    
                    let user:User
                    
                    if sectionTitle=="brands"
                    {
                        user=brands[indexPath.row]
                    }
                    else if sectionTitle=="agencies"
                    {
                        user=agencies[indexPath.row]
                    }
                    else if sectionTitle=="venues"
                    {
                        user=venues[indexPath.row]
                    }
                    else if sectionTitle=="talents"
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
                else
                {
                    let cell=tableView.dequeueReusableCellWithIdentifier("SeeMoreCell", forIndexPath:indexPath)
                    cell.textLabel?.text="See all \(sectionTitlesArray[indexPath.section])"
                    
                    return cell
                }
            }
        }
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if tableView==historyTbl
        {
            if indexPath.row==searchHistroy.count
            {
                SongManager.deleteSearchHistory()
                historyTbl.hidden=true
            }
            else
            {
                searchBar.text=searchHistroy[indexPath.row].valueForKey("title") as? String
                historyTbl.hidden=true
                tableView.hidden=false
                StreamConnector().search(searchBar.text!, success:searchSuccess, failure:searchFailure)
            }
        }
        else
        {
            let sectionTitle=sectionTitlesArray[indexPath.section] as! String
            
            if sectionTitle=="streams"
            {
                if indexPath.row<4
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
                    cellTapped(indexPath.section)
                }
            }
            else
            {
                if indexPath.row<4
                {
                    let vc=storyBoard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
                    
                    if sectionTitle=="brands"
                    {
                        vc.user=brands[indexPath.row]
                    }
                    else if sectionTitle=="agencies"
                    {
                        vc.user=agencies[indexPath.row]
                    }
                    else if sectionTitle=="venues"
                    {
                        vc.user=venues[indexPath.row]
                    }
                    else if sectionTitle=="talents"
                    {
                        vc.user=talents[indexPath.row]
                    }
                    else
                    {
                        vc.user=profiles[indexPath.row]
                    }
                    
                    vc.TBVC=TBVC
                    navigationController?.pushViewController(vc, animated:true)
                }
                else
                {
                    cellTapped(indexPath.section)
                }
            }
        }
    }
    
    func searchSuccess(brands:[User], agencies:[User], venues:[User], talents:[User], profiles:[User], streams:[Stream])
    {
        sectionTitlesArray.removeAllObjects()
        
        if brands.count>0
        {
            sectionTitlesArray.addObject("brands")
            self.brands=brands
        }
        if agencies.count>0
        {
            sectionTitlesArray.addObject("agencies")
            self.agencies=agencies
        }
        if venues.count>0
        {
            sectionTitlesArray.addObject("venues")
            self.venues=venues
        }
        if talents.count>0
        {
            sectionTitlesArray.addObject("talents")
            self.talents=talents
        }
        if profiles.count>0
        {
            sectionTitlesArray.addObject("profiles")
            self.profiles=profiles
        }
        if streams.count>0
        {
            sectionTitlesArray.addObject("streams")
            self.streams=streams
        }
        
        tableView.hidden=false
        historyTbl.hidden=true
        tableView.reloadData()
    }
    
    func searchFailure(error:NSError)
    {
        
    }
    
    func cellTapped(section:Int)
    {
        let vc=storyBoard.instantiateViewControllerWithIdentifier("SeeMoreViewController") as! SeeMoreViewController
        vc.t=sectionTitlesArray[section] as! String
        vc.q=searchBar.text
        vc.TBVC=TBVC
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func dotsButtonTapped(sender:UIButton)
    {
        let vc=storyBoard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        vc.stream=streams[sender.tag]
        presentViewController(vc, animated:true, completion:nil)
    }
}
