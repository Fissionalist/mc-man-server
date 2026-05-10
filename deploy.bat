@echo off
chcp 65001 > nul
echo ========================================
echo MC Admin 管理面板 - 部署脚本
echo ========================================
echo.

echo [1/6] 检查Node.js安装...
node --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未检测到Node.js，请先安装Node.js
    echo 下载地址: https://nodejs.org/
    pause
    exit /b 1
)
echo Node.js已安装

echo.
echo [2/6] 安装后端依赖...
call npm install
if errorlevel 1 (
    echo 错误: 后端依赖安装失败
    pause
    exit /b 1
)

echo.
echo [3/6] 安装前端依赖...
cd client
call npm install
if errorlevel 1 (
    echo 错误: 前端依赖安装失败
    pause
    exit /b 1
)
cd ..

echo.
echo [4/6] 构建前端...
cd client
call npm run build
if errorlevel 1 (
    echo 错误: 前端构建失败
    pause
    exit /b 1
)
cd ..

echo.
echo [5/6] 创建环境配置文件...
if not exist .env (
    copy .env.example .env
    echo .env文件已创建，请在配置RCON密码
)

echo.
echo [6/6] 安装PM2进程管理器...
call npm install -g pm2

echo.
echo ========================================
echo 部署完成!
echo ========================================
echo.
echo 请确保Minecraft服务器的server.properties中配置了:
echo   enable-rcon=true
echo   rcon.port=25575
echo   rcon.password=your_password
echo.
echo 请编辑.env文件配置正确的RCON密码
echo.
echo 启动服务: npm run dev
echo 或: npm start
echo.
echo 访问地址: http://localhost:3000
echo 默认管理员: admin / admin123
echo ========================================
echo.
pause
