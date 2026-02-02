[English](README_EN.md) | 简体中文

<div align="center">

# ⚡ Flux

### V2Board 机场商业化客户端解决方案 (Android / iOS / Windows / macOS)

**双内核架构 | 进程守护 | 支付集成 | 商业化闭环**

改一行 API 地址 → 编译 → 拥有专属品牌 App

[![Stars](https://img.shields.io/github/stars/flux-apphub/flux?style=flat-square&logo=github)](https://github.com/flux-apphub/flux/stargazers)
[![Forks](https://img.shields.io/github/forks/flux-apphub/flux?style=flat-square&logo=github)](https://github.com/flux-apphub/flux/network/members)
[![License](https://img.shields.io/github/license/flux-apphub/flux?style=flat-square)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)](https://flutter.dev)

💬 [加入 Telegram 群组](https://t.me/+62Otr015kSs1YmNk) · 📞 [商务合作 @fluxdeveloper](https://t.me/fluxdeveloper)

</div>

---

## 🚀 为什么选择 Flux？

本项目不仅仅是一个客户端，而是为机场站长打造的**营收工具**。

### 💎 商业化闭环 (增长核心)
- **支付系统**: 完整支持 V2Board 支付流程 (支付宝/微信/Stripe/USDT)，集成网页支付跳转。
- **订单管理**: 支持查看订单详情、取消订单、无需跳转直接支付。
- **邀请系统**: 支持邀请码生成、查看返利记录、申请提现，助力用户裂变。
- **客服集成**: 内置 Crisp 在线客服，支持工单与实时聊天，提升售后体验。

### 🛡️ 稳如磐石 (留存核心)
- **双内核引擎**: 
  - `V2Ray`: 负责订阅更新与基础代理。
  - `SingBox`: 负责高性能流量转发、Reality 协议与 **TUN 模式**。
- **TUN 模式**: 真正的系统级代理 (Android/Windows)，不依赖系统代理设置，完美支持游戏与所有软件。
- **进程守护**: Windows 端引入 PowerShell 守护进程，从底层防止核心意外退出，连接更持久。

### 🔒 安全合规
- **配置加密**: 敏感配置 (API, OSS) 支持 AES-128 加密，防止恶意抓包。
- **隐私脱敏**: 代码库已完全脱敏，无硬编码域名或 Key，开箱即用。

### 🆚 为什么选 Flux？（对比竞品）

| 特性 | ⚡ Flux | 🔴 v2rayNG | 🟡 Clash | 🔵 Shadowrocket |
| :--- | :---: | :---: | :---: | :---: |
| **跨平台** | **✅ 5 端** | ❌ 仅 Android | ⚠️ 多客户端 | ❌ 仅 iOS |
| **V2Board API** | **✅ 原生支持** | ❌ 需手动导入 | ❌ 需手动导入 | ❌ 需手动导入 |
| **Flutter UI** | **✅ Material 3** | ❌ 原生安卓 | ❌ Web 风格 | ❌ 原生 iOS |
| **白标定制** | **✅ 开箱即用** | ❌ 需改源码 | ❌ 困难 | ❌ 不可能 |
| **可商用** | **✅ MIT 协议** | ✅ | ⚠️ | ❌ |
| **开源** | **✅ 100%** | ✅ | ⚠️ 部分 | ❌ |

👉 **简单说：Flux 是目前唯一一个「开箱即用、可白标、可商用」的 V2Board 客户端方案。**

### 👥 Flux 适合谁用？

| 用户类型 | 你的需求 | Flux 能帮你 |
| :--- | :--- | :--- |
| 🛫 **机场站长** | 想快速出一个专属品牌客户端 | ✅ 改一行代码，5 分钟编译出 App |
| 🧑💻 **二次开发者** | 想 fork 一个干净的 Flutter 代理项目 | ✅ MIT 协议，可自由商用 |
| 👤 **终端用户** | 想要一个好看、好用的代理工具 | ✅ 联系你的机场获取专属客户端 |

---

## 📱 界面预览 (Screenshots)

> **精美 UI, 丝滑动画, 完美适配深色模式**

<details>
<summary>📸 点击查看截图展示</summary>

| 首页 (Home) | 节点 (Pro) | 个人 (Me) |
| :---: | :---: | :---: |
| <img src="assets/images/screenshots/1.png" alt="Flux VPN 首页 Dashboard" width="200"> | <img src="assets/images/screenshots/2.png" alt="Flux 节点列表 Node List" width="200"> | <img src="assets/images/screenshots/3.png" alt="Flux 个人中心 Profile" width="200"> |

| Windows / MacOS 桌面端 |
| :---: |
| <img src="assets/images/screenshots/6.png" alt="Flux Windows Desktop Client" width="600"> |

</details>

## 🛠 支持协议 (Tech Specs)

Flux 采用 **SingBox + V2Ray** 双核驱动，支持市面主流协议：

| 协议 (Protocol) | 状态 | 关键词 (Keywords) |
|:---|:---:|:---|
| **Hysteria 2** | ✅ | 极速, 拥塞控制, 抗封锁 |
| **VLESS Reality** | ✅ | Vision, XTLS, 防探测 |
| **VMess** | ✅ | WebSocket, gRPC, 广泛兼容 |
| **Trojan** | ✅ | TLS 伪装 |
| **TUIC v5** | ✅ | 0-RTT, QUIC 传输 |
| **Shadowsocks** | ✅ | AEAD 加密, 2022 新标准 |

---

## ⚡ 5 分钟快速上手

```bash
# 1. 克隆项目
git clone https://github.com/flux-apphub/flux.git
cd flux

# 2. 安装依赖
flutter pub get

# 3. 配置签名 (Android)
# 复制 key.properties.example 为 key.properties，并生成你的 key.jks
# (Debug 模式可跳过此步)

# 4. 修改 API 地址 (作为备份)
# 打开 lib/services/remote_config_service.dart
# 修改 _defaultDomain 为你的面板地址 (如 https://your-panel.com)
# *注意：这是备用域名，生产环境请务必配置 OSS (见下文指南)*

# 5. 运行
flutter run
```

---

## 📖 站长对接指南 (详细版)

Flux 提供了一整套定制化方案，请按以下步骤完成配置。

### 第一步：基础配置 (必做)

1.  **修改 App 包名 (Application ID)**
    *   *Android*: `android/app/build.gradle.kts` -> `applicationId`
    *   *iOS*: `ios/Runner.xcodeproj/project.pbxproj` -> `PRODUCT_BUNDLE_IDENTIFIER`
    *   *Windows*: `pubspec.yaml` -> `msix_config.identity_name`
    *   *Linux*: `linux/CMakeLists.txt` -> `APPLICATION_ID`

2.  **修改 App 名称与图标**
    *   *名称*: 修改 `pubspec.yaml` `name` 及各平台配置文件 (AndroidManifest.xml, Info.plist 等)。
    *   *图标*: 替换 `assets/images/app_icon.png` (1024x1024)，运行 `flutter pub run flutter_launcher_icons`。

### 第二步：后端加密配置 (防止滥用)

Flux 默认对部分敏感接口参数 (如邮件验证) 进行 AES-128 加密。

1.  打开 `lib/services/v2board_api.dart`。
2.  找到 `_emailVerifyKey`，填入一个 **16位** 随机字符串。
3.  确保你的后端支持解密，或者将 `useEncryption` 设为 `false` 关闭此功能。

### 第三步：OSS 远程配置 (强烈推荐)

通过 OSS 动态下发配置，实现**域名防封**与**功能开关**。

**1. 准备配置文件**
*   参考根目录 `release_config_plaintext.json` 模板。
*   配置备用域名 (`domains`)、更新检测 (`update`) 和客服 ID (`contact`).

**2. 加密并上传**
*   修改 `lib/utils/config_encryption.dart` 中的 `_encryptionKey` (App端密钥)。
*   修改 `encrypt_config.py` 中的 `KEY` (脚本端密钥)，**必须与App端一致**。
*   运行 `python encrypt_config.py` 生成加密文件。
*   上传到 OSS/CDN，获取下载链接。

**3. 接入 App**
*   将链接填入 `lib/services/remote_config_service.dart` 的 `_ossUrls` 列表。

### 第四步：路由规则 (分流)
*   修改 `routing_rules.json`，同样加密后上传 OSS，并在 `release_config` 中配置链接。

---

## 🔧 技术架构

<details>
<summary>点击展开技术细节</summary>

### 核心栈
- **UI 层**: Flutter 3.x + Material Design 3
- **逻辑层**: `UnifiedVpnService` 统一调度
- **内核层**: V2Ray / SingBox (Dual Core)

### 平台实现
| 平台 | 机制 | 说明 |
|:---|:---|:---|
| Android | `VpnService` | TUN 模式，无需 Root |
| iOS | `NetworkExtension` | Packet Tunnel Provider |
| Desktop | System Proxy + Sidecar | 系统代理 / TUN + 守护进程 |

### 目录结构
```
lib/
├── main.dart              # 入口
├── screens/               # 页面
├── services/              # 核心服务
│   ├── remote_config_service.dart # 👈 核心配置在这里
│   ├── v2ray_service.dart         # V2Ray内核
│   ├── singbox_service.dart       # SingBox内核 (TUN)
│   └── unified_vpn_service.dart   # 统一调度
├── models/                # 数据模型
└── widgets/               # 组件
```

</details>

---

## 📝 附录：配置文件详解

### 1. `release_config_plaintext.json` (核心配置)

⚠️ **注意：此文件不能直接上传！必须使用 `encrypt_config.py` 加密！**

1.  修改此文件内容。
2.  运行 `python encrypt_config.py` 生成 `release_config.json`。
3.  将生成的 `release_config.json` 上传至 OSS。

| 字段 | 说明 | 示例/备注 |
|:---|:---|:---|
| `config_version` | **配置版本号** | 每次修改配置后**必须+1**，App 才会重新拉取生效 |
| `domains` | **备用域名列表** | `["https://api.spare.com"]`，主 API 连不上时会自动切换 |
| `update` | **更新检查** | 包含 Android/Windows 等平台的 `version`, `url`, `force`(强制更新) |
| `announcement` | **首页公告** | `enabled`: 是否开启弹窗, `content`: 公告内容 |
| `maintenance` | **维护模式** | `enabled`: `true` 时用户无法使用 App，显示 `message` |
| `contact` | **联系方式** | `crisp_website_id`: 配置 Crisp 客服 ID |
| `features` | **功能开关** | `purchase_enabled`: 开启充值, `invite_enabled`: 开启邀请 |
| `routing_rules.url` | **路由规则地址** | 指向 OSS 上的 `routing_rules.json` 下载链接 |
| `recommended_nodes` | **推荐节点** | (可选) 首页显示的推荐节点 Tag 列表 |
| `backup_subscription` | **备用订阅** | (可选) 当 API 完全挂掉时，使用的备用 V2Ray 订阅地址 |

### 2. `routing_rules.json` (分流规则)

控制流量走代理还是直连，规则自上而下匹配。

```json
{
    "type": "field",
    "outboundTag": "direct", // 流量出口: proxy(代理), direct(直连), block(拦截)
    "domain": ["geosite:cn"], // 域名规则: geosite:cn 代表中国域名
    "ip": ["geoip:cn"]        // IP规则: geoip:cn 代表中国IP
}
```

---

## 💰 商业合作

如果你需要更专业的定制服务：

| 服务 | 说明 |
| :--- | :--- |
| 🎨 **UI 定制** | 改配色、改布局、加独家功能 (如流量悬浮窗) |
| 🔐 **授权系统** | 加入设备授权验证、多设备管理、到期弹窗提醒 |

由 **[@fluxdeveloper](https://t.me/fluxdeveloper)** 提供技术支持。

### ☕ 赞助开源

如果你觉得 Flux 不错，欢迎请作者喝杯咖啡：

| USDT (TRC20) | USDC (Arbitrum) | ETH (Arbitrum) |
| :---: | :---: | :---: |
| <img src="assets/images/donation/usdt_trc20.png" width="150"> | <img src="assets/images/donation/usdc_arbitrum.png" width="150"> | <img src="assets/images/donation/eth_arbitrum.png" width="150"> |

---

## 🔗 相关项目

*   [Sing-box](https://github.com/SagerNet/sing-box) - 通用代理平台 (核心引擎)
*   [Xray-core](https://github.com/XTLS/Xray-core) - 强大的网络工具
*   [V2Board](https://github.com/v2board/v2board) - 机场面板
*   [hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel) - 高性能 TUN 模式实现

---

## 📄 License

MIT License - 可自由商用、修改与分发。

---
> **Tags**: V2Board客户端, 机场专属App, Flutter代理客户端, 白标VPN, 开源代理工具, 科学上网, 机场托管, 流量变现
