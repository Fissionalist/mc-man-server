#!/bin/bash

# MC Admin - 启动脚本

APP_DIR="/opt/mc-admin-server"
cd $APP_DIR

echo "=========================================="
echo "MC Admin - 启动服务"
echo "=========================================="
echo ""

# 检查目录
if [ ! -d "$APP_DIR" ]; then
    echo "[错误] 目录不存在: $APP_DIR"
    exit 1
fi

# 检查.env配置
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "[提示] 已创建.env配置文件，请编辑并设置RCON密码"
fi

# 停止旧进程（如果存在）
pm2 delete mc-admin 2>/dev/null

# 启动服务
echo "[*] 启动MC Admin服务..."
pm2 start server/index.js --name mc-admin

# 保存进程列表
echo "[*] 保存PM2进程列表..."
pm2 save

# 设置开机自启
echo "[*] 配置开机自启..."
pm2 startup

echo ""
echo "=========================================="
echo "[✓] 服务已启动！"
echo "=========================================="
echo ""
echo "查看状态: pm2 status"
echo "查看日志: pm2 logs mc-admin"
echo ""
echo "访问地址: http://120.27.205.116:3000"
echo ""
echo "请编辑 /opt/mc-admin-server/.env 配置RCON密码"
echo "然后运行: pm2 restart mc-admin"
echo ""
