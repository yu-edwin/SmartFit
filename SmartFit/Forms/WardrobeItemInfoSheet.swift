import SwiftUI

struct ItemInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    let item: WardrobeItem

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Image on top
                    if let imageString = item.image_data,
                       let base64 = imageString.components(separatedBy: ",").last,
                       let data = Data(base64Encoded: base64),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 260)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "tshirt")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                            .padding(.horizontal)
                    }

                    // Info card
                    VStack(alignment: .leading, spacing: 10) {
                        // Title centered
                        Text(item.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 4)

                        Divider()

                        infoRow(label: "Brand", value: item.brand)
                        infoRow(label: "Category", value: item.category.capitalized)
                        infoRow(label: "Size", value: item.size?.uppercased())
                        infoRow(label: "Color", value: item.color?.capitalized)
                        infoRow(label: "Material", value: item.material?.capitalized)

                        if let price = item.price, price > 0 {
                            HStack {
                                Text("Price")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("$\(String(format: "%.2f", price))")
                            }
                        }

                        if let urlString = item.item_url,
                           !urlString.isEmpty,
                           let url = URL(string: urlString) {
                            Divider().padding(.vertical, 4)
                            Link("View Product", destination: url)
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 4, y: 2)
                    )
                    .padding(.horizontal, 16)

                    Spacer(minLength: 20)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func infoRow(label: String, value: String?) -> some View {
        if let value, !value.isEmpty {
            HStack {
                Text(label)
                    .fontWeight(.semibold)
                Spacer()
                Text(value)
            }
        }
    }
}
