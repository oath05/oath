# OATH-IDSwitch

作者：**誓言 / OATH**　QQ：**3506933923**

多 Apple ID 账号管理小工具。手动记下几个账号，切换时一键复制 + 带到系统账号页。

## 它做什么

- 手动录入、保存多条 Apple ID（备注名 + 邮箱），**不读取系统 App Store 登录数据**
- 点「切换」：把邮箱复制到剪贴板，并尽力打开系统的「Apple 账户」页面
- 深色仿酷安风格 UI，胶囊标题栏，iPhone / iPad 自适应
- 完全离线：无网络权限、不申请任何系统账号权限、不需要越狱或根权限

## 它不做什么（重要）

- **不保存密码。** 记录里只有备注和邮箱。密码请直接在系统登录页输入。
- **不能真正「一键切号」。** iOS 没有公开 API 能让第三方 App 跳进「设置 → 媒体与购买项目」的登录页，也没有 API 代为登录。App 做的是：复制账号 + 依次尝试系统深层链接（`App-prefs:APPLE_ACCOUNT` 等），全部被系统拦下时提示手动路径。
- 不联网、不上传、无统计。

## 装到手机

1. 打开 [Releases](https://github.com/oath05/oath/releases)，下载 `OATH-IDSwitch-unsigned.ipa`
2. 用 **全能签 / eSign / Sideloadly / AltStore** 自签安装（7 天到期重签）
3. 首次打开若提示「不受信任的开发者」，去 设置 → 通用 → VPN与设备管理 信任证书

> IPA 是**未签名**的，这是全能签能直接吃的前提；普通 ipa 一样，只是少了签名而已。

## 自己构建

```bash
brew install xcodegen
cd IDSwitch
python3 scripts/prepare_assets.py
xcodegen generate
open IDSwitch.xcodeproj     # 选真机 → Run
```

部署目标 iOS 17.0，向上兼容 iOS 27（工程里没有任何私有框架依赖，系统版本升级无需改代码）。

## 结构

```
IDSwitch/
├── project.yml                 # XcodeGen 工程描述
├── Sources/
│   ├── OATHIDSApp.swift        # 入口 + 胶囊标题栏 + 卡片/空状态/Toast
│   ├── AccountStore.swift      # 账号模型、存储、切换与跳转逻辑
│   ├── AddAccountView.swift    # 添加账号
│   └── AboutView.swift         # 关于作者 + QQ 跳转
├── Resources/Assets.xcassets/  # 图标与头像（构建时由 base64 还原）
└── Assets/base64/              # 二进制资源的 base64 载体
```

---

Made with ♥ by 誓言 / OATH
