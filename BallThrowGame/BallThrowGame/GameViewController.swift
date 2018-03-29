//
//  GameViewController.swift
//  BallThrowGame
//
//  Created by Chettiar Valliappan, Valliappan on 2/17/18.
//  Copyright © 2018 Ratan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity

class GameViewController: UIViewController,MCBrowserViewControllerDelegate,MCSessionDelegate{
    var sceneCopy:SKScene!
    var isConnected=false
    var playerTwoPeerID:MCPeerID = MCPeerID(displayName: "Hello")
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browser.dismiss(animated: true, completion: nil)
    }
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        playerTwoPeerID=peerID
    }
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browser.dismiss(animated: true, completion: nil)
    }
    
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState){
        //connected
        if state == MCSessionState.connected {
            isConnected=true
        }
        if state == MCSessionState.notConnected{
            if isConnected{//if it was connected
                let alert = UIAlertController(title: "The connection was lost", message: "OOPS", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Reconnect", style: UIAlertActionStyle.default, handler: { (action) in
                    self.startOrEndSession(advertise: true)//new session
                    self.connect()
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
            isConnected=false
        }
    }
    
    // Received data from remote peer.
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        var velocityArray:[String:String]=try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:String]
        (sceneCopy as! GameScene).createABox(x:(velocityArray.first?.key)!, y:(velocityArray.first?.value)!)
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        
    }
    
    
    // Start receiving a resource from remote peer.
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
        
    }
    
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?){
        
    }
    
    
    @IBOutlet var forceFielPlacer: UILongPressGestureRecognizer!
    @IBOutlet var brickLauncher: UIPanGestureRecognizer!
    // mpc stuff
    var playerOnePeerID:MCPeerID!
    var session:MCSession!
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant!
    func startOrEndSession(advertise:Bool){
        playerOnePeerID=MCPeerID(displayName: UIDevice.current.name)
        session=MCSession(peer: playerOnePeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        session.delegate = self
        browser=MCBrowserViewController(serviceType: "HelloDubaiah", session: session)
        if advertise{
            advertiser=MCAdvertiserAssistant(serviceType: "HelloDubaiah", discoveryInfo: nil, session: session)
            advertiser.start()
        }
        else{
            advertiser.stop()
            advertiser=nil
        }
    }
    @IBAction func connect(){
        if session != nil{
            browser.delegate=self
            self.present(browser, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                sceneCopy=scene
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
        startOrEndSession(advertise: true)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
