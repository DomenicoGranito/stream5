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
    
    var isPlaying=false
    var player:AVPlayer?
    var stream:Stream?
    var streamsArray:NSArray?
    let (host, port, _, _, _)=Config.shared.wowza()
    
    override func viewDidLoad()
    {
        updatePlayerWithStream()
        
        if let _=streamsArray
        {
            shuffleButton?.enabled=true
            previousButton?.enabled=true
            nextButton?.enabled=true
            
            let indexOfObject=streamsArray!.indexOfObject(stream!)
            
            if indexOfObject==0
            {
                previousButton?.enabled=false
            }
            
            if indexOfObject==streamsArray!.count-1
            {
                nextButton?.enabled=false
            }
        }
    }
    
    override func viewWillAppear(animated:Bool)
    {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation:.Fade)
    }
    
    override func viewDidAppear(animated:Bool)
    {
        playButton?.setImage(UIImage(named:"big_play_button"), forState:.Normal)
        
        isPlaying=false
    }
    
    override func viewDidDisappear(animated:Bool)
    {
        player?.pause()
    }
    
    func updatePlayerWithStream()
    {
        backgroundImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(stream!.id).jpg"))
        
        let streamName="\(stream!.streamHash)-\(stream!.id)"
        
        headerTitleLbl?.text=stream?.title
        videoTitleLbl?.text=stream?.title
        videoArtistNameLbl?.text=stream?.user.name
        
        let url = stream!.streamHash == "e5446fb6e576e69132ae32f4d01d52a1"
            ? "http://\(host)/media/\(stream!.id).mp4"
            : "http://\(host):\(port)/vod/_definist_/mp4:\(streamName).mp4/playlist.m3u8"
        
        SongManager.addToRecentlyPlayed(stream!.title, streamHash:stream!.streamHash, streamID:stream!.id, streamUserName:stream!.user.name)
        
        createPlayerWithURL(url)
        
        if SongManager.isAlreadyFavourited(stream!.id)
        {
            likeButton?.setImage(UIImage(named:"red_heart"), forState:.Normal)
        }
        else
        {
            likeButton?.setImage(UIImage(named:"empty_heart"), forState:.Normal)
        }
    }
    
    func createPlayerWithURL(url:String)
    {
        player=AVPlayer(URL:NSURL(string:"http://45781641eecb6cd60749-f791b41f39d35aa8e6b060bff269f650.r20.cf6.rackcdn.com/4d641cac9ef69613935894ee13974a4a.mp4")!)
        
        let durationSeconds=Int(CMTimeGetSeconds(player!.currentItem!.asset.duration))
        videoDurationLbl?.text="-\(secondsToReadableTime(durationSeconds))"
        seekBar!.maximumValue=Float(durationSeconds)
        
        player!.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue:dispatch_get_main_queue())
        {_ in
            if self.player!.currentItem!.status == .ReadyToPlay
            {
                let time=Int(CMTimeGetSeconds(self.player!.currentTime()))
                self.videoProgressDurationLbl!.text=self.secondsToReadableTime(time)
                self.videoDurationLbl!.text="-\(self.secondsToReadableTime(durationSeconds-time))"
                self.seekBar!.value=Float(time)
            }
        }
    }
    
    func addPlayer()
    {
        //let playerController=AVPlayerViewController()
        //playerController.showsPlaybackControls=false
        //playerController.player=player
        //addChildViewController(playerController)
        //playerView!.addSubview(playerController.view)
        //playerController.view.frame=playerView!.frame
        //playerController.view.backgroundColor=UIColor.clearColor()
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
    
    @IBAction func seekBarValueChanged()
    {
        let seconds=Int64(seekBar!.value)
        let targetTime=CMTimeMake(seconds, 1)
        
        player!.seekToTime(targetTime)
    }
    
    @IBAction func close()
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func menu()
    {
        
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
    
    @IBAction func shuffle()
    {
        let random=Int(arc4random_uniform(UInt32(streamsArray!.count)))
        stream=streamsArray![random] as? Stream
        updatePlayerWithStream()
        changeCarouselItem(random)
    }
    
    @IBAction func previous()
    {
        let indexOfObject=streamsArray!.indexOfObject(stream!)
        stream=streamsArray![indexOfObject-1] as? Stream
        
        changePreviousStatus(indexOfObject)
        
        updatePlayerWithStream()
        changeCarouselItem(indexOfObject)
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
    
    @IBAction func next()
    {
        let indexOfObject=streamsArray!.indexOfObject(stream!)
        stream=streamsArray![indexOfObject+1] as? Stream
        
        changeNextStatus(indexOfObject)
        
        updatePlayerWithStream()
        changeCarouselItem(indexOfObject)
    }
    
    func changeNextStatus(index:Int)
    {
        nextButton?.enabled=true
        previousButton?.enabled=true
        
        if index==streamsArray!.count-1
        {
            nextButton?.enabled=false
        }
    }
    
    func changePreviousStatus(index:Int)
    {
        nextButton?.enabled=true
        previousButton?.enabled=true
        
        if index==0
        {
            previousButton?.enabled=false
        }
    }
    
    func changeCarouselItem(index:Int)
    {
        carousel?.scrollToItemAtIndex(index, animated:true)
    }
    
    @IBAction func more()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        vc.stream=stream
        presentViewController(vc, animated:true, completion:nil)
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
        
        let imageView=UIImageView(frame:CGRectMake(0, 0, self.view.frame.size.width-60, carousel.frame.size.height-60))
        imageView.backgroundColor=UIColor.darkGrayColor()
        imageView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(stream!.id).jpg"))
        
        return imageView
    }
    
    func carouselDidEndScrollingAnimation(aCarousel:iCarousel)
    {
        if let _=streamsArray
        {
            stream=streamsArray![aCarousel.currentItemIndex] as? Stream
            
            backgroundImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(stream!.id).jpg"))
        }
    }
}
