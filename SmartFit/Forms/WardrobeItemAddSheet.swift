import SwiftUI
import PhotosUI

struct AddItemSheet: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @ObservedObject var controller: WardrobeController

    var body: some View {
        NavigationView {
            Form {
                if let errorMessage = controller.formErrorMessage {
                    Section {
                        Text("Invalid Input. Please try again.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section(header: Text("Photo *")) {
                    if let imageData = controller.formImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                    PhotosPicker(selection: $controller.formSelectedImage, matching: .images) {
                        Label("Select Photo", systemImage: "photo")
                    }
                }

                Section(header: Text("Basic Information (Required)")) {
                    TextField("Name *", text: $controller.formName)
                        .autocapitalization(.words)

                    Picker("Category *", selection: $controller.formCategory) {
                        ForEach(controller.formCategories, id: \.self) { cat in
                            Text(cat.capitalized)
                        }
                    }
                    TextField("Color *", text: $controller.formColor)
                        .autocapitalization(.words)
                }

                Section(header: Text("Size")) {
                    Picker("Size *", selection: $controller.formSize) {
                        ForEach(controller.sizeOptions, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Additional Infomation (Optimal)")) {
                    TextField("Brand", text: $controller.formBrand)
                        .autocapitalization(.words)
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("Price: 0.00", text: $controller.formPrice)
                            .keyboardType(.decimalPad)
                    }
                    TextField("Product URL", text: $controller.formItemUrl)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    TextField("Material", text: $controller.formMaterial)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        controller.resetForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        controller.submitAddItem()
                    }
                    .disabled(
                        controller.formName.isEmpty ||
                        controller.formColor.isEmpty ||
                        controller.formIsLoading
                    )
                }
            }
            .onChange(of: controller.formSelectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        controller.formImageData = data
                    }
                }
            }
        }
    }
}
