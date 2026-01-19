//
//  EventsView.swift
//  CidadeViva
//
//  Tela de eventos da cidade
//

import SwiftUI

struct EventsView: View {

    // MARK: - Properties

    @StateObject private var viewModel = EventsViewModel()
    @State private var selectedEvent: Event?
    @State private var showFilters = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Eventos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
            .sheet(isPresented: $showFilters) {
                EventFiltersView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear

        case .loading:
            ProgressView("Carregando eventos...")

        case .success:
            if viewModel.filteredEvents.isEmpty {
                emptyState
            } else {
                eventsList
            }

        case .failure(let error):
            ErrorView(
                message: error.localizedDescription,
                retryAction: {
                    Task {
                        await viewModel.loadData()
                    }
                }
            )
        }
    }

    private var eventsList: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Featured Events
                if !viewModel.featuredEvents.isEmpty && viewModel.searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Em Destaque")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.featuredEvents) { event in
                                    FeaturedEventCard(event: event)
                                        .onTapGesture {
                                            selectedEvent = event
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Search Bar
                SearchBar(text: $viewModel.searchText, placeholder: "Buscar eventos...")
                    .padding(.horizontal)

                // Category Filter
                if viewModel.searchText.isEmpty {
                    CategoryFilterView(
                        selectedCategory: $viewModel.selectedCategory,
                        onCategorySelected: { category in
                            viewModel.selectCategory(category)
                        }
                    )
                }

                // Events List
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredEvents) { event in
                        EventCard(event: event)
                            .onTapGesture {
                                selectedEvent = event
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Nenhum evento encontrado")
                .font(.headline)

            Text("Tente ajustar os filtros de busca")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty {
                Button("Limpar Filtros") {
                    viewModel.clearFilters()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

// MARK: - Featured Event Card

struct FeaturedEventCard: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            if let imageURL = event.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 280, height: 160)
                .clipped()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(event.startDateFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Label(event.location, systemImage: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)

                    Spacer()

                    Text(event.category.emoji)
                        .font(.title3)
                }
            }
            .padding(12)
        }
        .frame(width: 280)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: Event

    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            VStack {
                Text(event.category.emoji)
                    .font(.system(size: 32))
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                if event.isFeatured {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)

                Label(event.startDateFormatted, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Label(event.location, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(1)

                if let price = event.priceFormatted {
                    Text(price)
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Category Filter View

struct CategoryFilterView: View {
    @Binding var selectedCategory: EventCategory?
    let onCategorySelected: (EventCategory?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "Todos",
                    emoji: "📋",
                    isSelected: selectedCategory == nil,
                    action: {
                        onCategorySelected(nil)
                    }
                )

                ForEach(EventCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.description,
                        emoji: category.emoji,
                        isSelected: selectedCategory == category,
                        action: {
                            onCategorySelected(category)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.body)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Event Filters View

struct EventFiltersView: View {
    @ObservedObject var viewModel: EventsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Filtros") {
                    Toggle("Apenas em Destaque", isOn: Binding(
                        get: { viewModel.showFeaturedOnly },
                        set: { _ in viewModel.toggleFeatured() }
                    ))

                    Toggle("Apenas Futuros", isOn: Binding(
                        get: { viewModel.showUpcomingOnly },
                        set: { _ in viewModel.toggleUpcoming() }
                    ))
                }

                Section {
                    Button("Limpar Todos os Filtros") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Event Detail View

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image
                    if let imageURL = event.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(height: 250)
                        .clipped()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Category
                        HStack {
                            Text(event.category.emoji)
                                .font(.largeTitle)

                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(event.category.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Date and Time
                        InfoRow(icon: "calendar", title: "Data", value: event.startDateFormatted)

                        if let endDate = event.endDate {
                            InfoRow(icon: "calendar.badge.clock", title: "Até", value: event.dateFormatter.string(from: endDate))
                        }

                        if event.isAllDay {
                            InfoRow(icon: "clock", title: "Horário", value: "Dia todo")
                        }

                        // Location
                        InfoRow(icon: "mappin.circle.fill", title: "Local", value: event.location)

                        // Price
                        if let price = event.priceFormatted {
                            InfoRow(icon: "ticket.fill", title: "Ingresso", value: price)
                        }

                        // Organizer
                        if let organizer = event.organizer {
                            InfoRow(icon: "person.fill", title: "Organizador", value: organizer)
                        }

                        Divider()

                        // Description
                        Text("Sobre o Evento")
                            .font(.headline)

                        Text(event.description)
                            .font(.body)

                        // Contact
                        if event.contactEmail != nil || event.contactPhone != nil {
                            Divider()

                            Text("Contato")
                                .font(.headline)

                            if let email = event.contactEmail {
                                Button {
                                    if let url = URL(string: "mailto:\(email)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Label(email, systemImage: "envelope.fill")
                                }
                            }

                            if let phone = event.contactPhone {
                                Button {
                                    if let url = URL(string: "tel:\(phone)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Label(phone, systemImage: "phone.fill")
                                }
                            }
                        }

                        // Ticket Link
                        if let ticketURL = event.ticketURL, let url = URL(string: ticketURL) {
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                HStack {
                                    Spacer()
                                    Label("Comprar Ingresso", systemImage: "ticket.fill")
                                        .font(.headline)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}

// MARK: - Preview

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
