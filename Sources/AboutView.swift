import SwiftUI
import UIKit

// MARK: - 关于作者
struct AboutView: View {
    private let qqURL = URL(string: "https://qm.qq.com/q/4FMwbUUhHq")!
    private let qqScheme = URL(string: "mqq://")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Image("AuthorAvatar")                 // Assets 中放置头像，命名 AuthorAvatar
                        .resizable().scaledToFill()
                        .frame(width: 104, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 34)
                            .stroke(Color.white.opacity(0.16)))
                        .shadow(color: Color(hex: 0x8B7BFF).opacity(0.55), radius: 20, y: 12)
                        .padding(.top, 28)

                    Text("誓言").font(.system(size: 22, weight: .bold)).padding(.top, 16)
                    Text("OATH")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2.4).foregroundStyle(.secondary).padding(.top, 3)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("独立开发者 / 壁纸爱好者。")
                        Text("专注 iOS 交互式壁纸与个性化体验，喜欢把「会动、会回应」的画面放到锁屏上。")
                        Text("有壁纸需求、定制或问题反馈，欢迎直接加 QQ 找我。")
                    }
                    .font(.system(size: 13.5)).lineSpacing(5)
                    .foregroundStyle(Color(hex: 0xCFC9E6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(hex: 0x161226), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20).padding(.top, 18)

                    Button(action: addQQ) {
                        HStack(spacing: 9) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("加作者 QQ 好友")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(LinearGradient(colors: [Color(hex: 0x12B7F5), Color(hex: 0x0A84FF)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: 0x12B7F5).opacity(0.45), radius: 14, y: 8)
                    }
                    .padding(.horizontal, 20).padding(.top, 18)

                    VStack(spacing: 10) {
                        row("📱", "版本", "1.0.0 (Build 100)")
                        row("🛡", "兼容系统", "iOS 17.0 – 27.0.1")
                        row("💬", "反馈", "点击上方按钮，直接唤起 QQ 添加好友")
                    }
                    .padding(.horizontal, 20).padding(.top, 22)

                    Text("Made with ♥ by 誓言 / OATH")
                        .font(.system(size: 11.5)).foregroundStyle(Color(hex: 0x5B5578))
                        .padding(.vertical, 24)
                }
            }
            .background(Color(hex: 0x0A0814).ignoresSafeArea())
            .navigationTitle("关于作者")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// 直接拉起 QQ 加好友
    /// qm.qq.com 是 QQ 官方配置了 Universal Link 的域名：
    /// 装了 QQ → 系统直接交给 QQ 打开加好友卡片；没装 → 落到网页版加好友页。
    /// 注意 Info.plist 里必须声明 LSApplicationQueriesSchemes(mqq)，否则 canOpenURL 恒为 false。
    private func addQQ() {
        let app = UIApplication.shared
        let installed = app.canOpenURL(qqScheme)
        app.open(qqURL, options: [:]) { ok in
            if !ok {
                // 极少数情况（通用链接被禁用）→ 退回网页打开
                app.open(self.qqURL)
            }
        }
        if !installed {
            // 仅用于埋点/提示，不影响跳转
            print("[QQ] 未检测到 QQ 客户端，将打开网页版加好友页")
        }
    }

    private func row(_ icon: String, _ title: String, _ sub: String) -> some View {
        HStack(spacing: 13) {
            Text(icon).font(.system(size: 17))
                .frame(width: 34, height: 34)
                .background(Color(hex: 0x8B7BFF).opacity(0.18), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .medium))
                Text(sub).font(.system(size: 12)).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(.tertiary)
        }
        .padding(15)
        .background(Color(hex: 0x161226), in: RoundedRectangle(cornerRadius: 16))
    }
}
