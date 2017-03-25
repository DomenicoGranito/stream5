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
    var player:DWMoviePlayerController?
    var stream:Stream?
    var streamsArray:NSArray?
    let (host, port, _, _, _)=Config.shared.wowza()
    var videoIDs:[String]=[]
    var timer:NSTimer?
    
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
        else
        {
            carousel?.scrollEnabled=false
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
                
                videoIDs.append(stream.videoID)
            }
        }
        else
        {
            videoIDs.append(stream!.videoID)
        }
    }
    
    func addPlayer()
    {
        seekBar?.value=0
        videoProgressDurationLbl?.text="0:00"
        videoDurationLbl?.text="-0:00"
        
        player=DWMoviePlayerController(userId:"D43560320694466A", key:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229")
        player?.controlStyle = .None
        
        addObserverForMPMoviePlayController()
        addTimer()
    }
    
    func addTimer()
    {
        timer=NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:#selector(timerHandler), userInfo:nil, repeats:true)
    }
    
    func timerHandler()
    {
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration-player!.currentPlaybackTime))"
        videoProgressDurationLbl?.text=secondsToReadableTime(player!.currentPlaybackTime)
        seekBar?.value=Float(player!.currentPlaybackTime)
    }
    
    func addObserverForMPMoviePlayController()
    {
        let notificationCenter=NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector:#selector(moviePlayerDurationAvailable), name:MPMovieDurationAvailableNotification, object:player!)
    }
    
    func moviePlayerDurationAvailable()
    {
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration))"
        seekBar?.maximumValue=Float(player!.duration)
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

        let thumbnailView=UIImageView(frame:CGRectMake(0, 0, self.view.frame.size.width-50, self.view.frame.size.width-50))
        thumbnailView.backgroundColor=UIColor.darkGrayColor()
        thumbnailView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(stream!.id).jpg"))
        
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
        
        UIView.animateWithDuration(0.5, animations:{
            aCarousel.currentItemView!.frame=CGRectMake(-20, 0, self.view.frame.size.width, self.view.frame.size.width-50)
            }, completion:{(finished:Bool)->Void in
                self.addPlayerAtIndex(aCarousel.currentItemIndex)
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
    
    func addPlayerAtIndex(index:Int)
    {
        timer?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        addPlayer()
        
        player!.view.frame=CGRectMake(0, 0, view.frame.size.width, view.frame.size.width-50)
        carousel!.currentItemView!.addSubview(player!.view)
        
        if videoIDs[index]==""
        {
            let label=UILabel(frame:CGRectMake(0, (view.frame.size.width-50)/2-10, view.frame.size.width, 20))
            label.text="Video not available"
            label.textColor=UIColor.whiteColor()
            label.textAlignment = .Center
            player!.view.addSubview(label)
            
            playButton?.enabled=false
            playButton?.setImage(UIImage(named:"big_play_button"), forState:.Normal)
            
            return
        }
        
        player?.videoId=videoIDs[index]
        player?.startRequestPlayInfo()
        player?.play()
        playButton?.setImage(UIImage(named:"big_pause_button"), forState:.Normal)
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
        player?.seekStartTime=player!.currentPlaybackTime
        player?.currentPlaybackTime=Double(seekBar!.value)
        
        videoProgressDurationLbl?.text=secondsToReadableTime(player!.currentPlaybackTime)
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration-player!.currentPlaybackTime))"
    }
    
    @IBAction func close()
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func menu()
    {
        
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
