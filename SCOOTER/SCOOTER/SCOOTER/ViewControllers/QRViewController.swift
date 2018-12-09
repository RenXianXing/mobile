import AVFoundation
import UIKit
import Alamofire
import SwiftyJSON

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    
    var imei:String?
    var onTorch = true
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var btnTorch: UIButton!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        imageBackground.alpha = 0.6
        view.bringSubview(toFront: imageBackground)
        view.bringSubview(toFront: bottomBar)
        captureSession.startRunning()
        
        
        btnTorch.roundCorners(corners: [.topLeft, .topRight], radius: 5.0)
        
        
        //add observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(messageReceived(_ :)),
                                               name: .MessageReceived,
                                               object: nil)
        
    }
    
    @objc func messageReceived(_ notification:Notification) {
        
        if let message = notification.userInfo!["message"] as? [String]{
            if(message[0] == "unlock-scooter" && message[1] == "0"){
                NotificationCenter.default.removeObserver(self)
                let userid = UserDefaults.standard.value(forKey: "userid") as! String
                let imei = UserDefaults.standard.value(forKey: "imei") as! String
                startRiding(player: userid, imei: imei)
                let rideVC = RideViewController()
                rideVC.imei = imei
                self.navigationController?.pushViewController(rideVC, animated: true)
                
            }
            
            if(message[0] == "unlock-scooter" && message[1] == "3"){
                showFailedAlertToUnlock()
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - QR code api func
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    func found(code: String) {
        let url = "https://ridebogo.com/admin/v1/api/getScooterIMEIBySerial"
        let para = ["serial": code]
        Alamofire.request(url, method: .post, parameters: para).validate().responseJSON { (response) in
            switch response.result.isSuccess{
            case true:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.imei = json["imei"].string
                    if let imeiValue = self.imei {
                        UserDefaults.standard.set(imeiValue, forKey: "imei")
                        self.onScooter(imeiValue)
                    }
                }
                break
            case false:
                break
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: - TCP Communication
    func onScooter(_ imei:String){
        let userid = UserDefaults.standard.value(forKey: "userid") as! String
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let strInput = String(format: "%@,%@,%@,%@,%@", "mobile", "unlock-scooter", imei, userid, username)
        Connect.shared().sendMessage(message: strInput)
    }
    @IBAction func toggleTorch(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: .video) else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if onTorch == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                onTorch = !onTorch
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Trouch is not availabe")
        }
        
        
    }
    
    func showFailedAlertToUnlock(){
        let alert = UIAlertController(title:"Unlock failed", message: "This Scooter is in use now.", preferredStyle:UIAlertControllerStyle.alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) -> Void in
            self.captureSession.startRunning()
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
