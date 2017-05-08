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
    
    override func viewDidLoad()
    {
        
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
        
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 1
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 0
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        return UITableViewCell()
    }
    
    func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        return 44
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        
    }
}
