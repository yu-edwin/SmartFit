//
//  PhotoFormView.swift
//  SmartFit
//
//  Created by Claude Code on 2025-11-22.
//

import SwiftUI

struct PhotoFormView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    @ObservedObject var wardrobeController: WardrobeController
    @State private var selectedOutfit: Int = 1
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var generatedImage: String?

    var equippedItems: [WardrobeItem] {
        guard let outfit = wardrobeController.outfits[selectedOutfit] else { return [] }
        return outfit.compactMap { _, itemId in
            wardrobeController.model.items.first { $0.id == itemId }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Captured image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("capturedPhoto")

                Spacer()

                // Outfit selection at bottom
                VStack(spacing: 16) {
                    // Equipped items icons
                    if !wardrobeController.hasLoadedItems {
                        // Loading state
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading wardrobe...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        .accessibilityIdentifier("loadingWardrobeIndicator")
                    } else if !equippedItems.isEmpty {
                        HStack(spacing: 12) {
                            ForEach(equippedItems) { item in
                                if let imageDataString = item.image_data,
                                   let base64 = imageDataString.components(separatedBy: ",").last,
                                   let data = Data(base64Encoded: base64),
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        .accessibilityIdentifier("equippedItem_\(item.id)")
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "tshirt")
                                                .foregroundColor(.gray)
                                        )
                                        .accessibilityIdentifier("equippedItem_\(item.id)")
                                }
                            }
                        }
                        .padding(.horizontal)
                        .accessibilityIdentifier("equippedItemsContainer")
                    } else {
                        Text("No items equipped")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                            .accessibilityIdentifier("noItemsEquippedLabel")
                    }

                    // Segmented picker for outfit selection
                    Picker("Select Outfit", selection: $selectedOutfit) {
                        Text("Outfit 1").tag(1)
                        Text("Outfit 2").tag(2)
                        Text("Outfit 3").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .accessibilityIdentifier("outfitPicker")
                }
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Generate") {
                        print("=== Generate button tapped ===")
                        print("Selected outfit: \(selectedOutfit)")
                        print("Equipped items count: \(equippedItems.count)")
                        Task {
                            await generateOutfit()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(isGenerating)
                    .accessibilityIdentifier("generateButton")
                }
            }
            .overlay {
                if isGenerating {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView("Generating outfit...")
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { generatedImage != nil },
                set: { if !$0 { generatedImage = nil } }
            )) {
                if let generatedImage = generatedImage {
                    GeneratedOutfitView(
                        generatedImageBase64: generatedImage,
                        isPresented: Binding(
                            get: { self.generatedImage != nil },
                            set: { if !$0 { self.generatedImage = nil } }
                        )
                    )
                }
            }
        }
    }

    private func generateOutfit() async {
        print("=== generateOutfit() called ===")
        isGenerating = true
        errorMessage = nil
        print("isGenerating set to true")

        do {
            print("About to call wardrobeController.model.generateOutfit")
            print("Outfit number: \(selectedOutfit)")
            print("Image size: \(image.size)")

            let result = try await wardrobeController.model.generateOutfit(
                outfitNumber: selectedOutfit,
                picture: image
            )

            print("=== API call returned successfully ===")
            print("Result length: \(result.count)")
            generatedImage = result
            print("Successfully generated outfit image")
        } catch {
            print("=== ERROR in generateOutfit ===")
            print("Error: \(error)")
            print("Error localized description: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            print("Failed to generate outfit: \(error)")
        }

        isGenerating = false
        print("isGenerating set to false")
    }
}

struct GeneratedOutfitView: View {
    let generatedImageBase64: String
    @Binding var isPresented: Bool
    @State private var generatedUIImage: UIImage?
    @State private var isSaving = false
    @State private var showSaveSuccess = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if let generatedUIImage = generatedUIImage {
                    Image(uiImage: generatedUIImage)
                        .resizable()
                        .scaledToFit()
                        .accessibilityIdentifier("generatedOutfitImage")
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading generated outfit...")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveToPhotoLibrary()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .disabled(generatedUIImage == nil || isSaving)
                    .accessibilityIdentifier("saveButton")
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .overlay {
                if isSaving {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView("Saving...")
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
            }
            .alert("Saved", isPresented: $showSaveSuccess) {
                Button("OK") {
                    isPresented = false
                }
            } message: {
                Text("Outfit image saved to Photos")
            }
        }
        .onAppear {
            loadGeneratedImage()
        }
    }

    private func loadGeneratedImage() {
        // Parse base64 string to UIImage
        let cleanBase64: String
        if generatedImageBase64.contains(",") {
            cleanBase64 = generatedImageBase64.components(separatedBy: ",").last ?? ""
        } else {
            cleanBase64 = generatedImageBase64
        }

        if let data = Data(base64Encoded: cleanBase64),
           let uiImage = UIImage(data: data) {
            generatedUIImage = uiImage
            print("Successfully loaded generated outfit image")
        } else {
            print("Failed to parse generated image base64")
        }
    }

    private func saveToPhotoLibrary() {
        guard let imageToSave = generatedUIImage else {
            print("No image to save")
            return
        }

        isSaving = true
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)

        // Simulate brief save delay for UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            showSaveSuccess = true
            print("Saved generated outfit image to Photos")
        }
    }
}
