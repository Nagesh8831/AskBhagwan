//
//  MPRemoteCommand.swift
//  spotimusic
//
//  Created by Mac on 01/03/19.
//  Copyright © 2019 Appteve. All rights reserved.
//

import UIKit
import MediaPlayer

class MPRemoteCommand: NSObject {
    
//    let commandCenter = MPRemoteCommandCenter.shared()
//
//    commandCenter.playCommand.addTarget(handler: { (event)
//    in
//    self.play()
//    return MPRemoteCommandHandlerStatus.success})
    static let shared = MPRemoteCommand()
    
    func setupCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(self.playCommand(_:)))
        commandCenter.pauseCommand.addTarget(self, action: #selector(self.pauseCommand(_:)))
    }
    
    
    @objc func playCommand(_ action: MPRemoteCommandEvent) {
//        self.state = .play
//        self.playBtn.setBackgroundImage("some image"), for: .normal)
//        self.player.play()
//        self.fetchTracks()
        AudioPlayer.sharedAudioPlayer.resume()
    }
    @objc func pauseCommand(_ action: MPRemoteCommandEvent) {
//        self.state = .pause
//        self.playBtn.setBackgroundImage("some image"), for: .normal)
//        self.player.pause()
//        self.fetchTracks()
        AudioPlayer.sharedAudioPlayer.pause()
    }
}
