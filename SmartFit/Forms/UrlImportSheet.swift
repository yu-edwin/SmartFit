import SwiftUI

struct UrlImportSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var controller: WardrobeController

    var body: some View {
        NavigationView {
            Form {
                if let error = controller.urlImportError {
                    Section {
                        Text("Please try a different link")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Section(header: Text("Product URL")) {
                    TextField("Paste URL here", text: $controller.urlToImport)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }

                Section(header: Text("Size")) {
                    Picker("Size", selection: $controller.urlImportSize) {
                        ForEach(controller.sizeOptions, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Import from URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        controller.urlToImport = ""
                        controller.urlImportError = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        controller.importFromUrl()
                    }
                    .disabled(controller.isImportingUrl || controller.urlToImport.isEmpty)
                }
            }
        }
    }
}
