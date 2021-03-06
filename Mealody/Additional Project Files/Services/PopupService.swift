//
//  PopupService.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 18..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit
import PopupDialog

class PopupService {
    
    // MARK: - Error Setup Methods
    
    // we create a popup, set up it's appearance, add it's button the given completion then return
    /// - Parameters:
    ///   - message: popup's message
    ///   - completion: closure to run after hitting "OK"
    static func emptyStateError(withMessage message: String, completion: (() -> Void)?) -> PopupDialog {
        let popup = PopupDialog(title: "Error", message: message, tapGestureDismissal: false, panGestureDismissal: false)
        
        setupPopupAppearance()
        
        let okButton = DefaultButton(title: "OK") {
            completion?()
        }
        
        popup.addButton(okButton)
        
        return popup
    }
    
    // we create a popup, set up it's appearance, add it's button the given completion then return
    /// - Parameters:
    ///   - message: popup's message
    ///   - completion: closure to run after hitting "OK"
    static func parseError(withMessage message: String, completion: (() -> Void)?) -> PopupDialog {
        let popup = PopupDialog(title: "Error", message: message, tapGestureDismissal: false, panGestureDismissal: false)
        
        setupPopupAppearance()
        
        let okButton = DefaultButton(title: "OK") {
            completion?()
        }
        
        popup.addButton(okButton)
        
        return popup
    }
    
    // we create a popup, set up it's appearance, add it's button the given completion then return
    /// - Parameters:
    ///   - message: popup's message
    ///   - completion: closure to run after hitting "OK"
    static func networkError(withMessage message: String, completion: (() -> Void)?) -> PopupDialog {
        let popup = PopupDialog(title: "Network Error", message: message, tapGestureDismissal: false, panGestureDismissal: false)
        
        setupPopupAppearance()
        
        let okButton = DefaultButton(title: "OK") {
            completion?()
        }
        
        popup.addButton(okButton)
        
        return popup
    }
    
    // we create a popup, set up it's appearance, add it's button the given completion then return
    /// - Parameters:
    ///   - message: popup's message
    ///   - completion: closure to run after hitting "OK"
    static func requestError(withMessage message: String, completion: (() -> Void)?) -> PopupDialog {
        let popup = PopupDialog(title: "Request Error", message: message, tapGestureDismissal: false, panGestureDismissal: false)
        
        setupPopupAppearance()
        
        let okButton = DefaultButton(title: "OK") {
            completion?()
        }
        
        popup.addButton(okButton)
        
        return popup
    }
    
    // we create a popup, set up it's appearance, add it's button the given completion then return
    /// - Parameters:
    ///   - message: popup's message
    ///   - completion: closure to run after hitting "OK"
    static func compressingError(withMessage message: String, completion: (() -> Void)?) -> PopupDialog {
        let popup = PopupDialog(title: "Error", message: message, tapGestureDismissal: false, panGestureDismissal: false)
        
        setupPopupAppearance()
        
        let okButton = DefaultButton(title: "OK") {
            completion?()
        }
        
        popup.addButton(okButton)
        
        return popup
    }
    
    // we create a popup, set up it's appearance, add it's button the given completion then return
    /// - Parameters:
    ///   - message: popup's message
    ///   - completion: closure to run after hitting "OK"
    static func persistenceError(withMessage message: String, completion: (() -> Void)?) -> PopupDialog {
        let popup = PopupDialog(title: "Error", message: message, tapGestureDismissal: false, panGestureDismissal: false)
        
        setupPopupAppearance()
        
        let okButton = DefaultButton(title: "OK") {
            completion?()
        }
        
        popup.addButton(okButton)
        
        return popup
    }
    
    // we create a popup, set up it's appearance, add it's button the given completion then return
    /// - Parameters:
    ///   - message: popup's message
    ///   - completion: closure to run after hitting "OK"
    static func ingredientsError(withMessage message: String, completion: (() -> Void)?) -> PopupDialog {
        let popup = PopupDialog(title: nil, message: message, tapGestureDismissal: false, panGestureDismissal: false)
        
        setupPopupAppearance()
        
        let okButton = DefaultButton(title: "OK") {
            completion?()
        }
        
        popup.addButton(okButton)
        
        return popup
    }
    
    // we create a popup, set up it's appearance, add it's button the given completion then return
    /// - Parameters:
    ///   - message: popup's message
    ///   - completion: closure to run after hitting "OK"
    static func presentationError(withMessage message: String, completion: (() -> Void)?) -> PopupDialog {
        let popup = PopupDialog(title: "Error", message: message, tapGestureDismissal: false, panGestureDismissal: false)
        
        setupPopupAppearance()
        
        let okButton = DefaultButton(title: "OK") {
            completion?()
        }
        
        popup.addButton(okButton)
        
        return popup
    }
    
    // we set up the popup's appearance
    private static func setupPopupAppearance() {
        let defaultView = PopupDialogDefaultView.appearance()
        defaultView.titleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        defaultView.titleColor = .systemRed
        defaultView.messageFont = UIFont.systemFont(ofSize: 16)
        defaultView.messageColor = .label
        
        let containerView = PopupDialogContainerView.appearance()
        containerView.backgroundColor = .secondarySystemGroupedBackground
        containerView.cornerRadius = 12
        containerView.shadowEnabled = true
        containerView.shadowColor = .black
        
        let overlayView = PopupDialogOverlayView.appearance()
        overlayView.blurEnabled = true
        overlayView.blurRadius = 30
        overlayView.opacity = 0.7
        overlayView.color = .black
        
        let defaultButton = DefaultButton.appearance()
        defaultButton.titleFont = UIFont.systemFont(ofSize: 18, weight: .medium)
        defaultButton.titleColor = .systemOrange
    }
    
}
