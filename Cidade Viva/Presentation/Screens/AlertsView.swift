//
//  AlertsView.swift
//  CidadeViva
//
//  Tela de alertas REDESENHADA - Premium & Futurista
//

import SwiftUI

struct AlertsView: View {

    @ObservedObject var viewModel: AlertsViewModel
    @State private var showFilterSheet = false

    var body: some View {
        ZStack {
            // Fundo premium
            Color.backgroundDark
                .ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingViewPremium(message: "Carregando alertas...")

            case .success:
                alertsContent

            case .error(let error):
                ErrorViewPremium(error: error) {
                    Task {
                        await viewModel.loadAlerts()
                    }
                }
            }
        }
        .navigationTitle("Alertas")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilterSheet = true }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundStyle(LinearGradient.primary)
                    }
                }
                .bouncePress()
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheetPremium
        }
        .task {
            if case .idle = viewModel.loadingState {
                await viewModel.loadAlerts()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Alerts Content

    private var alertsContent: some View {
        VStack(spacing: 0) {
            // Stats premium
            statsBarPremium
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.vertical, Spacing.lg)

            // Lista de alertas
            if viewModel.filteredAlerts.isEmpty {
                emptyStatePremium
            } else {
                alertsListPremium
            }
        }
    }

    // MARK: - Stats Bar Premium

    private var statsBarPremium: some View {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.md) {
                // Ativos
                StatPillView(
                    icon: "checkmark.circle.fill",
                    value: viewModel.activeAlertsCount,
                    label: "Ativos",
                    color: .successNeon
                )
                
                // Críticos
                StatPillView(
                    icon: "exclamationmark.triangle.fill",
                    value: viewModel.criticalAlertsCount,
                    label: "Críticos",
                    color: .errorVibrant
                )
            }
            
            // Toggle apenas ativos
            Toggle(isOn: Binding(
                get: { viewModel.showActiveOnly },
                set: { _ in viewModel.toggleShowActiveOnly() }
            )) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: viewModel.showActiveOnly ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(viewModel.showActiveOnly ? LinearGradient.primary : LinearGradient(colors: [Color.textSecondary], startPoint: .leading, endPoint: .trailing))
                    
                    Text("Mostrar Apenas Ativos")
                        .font(.bodyCustom)
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.primaryStart))
            .padding(Spacing.lg)
            .glassCard(padding: 0)
        }
    }

    // MARK: - Alerts List Premium

    private var alertsListPremium: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.cardSpacing) {
                ForEach(Array(viewModel.filteredAlerts.enumerated()), id: \.element.id) { index, alert in
                    AlertCardPremium(alert: alert)
                        .staggeredAppearance(index: index)
                }
            }
            .padding(Spacing.screenPadding)
            .tabBarSafeAreaPadding()
        }
    }

    // MARK: - Empty State Premium

    private var emptyStatePremium: some View {
        VStack(spacing: Spacing.xxxl) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.successNeon.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.successNeon, Color.forestStart],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .glow(color: Color.successNeon, radius: 20)
            }
            .pulsing()

            VStack(spacing: Spacing.md) {
                Text("Nenhum alerta no momento")
                    .font(.title1Custom)
                    .foregroundStyle(Color.textPrimary)

                Text("Tudo tranquilo por aqui! 🎉")
                    .font(.title3Custom)
                    .foregroundStyle(Color.textSecondary)

                if viewModel.selectedType != nil || viewModel.selectedSeverity != nil {
                    Button(action: {
                        viewModel.clearFilters()
                    }) {
                        Text("Limpar Filtros")
                            .font(.bodyCustom)
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.md)
                            .background(
                                Capsule()
                                    .fill(LinearGradient.primary)
                            )
                    }
                    .bouncePress()
                    .padding(.top, Spacing.lg)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.screenPadding)
    }

    // MARK: - Filter Sheet Premium

    private var filterSheetPremium: some View {
        NavigationStack {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Tipo de alerta
                        filterSection(title: "Tipo de Alerta", icon: "tag.fill") {
                            FilterPillGroup(
                                options: ["Todos", "Trânsito", "Clima", "Segurança", "Infraestrutura", "Evento", "Emergência"],
                                selectedIndex: Binding(
                                    get: {
                                        if viewModel.selectedType == nil { return 0 }
                                        if viewModel.selectedType == .traffic { return 1 }
                                        if viewModel.selectedType == .weather { return 2 }
                                        if viewModel.selectedType == .security { return 3 }
                                        if viewModel.selectedType == .infrastructure { return 4 }
                                        if viewModel.selectedType == .event { return 5 }
                                        return 6
                                    },
                                    set: {
                                        switch $0 {
                                        case 0: viewModel.selectType(nil)
                                        case 1: viewModel.selectType(.traffic)
                                        case 2: viewModel.selectType(.weather)
                                        case 3: viewModel.selectType(.security)
                                        case 4: viewModel.selectType(.infrastructure)
                                        case 5: viewModel.selectType(.event)
                                        default: viewModel.selectType(.emergency)
                                        }
                                    }
                                )
                            )
                        }
                        
                        // Severidade
                        filterSection(title: "Severidade", icon: "exclamationmark.triangle.fill") {
                            FilterPillGroup(
                                options: ["Todas", "Baixa", "Média", "Alta", "Crítica"],
                                selectedIndex: Binding(
                                    get: {
                                        if viewModel.selectedSeverity == nil { return 0 }
                                        if viewModel.selectedSeverity == .low { return 1 }
                                        if viewModel.selectedSeverity == .medium { return 2 }
                                        if viewModel.selectedSeverity == .high { return 3 }
                                        return 4
                                    },
                                    set: {
                                        switch $0 {
                                        case 0: viewModel.selectSeverity(nil)
                                        case 1: viewModel.selectSeverity(.low)
                                        case 2: viewModel.selectSeverity(.medium)
                                        case 3: viewModel.selectSeverity(.high)
                                        default: viewModel.selectSeverity(.critical)
                                        }
                                    }
                                )
                            )
                        }
                        
                        // Botão limpar
                        Button(action: {
                            viewModel.clearFilters()
                            showFilterSheet = false
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Limpar Todos os Filtros")
                            }
                            .font(.title3Custom)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: Spacing.cardRadius)
                                    .fill(LinearGradient.fire)
                            )
                        }
                        .bouncePress()
                    }
                    .padding(Spacing.screenPadding)
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluído") {
                        showFilterSheet = false
                    }
                    .foregroundStyle(LinearGradient.primary)
                }
            }
        }
    }
    
    private func filterSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Label(title, systemImage: icon)
                .font(.title3Custom)
                .foregroundStyle(Color.textPrimary)
            
            content()
        }
        .padding(Spacing.xl)
        .glassCard(padding: 0)
    }
}

#Preview {
    NavigationStack {
        AlertsView(viewModel: AlertsViewModel())
            .preferredColorScheme(.dark)
    }
}
