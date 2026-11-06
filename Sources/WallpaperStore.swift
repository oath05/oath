import Foundation
import SwiftUI
import Photos
import UIKit

// MARK: - Model
struct Wallpaper: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var category: Category
    var gradient: [Color]          // 缩略图配色
    var image: UIImage? = nil      // 导入的自定义图片
    var videoURL: URL? = nil       // 导入的视频（Live 素材）
    var isImported: Bool = false

    enum Category: String, CaseIterable { case aurora = "极光", flow = "流体", star = "星空", mine = "我的" }
}

// MARK: - Store
@MainActor
final class WallpaperStore: ObservableObject {
    @Published var walls: [Wallpaper] = []
    @Published var toast: String?

    init() {
        walls = [
            .init(name: "极光流萤", category: .aurora,
                  gradient: [Color(hex: 0x38F0C0), Color(hex: 0x8B7BFF), Color(hex: 0xFF5EA8)]),
            .init(name: "深空脉动", category: .star,
                  gradient: [Color(hex: 0x1B1140), Color(hex: 0x6B5CFF), Color(hex: 0x05030F)]),
            .init(name: "霓虹流体", category: .flow,
                  gradient: [Color(hex: 0xFF2D80), Color(hex: 0x7B2DFF), Color(hex: 0x00D0FF)]),
            .init(name: "暮色粒子", category: .aurora,
                  gradient: [Color(hex: 0x2A1145), Color(hex: 0xE06A4A), Color(hex: 0xF4A15C)]),
            .init(name: "银河回声", category: .star,
                  gradient: [Color(hex: 0x0A0620), Color(hex: 0x7B6CFF), Color(hex: 0x04030C)]),
            .init(name: "液态光",   category: .flow,
                  gradient: [Color(hex: 0x04121F), Color(hex: 0x2FE0FF), Color(hex: 0x0C3550)])
        ]
    }

    func show(_ msg: String) {
        toast = msg
        Task {
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            if toast == msg { toast = nil }
        }
    }

    // MARK: 导入文件（.livepaper / .zip / 图片 / 视频）
    func importFile(from url: URL) {
        let didStart = url.startAccessingSecurityScopedResource()
        defer { if didStart { url.stopAccessingSecurityScopedResource() } }

        do {
            let data = try Data(contentsOf: url)
            let name = url.deletingPathExtension().lastPathComponent

            if let img = UIImage(data: data) {
                walls.insert(Wallpaper(name: name, category: .mine, gradient: [], image: img, isImported: true), at: 0)
                saveToPhotos(image: img)
            } else {
                // 视频类素材：复制到沙盒再处理
                let dest = FileManager.default.temporaryDirectory
                    .appendingPathComponent("\(UUID().uuidString)-\(url.lastPathComponent)")
                try data.write(to: dest)
                walls.insert(Wallpaper(name: name, category: .mine, gradient: [], videoURL: dest, isImported: true), at: 0)
                saveVideoToPhotos(url: dest)
            }
            show("导入成功：\(name)")
        } catch {
            show("导入失败：\(error.localizedDescription)")
        }
    }

    // MARK: 相册权限（iOS 17 – 27 统一使用 limited/full 授权）
    private func ensurePhotoPermission(_ done: @escaping (Bool) -> Void) {
        let level: PHAccessLevel = .addOnly
        PHPhotoLibrary.requestAuthorization(for: level) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited: done(true)
                default: done(false)
                }
            }
        }
    }

    func saveToPhotos(image: UIImage) {
        ensurePhotoPermission { [weak self] ok in
            guard ok else { self?.show("请在设置中允许「添加照片」权限"); return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, _ in
                DispatchQueue.main.async {
                    self?.show(success ? "已保存到相册，可在相册中设为墙纸" : "保存失败")
                }
            }
        }
    }

    func saveVideoToPhotos(url: URL) {
        ensurePhotoPermission { [weak self] ok in
            guard ok else { self?.show("请在设置中允许「添加照片」权限"); return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, _ in
                DispatchQueue.main.async {
                    self?.show(success ? "已保存到相册，可在相册中设为墙纸" : "保存失败")
                }
            }
        }
    }

    // MARK: 应用壁纸
    /// iOS 不提供第三方直接写入锁屏的公开 API，
    /// 因此这里走「保存到相册 → 打开系统墙纸设置」的标准流程。
    func apply(_ w: Wallpaper) {
        if let img = w.image {
            saveToPhotos(image: img)
        } else if let v = w.videoURL {
            saveVideoToPhotos(url: v)
        } else {
            show("已保存该壁纸到相册")
        }
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            openSystemWallpaperSettings()
        }
    }

    func openSystemWallpaperSettings() {
        // 尝试直达「墙纸」设置，失败则退回到 App 设置页
        let candidates = ["App-prefs:Wallpaper", "App-prefs:root=Wallpaper", UIApplication.openSettingsURLString]
        for c in candidates {
            if let url = URL(string: c), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue:  Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
