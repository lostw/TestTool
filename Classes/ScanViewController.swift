//
//  ScanViewController.swift
//  AVcaptureQRcode
//
//  Created by sim on 2018/2/8.
//  Copyright © 2018年 wanglupeng. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var centView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "扫一扫"
        addCaptureDevice()
        self.customUI()
    }
    func customUI() {
        centView = UIView()
        centView.layer.borderColor = UIColor.red.cgColor
        centView.layer.borderWidth = 1
        self.view.addSubview(centView)
        centView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(300)
        }
        self.view.bringSubviewToFront(centView)
    }
    func addCaptureDevice() {

        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            //初始化媒体捕捉的输入流
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            //初始化AVcaptureSession
            captureSession = AVCaptureSession()
            //设置输入到Session
            captureSession?.addInput(input)
        } catch {
            // 捕获到移除就退出
            print(error)
            return
        }

        let output = AVCaptureMetadataOutput()
        captureSession?.addOutput(output)

        //设置代理 扫描的目标设置为二维码
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()

    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.isEmpty {
            return
        }

        // 取出第一个对象
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            return
        }

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if metadataObj.stringValue != nil {
                captureSession?.stopRunning()

                let controller = H5PageController(link: metadataObj.stringValue!)
                self.navReplaceToController(controller, animated: true)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
