# YummyRepo

自动收集 RPM 包并构建自建 YUM 仓库，通过 S3 存储分发。

## 项目简介

本项目通过 GitHub Actions 定时从指定的 GitHub Releases 和 AUR 抓取 x86_64 架构的 RPM 包，使用 `createrepo_c` 生成 YUM 仓库元数据，并同步到 S3 存储，作为自建的 YUM 源使用。

## 工作流程

```
┌─────────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│  GitHub Releases │ ──> │  Fetch RPMs  │ ──> │ createrepo_c │ ──> │   S3     │
│  AUR 软件源      │     │  (fetch.sh)  │     │  生成元数据   │     │  存储    │
└─────────────────┘     └──────────────┘     └──────────────┘     └──────────┘
```

## 项目结构

```
YummyRepo/
├── .github/
│   └── workflows/
│       └── update.yml          # GitHub Actions 工作流配置
├── scripts/
│   ├── fetch.sh                # RPM 包抓取主脚本
│   ├── lib.sh                  # 公共函数库
│   ├── enabled.list            # 启用的 AUR 软件列表
│   └── avalible-pkgs/          # 各软件的更新脚本
│       ├── wps-cn.sh
│       └── trae-cn.sh
├── state/
│   └── releases.json           # 版本状态记录（自动生成）
├── packages/                   # RPM 包存放目录（由脚本创建）
├── .gitignore
└── README.md
```

## 自动化流程

### 触发条件

- **定时执行**: 每 24 小时自动运行一次 (`0 */24 * * *`)
- **代码推送**: 推送到 `main` 分支时触发
- **手动触发**: 通过 GitHub Actions 页面手动运行

### 执行步骤

1. **Checkout** - 拉取仓库代码
2. **Install tools** - 安装 `createrepo-c`、`jq`、`curl` 等工具
3. **Fetch RPMs** - 运行 `scripts/fetch.sh` 从 GitHub Releases 和 AUR 下载 RPM 包
4. **Generate metadata** - 使用 `createrepo_c --update packages` 生成 YUM 仓库元数据（仅在有更新时）
5. **Upload RPMs** - 将 RPM 包同步到 S3 存储（仅在有更新时）
6. **Upload repodata** - 将元数据同步到 S3 存储（仅在有更新时）
7. **Commit state** - 提交版本状态文件到仓库（仅在有更新时）

## 配置说明

### 环境变量

工作流需要以下 Secrets 配置：

| 变量名 | 类型 | 说明 |
|--------|------|------|
| `AWS_KEY` | Secret | S3 访问密钥 ID |
| `AWS_SECRET` | Secret | S3 访问密钥 |
| `BUCKET_NAME` | Secret | S3 存储桶名称 |
| `BASE_URL` | Secret | S3 端点 URL |

### 添加新的 RPM 源

#### GitHub Release 软件

编辑 `scripts/fetch.sh` 中的 `REPOS` 数组：

```bash
REPOS=(
  "chen08209/FlClash"
  "xishang0128/sparkle"
  "nashaofu/shell360"
  "farion1231/cc-switch"
  "owner/new-repo"  # 添加新的 GitHub 仓库
)
```

脚本会自动下载匹配 `*.rpm` 且包含 `x86_64` 或 `amd64` 的文件。

#### AUR 软件

1. 在 `scripts/avalible-pkgs/` 中创建更新脚本，如 `myapp.sh`：

```bash
#!/bin/bash
update_myapp() {
  local pkgver=$(get_aur_pkgver "myapp-aur")
  local old_ver=$(jq -r '.["myapp"] // "null"' state/releases.json)
  
  if [ "$pkgver" != "$old_ver" ]; then
    echo "New version: myapp $pkgver"
    # 下载 RPM 包的逻辑...
    
    # 更新状态
    tmp=$(mktemp)
    jq --arg pkg "myapp" --arg ver "$pkgver" '.[$pkg]=$ver' state/releases.json > "$tmp"
    mv "$tmp" state/releases.json
    UPDATED=1
  fi
}
```

2. 在 `scripts/enabled.list` 中添加软件名（每行一个）：

```
myapp
```

## 使用自建 YUM 仓库

在客户端配置 YUM 源：
```shell
sudo vim /etc/yum.repos.d/yummyrepo.repo
```

```conf
[yummyrepo]
name=YummyRepo Custom RPM Repository
baseurl=<endpoint-url>/<bucket-name>/
enabled=1
gpgcheck=0
```

然后即可安装：

```bash
sudo dnf clean all
sudo dnf makecache
sudo dnf install FlClash
sudo dnf install sparkle
```

## 本地测试

如果需要本地运行抓取脚本：

```bash
# 安装依赖
sudo apt-get install -y createrepo-c jq curl wget

# 运行抓取脚本
bash scripts/fetch.sh

# 生成元数据
createrepo_c --update packages
```

## 注意事项

- 脚本使用 `wget -nc` 避免重复下载已存在的文件
- `createrepo_c --update` 会增量更新元数据
- 只有检测到新版本时才会生成元数据和上传 S3
- `state/releases.json` 记录各软件的版本状态，用于增量更新判断

```bash
# 安装依赖
sudo apt-get install -y jq curl wget createrepo-c

# 运行抓取脚本
bash scripts/fetch.sh

# 生成元数据
createrepo_c --update packages
```
