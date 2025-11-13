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
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var currentInput: AVCaptureDeviceInput?
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupCloseButton()
        setupRotateButton()
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
        ])
    }
    
    private func setupRotateButton() {
        let rotateButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        
        rotateButton.setImage(UIImage(systemName: "camera.rotate", withConfiguration: config), for: .normal)
        rotateButton.tintColor = .white
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        rotateButton.addTarget(self, action: #selector(rotateCameraTapped), for: .touchUpInside)
        
        view.addSubview(rotateButton)
        
        NSLayoutConstraint.activate([
            rotateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            rotateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }

    
    @objc private func closeTapped() {
        onDismiss?()
    }
    
    @objc private func rotateCameraTapped() {
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        switchCamera()
    }
    
    private func switchCamera() {
        captureSession.beginConfiguration()
        
        // Remove current input
        if let currentInput = currentInput {
            captureSession.removeInput(currentInput)
        }
        
        // Get camera for new position
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: currentCameraPosition),
              let newInput = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(newInput) else {
            captureSession.commitConfiguration()
            return
        }
        
        // Add new input
        captureSession.addInput(newInput)
        currentInput = newInput
        
        captureSession.commitConfiguration()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: currentCameraPosition),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else { return }
        
        captureSession.addInput(input)
        currentInput = input
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

