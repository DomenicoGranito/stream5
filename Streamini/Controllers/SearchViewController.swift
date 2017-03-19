//
//  PeopleViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class SearchViewController: BaseViewController, UserSelecting, StreamSelecting, ProfileDelegate, UISearchBarDelegate, UserStatusDelegate
{
    var dataSource:SearchDataSource?
    
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchTypeSegment:UISegmentedControl!
    
    @IBAction func changeMode()
    {
        switch searchTypeSegment.selectedSegmentIndex
        {
        case 0:
            searchBar.resignFirstResponder()
            dataSource?.changeMode("categories")
            break
        case 1:
            searchBar.resignFirstResponder()
            dataSource?.changeMode("places")
            break
        default:
            dataSource?.changeMode("people")
            break
        }
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
        if searchText.characters.count>0&&(dataSource!.mode=="streams"||dataSource!.mode=="people")
        {
            dataSource!.search(searchText)
        }
    }
    
    func configureView()
    {
        tableView.addInfiniteScrollingWithActionHandler
            {()->Void in
                self.dataSource!.fetchMore()
        }
        
        dataSource=SearchDataSource(tableView:tableView)
        dataSource!.userSelectedDelegate=self
        dataSource!.streamSelectedDelegate=self
        
        searchTypeSegment.setTitle(NSLocalizedString("broadcasts", comment:""), forSegmentAtIndex:0)
        searchTypeSegment.setTitle(NSLocalizedString("places", comment:""), forSegmentAtIndex:1)
        searchTypeSegment.setTitle(NSLocalizedString("people", comment:""), forSegmentAtIndex:2)
        
        searchTypeSegment.layer.cornerRadius=0.0
        searchTypeSegment.layer.borderWidth=1.5
    }
    
    override func viewDidLoad()
    {
        configureView()
        
        dataSource!.reload()
    }
    
    override func viewWillAppear(animated:Bool)
    {
        self.navigationController?.navigationBarHidden=true
    }
    
    func reload()
    {
        dataSource!.reload()
    }
    
    func close()
    {
        
    }
    
    func followStatusDidChange(status:Bool, user:User)
    {
        dataSource!.updateUser(user, isFollowed:status, isBlocked:user.isBlocked)
    }
    
    func blockStatusDidChange(status:Bool, user:User)
    {
        dataSource!.updateUser(user, isFollowed:user.isFollowed, isBlocked:status)
    }
    
    func userDidSelected(user:User)
    {
        searchBar.resignFirstResponder()
    }
    
    func streamDidSelected(stream:Stream)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
        modalVC.stream=stream
        
        presentViewController(modalVC, animated:true, completion:nil)
    }
    
    func openPopUpForSelectedStream(stream:Stream)
    {
        
    }
}
