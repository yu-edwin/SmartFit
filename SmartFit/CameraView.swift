//
//  CameraView.swift
//  SmartFit
//
//  Created by Edwin Yu on 2025-10-14.
//

import SwiftUI

struct CameraView: View {
    @State private var controller: CameraViewController?

    var body: some View {
        ZStack {
            CameraViewControllerRepresentable(controller: $controller)
                .ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        controller?.rotateCamera()
                    } label: {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var controller: CameraViewController?

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        DispatchQueue.main.async {
            controller = viewController
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
