import SwiftUI

struct AppLayout<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.taupe100.ignoresSafeArea()
            content
        }
        .font(.custom("MaruBuri-Regular", size: 16))
        .foregroundStyle(Color.neutral950)
    }
}
