//
//  GameScene.swift
//  BallThrowGame
//
//  Created by Chettiar Valliappan, Valliappan on 2/17/18.
//  Copyright © 2018 Ratan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var opponentWall:SKSpriteNode!
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var viewController=(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! GameViewController
    override func didMove(to view: SKView) {
        opponentWall=(scene?.childNode(withName: "opponentWall")) as! SKSpriteNode
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            for child in children{
                if(child.name=="origin" && abs(touch.location(in: child).x+touch.location(in: child).x)<700){
                    let newNode=SKShapeNode(rectOf: CGSize(width: 90, height: 90))
                    newNode.name="ownBrick"
                    self.addChild(newNode)
                    newNode.zRotation=15
                    newNode.physicsBody=SKPhysicsBody(rectangleOf: CGSize(width: 90, height: 90))
                    newNode.position=CGPoint(x: 540, y: -240)
                    newNode.physicsBody?.isDynamic=true
                    newNode.physicsBody?.affectedByGravity=false
                    newNode.physicsBody?.velocity.dx=viewController.brickLauncher.velocity(in: viewController.view).x
                    newNode.physicsBody?.velocity.dy=viewController.brickLauncher.velocity(in: viewController.view).y*(-2)
                    newNode.physicsBody?.affectedByGravity=true
                    let data=try! JSONSerialization.data(withJSONObject: ["\(Double((newNode.physicsBody?.velocity.dx)!))":"\(Double((newNode.physicsBody?.velocity.dy)!))"], options: JSONSerialization.WritingOptions.prettyPrinted)
                    try? viewController.session.send(data, toPeers: viewController.session.connectedPeers, with: .reliable)
                    //THERE IS PROBLEM WITH SYNCING MIGHT BE A DELAY PROBLEM
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
        self.addChild(node)
        node.zRotation=15
        node.physicsBody=SKPhysicsBody(rectangleOf: CGSize(width: 90, height: 90))
        node.position=CGPoint(x: 540, y: -240)
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
    
    override func update(_ currentTime: TimeInterval) {
        for i in (opponentWall.physicsBody?.allContactedBodies())!{
            if(i.node?.name=="ownBrick"){
                scene?.removeChildren(in: [i.node!])
            }
        }
    }
}
