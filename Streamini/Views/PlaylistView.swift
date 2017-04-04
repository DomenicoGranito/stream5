//
//  PlaylistView.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/4/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

import UIKit

class PlaylistView: UIView
{
    class func instanceFromNib()->UIView
    {
        return UINib(nibName:"PlaylistView", bundle:nil).instantiateWithOwner(nil, options:nil)[0] as! UIView
    }
}
