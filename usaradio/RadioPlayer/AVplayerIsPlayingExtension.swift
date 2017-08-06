//
//  AVplayerIsPlayingExtension.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/19/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
