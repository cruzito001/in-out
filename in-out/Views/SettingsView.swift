//
//  SettingsView.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 04/09/25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - State Variables
    @State private var selectedCurrency = "MXM"
    @State private var selectedTheme = "Automático"
    @State private var selectedLanguage = "Español"
    @State private var faceIDEnabled = true
    @State private var pinEnabled = false
    @State private var expenseNotifications = true
    @State private var budgetNotifications = true
    @State private var monthlyReports = false
    @State private var monthlyBudget = "1000"
    
    let currencies = ["MXM", "USD", "EUR", "GBP", "JPY"]
    let themes = ["Claro", "Oscuro", "Automático"]
    let languages = ["Español", "English"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGroupedBackground),
                    Color(.secondarySystemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Perfil de Usuario
                    profileSection
                    
                    // Configuración de App
                    appConfigSection
                    
                    // Finanzas
                    financeSection
                    
                    // Seguridad y Privacidad
                    securitySection
                    
                    // Notificaciones
                    notificationsSection
                    
                    // Soporte
                    supportSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Configuración")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            Text("Personaliza tu experiencia")
                .font(.system(.subheadline, design: .default, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Perfil de Usuario", icon: "person.circle.fill")
            
            HStack(spacing: 16) {
                // Foto de perfil placeholder
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Usuario")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text("usuario@email.com")
                        .font(.system(.subheadline, design: .default, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: editProfileAction) {
                    Text("Editar")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - App Configuration Section
    private var appConfigSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Configuración de App", icon: "gear")
            
            VStack(spacing: 12) {
                settingRow("Moneda", icon: "dollarsign.circle.fill", color: .green) {
                    Picker("Moneda", selection: $selectedCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Divider().opacity(0.5)
                
                settingRow("Tema", icon: "paintbrush.fill", color: .purple) {
                    Picker("Tema", selection: $selectedTheme) {
                        ForEach(themes, id: \.self) { theme in
                            Text(theme).tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Divider().opacity(0.5)
                
                settingRow("Idioma", icon: "globe", color: .blue) {
                    Picker("Idioma", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Finance Section
    private var financeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Finanzas", icon: "chart.pie.fill")
            
            VStack(spacing: 12) {
                settingButton("Categorías de Gastos", icon: "tag.fill", color: .orange, action: categoriesAction)
                
                Divider().opacity(0.5)
                
                settingRow("Presupuesto Mensual", icon: "banknote.fill", color: .green) {
                    TextField("$20000", text: $monthlyBudget)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                }
                
                Divider().opacity(0.5)
                
                settingButton("Recordatorios de Pagos", icon: "bell.fill", color: .red, action: remindersAction)
                
                Divider().opacity(0.5)
                
                settingButton("Exportar Datos", icon: "square.and.arrow.up.fill", color: .blue, action: exportDataAction)
            }
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Security Section
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Seguridad y Privacidad", icon: "lock.shield.fill")
            
            VStack(spacing: 12) {
                settingRow("Face ID / Touch ID", icon: "faceid", color: .blue) {
                    Toggle("", isOn: $faceIDEnabled)
                        .labelsHidden()
                }
                
                Divider().opacity(0.5)
                
                settingRow("PIN de Acceso", icon: "number.circle.fill", color: .indigo) {
                    Toggle("", isOn: $pinEnabled)
                        .labelsHidden()
                }
                
                Divider().opacity(0.5)
                
                settingButton("Copia de Seguridad", icon: "icloud.fill", color: .cyan, action: backupAction)
                
                Divider().opacity(0.5)
                
                settingButton("Privacidad de Datos", icon: "hand.raised.fill", color: .gray, action: privacyAction)
            }
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Notificaciones", icon: "bell.fill")
            
            VStack(spacing: 12) {
                settingRow("Recordatorios de Gastos", icon: "exclamationmark.circle.fill", color: .orange) {
                    Toggle("", isOn: $expenseNotifications)
                        .labelsHidden()
                }
                
                Divider().opacity(0.5)
                
                settingRow("Límites de Presupuesto", icon: "chart.line.uptrend.xyaxis.circle.fill", color: .red) {
                    Toggle("", isOn: $budgetNotifications)
                        .labelsHidden()
                }
                
                Divider().opacity(0.5)
                
                settingRow("Reportes Mensuales", icon: "doc.text.fill", color: .blue) {
                    Toggle("", isOn: $monthlyReports)
                        .labelsHidden()
                }
            }
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Soporte", icon: "questionmark.circle.fill")
            
            VStack(spacing: 12) {
                settingButton("Centro de Ayuda", icon: "book.fill", color: .blue, action: helpCenterAction)
                
                Divider().opacity(0.5)
                
                settingButton("Contactar Soporte", icon: "message.fill", color: .green, action: contactSupportAction)
                
                Divider().opacity(0.5)
                
                settingButton("Valorar App", icon: "star.fill", color: .yellow, action: rateAppAction)
                
                Divider().opacity(0.5)
                
                settingButton("Términos y Condiciones", icon: "doc.text.fill", color: .gray, action: termsAction)
            }
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
        }
    }
    
    private func settingRow<Content: View>(_ title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(title)
                .font(.system(.body, design: .default, weight: .medium))
                .foregroundStyle(.primary)
            
            Spacer()
            
            content()
        }
    }
    
    private func settingButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(.body, design: .default, weight: .medium))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    private func editProfileAction() {
        // Implementar edición de perfil
    }
    
    private func categoriesAction() {
        // Implementar gestión de categorías
    }
    
    private func remindersAction() {
        // Implementar recordatorios
    }
    
    private func exportDataAction() {
        // Implementar exportación de datos
    }
    
    private func backupAction() {
        // Implementar copia de seguridad
    }
    
    private func privacyAction() {
        // Implementar configuración de privacidad
    }
    
    private func helpCenterAction() {
        // Implementar centro de ayuda
    }
    
    private func contactSupportAction() {
        // Implementar contacto con soporte
    }
    
    private func rateAppAction() {
        // Implementar valoración de app
    }
    
    private func termsAction() {
        // Implementar términos y condiciones
    }
}

#Preview {
    SettingsView()
}
