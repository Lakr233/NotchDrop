//
//  NotchContentView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import ColorfulX
import SwiftUI
import UniformTypeIdentifiers

struct NotchContentView: View {
    @ObservedObject var vm: NotchViewModel

    var body: some View {
        HStack(spacing: vm.spacing) {
            AirDropView(vm: vm)
            TrayView(vm: vm)
        }
    }
}

#Preview {
    NotchContentView(vm: .init())
        .padding()
        .frame(width: 500, height: 180, alignment: .center)
        .background(.black)
        .preferredColorScheme(.dark)
}
