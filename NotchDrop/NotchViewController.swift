//
//  NotchViewController.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import AppKit
import Cocoa
import SwiftUI

class NotchViewController: NSHostingController<NotchView> {
    init(_ vm: NotchViewModel) {
        super.init(rootView: .init(vm: vm))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
