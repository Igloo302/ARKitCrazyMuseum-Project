//
//  ViewController.swift
//  HelloARWorld
//
//  Created by Igloo on 2019/9/1.
//  Copyright © 2019年 SJTU. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        // 设置代理
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        // 显示ARKit的统计数据
        sceneView.showsStatistics = true
        // Create a new scene
        // 使用ship.scn素材创建一个新的场景scene（scn格式文件是一个基于3D建模的文件，这里系统有一个默认的3D飞机）
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // Set the scene to the view
        // 设置scene为SceneKit的当前场景
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        // 使用ARWorldTrackingSessionConfiguration来充分利用所有的运动信息，并给出最佳的结果。
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        // run(_:options)开启ARKit进程，并开始捕捉视频画面。该方法将会让设备请求使用相机，如果用户拒绝该请求，那么ARKit将无法工作。
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
