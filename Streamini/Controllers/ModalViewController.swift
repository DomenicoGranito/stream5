//
//  ModalViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/02/25.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import AVKit

class ModalViewController: UIViewController
{
    @IBOutlet var carousel:iCarousel?
    @IBOutlet var backgroundImageView:UIImageView?
    @IBOutlet var headerTitleLbl:UILabel?
    @IBOutlet var videoTitleLbl:UILabel?
    @IBOutlet var videoArtistNameLbl:UILabel?
    @IBOutlet var videoProgressDurationLbl:UILabel?
    @IBOutlet var videoDurationLbl:UILabel?
    @IBOutlet var likeButton:UIButton?
    @IBOutlet var playButton:UIButton?
    @IBOutlet var seekBar:UISlider?
    @IBOutlet var previousButton:UIButton?
    @IBOutlet var nextButton:UIButton?
    @IBOutlet var shuffleButton:UIButton?
    
    var isPlaying=true
    //var player:AVQueuePlayer?
    var player:DWMoviePlayerController?
    var stream:Stream?
    var streamsArray:NSArray?
    let (host, port, _, _, _)=Config.shared.wowza()
    var queue:[AVPlayerItem]=[]
    var durationSeconds:Int!
    
    override func viewDidLoad()
    {
        carousel?.pagingEnabled=true
        
        createPlayerWithPlaylist()
        updatePlayerWithStream()
        
        if let _=streamsArray
        {
            carousel?.type = .Rotary
            
            let index=streamsArray!.indexOfObject(stream!)
            
            carousel?.scrollToItemAtIndex(index, animated:true)
        }
    }
    
