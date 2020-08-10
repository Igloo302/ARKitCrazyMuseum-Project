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
    
    // Does this sentence mean that the oulet window is ARSCNView?
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // addBox()
        // addSphere()
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 仅放置通过平面检测找到的anchors的内容
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 创建一个SceneKit平面，以使用其位置和范围可视化平面anchor
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        // 修改材质
        let material = SCNMaterial()
        let img = UIImage(named: "grass")
        material.diffuse.contents = img
        material.lightingModel = .physicallyBased
        plane.materials = [material]
        
        // 创建平面node
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
