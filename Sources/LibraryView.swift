import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - 壁纸库
struct LibraryView: View {
    @EnvironmentObject var store: WallpaperStore
    @State private var cat: Wallpaper.Category? = nil
    @State private var preview: Wallpaper?

    private let cols = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                chips
                    .padding(.horizontal, 20).padding(.top, 6)
                LazyVGrid(columns: cols, spacing: 14) {
                    ForEach(filtered) { w in
                        WallpaperCard(w: w).onTapGesture { preview = w }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 30)
            }
            .background(Color(hex: 0x0A0814).ignoresSafeArea())
            .navigationTitle("交互式壁纸")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(item: $preview) { w in
                LockPreview(w: w) { store.apply(w) }
            }
        }
    }

    private var filtered: [Wallpaper] {
        guard let c = cat else { return store.walls }
        return store.walls.filter { $0.category == c }
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("全部", cat == nil) { cat = nil }
                ForEach(Wallpaper.Category.allCases, id: \.self) { c in
                    chip(c.rawValue, cat == c) { cat = c }
                }
            }
        }
    }

    private func chip(_ t: String, _ on: Bool, _ act: @escaping () -> Void) -> some View {
        Text(t)
            .font(.system(size: 13.5))
            .padding(.horizontal, 15).padding(.vertical, 7)
            .background(on ? Color(hex: 0x8B7BFF).opacity(0.25) : Color.white.opacity(0.07))
            .foregroundStyle(on ? Color(hex: 0xCFC7FF) : .gray)
            .overlay(Capsule().stroke(on ? Color(hex: 0x8B7BFF).opacity(0.5) : .clear))
            .clipShape(Capsule())
            .onTapGesture(perform: act)
    }
}

// MARK: - 卡片
struct WallpaperCard: View {
    let w: Wallpaper
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let img = w.image {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: w.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            }
            .frame(height: 250).frame(maxWidth: .infinity).clipped()

            LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .center, endPoint: .bottom)

            Text(w.name).font(.system(size: 13, weight: .medium)).foregroundStyle(.white)
                .padding(11)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08)))
        .overlay(alignment: .topLeading) {
            Text(w.isImported ? "已导入" : "LIVE")
                .font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(9)
        }
    }
}

// MARK: - 锁屏预览
struct LockPreview: View {
    let w: Wallpaper
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var now = Date()

    var body: some View {
        ZStack {
            Group {
                if let img = w.image {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: w.gradient, startPoint: .top, endPoint: .bottom)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 2) {
                Text(now.formatted(.dateTime.month().day().weekday(.wide)))
                    .font(.system(size: 15, weight: .medium))
                Text(now, format: .dateTime.hour().minute())
                    .font(.system(size: 74, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white).shadow(radius: 12)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 70)

            HStack(spacing: 10) {
                Button("返回") { dismiss() }
                    .frame(width: 92, height: 50)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                Button("应用到锁屏") { onApply(); dismiss() }
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(LinearGradient(colors: [Color(hex: 0x8B7BFF), Color(hex: 0x5C8BFF)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 16))
            }
            .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
            .padding(.horizontal, 20).padding(.bottom, 30)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { now = $0 }
    }
}

// MARK: - 导入
struct ImportView: View {
    @EnvironmentObject var store: WallpaperStore
    @State private var showPicker = false
    @State private var picked: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                Button { showPicker = true } label: {
                    VStack(spacing: 10) {
                        Text("＋").font(.system(size: 42, weight: .light))
                        Text("从「文件」中选择").font(.system(size: 16, weight: .semibold))
                        Text("支持 .livepaper / .mp4 / .mov / .heic")
                            .font(.system(size: 12.5)).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 40)
                    .background(Color(hex: 0x8B7BFF).opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 22)
                        .stroke(Color(hex: 0x8B7BFF).opacity(0.45), style: StrokeStyle(lineWidth: 1.5, dash: [6])))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .padding(.horizontal, 20).padding(.top, 8)

                VStack(spacing: 10) {
                    infoRow("🔐", "权限说明", "仅需相册「添加」权限，全部本地处理，不联网上传")
                    infoRow("🧩", "系统兼容", "已适配 iOS 17.0 – 27.0.1 的壁纸与相册权限差异")
                }
                .padding(.horizontal, 20).padding(.top, 24)
            }
            .background(Color(hex: 0x0A0814).ignoresSafeArea())
            .navigationTitle("导入壁纸")
            .fileImporter(isPresented: $showPicker,
                          allowedContentTypes: [.item],
                          allowsMultipleSelection: false) { result in
                if case .success(let urls) = result, let url = urls.first {
                    store.importFile(from: url)
                }
            }
        }
    }

    private func infoRow(_ icon: String, _ title: String, _ sub: String) -> some View {
        HStack(spacing: 13) {
            Text(icon).font(.system(size: 17))
                .frame(width: 34, height: 34)
                .background(Color(hex: 0x8B7BFF).opacity(0.18), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .medium))
                Text(sub).font(.system(size: 12)).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(15)
        .background(Color(hex: 0x161226), in: RoundedRectangle(cornerRadius: 16))
    }
}
