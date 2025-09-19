//
//  LoginView.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 29/08/25.
//

import SwiftUI

struct LoginView: View {
    @Binding var showingRegister: Bool
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isAuthenticating = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @StateObject private var authManager = AuthenticationManager()
    
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
            
            VStack(spacing: 20) {
                Spacer()
                
                Image("logoApp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                Text("Iniciar Sesión")
                    .font(.system(.largeTitle, design: .rounded, weight:
                            .bold))
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email")
                            .font(.system(.subheadline, design: .default, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        TextField("Ingresa tu email", text: $email)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .default))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Contraseña")
                            .font(.system(.subheadline, design: .default, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        SecureField("Ingresa tu contraseña", text: $password)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .default))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .textContentType(.password)
                    }
                    
                    Button(action: loginAction) {
                        Text("Iniciar Sesión")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    }
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    // "¿Olvidaste tu contraseña?
                    VStack {
                        Button(action: forgotPasswordAction) {
                            Text("¿Olvidaste tu contraseña?")
                                .font(.system(.footnote, design: .default, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, -15)
                    }
                    
                    // Nuevo Usuario
                    HStack(spacing: 4) {
                        Text("¿No tienes cuenta?")
                            .font(.system(.footnote, design: .default, weight: .regular))
                            .foregroundStyle(.secondary)
                        
                        Button(action: signUpAction) {
                            Text("Registrarse")
                                .font(.system(.footnote, design: .default, weight: .semibold))
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    // Línea coqueta separador
                    HStack {
                        Rectangle()
                            .fill(.quaternary)
                            .frame(height: 1)
                        
                        Text("o")
                            .font(.system(.caption, design: .default, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(.quaternary)
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Botón FaceID
                    Button(action: { BiometricAuthenticationHelper.performBiometricAuthentication(authManager: authManager, isAuthenticating: $isAuthenticating, showAlert: showAlert) }) {
                        HStack(spacing: 12) {
                            if isAuthenticating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.primary)
                            } else {
                                Image(systemName: BiometricAuthenticationHelper.getBiometricIcon(for: authManager))
                                    .font(.system(.title2, design: .default, weight: .medium))
                                    .foregroundStyle(.primary)
                            }
                            
                            Text(isAuthenticating ? "Autenticando..." : BiometricAuthenticationHelper.getBiometricButtonText(for: authManager))
                                .font(.system(.headline, design: .rounded, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                    }
                    .background(
                        .thinMaterial,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .disabled(isAuthenticating || !authManager.isBiometricAuthenticationAvailable())
                }
                .padding(.horizontal, 36)
                
                Spacer()
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loginAction() {
        // Simulación de autenticación exitosa
        // En una app real, aquí validarías las credenciales
        withAnimation(.easeInOut(duration: 0.5)) {
            isLoggedIn = true
        }
    }
    
    private func forgotPasswordAction() {
        // Aquí se implementará la lógica para recuperar contraseña
    }
    
    private func signUpAction() {
        showingRegister = true
    }
    

    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
}

#Preview {
    LoginView(showingRegister: .constant(false), isLoggedIn: .constant(false))
}
