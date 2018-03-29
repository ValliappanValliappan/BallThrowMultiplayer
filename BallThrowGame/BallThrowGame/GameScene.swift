//
//  GameScene.swift
//  BallThrowGame
//
//  Created by Valliappan, Valliappan on 2/17/18.
//  Copyright © 2018 Ratan. All rights reserved.
//

import SpriteKit
import GameplayKit
import MultipeerConnectivity
class GameScene: SKScene {
    var p2Wall:SKSpriteNode!
    var p1Wall:SKSpriteNode!
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var playerOne=""
    var playerTwo=""
    var playerWallDictionary:[String:String]=["":""]
    var viewController=(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! GameViewController
    override func didMove(to view: SKView) {
        p2Wall=(scene?.childNode(withName: "opponentWall")) as! SKSpriteNode
        p1Wall=(scene?.childNode(withName: "origin")) as! SKSpriteNode
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    func throwPosition(wallName:String)->CGPoint{
        if wallName=="opponentWall"{
            return CGPoint(x:-618, y:0)
        }
        return CGPoint(x:540, y:0)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            for child in children{
                if(child.name==playerWallDictionary[UIDevice.current.name] && abs(touch.location(in: child).x+touch.location(in: child).x)<700){
                    let newNode=SKShapeNode(rectOf: CGSize(width: 90, height: 90))
                    newNode.name=UIDevice.current.name
                    self.addChild(newNode)
                    newNode.zRotation=15
                    newNode.physicsBody=SKPhysicsBody(rectangleOf: CGSize(width: 90, height: 90))
                    newNode.position=throwPosition(wallName: playerWallDictionary[UIDevice.current.name]!)
                    newNode.physicsBody?.isDynamic=true
                    newNode.physicsBody?.affectedByGravity=false
                    newNode.physicsBody?.velocity.dx=viewController.brickLauncher.velocity(in: viewController.view).x
                    newNode.physicsBody?.velocity.dy=viewController.brickLauncher.velocity(in: viewController.view).y*(-2)
                    newNode.physicsBody?.affectedByGravity=true
                    let data=try! JSONSerialization.data(withJSONObject: ["\(Double((newNode.physicsBody?.velocity.dx)!))":"\(Double((newNode.physicsBody?.velocity.dy)!))"], options: JSONSerialization.WritingOptions.prettyPrinted)
                    try? viewController.session.send(data, toPeers: viewController.session.connectedPeers, with: .reliable)
                    //THERE IS PROBLEM WITH SYNCING. MIGHT BE A DELAY PROBLEM
                    break
                }
            }
        }
    }
    
    func createABox(x:String,y:String){
        var velocity:CGVector!
        if let dx=Double(x) {
            if let dy=Double(y){
                velocity=CGVector(dx: dx, dy: dy)
            }
        }
        let node=SKShapeNode(rectOf: CGSize(width: 90, height: 90))
        if UIDevice.current.name == playerOne{
            node.name = playerTwo
        }
        else{
            node.name = playerOne
        }
        self.addChild(node)
        node.zRotation=15
        node.physicsBody=SKPhysicsBody(rectangleOf: CGSize(width: 90, height: 90))
        node.position=throwPosition(wallName: playerWallDictionary[node.name!]!)
        node.physicsBody?.isDynamic=true
        node.physicsBody?.affectedByGravity=false
        node.physicsBody?.velocity.dx=velocity.dx
        node.physicsBody?.velocity.dy=velocity.dy
        node.physicsBody?.affectedByGravity=true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func initPlayers(p1 : MCPeerID, p2 : MCPeerID){
        playerOne = p1.displayName
        playerTwo = p2.displayName
        playerWallDictionary=[playerOne:"origin",playerTwo:"opponentWall"]
        print(playerWallDictionary)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for i in (p2Wall.physicsBody?.allContactedBodies())!{
            if(i.node?.name == playerOne){
                scene?.removeChildren(in: [i.node!])
                //Deduct points for player2
            }
        }
        for i in (p1Wall.physicsBody?.allContactedBodies())!{
            if(i.node?.name == playerTwo){
                scene?.removeChildren(in: [i.node!])
                //Deduct points for player1
            }
        }
    }
}
