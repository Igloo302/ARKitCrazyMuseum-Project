//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Igloo on 2019/9/2.
//  Copyright © 2019年 Igloo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - IBOutlets


    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet var mappingStatusLabel: UILabel!
    @IBOutlet var sendMapButton: UIButton!
    
    var multipeerSession: MultipeerSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognizers()
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
     
    }
    
    override  func  viewWillAppear(_  animated:  Bool)  {
        super.viewWillAppear(animated)
        // 设定配置
        let  configuration  =  ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        // 设置代理
        sceneView.session.delegate = self
        
        // 添加默认光照
        sceneView.autoenablesDefaultLighting = true
        
        // 显示特征点
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // 设备不熄屏
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let name = anchor.name, name.hasPrefix("dinosaur") {
            node.addChildNode(loadDinosaurModel())
        }
    }
    
    // MARK: - ARSessionDelegate
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            sendMapButton.isHidden = true
        case .extending:
            sendMapButton.isHidden = multipeerSession.connectedPeers.isEmpty
        case .mapped:
            sendMapButton.isHidden = multipeerSession.connectedPeers.isEmpty
        }
        mappingStatusLabel.text =  frame.worldMappingStatus.description
    }
    
    // MARK: - Multiuser shared session
    
    /// - Tag: PlaceDinosaur
    func setupRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(recognizer:) ))
        tapGestureRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTap(recognizer:UITapGestureRecognizer)  {
        let tapPoint = recognizer.location(in: sceneView)
        let result = sceneView.hitTest(tapPoint, types: .featurePoint)
        if  let  hitResult =  result.first {
            // 放置一个ARanchor
            let anchor = ARAnchor(name: "dinosaur", transform: hitResult.worldTransform)
            sceneView.session.add(anchor: anchor)
            
            // 发送anchor信息给同伴
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
                else { fatalError("can't encode anchor") }
            self.multipeerSession.sendToAllPeers(data)
            }
            return
        }
    
    /// - Tag: GetWorldMap
    @IBAction func shareSession(_ sender: UIButton) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            self.multipeerSession.sendToAllPeers(data)
        }
    }
        
    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        
        do {
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                // 加载收到的世界地图并重新启动AR会话
                let configuration = ARWorldTrackingConfiguration()
                configuration.initialWorldMap = worldMap
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            }
            else
            if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
                // 将anchor添加到会话中
                sceneView.session.add(anchor: anchor)
            }
            else {
                print("unknown data recieved from \(peer)")
            }
        } catch {
            print("can't decode data recieved from \(peer)")
        }
    }
    
    // MARK: - AR session management
    func loadDinosaurModel()  -> SCNNode {
        // 载入小恐龙模型
        let url = Bundle.main.url(forResource: "Chirostenotes", withExtension: "scn", subdirectory: "art.scnassets")!
        let dinosaurNode = SCNReferenceNode(url: url)!
        dinosaurNode.load()
        dinosaurNode.eulerAngles.y = Float(arc4random() % 200) / 100.0 * .pi
        return dinosaurNode
    }
    
}


extension  float4x4  {
    var  translation: float3  {
        let  translation  =  self.columns.3
        return  float3(translation.x,  translation.y,  translation.z)
    }
}

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        }
    }
}

