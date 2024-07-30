//
//  Ext+NSAlert.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/9.
//

import Cocoa

extension NSAlert {
    static func popError(_ error: String) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Error", comment: "")
        alert.alertStyle = .critical
        alert.informativeText = error
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.runModal()
    }
    
    static func popRestart(_ error: String, completion: @escaping () -> Void) {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Need Restart", comment: "")
            alert.alertStyle = .critical
            alert.informativeText = error
            alert.addButton(withTitle: NSLocalizedString("Restart now", comment: ""))
            alert.addButton(withTitle: NSLocalizedString("Later", comment: ""))
            
            // Show alert and handle the response
            let response = alert.runModal()
            
            if response == .alertFirstButtonReturn {
                // User clicked "Restart now"
                completion()
            }
        }

    
    
    static func popError(_ error: Error) {
        popError(error.localizedDescription)
    }
    
    
}
