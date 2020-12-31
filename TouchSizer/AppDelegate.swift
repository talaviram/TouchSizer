//
//  AppDelegate.swift
//  TouchSizer
//
//  Created by Tal Aviram on 31/12/2020.
//  Copyright © 2020 Tal Aviram. All rights reserved.
//
import AXSwift
import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate, WindowButtonsDelegate {

    // MARK - WindowButtonDelegate
    func closeButtonPressed() {
        applyToCurrentWindow(.closeButton)
    }

    func minimizeButtonPressed() {
        applyToCurrentWindow(.minimizeButton)
    }

    func fullscreenButtonPressed() {
        applyToCurrentWindow(.fullScreenButton)
    }

    func applyToCurrentWindow(_ attr : Attribute) {
        if let window = getWindowForCurrentMousePoisition() {
            applyToWindow(window: window, attr: attr)
        }
    }

    func applyToWindow (window : UIElement, attr : Attribute)
    {
        // fullscreen is a special case
        if attr == .fullScreenButton {
            if let isFullscreen : Bool = try! window.attribute(.fullScreen) {
                try! window.setAttribute(.fullScreen, value: !isFullscreen)
            }
            return
        }
        if attr == .minimizeButton {
            if let isMinimized : Bool = try! window.attribute(.minimized) {
                try! window.setAttribute(.minimized, value: !isMinimized)
                try! window.setAttribute(.minimized, value: !isMinimized)
            }
            return
        }
        if let button : UIElement = try! window.attribute(attr) {
            try! button.performAction(.press)
        }
    }

    func getWindowForCurrentMousePoisition() -> UIElement?
    {
        let mousePos = NSEvent.mouseLocation
        // TODO: optimize this!
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mousePos, $0.frame, false) })
        let element = try! systemWideElement.elementAtPosition(Float(mousePos.x), Float(screenWithMouse!.frame.height - mousePos.y))
        if (try! element?.role() == Role.window) {
            return element
        }
        if let window : UIElement = try! (element?.attribute(.window)) {
            return window
        }
        return nil
    }

    /// Status bar icon
    fileprivate let touchSizerStatusbarIcon = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    fileprivate let touchbarController = TouchBarController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // Check that we have permission
        guard UIElement.isProcessTrusted(withPrompt: true) else {
            // This needs to be approved each time you re-compile!
            NSLog("No accessibility API permission, exiting")
            NSRunningApplication.current.terminate()
            return
        }

        /// Touchbar
        touchbarController.buttonsDelegate = self
        touchbarController.present()

        /// Statusbar
        if let button = touchSizerStatusbarIcon.button {
            button.image = NSImage(named: NSImage.iconViewTemplateName)
            button.image?.isTemplate = true
            /// Create menu
            let menu = NSMenu(title: "TouchSizer Options")
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Quit...", action: #selector(NSApp.terminate), keyEquivalent: "q")
            touchSizerStatusbarIcon.menu = menu
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
