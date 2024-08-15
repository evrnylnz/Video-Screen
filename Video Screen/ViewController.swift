//
//  ViewController.swift
//  Video Screen
//
//  Created by Evren Yalnız on 13.08.2024.
//

import UIKit
import ARKit
import RealityKit
import AVKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var arView: ARView!
    
    override func viewDidLoad() {
        
        startPlaneDetection()
        startTapDetection()
        arView.isUserInteractionEnabled = true

    }
    
    func startPlaneDetection(){
        
        arView.automaticallyConfigureSession = true
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        configuration.isAutoFocusEnabled = true

        arView.session.run(configuration)
        
    }
    
    func startTapDetection(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        arView.addGestureRecognizer(tapGesture)
    }

    
    
    @objc func handleTap(recognizer: UITapGestureRecognizer){
        let tapLocation = recognizer.location(in: arView)
        
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        print(results)
        if let firtResult = results.first {
            
            
            let worldPosition = simd_make_float3(firtResult.worldTransform.columns.3)
            let width: Float = 0.5
            let height: Float = 0.3
            let videoScreen = createVideoScreen(width: width, height: height)
            videoScreen.setPosition(SIMD3(x: 0, y: height/2, z: 0), relativeTo: videoScreen)
            
            placeScreen(screen: videoScreen, worldPosition: worldPosition)
            
            installGestures(on: videoScreen)
        }
    }
    
    func placeScreen(screen: ModelEntity, worldPosition: SIMD3<Float>){
        
        let anchor = AnchorEntity(world: worldPosition)
        
        anchor.addChild(screen)
        
        arView.scene.addAnchor(anchor)
    }
    
    func installGestures(on model: ModelEntity) {
        
        model.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .scale, .translation], for: model)
    }
    // MARK: - Video Screen
    
    func createVideoScreen(width: Float, height: Float) -> ModelEntity{
        //mesh
        let screenMash = MeshResource.generatePlane(width: width, height: height, cornerRadius: 0.05)
        
        //video material
        let url = "https://cdn82.sobreatsesuyp.com/content/stream/pinup20th_tyr_150000_s.mp4"
        let videoItem = createVideoItem(with: url)
        let videoMaterial = createVideoMaterials(with: videoItem!)
        
        //model entity
        let videoScreenModelEntity = ModelEntity(mesh: screenMash, materials: [videoMaterial])
        
        return videoScreenModelEntity
    }
    
    func createVideoItem(with urlString: String) -> AVPlayerItem? {
        
        guard let url = URL(string: urlString) else {return nil}
        let asset = AVURLAsset(url: url)
        let videoItem = AVPlayerItem(asset: asset)
        
        return videoItem
    }
    
    func createVideoMaterials(with videoItem: AVPlayerItem) -> VideoMaterial{
        
        //player
        let player = AVPlayer()
        let videoMaterial = VideoMaterial(avPlayer: player)
        player.replaceCurrentItem(with: videoItem)
        player.play()
        
        return videoMaterial
    }
    

}
