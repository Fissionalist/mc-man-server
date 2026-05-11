#!/bin/bash

# MC Admin - 完整部署脚本

APP_DIR="/opt/mc-admin-server"

echo "=========================================="
echo "MC Admin - 完整部署"
echo "=========================================="
echo ""

# 检查目录
if [ ! -d "$APP_DIR" ]; then
    echo "[*] 创建目录并克隆代码..."
    mkdir -p $APP_DIR
    cd $APP_DIR
    git clone https://github.com/Fissionalist/mc-man-server.git .
else
    echo "[*] 目录已存在: $APP_DIR"
    cd $APP_DIR
fi

# 检查server目录
if [ ! -f "server/index.js" ]; then
    echo "[错误] server/index.js 不存在！"
    echo "[*] 重新克隆代码..."
    rm -rf $APP_DIR/*
    git clone https://github.com/Fissionalist/mc-man-server.git $APP_DIR
    cd $APP_DIR
fi

echo ""
echo "[✓] 检查文件结构:"
ls -la
echo ""
echo "[✓] 检查server目录:"
ls -la server/

echo ""
echo "[*] 安装后端依赖..."
npm install

echo ""
echo "[*] 安装前端依赖并构建..."
cd client
npm install
cd ..
npm run build

echo ""
echo "[*] 配置环境变量..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "[提示] 请编辑 .env 文件配置RCON密码"
fi

echo ""
echo "[*] 启动服务..."
pm2 delete mc-admin 2>/dev/null
pm2 start server/index.js --name mc-admin
pm2 save
pm2 startup

echo ""
echo "=========================================="
echo "[✓] 部署完成！"
echo "=========================================="
echo ""
echo "查看状态: pm2 status"
echo "查看日志: pm2 logs mc-admin"
echo ""
echo "访问地址: http://120.27.205.116:3000"
echo ""
echo "请编辑 .env 配置RCON密码"
echo "然后重启服务: pm2 restart mc-admin"
echo ""
