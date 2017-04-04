//
//  PlaylistDetailView.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/4/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

import UIKit

class PlaylistDetailView: UIView
{
    class func instanceFromNib()->UIView
    {
        return UINib(nibName:"PlaylistDetailView", bundle:nil).instantiateWithOwner(nil, options:nil)[0] as! UIView
    }
}
