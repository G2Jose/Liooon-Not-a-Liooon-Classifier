//
//  ViewController.swift
//  Liooon
//
//  Created by George Jose on 2017-06-13.
//  Copyright © 2017 g2jose. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var cameraView: UIView?
    @IBOutlet weak var classificationText: UILabel!
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    @IBOutlet weak var liooonText: UILabel!
    private var requests = [VNRequest]()
    private var textLayer:CATextLayer! = nil
    private var rootLayer:CALayer! = nil
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
        else { return session }
        session.addInput(input)
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
        self.setupVision()
        
//        self.classificationText.isUserInteractionEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: Inceptionv3().model)
            else { fatalError("Can't load VisionML model") }
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassifications)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop
        self.requests = [classificationRequest]
    }
    
    func getLiooonText(array: Array<String>) -> String {
        return array
            .reduce("Not a liooon") { (acc, curr) -> String in
                if curr.range(of: "lion") != nil || acc == "🦁 Liooooon 🦁" {
                    return "🦁 Liooooon 🦁"
                } else {
                    return "Not a liooon"
                }
        }
    }
    
    func handleClassifications(request: VNRequest, error: Error?) {
        guard let observations = request.results
            else { print("no results: \(error!)"); return }
        let classifications = observations[0...4]
            .flatMap({ $0 as? VNClassificationObservation })
            .filter({ $0.confidence > 0.3 })
            .map({ $0.identifier })
        DispatchQueue.main.async {
            print(classifications.joined(separator: "###"))
            self.classificationText.text = classifications.joined(separator: "\n")
            self.liooonText.text = self.getLiooonText(array: classifications)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var requestOptions:[VNImageOption : Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
//        let exifOrientation = self.exifOrientationFromDeviceOrientation()
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: 1, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }

}