    override func viewWillAppear(animated:Bool)
    {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation:.Fade)
    }
    
    func updatePlayerWithStream()
    {
        backgroundImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(stream!.id).jpg"))
        
        headerTitleLbl?.text=stream?.title
        videoTitleLbl?.text=stream?.title
        videoArtistNameLbl?.text=stream?.user.name
        
        SongManager.addToRecentlyPlayed(stream!.title, streamHash:stream!.streamHash, streamID:stream!.id, streamUserName:stream!.user.name)
        
        if SongManager.isAlreadyFavourited(stream!.id)
        {
            likeButton?.setImage(UIImage(named:"red_heart"), forState:.Normal)
        }
        else
        {
            likeButton?.setImage(UIImage(named:"empty_heart"), forState:.Normal)
        }
    }
    
    func createPlayerWithPlaylist()
    {
        if let _=streamsArray
        {
            for i in 0 ..< streamsArray!.count
            {
                let stream=streamsArray![i] as! Stream
                
                let item=AVPlayerItem(URL:NSURL(string:"http://\(host)/media/\(stream.id).mp4")!)
                
                queue.append(item)
            }
        }
        else
        {
            let item=AVPlayerItem(URL:NSURL(string:"http://\(host)/media/\(stream!.id).mp4")!)
            
            queue.append(item)
        }
        
        //player=AVQueuePlayer(items:queue)
        player=DWMoviePlayerController(userId:"D43560320694466A", key:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229")
        player?.videoId="F913E6FF859FA7B79C33DC5901307461"
        player?.startRequestPlayInfo()
        player?.controlStyle = .None
//        player!.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue:dispatch_get_main_queue())
//        {_ in
//            if self.player!.currentItem!.status == .ReadyToPlay
//            {
//                let time=Int(CMTimeGetSeconds(self.player!.currentTime()))
//                self.videoDurationLbl!.text="-\(self.secondsToReadableTime(self.durationSeconds-time))"
//                self.videoProgressDurationLbl!.text=self.secondsToReadableTime(time)
//                self.seekBar!.value=Float(time)
//            }
//        }
    }
    
    func helperFunction(index:Int)
    {
        stream=streamsArray![index] as? Stream
        
        updateButtons(index)
        updatePlayerWithStream()
        carousel?.scrollToItemAtIndex(index, animated:true)
    }
    
    @IBAction func shuffle()
    {
        let random=Int(arc4random_uniform(UInt32(streamsArray!.count)))
        
        helperFunction(random)
    }
    
    @IBAction func previous()
    {
        let index=streamsArray!.indexOfObject(stream!)
        
        helperFunction(index-1)
    }
    
    @IBAction func next()
    {
        let index=streamsArray!.indexOfObject(stream!)
        
        helperFunction(index+1)
    }
    
    @IBAction func play()
    {
        if isPlaying
        {
            player?.pause()
            
            playButton?.setImage(UIImage(named:"big_play_button"), forState:.Normal)
            isPlaying=false
        }
        else
        {
            player?.play()
            
            playButton?.setImage(UIImage(named:"big_pause_button"), forState:.Normal)
            isPlaying=true
        }
    }
    
    func numberOfItemsInCarousel(carousel:iCarousel)->Int
    {
        if let _=streamsArray
        {
            return streamsArray!.count
        }
        else
        {
            return 1
        }
    }
    
    func carouselItemWidth(carousel:iCarousel)->CGFloat
    {
        return view.frame.size.width-40
    }
    
    func carousel(carousel:iCarousel, viewForItemAtIndex index:Int, reusingView view:UIView?)->UIView
    {
        if let _=streamsArray
        {
            stream=streamsArray![index] as? Stream
        }
        
        let thumbnailView:UIImageView!
        let frame=CGRectMake(0, 0, self.view.frame.size.width-50, self.view.frame.size.width-50)
        
        if let v=view
        {
            thumbnailView=v.viewWithTag(1) as! UIImageView
            thumbnailView.frame=frame
            thumbnailView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(stream!.id).jpg"))
        }
        else
        {
            thumbnailView=UIImageView(frame:frame)
            thumbnailView.tag=1
            thumbnailView.backgroundColor=UIColor.darkGrayColor()
        }
        
        return thumbnailView
    }
    
    func carouselDidEndScrollingAnimation(aCarousel:iCarousel)
    {
        if let _=streamsArray
        {
            stream=streamsArray![aCarousel.currentItemIndex] as? Stream
            
            updateButtons(aCarousel.currentItemIndex)
            updatePlayerWithStream()
        }
        
//        UIView.animateWithDuration(0.5, animations:{
//            aCarousel.currentItemView!.frame=CGRectMake(-20, 0, self.view.frame.size.width, self.view.frame.size.width-50)
//            }, completion:{(finished:Bool)->Void in
//                let playerLayer=AVPlayerLayer(player:self.player)
//                playerLayer.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width-50)
//                aCarousel.currentItemView!.layer.addSublayer(playerLayer)
//                self.playAtIndex(aCarousel.currentItemIndex)
//        })
        
        UIView.animateWithDuration(0.5, animations:{
            aCarousel.currentItemView!.frame=CGRectMake(-20, 0, self.view.frame.size.width, self.view.frame.size.width-50)
            }, completion:{(finished:Bool)->Void in
                self.player!.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width-50)
                aCarousel.currentItemView!.addSubview(self.player!.view)
                self.player?.play()
        })
    }
    
    func carousel(carousel:iCarousel, valueForOption option:iCarouselOption, withDefault value:CGFloat)->CGFloat
    {
        switch(option)
        {
        case .ShowBackfaces:
            return 0
        case .Spacing:
            return value*1.2
        case .VisibleItems:
            return 3
        default:
            return value
        }
    }
    
    func playAtIndex(index:Int)
    {
        //player?.removeAllItems()
        
        for i in index ..< queue.count
        {
            let item=queue[i]
            item.seekToTime(kCMTimeZero)
            //player?.insertItem(item, afterItem:nil)
        }
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
//        {
//            self.durationSeconds=Int(CMTimeGetSeconds(self.player!.currentItem!.asset.duration))
//            
//            dispatch_async(dispatch_get_main_queue())
//            {
//                self.videoDurationLbl?.text="-\(self.secondsToReadableTime(self.durationSeconds))"
//                self.seekBar!.maximumValue=Float(self.durationSeconds)
//                
//                self.player?.play()
//                self.playButton?.setImage(UIImage(named:"big_pause_button"), forState:.Normal)
//            }
//        }
    }
    
    @IBAction func more()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        vc.stream=stream
        presentViewController(vc, animated:true, completion:nil)
    }
    
    @IBAction func like()
    {
        if SongManager.isAlreadyFavourited(stream!.id)
        {
            likeButton?.setImage(UIImage(named:"empty_heart"), forState:.Normal)
            SongManager.removeFromFavourite(stream!.id)
        }
        else
        {
            likeButton?.setImage(UIImage(named:"red_heart"), forState:.Normal)
            SongManager.addToFavourite(stream!.title, streamHash:stream!.streamHash, streamID:stream!.id, streamUserName:stream!.user.name, vType:1)
        }
    }
    
    @IBAction func seekBarValueChanged()
    {
        let seconds=Int64(seekBar!.value)
        let targetTime=CMTimeMake(seconds, 1)
        
        //player!.seekToTime(targetTime)
    }
    
    @IBAction func close()
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func menu()
    {
        
    }
    
    func secondsToReadableTime(durationSeconds:Int)->String
    {
        var readableDuration=""
        
        let hours=durationSeconds/3600
        var minutes=String(format:"%02d", durationSeconds%3600/60)
        let seconds=String(format:"%02d", durationSeconds%3600%60)
        
        if(hours>0)
        {
            readableDuration="\(hours):"
        }
        else
        {
            minutes="\(Int(minutes)!)"
        }
        
        readableDuration+="\(minutes):\(seconds)"
        
        return readableDuration
    }
    
    func updateButtons(index:Int)
    {
        nextButton?.enabled=true
        previousButton?.enabled=true
        shuffleButton?.enabled=true
        
        if index==0
        {
            previousButton?.enabled=false
        }
        
        if index==streamsArray!.count-1
        {
            nextButton?.enabled=false
        }
        
        if streamsArray!.count==1
        {
            shuffleButton?.enabled=false
        }
    }
}
