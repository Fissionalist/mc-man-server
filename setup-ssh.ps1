# MC Admin SSH Setup Script
# 运行此脚本自动配置SSH并修改仓库remote

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "MC Admin - SSH自动配置脚本" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 检查SSH密钥是否已存在
$sshDir = "$env:USERPROFILE\.ssh"
$keyPath = "$sshDir\id_rsa.pub"

if (Test-Path $keyPath) {
    Write-Host "[✓] SSH密钥已存在" -ForegroundColor Green
    $publicKey = Get-Content $keyPath
} else {
    Write-Host "[*] 正在生成SSH密钥..." -ForegroundColor Yellow
    ssh-keygen -t rsa -b 4096 -C "Fissionalist@GitHub" -f "$sshDir\id_rsa" -N ""

    if (Test-Path $keyPath) {
        Write-Host "[✓] SSH密钥生成成功" -ForegroundColor Green
        $publicKey = Get-Content $keyPath
    } else {
        Write-Host "[✗] SSH密钥生成失败" -ForegroundColor Red
        exit 1
    }
}

# 显示公钥
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "请复制以下公钥并添加到GitHub:" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host $publicKey -ForegroundColor White
Write-Host ""

# 打开GitHub添加密钥页面
Start-Process "https://github.com/settings/keys"

# 询问用户是否已添加
$response = Read-Host "密钥已添加到GitHub了吗？(y/n)"
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "请先在GitHub添加SSH密钥，然后重新运行此脚本" -ForegroundColor Yellow
    exit 0
}

# 修改仓库remote为SSH方式
Set-Location "d:\Code\mc-man-server"

# 移除旧的HTTPS remote
git remote remove origin 2>$null

# 添加新的SSH remote
git remote add origin "git@github.com:Fissionalist/mc-man-server.git"

# 设置默认分支
git branch -M main

Write-Host ""
Write-Host "[✓] Remote已修改为SSH方式" -ForegroundColor Green
Write-Host ""

# 测试SSH连接
Write-Host "[*] 正在测试SSH连接..." -ForegroundColor Yellow
ssh -T git@github.com 2>$null

if ($LASTEXITCODE -eq 1) {
    Write-Host "[✓] SSH连接成功！" -ForegroundColor Green
} else {
    Write-Host "[*] 正在尝试其他方式测试..." -ForegroundColor Yellow
}

# 推送代码
Write-Host ""
Write-Host "[*] 正在推送代码到GitHub..." -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "[✓] 推送成功！" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "以后推送代码只需运行:" -ForegroundColor Cyan
    Write-Host "  git push" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "[✗] 推送失败，请检查错误信息" -ForegroundColor Red
}

Write-Host ""
