//
//  NotchSeetingsView.swift
//  NotchDrop
//
//  Created by 曹丁杰 on 2024/7/29.
//

import SwiftUI

struct NotchSeetingsView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        ZStack {
            switch vm.contentType {
            case .normal:
                HStack(spacing: vm.spacing) {
                    AirDropView(vm: vm)
                    TrayView(vm: vm)
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            case .menu:
                NotchMenuView(vm: vm)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            case .settings:
                VStack(spacing: vm.spacing) {
                    NotchHeaderView(vm: vm)
//                    NotchSettingsContentView(vm: vm)
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(vm.animation, value: vm.contentType)
    }
}

#Preview {
    NotchContentView(vm: .init())
        .padding()
        .frame(width: 600, height: 150, alignment: .center)
        .background(.black)
        .preferredColorScheme(.dark)
}
