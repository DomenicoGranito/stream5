//
//  SongManager.swift
//  Music Player
//
//  Created by Samuel Chu on 2/19/16.
//  Copyright © 2016 Sem. All rights reserved.
//

import Foundation
import CoreData

public class SongManager{
    
    static var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    static var documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    //gets song associated with (identifier : String)
    class func getSong(identifier : String) -> NSManagedObject {
        //relevant song : selectedSong
        let songRequest = NSFetchRequest(entityName: "Song")
        songRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        let fetchedSongs : NSArray = try! context.executeFetchRequest(songRequest)
        return fetchedSongs[0] as! NSManagedObject
    }
    
    class func getRecentlyPlayed()->[NSManagedObject]
    {
        let recentlyPlayedRequest=NSFetchRequest(entityName:"RecentlyPlayed")
        return try! context.executeFetchRequest(recentlyPlayedRequest) as! [NSManagedObject]
    }
    
    //gets playlist associated with (playlistName : String)
    class func getPlaylist(playlistName : String) -> NSManagedObject {
        let playlistRequest = NSFetchRequest(entityName: "Playlist")
        playlistRequest.predicate = NSPredicate(format: "playlistName = %@", playlistName)
        let fetchedPlaylists : NSArray = try! context.executeFetchRequest(playlistRequest)
        return fetchedPlaylists[0] as! NSManagedObject
    }
    
    class func isPlaylist(playlistName: String) -> Bool {
        let playlistRequest = NSFetchRequest(entityName: "Playlist")
        playlistRequest.predicate = NSPredicate(format: "playlistName = %@", playlistName)
        let fetchedPlaylists : NSArray = try! context.executeFetchRequest(playlistRequest)
        if(fetchedPlaylists.count > 0) {
            return true
        }
        return false
    }
    
    class func isRecentlyPlayed(streamID:UInt)->Bool
    {
        let recentlyPlayedEntity=NSFetchRequest(entityName:"RecentlyPlayed")
        recentlyPlayedEntity.predicate=NSPredicate(format:"streamID=%d", streamID)
        let fetchedRecentlyPlayed=try! context.executeFetchRequest(recentlyPlayedEntity)
        
        if(fetchedRecentlyPlayed.count>0)
        {
            return true
        }
        
        return false
    }
    
    class func addToRecentlyPlayed(streamTitle:String, streamHash:String, streamID:UInt, streamUserName:String, streamKey:String)
    {
        if(!isRecentlyPlayed(streamID))
        {
            let newRecentlyPlayed=NSEntityDescription.insertNewObjectForEntityForName("RecentlyPlayed", inManagedObjectContext:context)
            newRecentlyPlayed.setValue(streamTitle, forKey:"streamTitle")
            newRecentlyPlayed.setValue(streamHash, forKey:"streamHash")
            newRecentlyPlayed.setValue(streamUserName, forKey:"streamUserName")
            newRecentlyPlayed.setValue(streamID, forKey:"streamID")
            newRecentlyPlayed.setValue(streamKey, forKey:"streamKey")
            save()
            
            if(getRecentlyPlayed().count>25)
            {
                let objectToBeDelete=getRecentlyPlayed().first
                
                deleteRecentlyPlayed(objectToBeDelete!)
            }
        }
    }
    
    class func deleteRecentlyPlayed(objectToBeDelete:NSManagedObject)
    {
        context.deleteObject(objectToBeDelete)
        save()
    }
    
    class func addToFavourite(streamTitle:String, streamHash:String, streamID:UInt, streamUserName:String, vType:Int, streamKey:String)
    {
        let newFavourite=NSEntityDescription.insertNewObjectForEntityForName("Favourites", inManagedObjectContext:context)
        newFavourite.setValue(streamTitle, forKey:"streamTitle")
        newFavourite.setValue(streamHash, forKey:"streamHash")
        newFavourite.setValue(streamUserName, forKey:"streamUserName")
        newFavourite.setValue(streamID, forKey:"streamID")
        newFavourite.setValue(streamKey, forKey:"streamKey")
        newFavourite.setValue(vType, forKey:"vType")
        save()
    }
    
    class func removeFromFavourite(streamID:UInt)
    {
        let favouriteEntity=NSFetchRequest(entityName:"Favourites")
        favouriteEntity.predicate=NSPredicate(format:"streamID=%d", streamID)
        let fetchedFavourites=try! context.executeFetchRequest(favouriteEntity)
        
        context.deleteObject(fetchedFavourites[0] as! NSManagedObject)
        save()
    }
    
