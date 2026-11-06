import SwiftUI
import UIKit

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let qqNumber = "3506933923"

    private var cardScheme: URL? {
        URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=\(qqNumber)&card_type=person&source=sharecard")
    }
    private var qqWeb: URL? {
        URL(string: "https://wpa.qq.com/msgrd?v=3&uin=\(qqNumber)&site=qq&menu=yes")
    }
    private var qqScheme: URL? { URL(string: "mqq://") }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("AuthorAvatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 0.8))
                    .shadow(color: Color(hex: 0x00C173).opacity(0.45), radius: 22, y: 10)
                    .padding(.top, 34)

                Text("誓言")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 16)

                Text("OATH")
                    .font(.system(size: 12, weight: .medium))
                    .tracking(2.6)
                    .foregroundStyle(Color(hex: 0x8A8F99))
                    .padding(.top, 3)

                VStack(alignment: .leading, spacing: 7) {
                    Text("独立开发者，做点自己用得上、别人也用得上的小工具。")
                    Text("OATH-IDSwitch 的定位很简单：把多个 Apple ID 记在一处，切换时少点几下，仅此而已。")
                    Text("App 不联网、不上传、不保存密码，所有数据只在本机。")
                }
                .font(.system(size: 13.5))
                .lineSpacing(5)
                .foregroundStyle(Color(hex: 0xC8CCD4))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(hex: 0x16181D), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top, 20)

                Button(action: addQQ) {
                    HStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 15, weight: .semibold))
                        Text("加作者 QQ 好友")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(Color(hex: 0x0B0C0F))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(LinearGradient(colors: [Color(hex: 0x00E08F), Color(hex: 0x00B4FF)],
                                               startPoint: .leading, endPoint: .trailing),
                                in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, 18)

                Text("QQ \(qqNumber)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0x6B6F78))
                    .padding(.top, 10)

                VStack(spacing: 10) {
                    row("number", "版本", "1.0.0 (100)")
                    row("iphone", "兼容", "iOS 17.0 – 27.0.1")
                    row("checkmark.shield", "权限", "无网络权限，无需越狱")
                }
                .padding(.top, 22)

                Text("Made with ♥ by 誓言 / OATH")
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color(hex: 0x50545C))
                    .padding(.vertical, 26)
            }
            .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
        }
        .background(Color(hex: 0x0E0F12).ignoresSafeArea())
        .navigationTitle("关于作者")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }.foregroundStyle(Color(hex: 0x00E08F))
            }
        }
    }

    /// 优先用 QQ 名片 schema 直接打开加好友，未安装则回落到网页
    private func addQQ() {
        let app = UIApplication.shared
        if let scheme = qqScheme, app.canOpenURL(scheme), let card = cardScheme {
            app.open(card, options: [:]) { ok in
                if !ok, let web = self.qqWeb { app.open(web) }
            }
        } else if let web = qqWeb {
            app.open(web)
        }
    }

    private func row(_ icon: String, _ title: String, _ sub: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: 0x00D98B))
                .frame(width: 34, height: 34)
                .background(Color(hex: 0x00C173).opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: 0xD5D8DE))
            Spacer()
            Text(sub)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: 0x8A8F99))
        }
        .padding(14)
        .background(Color(hex: 0x16181D), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
