//
//  CameraView.swift
//  SmartFit
//
//  Created by Edwin Yu on 2025-10-14.
//

import SwiftUI
import PhotosUI

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct CameraView: View {
    @ObservedObject var wardrobeController: WardrobeController
    @State private var controller: CameraViewController?
    @State private var capturedImage: IdentifiableImage?
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            CameraViewControllerRepresentable(
                controller: $controller,
                onPhotoCaptured: { image in
                    capturedImage = IdentifiableImage(image: image)
                }
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    Spacer()

                    // Photo library button
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .padding()
                            .background(Circle().fill(Color.white))
                    }
                    .accessibilityIdentifier("photoLibraryButton")

                    Spacer()

                    // Capture button
                    Button {
                        controller?.capturePhoto()
                    } label: {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 3)
                            .background(Circle().fill(Color.white.opacity(0.3)))
                            .frame(width: 70, height: 70)
                    }
                    .accessibilityIdentifier("capturePhotoButton")

                    Spacer()

                    // Rotate button
                    Button {
                        controller?.rotateCamera()
                    } label: {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .accessibilityIdentifier("rotateCameraButton")

                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(item: $capturedImage) { identifiableImage in
            PhotoFormView(
                image: identifiableImage.image,
                isPresented: Binding(
                    get: { capturedImage != nil },
                    set: { if !$0 { capturedImage = nil } }
                ),
                wardrobeController: wardrobeController
            )
        }
        .onChange(of: selectedPhotoItem) {
            Task {
                if let selectedPhotoItem = selectedPhotoItem,
                   let data = try? await selectedPhotoItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    capturedImage = IdentifiableImage(image: uiImage)
                }
                selectedPhotoItem = nil
            }
        }
    }
}

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var controller: CameraViewController?
    var onPhotoCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.onPhotoCaptured = onPhotoCaptured
        DispatchQueue.main.async {
            controller = viewController
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.onPhotoCaptured = onPhotoCaptured
    }
}
