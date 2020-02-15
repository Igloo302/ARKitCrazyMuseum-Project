//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Tryam on 2019/9/2.
//  Copyright © 2019年 Tryam. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // addBox()
        setupRecognizers()
     
    }
    
    override  func  viewWillAppear(_  animated:  Bool)  {
        super.viewWillAppear(animated)
        let  configuration  =  ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal, .vertical]

        sceneView.session.run(configuration)
        
        // 设置代理
        sceneView.delegate = self
        
        // 添加一些默认光照以便看清立方体的边缘
        sceneView.autoenablesDefaultLighting = true
        
        #if DEBUG
        // sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }


    // add form exsitingPlaneUsingExtent
    @objc func didTap(recognizer:UITapGestureRecognizer){
        let tapPoint = recognizer.location(in: sceneView)
        let result = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        if  let hitResult = result.first {
            let translation  =  hitResult.worldTransform.translation
            addDinosaur(x:  translation.x,  y:  translation.y,  z:  translation.z)
        }
    }
    
    
    // add form featurePoint
//    @objc func  didTap(recognizer:UITapGestureRecognizer)  {
//        let tapPoint = recognizer.location(in: sceneView)
//        let result = sceneView.hitTest(tapPoint)
//        // 判断是否点击到了点击过的位置，是的话删除
//        if let node  =  result.first?.node{
//            node.removeFromParentNode()
//        }  else  {
//            let result = sceneView.hitTest(tapPoint, types: .featurePoint)
//            if  let  hitResult =  result.first {
//                let  translation  =  hitResult.worldTransform.translation
//                addDinosaur(x:  translation.x,  y:  translation.y,  z:  translation.z)
//                }
//        }
//        return
//    }
    
    func setupRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(recognizer:) ))
        tapGestureRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }


    func addDinosaur(x:Float = -0.2, y: Float = 0, z:Float = -0.2){
        // Load the Dinosaur Model
        guard let url = Bundle.main.url(forResource: "Chirostenotes", withExtension: "scn", subdirectory: "art.scnassets") else {
            print("no file")
            return}
        if let dinosaurNode = SCNReferenceNode(url: url) {
            dinosaurNode.load()
            dinosaurNode.position = SCNVector3(x,y,z)
            dinosaurNode.eulerAngles.y = Float(arc4random() % 200) / 100.0 * .pi
            sceneView.scene.rootNode.addChildNode(dinosaurNode)
        }else{
            print("scn fail")
        }
    }

    func addBox(x:Float = 0.2, y: Float = 0, z:Float = -0.2){
        // Define the boxNode
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x,y,z)
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

        // 修改平面材质
        let material = SCNMaterial()
        let img = UIImage(named: "grass")
        material.diffuse.contents = img
        material.lightingModel = .physicallyBased
        plane.materials = [material]

        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

        /*
         `SCNPlane` is vertically oriented in its local coordinate space, so
         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
         */
        planeNode.eulerAngles.x = -.pi / 2

        // Make the plane visualization semitransparent to clearly show real-world placement.
        planeNode.opacity = 0.8

        /*
         Add the plane visualization to the ARKit-managed node so that it tracks
         changes in the plane anchor as plane estimation continues.
         */
        node.addChildNode(planeNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }

        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

        /*
         Plane estimation may extend the size of the plane, or combine previously detected
         planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
         corresponding node for one plane, then calls this method to update the size of
         the remaining plane.
         */
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
}
extension  float4x4  {
    var  translation: float3  {
        let  translation  =  self.columns.3
        return  float3(translation.x,  translation.y,  translation.z)
    }
}

