#!/bin/bash

echo "开始部署MC Admin管理系统..."

echo "1. 安装Node.js依赖..."
npm install

echo "2. 安装前端依赖..."
cd client && npm install && cd ..

echo "3. 构建前端..."
cd client && npm run build && cd ..

echo "4. 复制构建文件到public目录..."
mkdir -p public
cp -r client/dist/* public/

echo "5. 创建.env文件(如果不存在)..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "请编辑.env文件配置RCON密码"
fi

echo "6. 安装PM2进程管理器..."
npm install -g pm2

echo "7. 启动服务..."
pm2 delete mc-admin 2>/dev/null
pm2 start server/index.js --name mc-admin

echo "8. 保存PM2进程列表..."
pm2 save

echo "9. 设置PM2开机自启..."
pm2 startup

echo "========================================"
echo "部署完成!"
echo "========================================"
echo "请确保在server.properties中配置了RCON:"
echo "enable-rcon=true"
echo "rcon.port=25575"
echo "rcon.password=your_password"
echo ""
echo "请编辑.env文件配置正确的RCON_PASSWORD"
echo ""
echo "服务已启动，可以通过以下地址访问:"
echo "http://your-server-ip:3000"
echo ""
echo "默认管理员账户: admin / admin123"
echo "========================================"
