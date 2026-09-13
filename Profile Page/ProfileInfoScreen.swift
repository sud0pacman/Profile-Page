import SwiftUI

struct ProfileInfoScreen: View {
    let userName = "Ali Valiyev"
    let avatarImageName = "avatar"

    private let minAvatarSize: CGFloat = 96

    // Overscroll (pull down) size only
    @State private var pulledDown: CGFloat = 0
    @State private var isAvatarExpanded = false

    var body: some View {
        GeometryReader { outerProxy in
            let maxAvatarHeight = outerProxy.size.height / 3

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: - Avatar Header

                    GeometryReader { proxy in
                        let minY = proxy.frame(in: .named("scroll")).minY

                        avatar(
                            progress: progress(maxAvatarHeight: maxAvatarHeight),
                            screenWidth: proxy.size.width,
                            maxAvatarHeight: maxAvatarHeight
                        )
                        .onChange(of: minY) { _, newValue in
                            handleScrollChange(newValue, maxAvatarHeight: maxAvatarHeight)
                        }
                    }
                    .frame(height: headerHeight(maxAvatarHeight: maxAvatarHeight))
                    .animation(.easeOut(duration: 0.6), value: isAvatarExpanded)

                    // MARK: - Info

                    VStack(spacing: 0) {
                        Text(userName)
                            .font(.title2.bold())
                            .padding(.top, 12)

                        Text("was last online today at 14:32")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 12)

                        muteToggleRow

                        Divider().padding(.leading)
                        phoneRow
                        Divider().padding(.leading)
                        mediaCountersRow
                    }
                }
            }
            .coordinateSpace(name: "scroll")
        }
    }

    // MARK: - Calculating

    private func rawProgress(_ maxAvatarHeight: CGFloat) -> CGFloat {
        pulledDown / (maxAvatarHeight - minAvatarSize)
    }

    private func progress(maxAvatarHeight: CGFloat) -> CGFloat {
        if isAvatarExpanded { return 1 }
        let raw = rawProgress(maxAvatarHeight)
        if raw <= 0.3 { return raw }
        let normalized = (raw - 0.3) / 0.7
        let eased = pow(normalized, 1.8)
        return 0.3 + eased * 0.7
    }

    private func headerHeight(maxAvatarHeight: CGFloat) -> CGFloat {
        minAvatarSize + (maxAvatarHeight - minAvatarSize) * progress(maxAvatarHeight: maxAvatarHeight)
    }

    private func handleScrollChange(_ minY: CGFloat, maxAvatarHeight: CGFloat) {
        if minY < 0 {
            pulledDown = 0
            if isAvatarExpanded {
                withAnimation(.easeOut(duration: 0.35)) {
                    isAvatarExpanded = false
                }
            }
            return
        }

        pulledDown = minY
        guard !isAvatarExpanded else { return }

        let newRaw = minY / (maxAvatarHeight - minAvatarSize)
        if newRaw >= 0.3 {
            withAnimation(.easeOut(duration: 0.6)) {
                isAvatarExpanded = true
            }
        }
    }

    // MARK: - Avatar

    @ViewBuilder
    private func avatar(progress: CGFloat, screenWidth: CGFloat, maxAvatarHeight: CGFloat) -> some View {
        let height = minAvatarSize + (maxAvatarHeight - minAvatarSize) * progress
        let width = minAvatarSize + (screenWidth - minAvatarSize) * progress
        let circleRadius = minAvatarSize / 2
        let cornerRadius = circleRadius * (1 - progress) + 24 * progress

        Image(avatarImageName)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .frame(maxWidth: .infinity)
    }

    // MARK: - Rows

    private var muteToggleRow: some View {
        Toggle("Unmute", isOn: .constant(false))
            .padding()
    }

    private var phoneRow: some View {
        HStack {
            Text("Phone number")
            Spacer()
            Text("+998 90 123 45 67")
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var mediaCountersRow: some View {
        HStack {
            Label("124 pictures", systemImage: "photo")
            Spacer()
            Label("18 videos", systemImage: "video")
        }
        .font(.footnote)
        .padding()
    }
}

#Preview {
    ProfileInfoScreen()
}
