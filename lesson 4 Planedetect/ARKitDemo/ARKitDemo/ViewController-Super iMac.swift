//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Tryam on 2019/9/2.
//  Copyright © 2019年 Tryam. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // Does this sentence mean that the oulet window is ARSCNView?
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // addBox()
        // addSphere()
    }
    
    override  func  viewWillAppear(_  animated:  Bool)  {
        super.viewWillAppear(animated)
        let  configuration  =  ARWorldTrackingConfiguration()
        
        // 设置为检测水平面
        configuration.planeDetection = .horizontal

        sceneView.session.run(configuration)
        
        // 设置代理
        sceneView.delegate = self
        
        // 添加一些默认光照以便看清立方体的边缘
        sceneView.autoenablesDefaultLighting = true
        
        // 显示特征点和原点坐标
        #if DEBUG
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        #endif
    }
    
//    func addBox(x:Float = 0.2, y: Float = 0, z:Float = -0.2){
//        // Define the boxNode
//        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//        let boxNode = SCNNode()
//        boxNode.geometry = box
//        boxNode.position = SCNVector3(x,y,z)
//
//        sceneView.scene.rootNode.addChildNode(boxNode)
//    }
//
//    func addSphere(x:Float = -0.2, y: Float = 0, z:Float = -0.2){
//        // Define the sphereNode
//        let sphere = SCNSphere(radius: 0.05)
//        let sphereNode = SCNNode()
//        sphereNode.geometry = sphere
//        sphereNode.position = SCNVector3(x,y,z)
//        sceneView.scene.rootNode.addChildNode(sphereNode)
//    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 仅放置通过平面检测找到的anchors的内容。
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 创建一个SceneKit平面，以使用其位置和范围可视化平面anchors。
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
        
        // SCNPlane在其坐标空间中是垂直的，因此需要旋转平面以匹配ARPlaneAnchor的水平方向。
        planeNode.eulerAngles.x = -.pi / 2
        
        // 使平面可视化效果是半透明的，以清楚地显示实际位置。
        planeNode.opacity = 0.8
        
        // 将平面可视化添加到ARKit管理的节点，以便随着平面估计的继续进行跟踪平面anchors的变化。
        node.addChildNode(planeNode)
    }
        
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 仅更新平面锚和与在`renderer(_:didAdd:for:)`中创建的设置匹配的节点的内容。
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 平面估计可以使平面的中心相对于其锚点的变换移动。
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /*
         平面估计可以扩展平面的大小，或将先前检测到的平面合并为一个较大的平面。在后一种情况下，“ ARSCNView”会自动删除一个平面的相应节点，然后调用此方法来更新剩余平面的大小。
         */
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
}
