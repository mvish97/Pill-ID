//
//  CameraVC.swift
//  Pill ID
//
//  Created by Vatsal Rustagi on 11/2/17.
//  Copyright © 2017 MedAppJam. All rights reserved.
//

import UIKit
import ARKit
import Vision


class CameraVC: UIViewController, ARSessionDelegate, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    let bubbleDepth : Float = 0.01
    var latestPrediction : String = "…"
    var timer = Timer()
    
    var pills = ["Tylenol", "Advil"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        
    }
    
    
//    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        guard let model = try? VNCoreMLModel(for: VGG16().model) else {return}
//
//        let request = VNCoreMLRequest(model: model) {
//            (finishedReq, err) in
//
//            //print(finishedReq.results)
//
//            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
//
//            guard let firstObservation = results.first else {return}
//
//            print(firstObservation.identifier, firstObservation.confidence)
//
//        }
//        try? VNImageRequestHandler(cvPixelBuffer: (self.sceneView.session.currentFrame?.capturedImage)!, options: [:]).perform([request])
//    }
    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//
//
//    }
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // HIT TEST : REAL WORLD
        // Get Screen Centre
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Create 3D Text
            var pill = "Tylenol"
            /*if self.pills.count > 0 {
                pill = pills.popLast()!
            }*/
            let node : SCNNode = createNewBubbleParentNode(pill)
            sceneView.scene.rootNode.addChildNode(node)
            node.position = worldCoord
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [])
        
        sceneView.automaticallyUpdatesLighting = true
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(CameraVC.processImage), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
        timer.invalidate()
    }
    
    @objc func processImage() {
        
        guard let model = try? VNCoreMLModel(for: VGG16().model) else {return}
        
        let request = VNCoreMLRequest(model: model) {
            (finishedReq, err) in

            //print(finishedReq.results)

            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}

            guard let firstObservation = results.first else {return}

            print(firstObservation.identifier, firstObservation.confidence)

        }
        try? VNImageRequestHandler(cvPixelBuffer: (self.sceneView.session.currentFrame?.capturedImage)!, options: [:]).perform([request])
    }
    
    
    func createNewBubbleParentNode(_ text : String) -> SCNNode {
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.
        
        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // BUBBLE-TEXT
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        let font = UIFont(name: "Avenir-Heavy", size: 0.15)
//        font = font?.withTraits(traits: .traitBold)
        bubble.font = font
        bubble.alignmentMode = kCAAlignmentCenter
        bubble.firstMaterial?.diffuse.contents =  UIColor(red: 0.25, green: 0.52, blue: 0.95, alpha: 1.00)
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        // bubble.flatness // setting this too low can cause crashes.
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
        // BUBBLE NODE
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        // Centre Node - to Centre-Bottom point
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
        // Reduce default text size
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        // CENTRE POINT NODE
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.cyan
        let sphereNode = SCNNode(geometry: sphere)
        
        // BUBBLE PARENT NODE
        let bubbleNodeParent = SCNNode()
        bubbleNodeParent.addChildNode(bubbleNode)
        bubbleNodeParent.addChildNode(sphereNode)
        bubbleNodeParent.constraints = [billboardConstraint]
        
        return bubbleNodeParent
    }

}
