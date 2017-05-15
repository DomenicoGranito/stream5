//
//  ActivityIndicatorView.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/12/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class ActivityIndicatorView:UIView
{
    @IBOutlet var activityIndicatorView:DGActivityIndicatorView!
    
    override func awakeFromNib()
    {
        activityIndicatorView.type = .LineScalePulseOut
        activityIndicatorView.tintColor=UIColor.whiteColor()
        activityIndicatorView.startAnimating()
    }
}
