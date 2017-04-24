//
//  StreamCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class SearchStreamCell: StreamCell {
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamLiveView: StreamLiveView!
    @IBOutlet weak var streamNameLabelHeight: NSLayoutConstraint!
   
    var userSelectingHandler: UserSelectingHandler?
        
    override func update(stream: Stream) {
        super.update(stream)
        let (host, _, _, _, _) = Config.shared.wowza()
        
        self.backgroundColor = UIColor.blackColor()
        userLabel.text = stream.user.name
        streamNameLabel.text = stream.title
        
        let expectedSize = streamNameLabel.sizeThatFits(CGSizeMake(streamNameLabel.bounds.size.width, 10000))
        streamNameLabelHeight.constant = expectedSize.height > 75.0 ? 75.0 : expectedSize.height
        
        self.streamLiveView.setCount(stream.viewers)
                
        //streamImageView.sd_setImageWithURL(stream.urlToStreamImage())
        streamImageView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(stream.id).jpg"))

    }
}
