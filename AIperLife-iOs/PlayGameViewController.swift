//
//  PlayGameViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/9.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift


/*
 *  Create a subclass of FrameExtractor to play game
 */
protocol IdentifyFrameDelegate: class {
    func captured(image: UIImage)
    func fps(time: Double)
    func detection(info: String, found: Bool, numItem: Int)
}

class IdentifyFrame: FrameExtractor {
    
    weak var delegate: IdentifyFrameDelegate?
    
    // THNETS neural network loading and initalization:
    let nnEyeSize = 128
    var embeddingSize:Int32 = 0 // network embedding size returned by THNETS
    var categories:[String] = []
    var net: UnsafeMutablePointer<THNETWORK>?
    // load neural net from project:
    let docsPath = Bundle.main.resourcePath!// + "/neural-nets/"
    // prototypes of objects
    var protoNumber:Int = -1
    var protos:[[Float]] = [ [],[],[],[],[], [],[],[],[],[], [],[],[],[],[], [],[],[],[],[] ] // 20 max for now... TODO: do not let it break if > 20 protos
    var embedding:[Float] = []
    
    var protoString:[String] = []
    
    init(selectSave: Int) {
        super.init()

        THInit()
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
            } catch {
                print(error)
            }
        }
        
        // Load Network
        net = THLoadNetwork(docsPath, 1) // 0 == full neural net, 1 == net with removed classifier (returns features)
        
        // setup neural net:
        if net != nil {
            THUseSpatialConvolutionMM(net, 2)
        }
        
        // Opeartion on saves
        let defaults = UserDefaults.standard
        let realm = try! Realm()
        
        let cropWidth = nnEyeSize
        let cropHeight = nnEyeSize
        
        // Get the correct save file
        let result = realm.objects(SaveData.self)[selectSave]
        // Loop through the content
        let objList = result.objList
        for item in objList {
            // Save Hints
            protoString.append(item.hint)
            print("appended \(item.hint) at protoString \(protoString.count-1)")
            // Transform String back to Image
            let tempdata = defaults.object(forKey: item.objID) as! NSData
            let croppedScaledImage = UIImage(data: tempdata as Data) //Util.resizeImage(image: tempimage!, newWidth: CGFloat(nnEyeSize))
            let pixelData = croppedScaledImage?.cgImage!.dataProvider!.data
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
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
            // THNETS process image:
            let nbatch: Int32 = 1
            var results: UnsafeMutablePointer<Float>?
            var outwidth: Int32 = 0
            var outheight: Int32 = 0
            embeddingSize = THProcessImages(net, &pimage, nbatch, Int32(cropWidth), Int32(cropHeight), Int32(3*cropWidth), &results, &outwidth, &outheight, Int32(0))
            // convert results to array:
            embedding = convert(count: Int(embeddingSize), data: results!)
            protos[item.order] = embedding
        }
        protoNumber = result.numObj-1
    }
    
    override func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        //calculate fps
        let methodStart = NSDate()
        
        let cropWidth = nnEyeSize
        let cropHeight = nnEyeSize
        let croppedScaledImage = Util.resizeImage(image: uiImage, newWidth: CGFloat(nnEyeSize))
        let pixelData = croppedScaledImage?.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
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
        // THNETS process image:
        let nbatch: Int32 = 1
        var results: UnsafeMutablePointer<Float>?
        var outwidth: Int32 = 0
        var outheight: Int32 = 0
        embeddingSize = THProcessImages(net, &pimage, nbatch, Int32(cropWidth), Int32(cropHeight), Int32(3*cropWidth), &results, &outwidth, &outheight, Int32(0));
        // convert results to array:
        embedding = convert(count: Int(embeddingSize), data: results!)
        
        // compute distace of camera view to protos:
        var min:Float = 2.0
        var max:Float = 0.0
        var best:Int = -1
        if protoNumber >= 0 {
            for i in 0...protoNumber {
                let d = distance(a:protos[i], b:embedding, embeddingSize: embeddingSize)
                if (d > max) { max = d }
                if (d < min) {
                    best = i
                    min = d
                }
            }
        }
        
        // filter results by threshold:
        let threshold:Float = 0.5
        let methodFinish = NSDate()
        let executionTime = methodFinish.timeIntervalSince(methodStart as Date)
        DispatchQueue.main.async {
            [unowned self] in
            self.delegate?.captured(image: uiImage)
            self.delegate?.fps(time: executionTime)
            
            if (min < max*threshold) {
                //self.delegate?.detection(info: "Detected: " + self.protoString[best] + " Distance: \(min)")
                self.delegate?.detection(info: self.protoString[best], found: true, numItem: best)
            } else {
                self.delegate?.detection(info: "", found: false, numItem: 0)
            }
        }
    }
}

class PlayGameViewController: UIViewController, IdentifyFrameDelegate {
    
    var idFrame : IdentifyFrame!
    var progressLauncher : ProgressLauncher!

    @IBOutlet var playImageView: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    
    var selectSave = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idFrame = IdentifyFrame(selectSave: selectSave)
        idFrame.delegate = self
        
        progressLauncher = ProgressLauncher(selectSave: selectSave)

    }
    
    func captured(image: UIImage) {
        playImageView.image =  image
    }
    func fps(time: Double) {
        textLabel.text = "FPS: \(1/time)"
    }
    func detection(info: String, found: Bool, numItem: Int) {
        infoLabel.text = info
        if found {
            progressLauncher.updateProgress(item: numItem)
        }
    }
    
    
    @IBAction func progressPressed(_ sender: Any) {
        progressLauncher.showProgress()
    }

    

    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Manage the UIView Rotations
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        switch (orientation) {
            case .landscapeRight:
                playImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                break
            case .landscapeLeft:
                playImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2*3)
                break
            default:
                playImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
                break
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.idFrame.captureSession.stopRunning()
    }
}
