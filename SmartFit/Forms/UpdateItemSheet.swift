import SwiftUI
import PhotosUI

struct UpdateItemSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var controller: WardrobeController

    var body: some View {
        NavigationView {
            Form {
                if let errorMessage = controller.formErrorMessage {
                    Section {
                        Text("Could not update items with info provided. Please try again.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                // Update Image section
                Section(header: Text("Photo")) {
                    if let data = controller.editImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    } else if let item = controller.editingItem,
                            let imageString = item.image_data,
                            let base64 = imageString.components(separatedBy: ",").last,
                            let data = Data(base64Encoded: base64),
                            let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    } else {
                        Text("No image")
                            .foregroundColor(.secondary)
                    }

                    PhotosPicker(selection: $controller.editSelectedImage,
                                 matching: .images) {
                        Label("Change Photo", systemImage: "photo")
                    }
                }
                // Basic info section
                Section(header: Text("Basic Info")) {
                    HStack {
                        Text("Name: ")
                            .foregroundColor(.secondary)
                        TextField(" ", text: $controller.editName)
                    }
                    HStack {
                        Text("Brand: ")
                            .foregroundColor(.secondary)
                        TextField(" ", text: $controller.editBrand)
                    }
                    HStack {
                        Text("Color: ")
                            .foregroundColor(.secondary)
                        TextField(" ", text: $controller.editColor)
                    }
                    HStack {
                        Text("Material: ")
                            .foregroundColor(.secondary)
                        TextField(" ", text: $controller.editMaterial)
                    }
                    HStack {
                        Text("Price: $")
                            .foregroundColor(.secondary)
                        TextField("Price: 0.00", text: $controller.editPrice)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Picker("Category", selection: $controller.editCategory) {
                            ForEach(controller.formCategories, id: \.self) { category in
                                Text(category.capitalized).tag(category)
                            }
                        }
                    }
                }
                // Size section
                Section(header: Text("Size")) {
                    Picker("Size", selection: $controller.editSize) {
                        ForEach(controller.sizeOptions, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                // Optional Section
                Section(header: Text("Optional")) {
                    TextField("Product URL", text: $controller.editItemUrl)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        controller.submitEdit()
                    }
                }
            }
            // This is what actually sets editImageData
            .onChange(of: controller.editSelectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        controller.editImageData = data
                    }
                }
            }
        }
    }
}
