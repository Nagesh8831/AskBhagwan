

import UIKit

enum PlaylistMode: UInt {
    case repeatNone
    case repeatOne
    case repeatAll
    case shuffle
}

class Playlist: NSObject {
    var mode: PlaylistMode = .repeatAll
    var allTracks = [Audio]()

    var unplayedTracks = [Audio]()
    var playedTracks = [Audio]()
    
    var lastRequestedTrack: Audio?

    var newIndex = Int ()
    init(audios: [Audio]) {
        self.allTracks = audios
        self.unplayedTracks = audios
        
        super.init()
    }
    
    func count() -> Int {
        return self.allTracks.count
    }
    
    func indexOfTrack(_ audio: Audio?) -> Int {
        if let audio = audio {
            if let idx = self.allTracks.index(of: audio) {
                return idx
            }
        }
        return 0
    }
    
    func trackAtIndex(_ idx :Int) -> Audio? {
        self.lastRequestedTrack = self.allTracks[idx]
        return self.lastRequestedTrack
    }
    
    func previousTrack() -> Audio? {
        var track: Audio?

        switch self.mode {
        case .repeatNone:
            let idx = self.indexOfTrack(self.lastRequestedTrack) - 1
            if (idx < 0) {
                track = nil
            }
            track = self.allTracks[idx]
            
        case .repeatOne:
            track = self.lastRequestedTrack

        case .repeatAll:
            var idx = self.indexOfTrack(self.lastRequestedTrack) - 1
            if (idx < 0) {
                idx = self.allTracks.count - 1
            }
            track = self.allTracks[idx]
        case .shuffle:
            
            let allIdx = self.allTracks.count
            let x = UInt32(allIdx)
            
            let randomIdx = self.indexOfTrack(self.lastRequestedTrack) - 1 
            if randomIdx != -1 {
            //let randomIdx = Int(arc4random_uniform(x)+0)
            print("Track random: ",randomIdx)
//            if randomIdx == self.indexOfTrack(self.lastRequestedTrack){
//                AudioPlayer.sharedAudioPlayer.pause()
//            }
            track = self.allTracks[randomIdx]
            }else {
                //self.removeFromSuperview()
               // Utilities.displayToastMessage("No more songs in Queue")
            }
            
                    }
        
        self.lastRequestedTrack = track
        return track
    }
    
    func nextTrack() -> Audio? {
        var track: Audio?
        
        switch self.mode {
        case .repeatNone:
            let idx = self.indexOfTrack(self.lastRequestedTrack) + 1
            if (idx == self.allTracks.count) {
                track = nil
            }
            track = self.allTracks[idx]
            
        case .repeatOne:
            track = self.lastRequestedTrack

        case .repeatAll:
            var idx = self.indexOfTrack(self.lastRequestedTrack) + 1
            if (idx == self.allTracks.count) {
                idx = 0
            }
            track = self.allTracks[idx]
            
        case .shuffle:
            
            let allIdx = self.allTracks.count
            let x = UInt32(allIdx)
            if self.indexOfTrack(self.lastRequestedTrack) < self.allTracks.count - 1 {
            let randomIdx = self.indexOfTrack(self.lastRequestedTrack) + 1
            
            //let randomIdx = Int(arc4random_uniform(x)+0)
            print("Track random: ",randomIdx)
            track = self.allTracks[randomIdx]
                
            }else {
                //AudioPlayer.sharedAudioPlayer.pause()
            }
//            if (randomIdx) == self.indexOfTrack(self.lastRequestedTrack){
//                AudioPlayer.sharedAudioPlayer.pause()
//            }
            
            
        }
    
        self.lastRequestedTrack = track
        return track
    }

}
