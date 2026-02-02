# 配置文件说明 / Configuration Guide

## 概述

本项目使用远程配置系统来管理：
- API 域名切换
- 版本更新检测
- 公告和维护模式
- 路由分流规则
- 客服联系方式

## 文件说明

| 文件名 | 用途 |
|--------|------|
| `release_config_plaintext.json` | 配置明文模板（编辑此文件） |
| `encrypt_config.py` | 配置加密工具 |
| `release_config_encrypted.txt` | 加密后的配置（上传到 OSS） |
| `routing_rules.json` | 路由分流规则（直连/代理/阻止） |

## 使用步骤

### 1. 修改配置密钥

在以下两个文件中设置**相同**的加密密钥（至少 24 字符）：

**Python 脚本** (`encrypt_config.py`):
```python
KEY = "YOUR_ENCRYPTION_KEY_HERE_24CH"  # 替换为你的密钥
```

**Dart 代码** (`lib/utils/config_encryption.dart`):
```dart
static const String _encryptionKey = 'YOUR_ENCRYPTION_KEY_HERE_24CH';  // 必须与 Python 一致
```

### 2. 编辑配置文件

修改 `release_config_plaintext.json`：

```json
{
    "config_version": 1,
    "domains": [
        "https://your-v2board-api.com"  // 你的 V2Board API 域名
    ],
    "update": {
        "latest": {
            "android": {
                "version": "1.0.0",
                "url": "https://your-oss.com/app.apk"  // 应用下载链接
            }
            // ... 其他平台
        }
    },
    "routing_rules": {
        "version": 1,
        "url": "https://your-oss.com/routing_rules.json"  // 路由规则文件 URL
    },
    "contact": {
        "telegram": "https://t.me/your_support",
        "email": "support@your-domain.com",
        "crisp_website_id": "your-crisp-id"  // Crisp 客服 ID（可选）
    }
}
```

### 3. 加密配置

```bash
python encrypt_config.py
```

输出:
```
正在读取 release_config_plaintext.json ...
正在加密...
✅ 加密成功!
📁 已保存到: release_config_encrypted.txt
```

### 4. 上传到 OSS

将 `release_config_encrypted.txt` 的**内容**上传到你的 OSS/CDN，命名为 `release_config.json`。

### 5. 配置 Dart 代码

修改 `lib/services/remote_config_service.dart`：

```dart
static const List<String> _ossUrls = [
    'https://your-oss.com/release_config.json',  // 你的 OSS 地址
];

static const String _defaultDomain = 'https://your-v2board-api.com';  // 备用域名
```

## 路由规则说明

`routing_rules.json` 定义流量分流逻辑：

```json
{
    "rules": [
        {
            "type": "field",
            "outboundTag": "block",      // 阻止广告
            "domain": ["geosite:category-ads-all"]
        },
        {
            "type": "field",
            "outboundTag": "direct",     // 直连中国站点
            "domain": ["geosite:cn", "geosite:private"]
        },
        {
            "type": "field",
            "outboundTag": "proxy",      // 其他走代理
            "network": "tcp,udp"
        }
    ]
}
```

## 需要替换的敏感配置

搜索项目中的 `TODO:` 注释查看所有需要替换的位置：

| 文件 | 配置项 |
|------|--------|
| `config_encryption.dart` | `_encryptionKey` 加密密钥 |
| `remote_config_service.dart` | `_ossUrls` OSS 地址 |
| `remote_config_service.dart` | `_defaultDomain` 默认 API |
| `v2board_api.dart` | `_emailVerifyKey` 邮箱验证密钥 |
| `v2ray_service.dart` | 路由规则中的 API 域名 |

## 安全提示

⚠️ **不要**将以下内容提交到公开仓库：
- 真实的加密密钥
- 真实的 API 域名
- 真实的 OSS URL
- Crisp Website ID

建议使用 `.env` 文件或 CI/CD 环境变量管理敏感配置。
