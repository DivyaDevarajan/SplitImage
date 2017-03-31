//
//  ViewController.swift
//  SplitImage
//
//  Created by Casperon iOS on 15/2/2017.
//  Copyright © 2017 Casperon iOS. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class ViewController: UIViewController {
    var fullImage = [UInt8]()
    var joiningImg = [UInt8]()
    var ConstantTotalByteCount:Int=100000
    var ByteCount:Int!
    var toByte : Int!
    var TotalByteCount: Int = 0
    var reminderByteCount:Int = 0
    
    
    var fullVideo = [UInt8]()
    var joingVideo = [UInt8]()
    var byteCountVideo : Int!
    var toByteVideo : Int!
    var totalVideoByteCount : Int = 0
    var reminderVideoByteCount: Int = 0
    
    
    @IBOutlet var Before_image:UIImageView!
    @IBOutlet var after_image:UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        toByte=ConstantTotalByteCount
        toByteVideo = ConstantTotalByteCount
        byteCountVideo = 0
        ByteCount=0
        splitImage()
         // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitImage(){
        let imageForSplit = UIImage.init(named: "Split")
        Before_image.image=imageForSplit
        let imageData = UIImagePNGRepresentation(imageForSplit!)
        getArrayOfBytesFromImage(imageData!)
        //getArrayOfBytesFromVideo()
    }
    
    func getArrayOfBytesFromImage(imageData:NSData) {
        let count = imageData.length / sizeof(UInt8)
        var bytes = [UInt8](count: count, repeatedValue: 0)
        var byteArray:[UInt8] = [UInt8]()
        
        imageData.getBytes(&bytes, length:count * sizeof(UInt8))
        for i in 0 ..< count {
            byteArray.append(bytes[i])
        }
        fullImage = byteArray
        //Convert Bytes to image
//        ByteCount=ByteCount+1000
        uploadBytes(ByteCount)
    }
    
    
    
    func uploadBytes(NumberBytes:Int){
        var sam = [UInt8]()
        reminderByteCount = fullImage.count%ConstantTotalByteCount
        TotalByteCount = fullImage.count - reminderByteCount
        print(reminderByteCount)
        for i in NumberBytes  ..< toByte {
            if(i <= fullImage.count){
                sam.append(fullImage[i])
                joiningImg.append(fullImage[i])

            }
        }
        let datos1: NSData = NSData(bytes: joiningImg , length: joiningImg.count)
        var image2 =  UIImage(data: datos1)
        after_image.image=image2
        if(self.toByte != fullImage.count){
            uploadToServer()
        }
        else{
            after_image.image=image2
        }
    }
    
    
   func uploadVideoBytes(NumberBytes:Int){
        var sam = [UInt8]()
        reminderVideoByteCount = fullVideo.count%ConstantTotalByteCount
        totalVideoByteCount = fullVideo.count - reminderVideoByteCount
        print(reminderVideoByteCount)
        for i in NumberBytes  ..< toByteVideo {
            if(i <= fullVideo.count){
                sam.append(fullVideo[i])
                joingVideo.append(fullVideo[i])
            }
        }
    
//        let datos1: NSData = NSData(bytes: joingVideo , length: joingVideo.count)
//        var image2 =  UIImage(data: datos1)
        if(self.toByteVideo != fullVideo.count){
            uploadToServer()
        }
        else  {
            let videoPath = NSBundle.mainBundle().pathForResource("SampleVideo_1280x720_1mb", ofType: "mp4")
            let datos1: NSData = NSData(bytes: joingVideo , length: joingVideo.count)
            datos1.writeToFile(videoPath!, atomically: true)
            let url = NSURL(fileURLWithPath: videoPath!)
            let player = AVPlayer.init(URL: url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            presentViewController(playerController, animated: true) {
                player.play()
                
            }

            
        }
    }
    
    
    
    func forDelay(){
        let triggerTime = (Int64(NSEC_PER_SEC) * 3)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
           
            // For Image
            if(self.toByte == self.TotalByteCount) {
                self.toByte = self.toByte+self.reminderByteCount
            }else{
            self.toByte = self.toByte+self.ConstantTotalByteCount
            }
            self.ByteCount = self.ByteCount+self.ConstantTotalByteCount
            self.uploadBytes(self.ByteCount)
            
            // For Video
            if(self.toByteVideo == self.totalVideoByteCount) {
                self.toByteVideo = self.toByteVideo+self.reminderVideoByteCount
            }else{
                self.toByteVideo = self.toByteVideo+self.ConstantTotalByteCount
            }
            self.byteCountVideo = self.byteCountVideo+self.ConstantTotalByteCount
            self.uploadVideoBytes(self.byteCountVideo)
        })
    }
    
    func uploadToServer(){
        forDelay()
    }
    
    func getArrayOfBytesFromVideo(){
        
        let videoPath = NSBundle.mainBundle().pathForResource("SampleVideo_1280x720_1mb", ofType: "mp4")
        let videoData = NSData.init(contentsOfFile: videoPath!)
        let count = videoData!.length / sizeof(UInt8)
        print (count)
        var videoByte = [UInt8](count: count, repeatedValue: 0)
        videoData!.getBytes(&videoByte, length: count * sizeof(UInt8))
        var byteArray:[UInt8] = [UInt8]()
        for i in 0 ..< count {
            byteArray.append(videoByte[i])
        }
        
        fullVideo = byteArray
        uploadVideoBytes(byteCountVideo)
        

        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        getArrayOfBytesFromVideo()
    }
}

