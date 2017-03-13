//
//  ErrorView.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/13/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class ErrorView:UIView
{
    static var errorView:UIView!
    
    class func addErrorView(view:UIView)
    {
        errorView=UIView(frame:CGRectMake(0, view.frame.size.height/2-50, view.frame.size.height, 100))
        
        let imageView=UIImageView(frame:CGRectMake(view.frame.size.width/2-25, 0, 50, 50))
        imageView.image=UIImage(named:"user.png")
        
        let label=UILabel(frame:CGRectMake(0, 50, view.frame.size.width, 50))
        label.text="An error occured"
        label.textColor=UIColor.whiteColor()
        label.textAlignment = .Center
        
        errorView.addSubview(imageView)
        errorView.addSubview(label)
        
        view.addSubview(errorView)
    }
    
    class func removeErrorView()
    {
        errorView.removeFromSuperview()
    }
}
