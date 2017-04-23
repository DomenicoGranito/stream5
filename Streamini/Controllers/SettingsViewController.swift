//
//  ProfileViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class SettingsViewController:UITableViewController, UIActionSheetDelegate
{
    func logout()
    {
        let actionSheet=UIActionSheet.confirmLogoutActionSheet(self)
        actionSheet.showInView(view)
    }
    
    func logoutFailure(error:NSError)
    {
        
    }
    
    func actionSheet(actionSheet:UIActionSheet, clickedButtonAtIndex buttonIndex:Int)
    {
        if buttonIndex != actionSheet.cancelButtonIndex
        {
            UserConnector().logout(logoutSuccess, failure:logoutFailure)
        }
    }
    
    func logoutSuccess()
    {
        A0SimpleKeychain().clearAll()
        
        let appDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
        let navController=appDelegate.window!.rootViewController as! UINavigationController
        navController.popToRootViewControllerAnimated(true)
    }

    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        if indexPath.section==2&&indexPath.row==0
        {
            logout()
        }
    }
}
