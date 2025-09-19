//
//  BiometricAuthenticationHelper.swift
//  in-out
//
//  Created by Alan Cruz on 24/1/25.
//

import SwiftUI
import Foundation

class BiometricAuthenticationHelper {
    
    // MARK: - Static Methods
    
    /// Obtiene el ícono correspondiente al tipo de biometría disponible
    static func getBiometricIcon(for authManager: AuthenticationManager) -> String {
        switch authManager.getBiometricType() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.fill"
        }
    }
    
    /// Obtiene el texto del botón correspondiente al tipo de biometría disponible
    static func getBiometricButtonText(for authManager: AuthenticationManager) -> String {
        switch authManager.getBiometricType() {
        case .faceID:
            return "Iniciar con Face ID"
        case .touchID:
            return "Iniciar con Touch ID"
        case .none:
            return "Biometría no disponible"
        }
    }
    
    /// Ejecuta la acción de autenticación biométrica
    static func performBiometricAuthentication(
        authManager: AuthenticationManager,
        isAuthenticating: Binding<Bool>,
        onSuccess: @escaping () -> Void,
        showAlert: @escaping (String, String) -> Void
    ) {
        guard authManager.isBiometricAuthenticationAvailable() else {
            showAlert("Biometría no disponible", "La autenticación biométrica no está disponible en este dispositivo.")
            return
        }
        
        isAuthenticating.wrappedValue = true
        
        Task {
            let result = await authManager.authenticateWithBiometrics()
            
            await MainActor.run {
                isAuthenticating.wrappedValue = false
                
                switch result {
                case .success(let success):
                    if success {
                        // Autenticación exitosa
                        onSuccess()
                    }
                case .failure(let error):
                    showAlert("Error de autenticación", error.localizedDescription)
                }
            }
        }
    }
}