# ============================================================
#  Software Installation Script
#  Запускать от имени Администратора (Run as Administrator)
# ============================================================

# Проверка прав администратора
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Скрипт требует прав Администратора. Запусти через ПКМ → 'Запуск от имени администратора'." -ForegroundColor Red
    pause
    exit
}

# ============================================================
# УСТАНОВКА ПРОГРАММ ЧЕРЕЗ WINGET
# ============================================================
Write-Host ""
Write-Host "Установка программ через Winget..." -ForegroundColor White

$wingetApps = @(
    # --- 1. Системные библиотеки (Visual C++ Redistributables) ---
    "Microsoft.VCRedist.2005.x86",
    "Microsoft.VCRedist.2005.x64",
    "Microsoft.VCRedist.2008.x86",
    "Microsoft.VCRedist.2008.x64",
    "Microsoft.VCRedist.2010.x86",
    "Microsoft.VCRedist.2010.x64",
    "Microsoft.VCRedist.2012.x86",
    "Microsoft.VCRedist.2012.x64",
    "Microsoft.VCRedist.2013.x86",
    "Microsoft.VCRedist.2013.x64",
    "Microsoft.VCRedist.2015+.x86",
    "Microsoft.VCRedist.2015+.x64",

    # --- 2. .NET Runtimes ---
    "Microsoft.DotNet.DesktopRuntime.6",
    "Microsoft.DotNet.DesktopRuntime.8",
    "Microsoft.DotNet.DesktopRuntime.9",

    # --- 3. Инструменты разработки ---
    "Git.Git",
    "Notepad++.Notepad++",
    "EpicGames.EpicGamesLauncher",

    # --- 3. Браузеры ---
    "Google.Chrome",
    "Mozilla.Firefox",

    # --- 4. Системные утилиты ---
    "mcmilk.7zip-zstd",
    "AntibodySoftware.WizTree",
    "voidtools.Everything.Lite",
    "Microsoft.Sysinternals.Autoruns",
    "AdrienAllard.FileConverter",

    # --- 5. Медиа ---
    "Daum.PotPlayer",
    "PeterPawlowski.foobar2000",
    "DuongDieuPhap.ImageGlass",
    "SumatraPDF.SumatraPDF",
    "Gyan.FFmpeg.Shared",

    # --- 6. Загрузчики и торренты ---
    "aria2.aria2",
    "yt-dlp.yt-dlp",
    "c0re100.qBittorrent-Enhanced-Edition",

    # --- 7. Мессенджеры и связь ---
    "Telegram.TelegramDesktop",
    "LocalSend.LocalSend",

    # --- 8. Облако и синхронизация ---
    "Bitwarden.Bitwarden",
    "Rclone.Rclone",
    "kapitainsky.RcloneBrowser"
)

foreach ($app in $wingetApps) {
    Write-Host "   Установка $app ..." -ForegroundColor Cyan
    # Используем --accept-package-agreements и --accept-source-agreements для тихой установки
    winget install -e --id $app --accept-package-agreements --accept-source-agreements
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🎉 Установка программ завершена!" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
pause
