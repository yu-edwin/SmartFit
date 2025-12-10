import SwiftUI
import PhotosUI

struct WardrobeView: View {
    @ObservedObject var controller: WardrobeController
    @State private var showAddOptions = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]
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
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 0) {
                            ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(controller.categories, id: \.self) { category in
                                    Button(category.capitalized) {
                                        controller.selectedCategory = category
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        controller.selectedCategory == category
                                            ? Color.blue
                                            : Color.gray.opacity(0.8)
                                    )
                                    .foregroundColor(
                                        controller.selectedCategory == category
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
                                    showAddOptions = true
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .frame(maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: gridColumns, spacing: 16) {  // 16 = vertical gap
                                    ForEach(controller.filteredItems) { item in
                                        ItemCard(item: item, controller: controller)
                                    }
                                }
                                .padding(.horizontal, 8)  // side padding, optional
                            }
                        }
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
            }
            .overlay(alignment: .bottomTrailing) {
                ZStack(alignment: .bottomTrailing) {
                    // Background overlay when menu is open
                    if showAddOptions {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    showAddOptions = false
                                }
                            }
                    }
                    VStack(alignment: .trailing, spacing: 16) {
                        // Menu items (shown when expanded)
                        if showAddOptions {
                            // Manual Entry button
                            HStack(spacing: 12) {
                                Text("Manual Entry")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        showAddOptions = false
                                    }
                                    controller.showAddSheet = true
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                            }
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            // Import from URL button
                            HStack(spacing: 12) {
                                Text("Import from URL")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        showAddOptions = false
                                    }
                                    controller.showUrlImportSheet = true
                                } label: {
                                    Image(systemName: "link")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color.cyan)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                            }
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        // Main "+" button
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showAddOptions.toggle()
                            }
                        } label: {
                            Image(systemName: showAddOptions ? "xmark" : "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(showAddOptions ? Color.red : Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                                .rotationEffect(.degrees(showAddOptions ? 45 : 0))
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 60)
                }
            }
            // URL import sheet
            .sheet(isPresented: $controller.showUrlImportSheet) {
                UrlImportSheet(controller: controller)
            }
            .navigationTitle("Wardrobe")
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
                                .fill(Color(UIColor.systemBackground))
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
                            .background(Color(UIColor.systemBackground).opacity(0.9))
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
                            .background(Color(UIColor.systemBackground).opacity(0.9))
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
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    HStack {
                        if let brand = item.brand, !brand.isEmpty {
                            Text("\(brand.uppercased())")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Brand: ---")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Button {
                            controller.deleteItem(item)
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .padding(6)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)

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
        .background(Color(UIColor.secondarySystemBackground))   // <– card background
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
        )
        .onTapGesture {
            controller.equipItem(itemId: item.id, category: item.category)
        }
    }
}

#Preview {
    WardrobeView(controller: WardrobeController())
}
