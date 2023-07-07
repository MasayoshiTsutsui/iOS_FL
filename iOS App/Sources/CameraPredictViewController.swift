import UIKit
import AVFoundation
import CoreML

class CameraPredictViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureOutput: AVCaptureVideoDataOutput?
    var model: MLModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // カメラのセットアップ
        setupCamera()
        
        // シャッターボタンの作成
        let button = UIButton(type: .system)
        button.setTitle("シャッター", for: .normal)
        button.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCamera()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("カメラデバイスが見つかりません")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            if let videoPreviewLayer = videoPreviewLayer {
                view.layer.addSublayer(videoPreviewLayer)
            }
            
            captureOutput = AVCaptureVideoDataOutput()
            captureOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            captureOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .default))
            if let captureOutput = captureOutput {
                captureSession.addOutput(captureOutput)
            }
        } catch {
            print("カメラのセットアップに失敗しました: \(error.localizedDescription)")
        }
    }
    
    func startCamera() {
        captureSession?.startRunning()
    }
    
    func stopCamera() {
        captureSession?.stopRunning()
    }
    
    @objc func shutterButtonTapped() {
        /*if let videoConnection = captureOutput?.connection(with: .video) {
            captureOutput?.(to: videoConnection, completionHandler: { (buffer, error) in
                if let buffer = buffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil) {
                    if let image = UIImage(data: data) {
                        self.predict(image)
                    }
                }
            })
        }*/
    }
    
    func predict(_ image: UIImage) {
        // ここで画像を予測する処理を実装する
        // 例えば、Core MLモデルを使用して予測を行うなど
    }
    
    // AVCaptureVideoDataOutputSampleBufferDelegateのメソッド
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // ビデオフレームがキャプチャされたときの処理を記述する
        // 例えば、画像処理を行ったり、プレビュー表示に利用するなど
    }
}
