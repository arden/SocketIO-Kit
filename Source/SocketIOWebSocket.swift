//
//  SocketIOWebSocket.swift
//  Smartime
//
//  Created by Ricardo Pereira on 02/04/2015.
//  Copyright (c) 2015 Ricardo Pereira. All rights reserved.
//

import Foundation

class SocketIOWebSocket: SocketIOTransport, WebSocketDelegate {
    
    var socket: WebSocket!
        
    final override func connect(hostUrl: NSURL, withHandshake handshake: SocketIOHandshake) {
        // WebSocket
        if let scheme = hostUrl.scheme, let host = hostUrl.host, let port = hostUrl.port {
            // Establish connection
            if scheme.lowercaseString == "http" {
                // Standard
                socket = WebSocket(url: NSURL(scheme: "ws", host: "\(host):\(port)", path: "/socket.io/?transport=websocket&sid=\(handshake.sid)")!)
            }
            else {
                // TLS
                socket = WebSocket(url: NSURL(scheme: "wss", host: "\(host):\(port)", path: "/socket.io/?transport=websocket&sid=\(handshake.sid)")!)
            }
            
            socket.delegate = self
            socket.connect()
        }
    }
    
    final override func send(event: String, withString message: String) {
        
    }
    
    final override func send(event: String, withDictionary message: NSDictionary) {
        
    }
    
    
    // MARK: WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocket) {
        // Complete upgrade to WebSocket
        let confirmation = SocketIOPacket.encode(.Upgrade, key: .Event)
        socket.writeString(confirmation)
        
        // Server flushes and closes old transport and switches to new
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        println("Disconnet websocket: \(error)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        println("Received: \(data)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        #if DEBUG
            println("--- WebSocket")
            println("\(SocketIO.name): received message> \(text)")
        #endif
        
        let (valid, id, key, data) = SocketIOPacket.decode(text)
        
        if valid {
            switch (id, key) {
            case (PacketTypeID.Message, PacketTypeKey.Connect):
                #if DEBUG
                    println("--- packet decoded")
                    println("\(SocketIO.name): connected")
                #endif
            case (PacketTypeID.Message, PacketTypeKey.Event):
                // Event data
                if data.count == 2, let eventName = data[0] as? String {
                    
                    //String or NSDictionary
                    if let dict = data[1] as? NSDictionary {
                        delegate.didReceiveMessage(eventName, withDictionary: dict)
                    }
                    else if let value = data[1] as? String {
                        delegate.didReceiveMessage(eventName, withString: value)
                    }
                }
            default:
                #if DEBUG
                    println("--- packet decoded")
                    println("\(SocketIO.name): not supported")
                #endif
            }
        }
                
        //There's two distinct types of encodings
        // - packet
        // - payload
        
        // engine:ws received "42["chat message","hello men"]"
        // decoded 2["chat message","hello men"] as {"type":2,"nsp":"/","data":["chat message","hello men"]}
        
        // encoding packet {"type":2,"data":["chat message","hello men"],"nsp":"/"}
        // encoded {"type":2,"data":["chat message","hello men"],"nsp":"/"} as 2["chat message","hello men"]
    }
    
}
