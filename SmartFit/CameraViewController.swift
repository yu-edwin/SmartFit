//
//  CameraViewController.swift
//  SmartFit
//
//  Created by Edwin Yu on 2025-10-14.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else { return }

        captureSession.addInput(input)
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        captureSession.startRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeBounds = view.bounds.inset(by: view.safeAreaInsets)
        previewLayer?.frame = safeBounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
}
