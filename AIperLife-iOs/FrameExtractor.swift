//
//  FrameExtractor.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/11.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

/*  
 *  This File is created to contain all frame extraction in one file
 *  Highly customizable
 *
 */
import UIKit
import AVFoundation

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    weak var delegate: FrameExtractorDelegate?
    
    private let position = AVCaptureDevicePosition.back
    private let quality = AVCaptureSessionPresetMedium
    
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var permissionGranted = false
    let context = CIContext()
    
    override init() {
        super.init()
        
        //Manage camera permission
        checkPermission()
        sessionQueue.async {
            [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    /*
     *  Helper functions
     */
    
    private func configureSession() {
        guard permissionGranted else { return }
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(withMediaType: AVFoundation.AVMediaTypeVideo) else { return }
        guard connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async {
            [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: position)
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            permissionGranted = true
            break
            
        case .notDetermined:
            requestPermission()
            break
            
        default:
            permissionGranted = false
            break
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) {
            [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
}

