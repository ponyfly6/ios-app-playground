import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor: Color = .blue
    
    private let availableIcons = [
        "folder", "star", "heart", "bookmark", "tag",
        "briefcase", "house", "person", "cart", "gift",
        "book", "graduationcap", "sportscourt", "gamecontroller",
        "music.note", "camera", "paintbrush", "leaf", "airplane"
    ]
    
    private let availableColors: [Color] = [
        .blue, .purple, .pink, .red, .orange,
        .yellow, .green, .mint, .teal, .cyan, .indigo
    ]
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                nameSection
                iconSection
                colorSection
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // MARK: - Form Sections
    
    private var nameSection: some View {
        Section {
            TextField("Category name", text: $name)
                .font(.headline)
        }
    }
    
    private var iconSection: some View {
        Section("Icon") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(availableIcons, id: \.self) { icon in
                    iconButton(for: icon)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func iconButton(for icon: String) -> some View {
        Button {
            selectedIcon = icon
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
    }
    
    private var colorSection: some View {
        Section("Color") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                ForEach(availableColors, id: \.self) { color in
                    colorButton(for: color)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func colorButton(for color: Color) -> some View {
        Button {
            selectedColor = color
        } label: {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay {
                    if selectedColor == color {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func saveCategory() {
        let category = TaskCategory(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            iconName: selectedIcon,
            color: selectedColor
        )
        
        modelContext.insert(category)
        dismiss()
    }
}

#Preview {
    AddCategoryView()
        .modelContainer(for: TaskCategory.self, inMemory: true)
}
