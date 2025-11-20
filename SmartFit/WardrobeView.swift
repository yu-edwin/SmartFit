import SwiftUI
import PhotosUI

struct WardrobeView: View {
    @StateObject private var controller = WardrobeController()

    var body: some View {
        NavigationView {
            ZStack {
                if controller.isLoading {
                    // Loading screen
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        Text("Loading your wardrobe...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(controller.categories, id: \.self) { category in
                                    Button(category.capitalized) {
                                        controller.selectedCategory = category
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(controller.selectedCategory == category
                                        ? Color.blue
                                        : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(controller.selectedCategory == category
                                        ? .white
                                        : .black
                                    )
                                    .cornerRadius(20)
                                }
                            }
                            .padding()
                        }

                        if controller.filteredItems.isEmpty {
                            VStack {
                                Image(systemName: "hanger")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No items yet")
                                    .font(.headline)
                                    .padding()
                                Button("Add Item") {
                                    controller.showAddSheet = true
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .frame(maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(controller.filteredItems) { item in
                                        ItemCard(item: item, controller: controller)
                                    }
                                }
                                .padding()
                                .padding(.bottom, 70)
                            }
                        }

                        Spacer(minLength: 0)

                        // Add button above picker
                        HStack {
                            Spacer()
                            Button {
                                controller.showAddSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                        // Outfit selector bar at bottom
                        VStack(spacing: 0) {
                            Divider()
                            Picker("Select Outfit", selection: $controller.selectedOutfit) {
                                ForEach(1...3, id: \.self) { outfitNumber in
                                    Text("Outfit \(outfitNumber)").tag(outfitNumber)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.systemBackground))
                        }
                    }
                }
            }
            .navigationTitle("Wardrobe")
            .overlay(alignment: .bottomTrailing) {
                Button {
                    controller.showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .padding(20)
            }
            // Displays Add item to wardrobe sheet (POST Request)
            .sheet(isPresented: $controller.showAddSheet) {
                AddItemSheet(controller: controller)
            }
            // Displays Update existing clothing item sheet (PUT Request)
            .sheet(isPresented: $controller.showEditSheet) {
                UpdateItemSheet(controller: controller)
            }
            // Displays wardrobeItem info card
            .sheet(isPresented: $controller.showInfoSheet) {
                if let item = controller.infoItem {
                    ItemInfoSheet(item: item)
                }
            }
            .task {
                controller.loadItems()
            }
        }
    }
}

struct ItemCard: View {
    let item: WardrobeItem
    @ObservedObject var controller: WardrobeController

    var isEquipped: Bool {
        controller.currentEquippedOutfit[item.category] == item.id
    }

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if let imageData = item.image_data,
                   let base64 = imageData.components(separatedBy: ",").last,
                   let data = Data(base64Encoded: base64),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 160)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 160)
                        .aspectRatio(1, contentMode: .fill)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "tshirt")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }

                if isEquipped {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                        )
                        .padding(8)
                }
            }
            .overlay(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    // Info button (top)
                    Button {
                        controller.showInfo(for: item)
                        print("Info tapped for \(item.name)")
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14, weight: .bold))
                            .padding(6)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .buttonStyle(.plain)

                    // Edit button (below)
                    Button {
                        controller.startEditing(item)
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .bold))
                            .padding(6)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .buttonStyle(.plain)
                }
                .padding(8)
            }

            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .center) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }

                    HStack {
                        if let brand = item.brand, !brand.isEmpty {
                            Text("\(brand.uppercased()) •")
                                .font(.caption2)
                                .foregroundColor(.black)
                        } else {
                            Text("Brand: --- •")
                                .font(.caption2)
                                .foregroundColor(.black)
                        }
                        if let size = item.size, !size.isEmpty {
                            Text("Size: \(size.uppercased())")
                                .font(.caption2)
                                .foregroundColor(.black)
                        } else {
                            Text("Size: --")
                                .font(.caption2)
                                .foregroundColor(.black)
                        }
                    }

                    HStack {
                        if let color = item.color, !color.isEmpty {
                            Text("\(color.capitalized) •")
                                .font(.caption2)
                                .foregroundColor(.black)
                        } else {
                            Text("Color: -- •")
                                .font(.caption2)
                                .foregroundColor(.black)
                        }
                        if let material = item.material, !material.isEmpty {
                            Text("\(material.capitalized)")
                                .font(.caption2)
                                .foregroundColor(.black)
                        } else {
                            Text("Material: --")
                                .font(.caption2)
                                .foregroundColor(.black)
                        }
                    }

                    HStack {
                        Spacer()
                        if let price = item.price, price > 0 {
                            Text("$\(String(format: "%.2f", price))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        } else {
                            Text("Price: ---")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding(8)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
        // .border(Color.gray)
        // .cornerRadius(5)
        // .shadow(radius: 2)
        .onTapGesture {
            controller.equipItem(itemId: item.id, category: item.category)
        }
    }
}

struct AddItemSheet: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @ObservedObject var controller: WardrobeController

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photo *")) {
                    if let imageData = controller.formImageData, let uiImage = UIImage(data: imageData) {
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

                Section(header: Text("Basic Information")) {
                    TextField("Name *", text: $controller.formName)
                        .autocapitalization(.words)

                    Picker("Category *", selection: $controller.formCategory) {
                        ForEach(controller.formCategories, id: \.self) { cat in
                            Text(cat.capitalized)
                        }
                    }

                    TextField("Brand (optional)", text: $controller.formBrand)
                        .autocapitalization(.words)
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

                Section(header: Text("Price (Optional)")) {
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $controller.formPrice)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Additional Information (Optional)")) {
                    TextField("Product URL", text: $controller.formItemUrl)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    TextField("Material", text: $controller.formMaterial)
                        .autocapitalization(.words)
                }

                if let errorMessage = controller.formErrorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Text("* Required fields")
                        .font(.caption)
                        .foregroundColor(.gray)
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
                    .disabled(controller.formName.isEmpty ||
                             controller.formColor.isEmpty ||
                             controller.formIsLoading)
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

#Preview {
    WardrobeView()
}
