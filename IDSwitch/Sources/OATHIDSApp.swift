import SwiftUI

@main
struct OATHIDSApp: App {
    @StateObject private var store = AccountStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(Color(hex: 0x00C173))
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: AccountStore
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var showAdd = false
    @State private var showAbout = false

    private var maxW: CGFloat { sizeClass == .regular ? 620 : .infinity }

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: 0x0E0F12).ignoresSafeArea()

            // 背景微光
            RadialGradient(colors: [Color(hex: 0x00C173).opacity(0.16), .clear],
                           center: .topLeading, startRadius: 8, endRadius: 420)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScrollView {
                VStack(spacing: 12) {
                    if store.accounts.isEmpty {
                        EmptyState { showAdd = true }
                            .padding(.top, 90)
                    } else {
                        ForEach(store.accounts) { acc in
                            AccountCard(account: acc,
                                        onSwitch: { store.switchTo(acc) },
                                        onDelete: { store.delete(acc) })
                        }
                        Text("长按卡片可删除 · 所有数据仅保存在本机")
                            .font(.system(size: 11.5))
                            .foregroundStyle(Color(hex: 0x6B6F78))
                            .padding(.top, 14)
                    }
                }
                .frame(maxWidth: maxW)
                .padding(.horizontal, 16)
                .padding(.top, 76)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
            }

            header
        }
        .sheet(isPresented: $showAdd) {
            AddAccountView().environmentObject(store)
        }
        .sheet(isPresented: $showAbout) {
            NavigationStack { AboutView() }
        }
        .overlay(alignment: .bottom) {
            if let t = store.toast {
                Toast(text: t).padding(.bottom, 28).transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.85), value: store.accounts)
        .animation(.easeOut(duration: 0.2), value: store.toast)
    }

    // MARK: 胶囊标题栏
    private var header: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(LinearGradient(colors: [Color(hex: 0x00C173), Color(hex: 0x00B4FF)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 10, height: 10)

            Text("OATH · IDSwitch")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)

            Spacer(minLength: 6)

            iconButton("person.crop.circle") { showAbout = true }
            iconButton("plus") { showAdd = true }
        }
        .padding(.horizontal, 18)
        .frame(height: 52)
        .frame(maxWidth: maxW)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.09), lineWidth: 0.8))
        .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func iconButton(_ name: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(hex: 0xD5D8DE))
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.07), in: Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 账号卡片
struct AccountCard: View {
    let account: SavedAccount
    var onSwitch: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Text(account.initial)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(hex: 0x00E08F))
                .frame(width: 42, height: 42)
                .background(Color(hex: 0x00C173).opacity(0.14), in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(account.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(account.email)
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color(hex: 0x8A8F99))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 6)

            Button(action: onSwitch) {
                Text("切换")
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x0B0C0F))
                    .padding(.horizontal, 16)
                    .frame(height: 34)
                    .background(Color(hex: 0x00E08F), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color(hex: 0x16181D), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.white.opacity(0.06), lineWidth: 0.8))
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("删除账号", systemImage: "trash")
            }
        }
    }
}

// MARK: - 空状态
struct EmptyState: View {
    var onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.badge.key")
                .font(.system(size: 46, weight: .light))
                .foregroundStyle(Color(hex: 0x00D98B).opacity(0.85))

            Text("还没有添加账号")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Text("手动录入 Apple ID 邮箱，切换时自动复制并带你到系统登录页。\n不读取、不保存任何密码。")
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: 0x8A8F99))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)

            Button(action: onAdd) {
                Text("添加第一个账号")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x0B0C0F))
                    .padding(.horizontal, 22)
                    .frame(height: 44)
                    .background(Color(hex: 0x00E08F), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }
}

// MARK: - Toast
struct Toast: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13.5, weight: .medium))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color(hex: 0x22252B).opacity(0.98), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.8))
            .padding(.horizontal, 28)
    }
}
