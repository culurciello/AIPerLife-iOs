//
//  ViewController.swift
//  AIperLife-iOs
//
//  Created by Eugenio Culurciello on 2/17/17.
//  Copyright © 2017 Eugenio Culurciello. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //UIVariables
    @IBOutlet weak var textresults: UILabel!
    @IBOutlet weak var textfps: UILabel!
    @IBOutlet weak var buttonLearnProto: UIButton!
    @IBOutlet weak var textprotonum: UILabel!
    
    @IBOutlet var loadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraSession()
        
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "ObjNum") == nil {
            print("Nothing to load, Load button hidden")
            loadButton.isHidden = true
        } else {
            print("Save data found, Load button not hidden")
            loadButton.isHidden = false
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layer.addSublayer(previewLayer)
        view.addSubview(textresults)
        view.addSubview(textfps)
        
        cameraSession.startRunning()
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        previewLayer.frame = self.view.bounds
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewLayer.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                }
            }
        }
    }
    
    
    // THNETS neural network loading and initalization:
    let nnEyeSize = 128
    var embeddingSize:Int32 = 0 // network embedding size returned by THNETS
    var categories:[String] = []
    var net: UnsafeMutablePointer<THNETWORK>?
    // load neural net from project:
    let docsPath = Bundle.main.resourcePath! + "/neural-nets/"
    // prototypes of objects
    var protoNumber:Int = -1
    var protos:[[Float]] = [ [],[],[],[],[], [],[],[],[],[], [],[],[],[],[], [],[],[],[],[] ] // 20 max for now... TODO: do not let it break if > 20 protos
    var embedding:[Float] = []
    var protoString:[String] = ["1", "2", "3", "4", "5"]
    
    lazy var cameraSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetLow //https://developer.apple.com/reference/avfoundation/avcapturesession/video_input_presets
        return captureSession
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        //preview?.videoGravity = AVLayerVideoGravityResize
        return preview!
    }()
    
    func setupCameraSession() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)] //https://developer.apple.com/reference/corevideo/cvpixelformatdescription/1563591-pixel_format_types
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
        
        // THNETS init and load
        THInit();
        
        //test if correct file located
        let fileManager = FileManager.default
        do {
            let docsArray = try fileManager.contentsOfDirectory(atPath: docsPath)
            print(docsArray)
        } catch {
            print(error)
        }
        
        // load categories file:
        if true {
            do {
                let data = try String(contentsOfFile: "\(docsPath)/categories.txt", encoding: .utf8)
                categories = data.components(separatedBy: .newlines)
                categories.remove(at: 0)
                categories.remove(at: 46)
                //print(categories)
            } catch {
                print(error)
            }
        }
        
        
        // Load Network
        net = THLoadNetwork(docsPath, 1) // 0 == full neural net, 1 == net with removed classifier (returns features)
        print("network loaded:", net)
        
        // setup neural net:
        if net != nil {
            THUseSpatialConvolutionMM(net, 2)
        }
    
    }
    
    // resize and rescale func
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        //new Height may not be 128, rescale the height
        let tempH = image.size.height * scale
        let newHeight = (newWidth/tempH)*tempH
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func convert<T>(count: Int, data: UnsafePointer<T>) -> [T] {
        
        let buffer = UnsafeBufferPointer(start: data, count: count);
        return Array(buffer)
    }
    
    func distance(a:[Float], b:[Float]) -> Float {
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
    
    /** Learn Button Pressed
        Set maximum to 3 for debugging purposes
    **/
    @IBAction func pressLearnProto(_ sender: Any) {
        
        if protoNumber < 2 {
            
            protoNumber = protoNumber+1
            self.textprotonum.text = "Protos: \(protoNumber+1)"
            protos[protoNumber] = embedding
            
        } else {
            
            textprotonum.text = "Maximum reached"
            
        }
        
    }
    
    //Prototype save function
    @IBAction func savePressed(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        
        //save items
        defaults.set(protoNumber, forKey: "ObjNum")
        
        print("Saving \(protoNumber+1) itmes")

        for idx in 0...protoNumber{
            
            let key = "obj" + String(idx)
            defaults.setValue(embedding, forKey: key)
            print("idx \(idx) is  \(embedding[0])")
            
        }
        //make load button appear
        loadButton.isHidden = false
    }
    
    //Prototype load function
    @IBAction func loadPressed(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        let numload = defaults.integer(forKey: "ObjNum")

        print("loading \(numload+1) items")
        
        self.textprotonum.text = "Protos: \(numload+1)"
        
        for idx in 0...numload {
            let key = "obj" + String(idx)
            protos[idx] = defaults.array(forKey: key) as! [Float]
            print( "protos \(idx) is \(protos[idx][0])")
        }

        protoNumber = numload
        print(protoNumber)
    }
    
    //prototype clear save function
    @IBAction func clearPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "ObjNum") == nil {
            
            print("No saved data to clear")
            
        } else {
            //clear saved data
            let numClear = defaults.integer(forKey: "ObjNum")
            
            print("removing \(numClear+1) items")
            
            for idx in 0...numClear{
                
                let key = "obj" + String(idx)
                defaults.removeObject(forKey: key)
                
            }
            defaults.removeObject(forKey: "ObjNum")
            
            //make sure chages saved
            defaults.synchronize()
            loadButton.isHidden = true

        }
        protoNumber = -1
        textprotonum.text = "Protos: \(protoNumber+1)"
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // Here you collect each frame and process it
        let methodStart = NSDate()
        
        let cropWidth = nnEyeSize
        let cropHeight = nnEyeSize
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let cameraImage = CIImage(cvPixelBuffer: imageBuffer)
        let uiImage = UIImage(ciImage: cameraImage)
        //print("Camera input size:", uiImage.size)
        
        // crop and scale buffer:
        let croppedScaledImage = resizeImage(image: uiImage, newWidth: CGFloat(nnEyeSize))
        //print("croppedScaledImage size:", croppedScaledImage!.size)
        //print(croppedScaledImage?.cgImage!.colorSpace!) // gives: <CGColorSpace 0x174020d00> (kCGColorSpaceICCBased; kCGColorSpaceModelRGB; sRGB IEC61966-2.1)
        let pixelData = croppedScaledImage?.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData) // data is in BGRA format
        
        
        // input image pixel samples:
        //let imdatay = convert(count:16, data: data)
        //print("input image:", imdatay)
        
        /// convert BGRA to RGB:
        var idx = 0
        var dataRGB = [CUnsignedChar](repeating: 0, count: (nnEyeSize*nnEyeSize*3))
        for i in stride(from:0, through: nnEyeSize*nnEyeSize*4-1, by: 4) { // every 4 values do this:
            dataRGB[idx]   = data[i+2]
            dataRGB[idx+1] = data[i+1]
            dataRGB[idx+2] = data[i]
            idx = idx+3
        }
        
        // get usable pointer to image:
        var pimage : UnsafeMutablePointer? = UnsafeMutablePointer(mutating: dataRGB)
        
        // converted image pixel samples:
        //let imdatay2 = convert(count:16, data: pimage!)
        //print("converted image:", imdatay2)
        
        // THNETS process image:
        let nbatch: Int32 = 1
        //var data = [UInt8](repeating: 0, count: 3*nnEyeSize*nnEyeSize) // TEST pixel data
        //var pimage: UnsafeMutablePointer? = UnsafeMutablePointer(mutating: data) // TEST pointer to pixel data
        var results: UnsafeMutablePointer<Float>?
        var outwidth: Int32 = 0
        var outheight: Int32 = 0
        embeddingSize = THProcessImages(net, &pimage, nbatch, Int32(cropWidth), Int32(cropHeight), Int32(3*cropWidth), &results, &outwidth, &outheight, Int32(0));
        //print("TH out sizes:", outwidth, outheight)
        
        // convert results to array:
        embedding = convert(count: Int(embeddingSize), data: results!)
        
        // compute distace of camera view to protos:
        var min:Float = 2
        var max:Float = 0
        var best:Int = -1
        if protoNumber >= 0 {
            for i in 0...protoNumber {
                let d = distance(a:protos[i], b:embedding)
                if (d > max) { max = d }
                if (d < min) {
                    best = i
                    min = d
                }
            }
        }
        
        // filter results by threshold:
        let threshold:Float = 0.5
        if (min < max*threshold) {
            DispatchQueue.main.async { self.textresults.text = "Detected: " + self.protoString[best] + " Distance: \(min)" }
        } else {
            DispatchQueue.main.async { self.textresults.text = "" }
        }
        
        // print time:
        let methodFinish = NSDate()
        let executionTime = methodFinish.timeIntervalSince(methodStart as Date)
        //print("Processing time: \(executionTime) \n")
        DispatchQueue.main.async { self.textfps.text = "FPS: \(1/executionTime)" }
        
        
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you can count how many frames are dropped
    }
    
}


