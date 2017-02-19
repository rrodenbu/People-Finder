//
//  PeepServiceManager.swift
//  peep
//
//  Created by Riley Rodenburg on 2/17/17.
//  Copyright © 2017 buddhabuddha. All rights reserved.
//

import Foundation
import MultipeerConnectivity


// Blueprint of methods, properties, and other requirements when there is a change in service events.
protocol PeepServiceManagerDelegate {
    
    // Functions that execute when someone connected takes an action.
    func connectedDevicesChanged(manager : PeepServiceManager, connectedDevices: [String])
    func colorChanged(manager : PeepServiceManager, colorString: String)
    
}

class PeepServiceManager: NSObject {
    
    
    //Constant to identify the service uniquely.
    private let PeepServiceType = "peep-123"
    
    // MCPeerID - The displayName visible to other devices.
    private let myPeerId = MCPeerID(displayName: "Riley Rodenburg")
    
    // Advertises availability of the local peer, and handles invitations from nearby peers.
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    
    // Searches (by service type) for services offered by nearby devices
    private let serviceBrowser : MCNearbyServiceBrowser
    
    var delegate : PeepServiceManagerDelegate? // From protocol above
    
    // session: enables and manages communication among all peers in a Multipeer Connectivity session
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {

        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: PeepServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: PeepServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer() // Begin advertising!
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers() // Begin looking for others!
        
    }
    
    // Sends Data to all connected peers.
    // Called from ViewController
    func send(colorName : String) {
        NSLog("%@", "sendColor: \(colorName) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    
    deinit {
        
        self.serviceAdvertiser.stopAdvertisingPeer() // Stop advertising object destroyed
        self.serviceBrowser.stopBrowsingForPeers() // Stop searching object destroyed
        
    }
    
}


// Advertising
extension PeepServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        // Recieved invitation from peer, accept it.
        // NOTE: Accepts any invitation (could be privacy issue)
        invitationHandler(true, self.session)
    }
    
}

// Scanning
extension PeepServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        
        // NOTE: Invites anyone found on same service.
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

// Session (Once connection has been established)
// Handles communication between peers.
extension PeepServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        
        // Peer joined or left.
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.colorChanged(manager: self, colorString: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}
