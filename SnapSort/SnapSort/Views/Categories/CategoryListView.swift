import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Query private var screenshots: [ScreenshotItem]
    @State private var selectedCategory: ScreenshotCategory?

    private var categoryCounts: [ScreenshotCategory: Int] {
        Dictionary(grouping: screenshots, by: { $0.category })
            .mapValues { $0.count }
    }

    private var temporaryCount: Int {
        screenshots.filter { $0.isTemporary }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if temporaryCount > 0 {
                        temporaryBanner
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(ScreenshotCategory.allCases, id: \.self) { category in
                            CategoryCard(
                                category: category,
                                count: categoryCounts[category] ?? 0
                            )
                            .onTapGesture {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Categories")
            .sheet(item: $selectedCategory) { category in
                CategoryDetailView(category: category)
            }
        }
    }

    private var temporaryBanner: some View {
        NavigationLink {
            CleanupView()
        } label: {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("\(temporaryCount) temporary screenshots need cleanup")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

struct CategoryCard: View {
    let category: ScreenshotCategory
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.color)?.opacity(0.15) ?? Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(Color(hex: category.color) ?? .blue)
            }

            Text(category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(count)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
