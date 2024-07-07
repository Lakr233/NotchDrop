//
//  NotchHeaderView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import SwiftUI

struct NotchHeaderView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        HStack {
            Text("Notch Drop")
            Spacer()
            Text("GitHub Logo")
                .hidden()
                .overlay {
                    Image(.gitHub)
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    NSWorkspace.shared.open(productPage)
                }
        }
        .font(.system(.headline, design: .rounded))
    }
}

#Preview {
    NotchHeaderView(vm: .init())
}
