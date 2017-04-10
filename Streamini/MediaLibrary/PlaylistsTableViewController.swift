//
//  PlaylistsTableViewController.swift
//  Music Player
//
//  Created by 岡本拓也 on 2016/01/02.
//  Copyright © 2016年 Sem. All rights reserved.
//

class PlaylistsTableViewController: UITableViewController
{
    override func viewDidLoad()
    {
        
    }
    
    @IBAction func didTapAddButton()
    {
        showTextFieldDialog("Add playlist", message:"", placeHolder:"Name", okButtonTitle:"Add", didTapOkButton:{title in})
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("playlistCell")! as UITableViewCell
        cell.textLabel?.text="ANKIT"
        
        return cell
    }
    
    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        performSegueWithIdentifier("PlaylistsToPlaylist", sender:nil)
    }
    
    override func tableView(tableView:UITableView, commitEditingStyle editingStyle:UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath)
    {
        if editingStyle == .Delete
        {
            
        }
    }
}
