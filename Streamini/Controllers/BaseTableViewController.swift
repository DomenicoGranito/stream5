//
//  BaseTableViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 02/09/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class BaseTableViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func handleError(error:NSError)
    {
        if let userInfo=error.userInfo as? [NSObject:NSObject]
        {
            if userInfo["code"]==Error.kLoginExpiredCode
            {
                let root=UIApplication.sharedApplication().delegate!.window!?.rootViewController as! UINavigationController
                
                if root.topViewController!.presentedViewController != nil
                {
                    root.topViewController!.presentedViewController!.dismissViewControllerAnimated(true, completion:nil)
                }
                
                let controllers=root.viewControllers.filter({($0 is LoginViewController)})
                root.setViewControllers(controllers, animated:true)
                
                let message=userInfo[NSLocalizedDescriptionKey] as! String
                let alertView=UIAlertView.notAuthorizedAlert(message)
                alertView.show()
            }
        }
    }
}
