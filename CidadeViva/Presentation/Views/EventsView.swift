import SwiftUI

struct EventsListView: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredEvents) { event in
                    EventRow(event: event)
                }
            }
            .navigationTitle("Eventos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Todos") {
                            viewModel.selectedCategory = nil
                        }
                        ForEach(Event.Category.allCases, id: \.self) { category in
                            Button {
                                viewModel.selectedCategory = category
                            } label: {
                                Label(category.rawValue, systemImage: category.iconName)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.loadEvents()
            }
            .overlay {
                if viewModel.isLoading && viewModel.events.isEmpty {
                    LoadingView()
                }
            }
        }
        .task {
            await viewModel.loadEvents()
        }
    }
}

struct EventRow: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: event.category.iconName)
                    .foregroundStyle(AppConfiguration.primaryBlue)

                Text(event.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if event.isFree {
                    Text("Gratuito")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                } else if let price = event.price {
                    Text("R$ \(String(format: "%.2f", price))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(event.title)
                .font(.headline)

            Text(event.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Label {
                    Text(event.startDate, style: .date)
                } icon: {
                    Image(systemName: "calendar")
                }
                Label {
                    Text(event.startDate, style: .time)
                } icon: {
                    Image(systemName: "clock")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let address = event.location.address {
                Label(address, systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    EventsListView()
}
