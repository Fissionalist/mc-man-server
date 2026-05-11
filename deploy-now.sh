#!/bin/bash

#========================================
# MC Admin - 快速部署启动脚本
#========================================

echo "=========================================="
echo "MC Admin - 快速部署启动"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

APP_DIR="/opt/mc-admin-server"

# 检查目录
if [ ! -d "$APP_DIR" ]; then
    echo -e "${YELLOW}[*] 正在克隆代码...${NC}"
    mkdir -p $APP_DIR
    cd $APP_DIR
    git clone https://github.com/Fissionalist/mc-man-server.git .
else
    echo -e "${GREEN}[✓] 代码目录已存在${NC}"
    cd $APP_DIR
fi

echo ""
echo -e "${YELLOW}[1/5] 安装后端依赖...${NC}"
npm install

echo ""
echo -e "${YELLOW}[2/5] 构建前端...${NC}"
cd client
npm install
cd ..
npm run build

echo ""
echo -e "${YELLOW}[3/5] 配置环境变量...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}请编辑 .env 文件配置RCON密码${NC}"
fi

echo ""
echo -e "${YELLOW}[4/5] 配置防火墙...${NC}"
ufw allow 3000/tcp 2>/dev/null || firewall-cmd --permanent --add-port=3000/tcp 2>/dev/null || echo "防火墙配置跳过"

echo ""
echo -e "${YELLOW}[5/5] 启动服务...${NC}"
pm2 delete mc-admin 2>/dev/null
pm2 start server/index.js --name mc-admin
pm2 save
pm2 startup

echo ""
echo "=========================================="
echo -e "${GREEN}[✓] 部署完成！${NC}"
echo "=========================================="
echo ""
echo -e "访问地址: ${GREEN}http://120.27.205.116:3000${NC}"
echo ""
echo -e "默认账户:"
echo "  用户名: ${GREEN}admin${NC}"
echo "  密码: ${GREEN}admin123${NC}"
echo ""
echo -e "${RED}⚠️ 请立即修改默认密码！${NC}"
echo ""
echo "常用命令:"
echo "  查看状态: pm2 status"
echo "  查看日志: pm2 logs mc-admin"
echo "  重启服务: pm2 restart mc-admin"
echo ""
