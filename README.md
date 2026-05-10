# MC Admin - Minecraft服务器管理后台

一个现代化的 Minecraft 服务器管理面板，支持 1.12.2 及以上版本的服务器。

## 功能特性

### 🎮 核心功能
- ✅ **玩家管理** - OP/DEOP、踢出、封禁、白名单
- ✅ **游戏设置** - 难度、游戏模式、天气、时间
- ✅ **世界管理** - 自动保存、立即保存
- ✅ **实时监控** - 在线玩家、服务器状态
- ✅ **多账户** - 支持多个管理员账户
- ✅ **认证系统** - JWT Token 认证
- ✅ **Web Socket** - 实时状态更新

### 🎨 界面特性
- 深色主题，适合长时间使用
- 响应式设计，支持各种屏幕尺寸
- 清晰的操作反馈
- Minecraft 风格的界面设计

## 技术栈

| 技术 | 说明 |
|------|------|
| **后端** | Node.js + Express + Socket.IO |
| **前端** | Vue 3 + Vite + Element Plus |
| **MC通信** | RCON协议 |
| **认证** | JWT + bcrypt |

## 快速开始

### 前置要求

- **Node.js**: >= 16.x
- **Minecraft服务器**: 1.12.2 或更新版本，**已启用RCON**

### 本地开发

```bash
# 1. 克隆项目
git clone <your-repository>
cd mc-man-server

# 2. 安装后端依赖
npm install

# 3. 安装前端依赖
cd client
npm install
cd ..

# 4. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，配置你的 RCON 密码

# 5. 启动开发模式
npm run dev
```

开发模式会同时启动：
- 后端服务 (API + Socket.IO) 运行在 http://localhost:3000
- 前端热开发服务器运行在 http://localhost:8080

### 生产构建和启动

```bash
# 1. 构建前端并复制到 public/
npm run build

# 2. 启动服务
npm start
```

此时访问 http://localhost:3000 即可使用。

## 配置说明

### 环境变量 (.env)

```env
PORT=3000
RCON_HOST=127.0.0.1
RCON_PORT=25575
RCON_PASSWORD=your_rcon_password
JWT_SECRET=mc-admin-secret-key-change-in-production
CLIENT_URL=http://localhost:3000
```

### Minecraft服务器配置 (server.properties)

必须在 Minecraft 服务器中启用 RCON：

```properties
enable-rcon=true
rcon.port=25575
rcon.password=your_secure_password
```

**重启服务器** 使配置生效。

## 默认账户

- **用户名**: `admin`
- **密码**: `admin123`

⚠️ **重要**: 首次登录后请立即修改默认密码！

## 部署到服务器

### Linux (Ubuntu/CentOS)

```bash
# 1. 安装 Node.js 18.x
# Ubuntu/Debian:
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# CentOS/RHEL:
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# 2. 上传项目到服务器并安装依赖
cd /opt/mc-man-server
npm install
cd client && npm install && cd ..

# 3. 构建前端
npm run build

# 4. 安装 PM2
npm install -g pm2

# 5. 使用 PM2 启动服务
pm2 start server/index.js --name mc-admin
pm2 save
pm2 startup
```

### 防火墙配置

```bash
# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload

# Ubuntu UFW
sudo ufw allow 3000/tcp
sudo ufw reload
```

## Nginx 反向代理 (推荐生产环境)

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Static files (frontend)
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    client_max_body_size 10M;
}
```

## 项目结构

```
mc-man-server/
├── server/                 # 后端服务
│   └── index.js           # 主服务器文件
├── client/                # 前端应用
│   ├── src/
│   │   ├── views/         # 页面组件
│   │   ├── api/          # API 封装
│   │   └── router/       # 路由配置
│   └── vite.config.js
├── public/               # 构建输出（生成的文件）
├── package.json
├── .env.example
├── deploy.sh
└── README.md
```

## 常用命令

| 命令 | 说明 |
|------|------|
| `npm run dev` | 启动开发环境 |
| `npm run build` | 构建前端 |
| `npm start` | 生产环境启动 |
| `pm2 logs mc-admin` | 查看服务日志 |
| `pm2 restart mc-admin` | 重启服务 |

## 安全建议

1. 修改默认管理员密码
2. 使用强密码保护 RCON
3. 配置防火墙，限制 25575 端口访问
4. 使用 HTTPS（推荐 Nginx + Let's Encrypt）
5. 定期更新依赖包

## 许可证

MIT License

## 贡献

欢迎 Issue 和 Pull Request！
