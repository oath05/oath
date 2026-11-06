import Foundation
import SwiftUI
import UIKit

// MARK: - 模型
struct SavedAccount: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var label: String
    var email: String
    var createdAt: Date = Date()

    var initial: String {
        let s = label.isEmpty ? email : label
        return String(s.prefix(1)).uppercased()
    }
}

// MARK: - Store
@MainActor
final class AccountStore: ObservableObject {
    @Published private(set) var accounts: [SavedAccount] = []
    @Published var toast: String?

    private let key = "oath.idswitch.accounts.v1"

    init() { load() }

    // MARK: 增删
    func add(label: String, email: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else { return }

        if accounts.contains(where: { $0.email.lowercased() == trimmedEmail.lowercased() }) {
            show("这个账号已经在列表里了")
            return
        }

        var name = label.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { name = Self.suggestLabel(for: trimmedEmail) }

        accounts.insert(SavedAccount(label: name, email: trimmedEmail), at: 0)
        persist()
        show("已保存 \(name)")
    }

    func delete(_ account: SavedAccount) {
        accounts.removeAll { $0.id == account.id }
        persist()
        show("已删除")
    }

    func move(from source: IndexSet, to destination: Int) {
        accounts.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    // MARK: 切换
    /// 复制账号 → 尽量打开系统账号登录页。
    /// 说明：iOS 没有公开 API 能直接打开「App Store 账号登录」页，
    /// 这里按可用性依次尝试系统深层链接，全部失败时提示手动路径。
    func switchTo(_ account: SavedAccount) {
        UIPasteboard.general.string = account.email
        show("已复制 \(account.email)\n正在打开系统账号页面…")
        openAccountPage(candidates: Self.accountURLs)
    }

    private static var accountURLs: [String] {
        [
            "App-prefs:APPLE_ACCOUNT",
            "App-prefs:root=APPLE_ACCOUNT&path=APPLE_ACCOUNT",
            "App-prefs:APPSTORE",
            "App-prefs:root=APPSTORE",
            UIApplication.openSettingsURLString
        ]
    }

    private func openAccountPage(candidates: [String]) {
        guard let raw = candidates.first, let url = URL(string: raw) else {
            show("无法自动跳转\n请打开「设置 → 你的头像」手动切换账号")
            return
        }
        UIApplication.shared.open(url, options: [:]) { [weak self] ok in
            DispatchQueue.main.async {
                guard let self else { return }
                if ok {
                    self.show("已复制账号，粘贴到登录框即可\n（密码只在系统页面输入）")
                } else if candidates.count > 1 {
                    self.openAccountPage(candidates: Array(candidates.dropFirst()))
                } else {
                    self.show("系统限制了自动跳转\n请打开「设置 → 你的头像 → 媒体与购买项目」")
                }
            }
        }
    }

    // MARK: 辅助
    private static func suggestLabel(for email: String) -> String {
        if let at = email.firstIndex(of: "@") {
            return String(email[..<at])
        }
        return email
    }

    private func show(_ msg: String) {
        toast = msg
        let current = msg
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            if self?.toast == current { self?.toast = nil }
        }
    }

    // MARK: 持久化（仅本机 UserDefaults，不联网、不上传）
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedAccount].self, from: data) else { return }
        accounts = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - 颜色
extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
