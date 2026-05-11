#!/bin/bash

#========================================
# MC Admin - Node.js升级与PM2安装脚本
# 适用于 Ubuntu/Debian
#========================================

echo "=========================================="
echo "Node.js升级与PM2安装脚本"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用root用户运行此脚本${NC}"
    exit 1
fi

# 显示当前版本
echo -e "${YELLOW}当前Node.js版本:${NC}"
node --version
echo ""

# 步骤1：移除旧版本
echo -e "${YELLOW}[1/4] 移除旧版本Node.js和npm...${NC}"
apt-get remove -y nodejs npm
apt-get autoremove -y
rm -rf /usr/bin/node /usr/local/bin/node /usr/local/lib/node_modules

# 步骤2：安装Node.js 18.x
echo -e "${YELLOW}[2/4] 安装Node.js 18.x...${NC}"

# 安装依赖
apt-get update
apt-get install -y curl

# 添加NodeSource仓库
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# 安装Node.js
apt-get install -y nodejs

# 验证安装
echo ""
echo -e "${GREEN}Node.js安装完成！${NC}"
echo -e "Node.js版本: $(node --version)"
echo -e "npm版本: $(npm --version)"
echo ""

# 步骤3：安装PM2
echo -e "${YELLOW}[3/4] 安装PM2...${NC}"
npm install -g pm2

# 验证PM2安装
if command -v pm2 &> /dev/null; then
    echo -e "${GREEN}PM2安装成功！${NC}"
    echo -e "PM2版本: $(pm2 --version)"
else
    echo -e "${RED}PM2安装失败${NC}"
    exit 1
fi

# 步骤4：启动MC Admin服务
echo -e "${YELLOW}[4/4] 启动MC Admin服务...${NC}"
cd /opt/mc-admin-server

# 检查目录是否存在
if [ ! -d "/opt/mc-admin-server" ]; then
    echo -e "${RED}目录 /opt/mc-admin-server 不存在${NC}"
    echo -e "${YELLOW}请先克隆代码：${NC}"
    echo "git clone https://github.com/Fissionalist/mc-man-server.git /opt/mc-admin-server"
    exit 1
fi

# 安装依赖（如果还没有安装）
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}安装项目依赖...${NC}"
    npm install
fi

# 构建前端
if [ ! -d "client/dist" ]; then
    echo -e "${YELLOW}构建前端...${NC}"
    cd client
    npm install
    cd ..
    npm run build
fi

# 停止旧进程
pm2 delete mc-admin 2>/dev/null

# 启动服务
pm2 start server/index.js --name mc-admin

# 保存进程
pm2 save

# 设置开机自启
pm2 startup

echo ""
echo "=========================================="
echo -e "${GREEN}安装完成！${NC}"
echo "=========================================="
echo ""
echo "服务状态:"
pm2 status
echo ""
echo "访问地址: http://120.27.205.116:3000"
echo ""
echo "常用命令:"
echo "  查看日志: pm2 logs mc-admin"
echo "  重启服务: pm2 restart mc-admin"
echo "  查看状态: pm2 status"
echo ""
