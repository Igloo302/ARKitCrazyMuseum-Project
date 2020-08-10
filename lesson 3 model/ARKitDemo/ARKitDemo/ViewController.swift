//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Tryam on 2019/9/2.
//  Copyright © 2019年 Tryam. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    // Does this sentence mean that the oulet window is ARSCNView?
    @IBOutlet weak var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // addBox()
        // addSphere()
        // showImage()
        // playVideo()
        //addModel()
        //addDinosaur()
        addText()
        
        
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/Chirostenotes.scn")!
//        // Set the scene to the view
//        sceneView.scene = scene
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        
 
    }
    
    override  func  viewWillAppear(_  animated:  Bool)  {
        super.viewWillAppear(animated)
        let  configuration  =  ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        // 添加一些默认光照以便看清立方体的边缘
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    /*
     在AR中添加各类模型
     */
    
        func playVideo(x:Float = 0, y: Float = 0, z:Float = -0.2){
            // 从资源包中抓取文件名为road.mp4的视频
            guard let videoURL = Bundle.main.url(forResource: "road", withExtension: "mp4", subdirectory: "art.scnassets") else {return}
            // 为该视频创建和启动AVPlayer
            let avPlayerItem = AVPlayerItem(url: videoURL)
            let avPlayer = AVPlayer(playerItem: avPlayerItem)
            avPlayer.play()
            
            // AVPlayer实例不会自动重复。此通知块通过监听播放器来完成视频循环。然后它回到开头并重新开始。
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: nil,
                queue: nil) { notification in
                    avPlayer.seek(to: .zero)
                    avPlayer.play()
            }
            
            // SceneKit不使用UIViews，而是使用节点渲染场景。无法直接添加AVPlayer。相反，视频播放器可以用作节点的纹理或“材料”。这将视频帧映射到相关节点。
            let avMaterial = SCNMaterial()
            avMaterial.diffuse.contents = avPlayer
            
            // 创建SCNPlane，将材料修改为avPlayer
            let videoPlane = SCNPlane(width: 0.32, height: 0.18)
            videoPlane.materials = [avMaterial]
            
            // 创建将成为场景一部分的实际节点
            let videoNode = SCNNode(geometry: videoPlane)
            videoNode.position = SCNVector3(x,y,z)
            sceneView.scene.rootNode.addChildNode(videoNode)
        }
    
    
    func showImage(x:Float = 0, y: Float = 0, z:Float = -0.2){
        let material = SCNMaterial()
        // 将材质的漫反射贴图改为fish图片
        guard let img = UIImage(named: "fish") else {return}
        material.diffuse.contents = img
        
        material.lightingModel = .physicallyBased
        
        // 创建一个SCNPlane，并修改其材质
        let imgPlane = SCNPlane(width: 0.3, height: 0.2)
        imgPlane.materials = [material]
        
        let imgNode = SCNNode(geometry: imgPlane)
        imgNode.position = SCNVector3(x,y,z)
    
        sceneView.scene.rootNode.addChildNode(imgNode)
    }
    
    func addBox(x:Float = 0.2, y: Float = 0, z:Float = -0.2){
        // Define the boxNode
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x,y,z)
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    
    func addSphere(x:Float = -0.2, y: Float = 0, z:Float = -0.2){
        // Define the sphereNode
        let sphere = SCNSphere(radius: 0.05)
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        sphereNode.position = SCNVector3(x,y,z)
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    func addText(x:Float = 0, y: Float = 0, z:Float = -0.5) {
        let text = SCNText(string: "Hello AR World", extrusionDepth: 0)
        text.font = UIFont(name: "Optima", size: 1)

        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        let (min, max) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation(min.x + 0.5 * (max.x - min.x), min.y, min.z + 0.5 * (max.z - min.z))
        textNode.position = SCNVector3(x,y,z)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    

    func addDinosaur(x:Float = -0.2, y: Float = 0, z:Float = -0.2){
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
    
    func addModel(x:Float = 0, y: Float = 0, z:Float = -0.5){
        guard let url = Bundle.main.url(forResource: "model", withExtension: "dae", subdirectory: "art.scnassets") else {
            print("no file")
            return}
        if let modelNode = SCNReferenceNode(url: url) {
            modelNode.load()
            modelNode.position = SCNVector3(x,y,z)
            sceneView.scene.rootNode.addChildNode(modelNode)
        }else{
            print("fail")
        }
    }
    
    func addModelTwo(x:Float = -0.2, y: Float = 0, z:Float = -0.2){
        guard let modelScene = SCNScene(named: "art.scnassets/model.dae") else{
            print("no file")
        return}
        let modelNode = SCNNode()
        let modelSceneChildNodes = modelScene.rootNode.childNodes // 遍历modelScene的所有子节点，添加到modelNode中
        for childNode in modelSceneChildNodes {
            modelNode.addChildNode(childNode)
        }
        modelNode.position = SCNVector3(x,y,z)
        sceneView.scene.rootNode.addChildNode(modelNode)
    }
}