    class func isAlreadyFavourited(streamID:UInt)->Bool
    {
        let favouriteEntity=NSFetchRequest(entityName:"Favourites")
        favouriteEntity.predicate=NSPredicate(format:"streamID=%d", streamID)
        let fetchedFavourites=try! context.executeFetchRequest(favouriteEntity)
        
        if(fetchedFavourites.count>0)
        {
            return true
        }
        
        return false
    }
    
    class func getFavourites(vType:Int)->[NSManagedObject]
    {
        let favouritesRequest=NSFetchRequest(entityName:"Favourites")
        favouritesRequest.predicate=NSPredicate(format:"vType=%d", vType)
        return try! context.executeFetchRequest(favouritesRequest) as! [NSManagedObject]
    }
    
    class func addToRelationships(identifier : String, playlistName : String){
        
        let selectedPlaylist = getPlaylist(playlistName)
        let selectedSong = getSong(identifier)
        
        //add song reference to songs relationship (in playlist entity)
        let playlist = selectedPlaylist.mutableSetValueForKey("songs")
        playlist.addObject(selectedSong)
        
        //add playlist reference to playlists relationship (in song entity)
        let inPlaylists = selectedSong.mutableSetValueForKey("playlists")
        inPlaylists.addObject(selectedPlaylist)
        
        save()
    }
    
    class func removeFromRelationships(identifier : String, playlistName : String){
        let selectedPlaylist = getPlaylist(playlistName)
        let selectedSong = getSong(identifier)
        
        //delete song reference in songs relationship (in playlist entity)
        let playlist = selectedPlaylist.mutableSetValueForKey("songs")
        playlist.removeObject(selectedSong)
        
        //remove from playlist reference in playlists relationship (in song entity)
        let inPlaylists = selectedSong.mutableSetValueForKey("playlists")
        inPlaylists.removeObject(selectedPlaylist)
        
        save()
    }
    
    class func addNewSong(vidInfo : VideoDownloadInfo) {
        
        let video = vidInfo.video
        let playlistName = vidInfo.playlistName
        
        //save to CoreData
        let newSong = NSEntityDescription.insertNewObjectForEntityForName("Song", inManagedObjectContext: context)
        
        newSong.setValue(video.identifier, forKey: "identifier")
        newSong.setValue(video.title, forKey: "title")
        
        var expireDate = video.expirationDate
        expireDate = expireDate!.dateByAddingTimeInterval(-60*60) //decrease expire time by 1 hour
        newSong.setValue(expireDate, forKey: "expireDate")
        newSong.setValue(true, forKey: "isDownloaded")
        
        let duration = video.duration
        let durationStr = MiscFuncs.stringFromTimeInterval(duration)
        newSong.setValue(duration, forKey: "duration")
        newSong.setValue(durationStr, forKey: "durationStr")
        
        var streamURLs = video.streamURLs
        //  let desiredURL = (streamURLs![22] != nil ? streamURLs[22] : (streamURLs[18] != nil ? streamURLs[18] : streamURLs[36]))! as NSURL
        //  newSong.setValue("\(desiredURL)", forKey: "streamURL")
        
        let large = video.largeThumbnailURL
        let medium = video.mediumThumbnailURL
        let small = video.smallThumbnailURL
        let imgData = NSData(contentsOfURL: (large != nil ? large : (medium != nil ? medium : small))!)
        newSong.setValue(imgData, forKey: "thumbnail")
        
        addToRelationships(video.identifier, playlistName: playlistName)
        save()
    }
    
    //deletes song only if not in other playlists
    class func deleteSong(identifier : String, playlistName : String){
        
        removeFromRelationships(identifier, playlistName: playlistName)
        
        let selectedSong = getSong(identifier)
        let inPlaylists = selectedSong.mutableSetValueForKey("playlists")
        
        if (inPlaylists.count < 1){
            
            //allows for redownload of deleted song
            let dict = ["identifier" : identifier]
            NSNotificationCenter.defaultCenter().postNotificationName("resetDownloadTasksID", object: nil, userInfo: dict as [NSObject : AnyObject])
            
            let fileManager = NSFileManager.defaultManager()
            
            let isDownloaded = selectedSong.valueForKey("isDownloaded") as! Bool
            
            //remove item in both documents directory and persistentData
            if isDownloaded {
                let filePath0 = MiscFuncs.grabFilePath("\(identifier).mp4")
                let filePath1 = MiscFuncs.grabFilePath("\(identifier).m4a")
                
                do {
                    try fileManager.removeItemAtPath(filePath0)
                } catch _ {
                }
                
                do {
                    try fileManager.removeItemAtPath(filePath1)
                } catch _ {
                }
            }
            context.deleteObject(selectedSong)
        }
        save()
    }
    
    class func save()
    {
        do
        {
            try context.save()
        }
        catch _
        {
            
        }
    }
}
