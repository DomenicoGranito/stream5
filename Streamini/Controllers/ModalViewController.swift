//
//  ModalViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/02/25.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

class ModalViewController: UIViewController, ARNImageTransitionZoomable
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
    @IBOutlet var playlistButton:UIButton?
    @IBOutlet var closeButton:UIButton?
    @IBOutlet var seekBar:UISlider?
    @IBOutlet var previousButton:UIButton?
    @IBOutlet var nextButton:UIButton?
    @IBOutlet var shuffleButton:UIButton?
    @IBOutlet var bottomSpaceConstraint:NSLayoutConstraint?
    @IBOutlet var informationView:UIView?
    @IBOutlet var topView:UIView?
    
    var isPlaying=true
    var TBVC:TabBarViewController!
    var player:DWMoviePlayerController?
    var stream:Stream?
    var streamsArray:NSArray?
    let (host, port, _, _, _)=Config.shared.wowza()
    var videoIDs:[String]=[]
    var timer:NSTimer?
    var selectedItemIndex=0
    var appDelegate:AppDelegate!
    var fullScreenButton:UIButton!
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    
    override func viewDidLoad()
    {
        seekBar!.setThumbImage(UIImage(), forState:.Normal)
        
        appDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
        
        stream=streamsArray!.objectAtIndex(selectedItemIndex) as? Stream
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(onDeviceOrientationChange), name:UIDeviceOrientationDidChangeNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(deleteBlockUserVideos), name:"blockUser", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(updatePlayer), name:"updatePlayer", object:nil)
        
        createPlaylist()
        updatePlayerWithStream()
        
        if streamsArray!.count>1
        {
            carousel?.pagingEnabled=true
            carousel?.type = .Rotary
            
            carousel?.scrollToItemAtIndex(selectedItemIndex, animated:true)
        }
        else
        {
            carousel?.scrollEnabled=false
        }
    }
    
    override func viewWillAppear(animated:Bool)
    {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation:.Fade)
        
        songLikeStatus()
        
        appDelegate.shouldRotate=true
    }
    
    override func viewDidAppear(animated:Bool)
    {
        if isPlaying
        {
            player?.play()
            
            playButton?.setImage(UIImage(named:"big_pause_button"), forState:.Normal)
        }
        else
        {
            player?.pause()
            
            playButton?.setImage(UIImage(named:"big_play_button"), forState:.Normal)
        }
    }
    
    override func viewWillDisappear(animated:Bool)
    {
        player?.shouldAutoplay=false
        player?.pause()
        
        TBVC.updateSeekBar(seekBar!.value, maximum:seekBar!.maximumValue)
        appDelegate.shouldRotate=false
    }
    
    func updatePlayer(notification:NSNotification)
    {
        selectedItemIndex=notification.object as! Int
        updateButtons()
        videoIDs.removeAll()
        createPlaylist()
    }
    
    func deleteBlockUserVideos()
    {
        let blockedUserID=stream!.user.id
        let streamsMutableArray=NSMutableArray(array:streamsArray!)
        
        for i in 0 ..< streamsArray!.count
        {
            let stream=streamsArray![i] as! Stream
            
            if blockedUserID==stream.user.id
            {
                streamsMutableArray.removeObject(stream)
                
                let index=videoIDs.indexOf(stream.videoID)
                videoIDs.removeAtIndex(index!)
            }
        }
        
        streamsArray=streamsMutableArray
        
        if streamsArray!.count==0
        {
            close()
        }
        else
        {
            carousel!.reloadData()
        }
    }
    
    func updatePlayerWithStream()
    {
        backgroundImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(stream!.id).jpg"))
        
        headerTitleLbl?.text=stream?.title
        videoTitleLbl?.text=stream?.title
        videoArtistNameLbl?.text=stream?.user.name
        
        SongManager.addToRecentlyPlayed(stream!.title, streamHash:stream!.streamHash, streamID:stream!.id, streamUserName:stream!.user.name, streamKey:stream!.videoID, streamUserID:stream!.user.id)
        
        songLikeStatus()
    }
    
    func songLikeStatus()
    {
        if SongManager.isAlreadyFavourited(stream!.id)
        {
            likeButton?.setImage(UIImage(named:"red_heart"), forState:.Normal)
        }
        else
        {
            likeButton?.setImage(UIImage(named:"empty_heart"), forState:.Normal)
        }
    }
    
    func createPlaylist()
    {
        for i in 0 ..< streamsArray!.count
        {
            let stream=streamsArray![i] as! Stream
            
            videoIDs.append(stream.videoID)
        }
    }
    
    func addPlayer()
    {
        seekBar?.value=0
        videoProgressDurationLbl?.text="0:00"
        videoDurationLbl?.text="-0:00"
        
        player=DWMoviePlayerController(userId:"D43560320694466A", key:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229")
        player?.controlStyle = .None
        player?.scalingMode = .AspectFit
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(moviePlayerDurationAvailable), name:MPMovieDurationAvailableNotification, object:player!)
        
        timer=NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:#selector(timerHandler), userInfo:nil, repeats:true)
    }
    
    func timerHandler()
    {
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration-player!.currentPlaybackTime))"
        videoProgressDurationLbl?.text=secondsToReadableTime(player!.currentPlaybackTime)
        seekBar?.value=Float(player!.currentPlaybackTime)
    }
    
    func moviePlayerDurationAvailable()
    {
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration))"
        seekBar?.maximumValue=Float(player!.duration)
        
        player!.view.hidden=false
    }
    
    @IBAction func shuffle()
    {
        selectedItemIndex=Int(arc4random_uniform(UInt32(streamsArray!.count)))
        
        carousel?.scrollToItemAtIndex(selectedItemIndex, animated:true)
    }
    
    @IBAction func previous()
    {
        selectedItemIndex=streamsArray!.indexOfObject(stream!)-1
        
        carousel?.scrollToItemAtIndex(selectedItemIndex, animated:true)
    }
    
    @IBAction func next()
    {
        selectedItemIndex=streamsArray!.indexOfObject(stream!)+1
        
        carousel?.scrollToItemAtIndex(selectedItemIndex, animated:true)
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
            
            if carousel!.currentItemView!.subviews.count==0
            {
                showPlayer()
            }
        }
    }
    
    func numberOfItemsInCarousel(carousel:iCarousel)->Int
    {
        return streamsArray!.count
    }
    
    func carouselItemWidth(carousel:iCarousel)->CGFloat
    {
        return view.frame.size.width-40
    }
    
    func carousel(carousel:iCarousel, viewForItemAtIndex index:Int, reusingView view:UIView?)->UIView
    {
        stream=streamsArray![index] as? Stream
        
        let thumbnailView=UIImageView(frame:CGRectMake(0, 0, self.view.frame.size.width-5, self.view.frame.size.width-140))
        thumbnailView.backgroundColor=UIColor.darkGrayColor()
        thumbnailView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(stream!.id).jpg"))
        
        return thumbnailView
    }
    
    func carouselCurrentItemIndexDidChange(carousel:iCarousel)
    {
        carousel.reloadData()
    }
    
    func carousel(carousel:iCarousel, didSelectItemAtIndex index:Int)
    {
        play()
    }
    
    func carouselDidEndScrollingAnimation(carousel:iCarousel)
    {
        if streamsArray!.count>1
        {
            selectedItemIndex=carousel.currentItemIndex
            stream=streamsArray![selectedItemIndex] as? Stream
            
            TBVC.updateMiniPlayerWithStream(stream!)
            updateButtons()
            updatePlayerWithStream()
        }
        
        if isPlaying&&carousel.currentItemView!.subviews.count==0
        {
            showPlayer()
        }
    }
    
    func carousel(carousel:iCarousel, valueForOption option:iCarouselOption, withDefault value:CGFloat)->CGFloat
    {
        switch(option)
        {
        case .Wrap:
            return 0
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
    
    func showPlayer()
    {
        UIView.animateWithDuration(0.5, animations:{
            self.carousel!.currentItemView!.frame=CGRectMake(-20, 0, self.view.frame.size.width, self.view.frame.size.width-140)
            }, completion:{(finished:Bool)->Void in
                self.addPlayerAtIndex()
        })
    }
    
    func addPlayerAtIndex()
    {
        timer?.invalidate()
        addPlayer()
        
        player!.view.frame=CGRectMake(0, 0, view.frame.size.width, view.frame.size.width-140)
        player!.view.hidden=true
        carousel!.currentItemView!.addSubview(player!.view)
        
        fullScreenButton=UIButton(frame:CGRectMake(view.frame.size.width-50, player!.view.frame.size.width-47, 50, 50))
        fullScreenButton.setImage(UIImage(named:"fullscreen"), forState:.Normal)
        fullScreenButton.addTarget(self, action:#selector(rotateScreen), forControlEvents:.TouchUpInside)
        view.insertSubview(fullScreenButton, aboveSubview:player!.view)
        
        if videoIDs[selectedItemIndex]==""
        {
            let label=UILabel(frame:CGRectMake(0, (view.frame.size.width-140)/2-10, view.frame.size.width, 20))
            label.text="Video not available"
            label.textColor=UIColor.whiteColor()
            label.textAlignment = .Center
            player!.view.addSubview(label)
            
            playButton?.enabled=false
            playButton?.setImage(UIImage(named:"big_play_button"), forState:.Normal)
            
            return
        }
        
        player?.videoId=videoIDs[selectedItemIndex]
        player?.startRequestPlayInfo()
        player?.play()
        playButton?.enabled=true
        playButton?.setImage(UIImage(named:"big_pause_button"), forState:.Normal)
    }
    
    func rotateScreen()
    {
        let value=UIInterfaceOrientation.LandscapeRight.rawValue
        UIDevice.currentDevice().setValue(value, forKey:"orientation")
    }
    
    func onDeviceOrientationChange()
    {
        let orientation=UIApplication.sharedApplication().statusBarOrientation
        
        if UIInterfaceOrientationIsLandscape(orientation)
        {
            showLandscape()
        }
        else
        {
            showPortrait()
        }
    }
    
    func showLandscape()
    {
        informationView?.hidden=true
        bottomSpaceConstraint!.constant=75
        player!.view.frame=CGRectMake(-(view.frame.size.width-view.frame.size.height)/2, -56, view.frame.size.width, view.frame.size.height)
        fullScreenButton.frame=CGRectMake(0, 0, 0, 0)
        player?.scalingMode = .Fill
        carousel?.scrollEnabled=false
        view.bringSubviewToFront(topView!)
        playlistButton?.hidden=true
        closeButton?.setImage(UIImage(named:"nonfullscreen"), forState:.Normal)
    }
    
    func showPortrait()
    {
        informationView?.hidden=false
        bottomSpaceConstraint!.constant=0
        player!.view.frame=CGRectMake(0, 0, view.frame.size.width, view.frame.size.width-140)
        fullScreenButton.frame=CGRectMake(view.frame.size.width-50, player!.view.frame.size.width-47, 50, 50)
        player?.scalingMode = .AspectFit
        playlistButton?.hidden=false
        closeButton?.setImage(UIImage(named:"arrow_down"), forState:.Normal)
        
        if streamsArray!.count>1
        {
            carousel?.scrollEnabled=true
        }
    }
    
    @IBAction func more()
    {
        let vc=storyBoard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
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
            SongManager.addToFavourite(stream!.title, streamHash:stream!.streamHash, streamID:stream!.id, streamUserName:stream!.user.name, vType:stream!.vType, streamKey:stream!.videoID, streamUserID:stream!.user.id)
        }
    }
    
    @IBAction func seekBarValueChanged()
    {
        player?.seekStartTime=player!.currentPlaybackTime
        player?.currentPlaybackTime=Double(seekBar!.value)
        
        videoProgressDurationLbl?.text=secondsToReadableTime(player!.currentPlaybackTime)
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration-player!.currentPlaybackTime))"
    }
    
    @IBAction func close()
    {
        let orientation=UIApplication.sharedApplication().statusBarOrientation
        
        if UIInterfaceOrientationIsLandscape(orientation)
        {
            let value=UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey:"orientation")
        }
        else
        {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
            dismissViewControllerAnimated(true, completion:nil)
        }
    }
    
    @IBAction func menu()
    {
        let vc=storyBoard.instantiateViewControllerWithIdentifier("PlaylistViewController") as! PlaylistViewController
        vc.transitioningDelegate=vc
        vc.nowPlayingStreamIndex=selectedItemIndex
        vc.streamsArray=streamsArray as! NSMutableArray
        presentViewController(vc, animated:true, completion:nil)
    }
    
    func secondsToReadableTime(durationSeconds:Double)->String
    {
        if durationSeconds.isNaN
        {
            return "0:00"
        }
        
        let durationSeconds=Int(durationSeconds)
        
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
    
    func updateButtons()
    {
        nextButton?.enabled=true
        previousButton?.enabled=true
        shuffleButton?.enabled=true
        
        if selectedItemIndex==0
        {
            previousButton?.enabled=false
        }
        
        if selectedItemIndex==streamsArray!.count-1
        {
            nextButton?.enabled=false
        }
        
        if streamsArray!.count==1
        {
            shuffleButton?.enabled=false
        }
    }
    
    func createTransitionImageView()->UIImageView
    {
        return UIImageView()
    }
}
