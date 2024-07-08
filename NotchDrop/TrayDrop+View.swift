//
//  TrayDrop+View.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Foundation
import Pow
import SwiftUI

struct TrayView: View {
    @StateObject var vm: NotchViewModel
    @StateObject var tvm = TrayDrop.shared

    @State private var targeting = false

    var body: some View {
        panel
            .onDrop(of: [.data], isTargeted: $targeting) { providers in
                DispatchQueue.global().async { tvm.load(providers) }
                return true
            }
    }

    var panel: some View {
        RoundedRectangle(cornerRadius: vm.cornerRadius)
            .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
            .foregroundStyle(.white.opacity(0.1))
            .background(loading)
            .overlay { content.padding() }
            .animation(vm.animation, value: tvm.items)
            .animation(vm.animation, value: tvm.isLoading)
    }

    var loading: some View {
        RoundedRectangle(cornerRadius: vm.cornerRadius)
            .foregroundStyle(.white.opacity(0.1))
            .conditionalEffect(
                .repeat(
                    .glow(color: .blue, radius: 50),
                    every: 1.5
                ),
                condition: tvm.isLoading > 0
            )
    }

    @ViewBuilder
    var content: some View {
        if tvm.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "tray.and.arrow.down.fill")
                Text(NSLocalizedString("Drag files here to keep them for a day & Press Option to delete", comment: ""))
            }
            .font(.system(.headline, design: .rounded))
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: vm.spacing) {
                    ForEach(tvm.items) { item in
                        DropItemView(item: item, vm: vm, tvm: tvm)
                    }
                }
                .padding(vm.spacing)
            }
            .padding(-vm.spacing)
            .scrollIndicators(.never)
        }
    }
}

#Preview {
    NotchContentView(vm: .init())
        .padding()
        .frame(width: 550, height: 150, alignment: .center)
        .background(.black)
        .preferredColorScheme(.dark)
}
