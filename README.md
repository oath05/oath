# 誓言 · 交互式壁纸（OATH Wallpaper）

作者：**誓言 / OATH** ｜ QQ：<https://qm.qq.com/q/4FMwbUUhHq>

一个 iOS 壁纸工具 App，用 SwiftUI 编写，通过 GitHub Actions 自动打包。

---

## ⚠️ 先看清楚：这个 App 能做什么、不能做什么

| 能力 | 状态 |
|---|---|
| 壁纸库 / 分类筛选 / 锁屏效果预览（实时时钟） | ✅ |
| 从「文件」导入自定义图片 / 视频壁纸 | ✅ |
| 关于作者页 + 一键加 QQ 好友 | ✅ 真实跳转 |
| 「一键应用到锁屏」 | ⚠️ 只能「存相册 + 跳墙纸设置」，**第三方 App 无法直接写入锁屏**，苹果无公开 API |
| 交互式壁纸装到锁屏 | ⚠️ iOS 16 起系统已移除第三方 Live Photo 锁屏动态，只能在 App 内预览 |

## 自动打包说明（重点）

工作流产出的 `.ipa` 是 **未签名（unsigned）** 的。GitHub Actions 的 macOS 机器上没有你的开发者证书，
所以它只能把 `.app` 装进 `Payload/` 打成 ipa。要装到手机上还需要一步签名：

- **电脑端**：Sideloadly / AltStore 用你的 Apple ID 重签（免费账号 7 天有效期）
- **手机端**：用 eSign / Scarlet 等工具导入 ipa 并自签
- **正式分发**：需要 Apple Developer 付费账号 + 证书，改工作流走 `xcodebuild -exportArchive`

想让 Actions 直接产出可安装的 ipa，需要在仓库 Secrets 里放：
`BUILD_CERTIFICATE_BASE64`、`P12_PASSWORD`、`PROVISIONING_PROFILE_BASE64`、`KEYCHAIN_PASSWORD`，
再用 `apple-actions/import-codesign-certs` 之类 action 导入证书。这需要你先有付费开发者账号。

## 目录结构

```
├── .github/workflows/build.yml   # CI：归档 → 打包 unsigned ipa → 上传 artifact
├── project.yml                   # XcodeGen 工程描述（CI 用它生成 .xcodeproj）
├── Sources/                      # SwiftUI 源码
│   ├── OathWallpaperApp.swift
│   ├── WallpaperStore.swift
│   ├── LibraryView.swift
│   └── AboutView.swift
├── Resources/Assets.xcassets/    # 图标 / 头像（PNG、JPG 由 base64 解码生成）
├── Assets/base64/                # 图标与头像的 base64（二进制不便走文本提交）
└── scripts/prepare_assets.py     # 构建前还原资源
```

## 本地构建

```bash
brew install xcodegen
python3 scripts/prepare_assets.py
xcodegen generate
open OathWallpaper.xcodeproj     # 选真机 → Run
```

部署目标 iOS 17.0，向上兼容；Xcode 16 / iOS 18 SDK 编译无警告。

---

Made with ♥ by 誓言 / OATH
