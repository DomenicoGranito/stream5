//
//  ActivityIndicatorView.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/12/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class ActivityIndicatorView:UIView
{
    static var activityIndicatorView:DGActivityIndicatorView!
    
    class func addActivityIndictorView(view:UIView)
    {
        activityIndicatorView=DGActivityIndicatorView(type:.LineScalePulseOut, tintColor:UIColor.whiteColor())
        activityIndicatorView.frame=CGRectMake(view.frame.size.width/2, view.frame.size.height/2, 0, 0)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    class func removeActivityIndicatorView()
    {
        activityIndicatorView.removeFromSuperview()
    }
}
