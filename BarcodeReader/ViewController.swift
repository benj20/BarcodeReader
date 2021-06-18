//
//  ViewController.swift
//  BarcodeReader
//
//  Created by Benjamin Gouguet on 28/02/2018.
//  Copyright © 2018 Benjamin Gouguet. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    
    var captureSession: AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView = UIView()
    
    var metadataObjString = ""
    var metadataObjCode: Code?
    var codeList: [Code]?
    var firstTime = true
    
    @IBOutlet weak var scanCodeView: UIView!
    @IBOutlet weak var flashButtonItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVideoCamera()
    }

    
    
    // MARK: - Video camera
    
    func initVideoCamera() {
        // Get the back-facing camera for capturing videos
        if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            do {
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                // Set the input device on the capture session.
                captureSession.addInput(input)
                
                // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                
                // Set delegate and use the default dispatch queue to execute the call back
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
            } catch {
                print(error)
                return
            }
        } else {
            print("Failed to get the camera device")
            return
        }
        
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubviewToFront(scanCodeView)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
        qrCodeFrameView.layer.borderWidth = 4
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
        
        if metadataObj.type == AVMetadataObject.ObjectType.ean13 {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            if let barCodeObject = barCodeObject {
                qrCodeFrameView.frame = barCodeObject.bounds
                qrCodeFrameView.frame.size.height = 4
            }
            
            if metadataObj.stringValue != nil && firstTime {
                
                firstTime = false
                AudioServicesPlaySystemSound(1519)
                
                metadataObjString = metadataObj.stringValue!
                
                if let codes = codeList {
                    for code in codes {
                        if String(code.code) == metadataObjString {
                            let alert = UIAlertController(title: "Le code \(metadataObjString) correspond à :", message: code.name, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "retour", style: .cancel){ (alertAction) in
                                self.firstTime = true
                            })
                            self.present(alert, animated: true)
                            return
                        }
                    }
                }
                
                let alert = UIAlertController(title: "Voulez vous utiliser se code :", message: metadataObjString, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Non", style: .cancel){ (alertAction) in
                    self.firstTime = true
                })
                let action = UIAlertAction(title: "oui", style: .destructive) { (alertAction) in
                    let textField = alert.textFields![0] as UITextField
                    if let text = textField.text, let code = Int(self.metadataObjString) {
                        self.metadataObjCode = Code(name: text, code: code)
                        self.performSegue(withIdentifier: "return", sender: self)
                        self.dismiss(animated: true, completion: nil)
                        self.firstTime = true
                    }
                }
                action.isEnabled = false
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter name"
                    textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
                }
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
    }
    
    
    @objc func alertTextFieldDidChange(field: UITextField){
        let alertController: UIAlertController = self.presentedViewController as! UIAlertController;
        let textField: UITextField  = alertController.textFields![0]
        let addAction: UIAlertAction = alertController.actions[1]
        addAction.isEnabled = (textField.text!.count) > 0
    }
    
    
    
    // MARK: - Torch
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    
    @IBAction func flashToggle(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.isTorchActive {
            toggleTorch(on: false)
            flashButtonItem.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        } else {
            toggleTorch(on: true)
            flashButtonItem.tintColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
        }
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "return" {
            let controller = segue.destination as! QRCodeViewController
            if let metadataObjCode = metadataObjCode {
                controller.codes.append(metadataObjCode)
            }
            toggleTorch(on: false)
        }
    }


}

