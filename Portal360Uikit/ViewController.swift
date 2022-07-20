//
//  ViewController.swift
//  Portal360Uikit
//
//  Created by Oscar Castillo on 6/1/22.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var player: AVPlayer?
    var videoNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addVideoToNode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    
    func addVideoToNode() {
        guard let path = Bundle.main.path(forResource: "360nature", ofType: "mp4") else { return }
        let fileUrl = URL(fileURLWithPath: path)
        let player = AVPlayer(url: fileUrl)
        
        let videoGeometry = SCNSphere(radius: 1.5)
        videoGeometry.firstMaterial?.diffuse.contents = player
        videoGeometry.firstMaterial?.isDoubleSided = true
        
        let videoNode = SCNNode(geometry: videoGeometry)
        videoNode.position = SCNVector3(0, 0, -2)
        videoGeometry.firstMaterial?.diffuse.contentsTransform =
        SCNMatrix4Translate(SCNMatrix4MakeScale(-1, 1, 1), 1, 0, 0)
        
        sceneView.scene.rootNode.addChildNode(videoNode)
        self.videoNode = videoNode
        self.player = player
        
       
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let node = videoNode else { return }
        let transform = frame.camera.transform.columns.3
        let devicePosition = simd_float3(x: transform.x, y: transform.y, z: transform.z)
        
        if distance(node.simdPosition, devicePosition) < 0.8 {
            player?.play()
        }
    }
}

