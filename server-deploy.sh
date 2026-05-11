#!/bin/bash

#========================================
# MC Admin - 阿里云服务器部署脚本
# 适用于 Ubuntu/CentOS
#========================================

echo "=========================================="
echo "MC Admin 部署脚本"
echo "服务器: 120.27.205.116"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用root用户运行此脚本${NC}"
    exit 1
fi

# 更新系统
echo -e "${YELLOW}[1/8] 更新系统...${NC}"
if command -v apt-get &> /dev/null; then
    apt-get update && apt-get upgrade -y
elif command -v yum &> /dev/null; then
    yum update -y
fi

# 安装Node.js 18.x
echo -e "${YELLOW}[2/8] 安装Node.js 18.x...${NC}"
if command -v apt-get &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
elif command -v yum &> /dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs
fi

# 验证Node.js安装
node_version=$(node --version)
npm_version=$(npm --version)
echo -e "${GREEN}Node.js版本: $node_version${NC}"
echo -e "${GREEN}npm版本: $npm_version${NC}"
echo ""

# 创建应用目录
echo -e "${YELLOW}[3/8] 创建应用目录...${NC}"
APP_DIR="/opt/mc-admin-server"
if [ -d "$APP_DIR" ]; then
    echo -e "${YELLOW}目录已存在，正在备份...${NC}"
    mv "$APP_DIR" "$APP_DIR.backup.$(date +%s)"
fi

mkdir -p "$APP_DIR"
cd "$APP_DIR"

# 克隆代码
echo -e "${YELLOW}[4/8] 克隆代码...${NC}"
if command -v git &> /dev/null; then
    git clone https://github.com/Fissionalist/mc-man-server.git "$APP_DIR"
    cd "$APP_DIR"
else
    echo -e "${RED}请先安装git: apt-get install git 或 yum install git${NC}"
    exit 1
fi

# 安装后端依赖
echo -e "${YELLOW}[5/8] 安装后端依赖...${NC}"
npm install

# 安装前端依赖并构建
echo -e "${YELLOW}[6/8] 安装前端依赖并构建...${NC}"
cd client
npm install
cd ..
npm run build

# 配置环境变量
echo -e "${YELLOW}[7/8] 配置环境变量...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}请编辑 /opt/mc-admin-server/.env 文件配置RCON密码${NC}"
fi

# 安装PM2
echo -e "${YELLOW}[8/8] 安装PM2并启动服务...${NC}"
npm install -g pm2

# 停止旧进程（如果存在）
pm2 delete mc-admin 2>/dev/null

# 启动服务
pm2 start server/index.js --name mc-admin

# 保存PM2进程列表
pm2 save

# 设置开机自启
pm2 startup

# 配置防火墙
echo ""
echo -e "${YELLOW}配置防火墙...${NC}"
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=3000/tcp
    firewall-cmd --reload
    echo -e "${GREEN}防火墙端口3000已开放${NC}"
elif command -v ufw &> /dev/null; then
    ufw allow 3000/tcp
    echo -e "${GREEN}防火墙端口3000已开放${NC}"
fi

# 显示完成信息
echo ""
echo "=========================================="
echo -e "${GREEN}部署完成！${NC}"
echo "=========================================="
echo ""
echo "访问地址: http://120.27.205.116:3000"
echo ""
echo "默认管理员账户:"
echo "  用户名: admin"
echo "  密码: admin123"
echo ""
echo -e "${RED}⚠️ 重要提醒:${NC}"
echo "1. 请立即修改默认密码！"
echo "2. 请在Minecraft服务器的server.properties中配置RCON"
echo "3. 请编辑 /opt/mc-admin-server/.env 配置RCON密码"
echo ""
echo "常用命令:"
echo "  查看日志: pm2 logs mc-admin"
echo "  重启服务: pm2 restart mc-admin"
echo "  停止服务: pm2 stop mc-admin"
echo "  查看状态: pm2 status"
echo ""
echo "=========================================="
