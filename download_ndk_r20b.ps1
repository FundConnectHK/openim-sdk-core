# NDK r20b 自动下载安装脚本
# 需要管理员权限运行

param(
    [string]$SDKPath = "C:\Users\yu142\AppData\Local\Android\Sdk"
)

# 设置变量
$NDK_URL = "https://dl.google.com/android/repository/android-ndk-r20b-windows-x86_64.zip"
$NDK_ZIP = "$env:TEMP\android-ndk-r20b.zip"
$NDK_BUNDLE = "$SDKPath\ndk-bundle"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NDK r20b 自动下载安装脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "SDK 路径: $SDKPath" -ForegroundColor Gray
Write-Host "目标路径: $NDK_BUNDLE" -ForegroundColor Gray
Write-Host ""

# 检查是否已存在
if (Test-Path $NDK_BUNDLE) {
    Write-Host "[警告] ndk-bundle 目录已存在" -ForegroundColor Yellow
    Write-Host ""
    $overwrite = Read-Host "是否覆盖? (Y/N)"
    if ($overwrite -ne "Y" -and $overwrite -ne "y") {
        Write-Host "取消安装" -ForegroundColor Red
        Read-Host "按 Enter 键退出"
        exit 0
    }
    Write-Host "删除旧版本..." -ForegroundColor Yellow
    Remove-Item $NDK_BUNDLE -Recurse -Force -ErrorAction SilentlyContinue
}

# 下载 NDK
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[1/3] 下载 NDK r20b" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URL: $NDK_URL" -ForegroundColor Gray
Write-Host "大小: 约 800 MB" -ForegroundColor Gray
Write-Host "预计时间: 10-30 分钟（取决于网络速度）" -ForegroundColor Gray
Write-Host ""
Write-Host "下载中，请耐心等待..." -ForegroundColor Yellow
Write-Host ""

try {
    # 使用 .NET WebClient 下载
    $webClient = New-Object System.Net.WebClient
    
    # 进度更新
    $lastPercent = 0
    Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
        $percent = $EventArgs.ProgressPercentage
        $received = [Math]::Round($EventArgs.BytesReceived / 1MB, 2)
        $total = [Math]::Round($EventArgs.TotalBytesToReceive / 1MB, 2)
        
        if ($percent -gt $using:lastPercent) {
            $using:lastPercent = $percent
            Write-Progress -Activity "下载 NDK r20b" `
                          -Status "$percent% 完成 - $received MB / $total MB" `
                          -PercentComplete $percent
        }
    } | Out-Null
    
    # 下载完成事件
    Register-ObjectEvent -InputObject $webClient -EventName DownloadFileCompleted -Action {
        Write-Progress -Activity "下载 NDK r20b" -Completed
    } | Out-Null
    
    # 开始下载
    $webClient.DownloadFileAsync((New-Object System.Uri($NDK_URL)), $NDK_ZIP)
    
    # 等待完成
    while ($webClient.IsBusy) {
        Start-Sleep -Milliseconds 500
    }
    
    # 清理事件
    Get-EventSubscriber | Where-Object { $_.SourceObject -eq $webClient } | Unregister-Event
    $webClient.Dispose()
    
    Write-Host ""
    Write-Host "[✓] 下载完成!" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "[✗] 下载失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "请手动下载并安装:" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 下载地址:" -ForegroundColor Yellow
    Write-Host "   $NDK_URL" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. 解压到:" -ForegroundColor Yellow
    Write-Host "   $NDK_BUNDLE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. 确保解压后的目录结构为:" -ForegroundColor Yellow
    Write-Host "   $NDK_BUNDLE\" -ForegroundColor Cyan
    Write-Host "   ├── build\" -ForegroundColor Cyan
    Write-Host "   ├── meta\" -ForegroundColor Cyan
    Write-Host "   ├── platforms\" -ForegroundColor Cyan
    Write-Host "   └── ..." -ForegroundColor Cyan
    Write-Host ""
    Read-Host "按 Enter 键退出"
    exit 1
}

# 解压 NDK
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[2/3] 解压 NDK" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "解压中，这可能需要几分钟..." -ForegroundColor Yellow
Write-Host ""

try {
    # 加载压缩库
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    # 临时解压目录
    $tempExtract = "$env:TEMP\ndk-r20b-extract"
    if (Test-Path $tempExtract) {
        Remove-Item $tempExtract -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null
    
    # 解压
    Write-Host "解压到临时目录..." -ForegroundColor Gray
    [System.IO.Compression.ZipFile]::ExtractToDirectory($NDK_ZIP, $tempExtract)
    
    # 查找 NDK 目录（可能是 android-ndk-r20b）
    $extractedDirs = Get-ChildItem $tempExtract -Directory
    if ($extractedDirs.Count -eq 0) {
        throw "解压后未找到目录"
    }
    
    $ndkDir = $extractedDirs[0]
    Write-Host "移动到目标位置..." -ForegroundColor Gray
    Move-Item $ndkDir.FullName $NDK_BUNDLE -Force
    
    # 清理
    Write-Host "清理临时文件..." -ForegroundColor Gray
    Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $NDK_ZIP -Force -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Host "[✓] 解压完成!" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "[✗] 解压失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "请手动解压:" -ForegroundColor Yellow
    Write-Host "  ZIP 文件: $NDK_ZIP" -ForegroundColor Cyan
    Write-Host "  目标位置: $NDK_BUNDLE" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "按 Enter 键退出"
    exit 1
}

# 验证安装
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[3/3] 验证安装" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$isValid = $true

# 检查关键文件
$requiredFiles = @(
    "meta\platforms.json",
    "build\tools\make_standalone_toolchain.py",
    "platforms",
    "toolchains"
)

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $NDK_BUNDLE $file
    if (Test-Path $fullPath) {
        Write-Host "[✓] 找到: $file" -ForegroundColor Green
    } else {
        Write-Host "[✗] 缺失: $file" -ForegroundColor Red
        $isValid = $false
    }
}

Write-Host ""

if ($isValid) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ NDK r20b 安装成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "安装路径:" -ForegroundColor Cyan
    Write-Host "  $NDK_BUNDLE" -ForegroundColor White
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "下一步：编译 Android AAR" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "在项目目录运行:" -ForegroundColor White
    Write-Host "  cd E:\openim-sdk-core" -ForegroundColor Cyan
    Write-Host "  .\build_android.bat" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "或者手动运行:" -ForegroundColor White
    Write-Host "  gomobile bind -v -trimpath -ldflags=`"-s -w`" -o ./open_im_sdk.aar -target=android ./open_im_sdk/ ./open_im_sdk_callback/" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "✗ 安装验证失败" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查安装目录:" -ForegroundColor Yellow
    Write-Host "  $NDK_BUNDLE" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host ""
Read-Host "按 Enter 键退出"

