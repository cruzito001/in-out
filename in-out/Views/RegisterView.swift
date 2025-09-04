//
//  RegisterView.swift
//  in-out
//
//  Created by Alan Cruz on 24/1/25.
//

import SwiftUI

struct RegisterView: View {
    @Binding var showingRegister: Bool
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
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
                VStack(spacing: 20) {
                    
                    Image("logoApp")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.top, 25)

                    Text("Crear Cuenta")
                        .font(.system(.largeTitle, design: .rounded, weight:
                                .bold))
                        .foregroundStyle(.primary)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    VStack(spacing: 28) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Nombre Completo")
                                .font(.system(.subheadline, design: .default, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            TextField("Ingresa tu nombre completo", text: $fullName)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .default))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                .autocapitalization(.words)
                                .textContentType(.name)
                        }
                        
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
                                .textContentType(.newPassword)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Confirmar Contraseña")
                                .font(.system(.subheadline, design: .default, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            SecureField("Confirma tu contraseña", text: $confirmPassword)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .default))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                .textContentType(.newPassword)
                        }
                    }
                    .padding(.horizontal, 36)
                    
                    Button(action: createAccountAction) {
                        Text("Crear Cuenta")
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
                    .padding(.horizontal, 36)
                    .padding(.top, 10)
                    
                    // Linea separador con un "o"
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
                    .padding(.horizontal, 36)
                    
                    

                    
                    // Enlace para iniciar sesión
                    HStack(spacing: 4) {
                        Text("¿Ya tienes cuenta?")
                            .font(.system(.footnote, design: .default, weight: .regular))
                            .foregroundStyle(.secondary)
                        
                        Button(action: goToLoginAction) {
                            Text("Iniciar Sesión")
                                .font(.system(.footnote, design: .default, weight: .semibold))
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Spacer(minLength: 30)
                }
            }
        }
    }
    
    private func createAccountAction() {
        print("Crear cuenta - Nombre: \(fullName), Email: \(email)")
        // TODO: Implementar lógica de registro
    }
    
    private func goToLoginAction() {
        showingRegister = false
    }
}

#Preview {
    RegisterView(showingRegister: .constant(true))
}
