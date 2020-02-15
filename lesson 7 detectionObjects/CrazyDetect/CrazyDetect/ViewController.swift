//
//  ViewController.swift
//  CrazyDetect
//
//  Created by Igloo on 2019/9/3.
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
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 设置参考图像
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // 设置识别项
        configuration.detectionImages = referenceImages
        
        
        // 设置参考对象
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "AR Objects", bundle: nil) else{
            fatalError("Missing expected asset catalog resources.")
        }
        
        configuration.detectionObjects = referenceObjects
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 获取锚点对应的图片
        // guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        if let imageAnchor = anchor as? ARImageAnchor {
            crazyImage(imageAnchor, node)
        }else if let objectAnchor = anchor as? ARObjectAnchor {
            crazyObject(objectAnchor, node)
        }
    }
    
    // 识别到对象后操作
    func crazyObject(_ objectAnchor:ARObjectAnchor,_ node:SCNNode ) {
        let referenceObject = objectAnchor.referenceObject
        // 输出检测到的对象的名字
        let name = referenceObject.name!
        print("you found a \(name) object")
        
        // 获取识别到的对象的实际大小
        let size = referenceObject.extent
        
        // 创建文字Node
        if let textNode = makeTextNode(size: CGSize(width: CGFloat(size.x), height: CGFloat(size.y)), name: name){
            // 让文字朝向摄像头
            let billboardConstraints = SCNBillboardConstraint()
            textNode.constraints = [billboardConstraints]
            
            textNode.position.y = textNode.position.y + Float(size.y)
            
            node.addChildNode(textNode)
            node.opacity = 1
        }
        
        // 播放声音
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(fileNamed: "growls.wav")!))

    }
    
    // 识别到图片后操作
    func crazyImage(_ imageAnchor:ARImageAnchor,_ node:SCNNode ) {
        let referenceImage = imageAnchor.referenceImage
        
        // 输出检测到的图片的名字
        let name = referenceImage.name!
        print("you found a \(name) image")
        
        // 获取识别到的图片的实际大小
        let size = referenceImage.physicalSize
        
        // 创建视频Node
        if let videoNode = makeVideoNode(size:size,name: name){
            node.addChildNode(videoNode)
            node.opacity = 1
        }
        
        // 创建图片Node
        if let imgNode = makeImageNode(size: size,name: name){
            node.addChildNode(imgNode)
            node.opacity = 1
        }
        
        // 创建文字Node
        if let textNode = makeTextNode(size: size,name: name){
            textNode.runAction(self.imageHighlightAction)
            
            // 绕x轴旋转90度
            textNode.eulerAngles.x = -.pi / 2
            
            // 移动位置
            // textNode.position.y = textNode.position.y + Float(size.height)
            
            node.addChildNode(textNode)
            node.opacity = 1
        }
    }
    
    // 高亮动画
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 3),
            .removeFromParentNode()
            ])
    }
    
    func makePlaneNode(size:CGSize) -> SCNNode? {
        // 创建一个平面来显示检测到的图片(与图片相同大小)
        let plane = SCNPlane(width: size.width, height: size.height)
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.25
        
        // `SCNPlane`在它的本地坐标系是竖直的, 但`ARImageAnchor`会假设图片在自身本地坐标系中是水平的,所以要旋转平面.
        planeNode.eulerAngles.x = -.pi / 2
        
        return planeNode
    }
    
    
    func makeTextNode(size:CGSize,name: String) -> SCNNode?{
        let text = SCNText(string: name, extrusionDepth: 0)
        text.font = UIFont(name: "Optima", size: 1)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(size.width/5)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        let (min, max) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation(min.x + 0.5 * (max.x - min.x), min.y, min.z + 0.5 * (max.z - min.z))
        
        return textNode
    }

    
    func makeImageNode(size:CGSize,name: String = "noPhoto")-> SCNNode?{
        // 根据识别到的图片名从资源包中抓取对应的图片
        guard let img = UIImage(named: name + "_AR") else {return nil}
        let material = SCNMaterial()
        material.diffuse.contents = img
        material.lightingModel = .physicallyBased
        
        let imgPlane = SCNPlane(width: size.width, height: size.height)
        imgPlane.materials = [material]
        
        // 创建将成为场景一部分的实际节点
        let imgNode = SCNNode(geometry: imgPlane)
        
        // 绕x轴旋转90度
        imgNode.eulerAngles.x = -.pi / 2
        
        // 移动位置
        imgNode.position.x = imgNode.position.x - Float(size.width)
        
        return imgNode
        }

    // 生成包含视频的Node
    func makeVideoNode(size:CGSize,name: String = "noVideo") -> SCNNode?{
        // 根据识别到的图片名从资源包中抓取对应的视频
        guard let videoURL = Bundle.main.url(forResource: name, withExtension: "mov") else {return nil}
        
        // 为该视频创建和启动AVPlayer
        let avPlayerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        avPlayer.play()
        
        // AVPlayer实例不会自动重复。此通知块通过监听播放器来完成视频循环。然后它回到开头并重新开始。
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) {
            notification in avPlayer.seek(to: .zero)
            avPlayer.play()
        }
        
        // SceneKit不使用UIViews，而是使用节点渲染场景。无法直接添加AVPlayer。相反，视频播放器可以用作节点的纹理或“材料”。这将视频帧映射到相关节点。
        let avMaterial = SCNMaterial()
        avMaterial.diffuse.contents = avPlayer
        
        // 创建SCNPlane，将材料修改为avPlayer
        let videoPlane = SCNPlane(width: size.width, height: size.height)
        videoPlane.materials = [avMaterial]
        
        // 创建将成为场景一部分的实际节点
        let videoNode = SCNNode(geometry: videoPlane)
        
        // 绕x轴旋转90度
        videoNode.eulerAngles.x = -.pi / 2
        
        // 移动位置
        videoNode.position.x = videoNode.position.x + Float(size.width)
        
        return videoNode
    }
    
    
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
