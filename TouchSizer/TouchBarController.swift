//
//  TouchBarController.swift
//  TouchSizer
//
//  Created by Tal Aviram on 01/01/2021.
//  Copyright © 2021 Tal Aviram. All rights reserved.
//

import Foundation
import AppKit

extension NSTouchBarItem.Identifier {
    static let touchSizerBar = NSTouchBarItem.Identifier("com.talaviram.TouchSizerToggle")
    static let windowButtons = NSTouchBarItem.Identifier("com.talavriam.WindowButtons")
}

public protocol WindowButtonsDelegate: class {
    func closeButtonPressed()
    func minimizeButtonPressed()
    func fullscreenButtonPressed()
}

class TouchBarController: NSObject, NSTouchBarDelegate {

    var buttonsDelegate : WindowButtonsDelegate?
    var touchBar: NSTouchBar?

    private(set) var isVisible: Bool = false

    var systemTrayItem:           NSCustomTouchBarItem?      { return nil }
    var systemTrayItemIdentifier: NSTouchBarItem.Identifier? { return nil }

    override required init() { super.init() }

    func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.windowButtons]
        return touchBar
    }

    private func makeTouchBarImageButton (identifier: NSTouchBarItem.Identifier, image: String, sel: Selector?) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: identifier)
        let button = NSButton(image: NSImage(named: image)!, target: self, action: sel)
        button.isBordered = false
        button.imagePosition = .imageOnly
        item.view = button
        return item
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.windowButtons:
            let appCurrentInfoItem = NSCustomTouchBarItem(identifier: identifier)

            let control = NSSegmentedControl(images: [NSImage(named: "Close")!, NSImage(named: "Minimize")!, NSImage(named: "Fullscreen")!], trackingMode: .momentary, target: self, action: #selector(toolbarClicked))

            control.segmentDistribution = .fit

            appCurrentInfoItem.view = control
            return appCurrentInfoItem
        default:
          return nil
        }
    }

    @objc func toolbarClicked(sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            buttonsDelegate?.closeButtonPressed()
            break
        case 1:
            buttonsDelegate?.minimizeButtonPressed()
            break
        case 2:
            buttonsDelegate?.fullscreenButtonPressed()
            break
        default:
            return
        }
    }

    func showControlStripIcon() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(false)
        guard systemTrayItem != nil else { return }
        NSTouchBarItem.removeSystemTrayItem(systemTrayItem!)
        NSTouchBarItem.addSystemTrayItem(systemTrayItem!)
    }

    @objc func toggle() {
        if self.isVisible {
            self.minimize()
        }else {
            self.present()
        }
    }

    @objc func dismiss() {
        if #available (macOS 10.14, *) {
            NSTouchBar.dismissSystemModalTouchBar(touchBar)
        } else {
            NSTouchBar.dismissSystemModalFunctionBar(touchBar)
        }
        self.isVisible = false
    }

    @objc func minimize() {
        if #available (macOS 10.14, *) {
            NSTouchBar.minimizeSystemModalTouchBar(touchBar)
        } else {
            NSTouchBar.minimizeSystemModalFunctionBar(touchBar)
        }
        self.isVisible = false
    }

    @objc func present() {
        if touchBar == nil {
            touchBar = makeTouchBar()
        }
        if #available (macOS 10.14, *) {
            NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: systemTrayItemIdentifier)
        } else {
            NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: systemTrayItemIdentifier)
        }
        self.isVisible = true

        let item = NSCustomTouchBarItem.init(identifier: NSTouchBarItem.Identifier.touchSizerBar)
        item.view = NSButton(image: NSImage(named: "Icon")!, target: self, action: #selector(toggle))
        NSTouchBarItem.addSystemTrayItem(item)
        DFRElementSetControlStripPresenceForIdentifier (NSTouchBarItem.Identifier.touchSizerBar, true)
    }
}
