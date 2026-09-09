@echo off
title 高性能游戏启动器 (无痕模式)
chcp 65001 >nul
cls

echo ======================================
echo  正在搜捕当前文件夹下的 HTML 游戏...
echo ======================================

:: 1. 自动查找当前目录下第一个 .html 文件（优先找 index.html）
set "html_file="
if exist "index.html" set "html_file=index.html"
if not defined html_file (
    for %%f in (*.html) do (
        set "html_file=%%f"
        goto :found
    )
)
:found

if not defined html_file (
    echo [错误] 没有找到任何 .html 文件！
    echo 请把这个 .bat 文件和你的游戏HTML放在同一个文件夹。
    pause
    exit /b
)
echo [成功] 找到游戏文件：%html_file%
echo.

:: 2. 强行抓取浏览器（无视 PATH 环境变量）
set "browser="

:: 先试试能不能直接调起（万一你装了绿色版）
for /f "usebackq tokens=*" %%i in (`where chrome 2^>nul`) do set "browser=%%i"
if not defined browser (
    for /f "usebackq tokens=*" %%i in (`where msedge 2^>nul`) do set "browser=%%i"
)

:: 如果 where 找不到，直接抄家伙去默认安装目录硬搜！
if not defined browser (
    if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" set "browser=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
)
if not defined browser (
    if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" set "browser=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

:: 3. 最后再抢救一下：如果还是没找到，用 Windows 的 start 命令直接唤醒来宾模式
if not defined browser (
    echo [警告] 没找到 exe 路径，尝试用系统协议唤醒 Edge...
    set "browser=msedge"
)

echo [启动] 正在调用浏览器内核：%browser%
echo [参数] 强制开启GPU硬件加速、禁用渲染节流、锁定独立显卡...

:: 获取文件的绝对路径
set "full_path=%~dp0%html_file%"

:: 启动浏览器，带上极致性能参数
start "" "%browser%" ^
--enable-gpu ^
--ignore-gpu-blocklist ^
--enable-features="Vulkan,DefaultANGLEVulkan,OverrideSoftwareRenderingList" ^
--disable-software-rasterizer ^
--disable-gpu-watchdog ^
--disable-renderer-backgrounding ^
--disable-backgrounding-occluded-windows ^
--disable-background-timer-throttling ^
--disable-client-side-phishing-detection ^
--disable-default-apps ^
--disable-extensions ^
--disable-plugins ^
"file:///%full_path%"

:: ===== 关键改动：不再 pause，直接优雅退出 =====
echo.
echo 游戏已启动！此窗口将在 1 秒后自动关闭...
timeout /t 1 /nobreak >nul
exit