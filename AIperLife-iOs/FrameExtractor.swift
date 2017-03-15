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

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //weak var delegate: FrameExtractorDelegate?
    
    private let position = AVCaptureDevicePosition.back
    private let quality = AVCaptureSessionPresetMedium
    
    let captureSession = AVCaptureSession()
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
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        /*
         * FrameExtractor is a base class and this function is intentionally empty.
         * This method captures each frame.
         * Define a subclass and override this function to perform different operation as needed
         *
         */
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
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: position)
    }
    
     func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
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
    
    func convert<T>(count: Int, data: UnsafePointer<T>) -> [T] {
        
        let buffer = UnsafeBufferPointer(start: data, count: count);
        return Array(buffer)
    }
    
    func distance(a:[Float], b:[Float], embeddingSize:Int32) -> Float {
        // calculate the cosine distance:
        var num:Float = 0, den1:Float = 0, den2:Float = 0
        
        for i in 0...Int(embeddingSize-1) {
            num = num + a[i] * b[i]
            den1 = den1 + a[i] * a[i]
            den2 = den2 + b[i] * b[i]
        }
        den1 = sqrt(den1 * den2)
        if den1 > 0 { return (1-num/den1) }
        else { return 2 }
    }
}

