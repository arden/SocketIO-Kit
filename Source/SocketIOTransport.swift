//
//  SocketIOTransport.swift
//  Smartime
//
//  Created by Ricardo Pereira on 02/04/2015.
//  Copyright (c) 2015 Ricardo Pereira. All rights reserved.
//

import Foundation

protocol SocketIOTransport {
    
    func connect(hostUrl: NSURL, withHandshake handshake: SocketIOHandshake)
    
}
