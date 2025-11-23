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

    var equippedItems: [WardrobeItem] {
        guard let outfit = wardrobeController.outfits[selectedOutfit] else { return [] }
        return outfit.compactMap { category, itemId in
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
                        // Placeholder button - functionality to be implemented later
                        print("Generate button tapped with outfit \(selectedOutfit)")
                    }
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("generateButton")
                }
            }
        }
    }
}
