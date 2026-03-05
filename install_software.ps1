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

$scriptPath = $PSScriptRoot

# ============================================================
# 1. VISUAL C++ RUNTIMES
# ============================================================
Write-Host ""
Write-Host "📦 Установка Visual C++ Runtimes..." -ForegroundColor White

$vcZip = Join-Path -Path $scriptPath -ChildPath "Visual-C-Runtimes-All-in-One-Dec-2025.zip"
$tempExtractedPath = Join-Path -Path $env:TEMP -ChildPath "VC_Runtimes_Temp"

if (Test-Path $vcZip) {
    Write-Host "   Извлечение файлов..."
    if (Test-Path $tempExtractedPath) { Remove-Item -Path $tempExtractedPath -Recurse -Force }
    Expand-Archive -Path $vcZip -DestinationPath $tempExtractedPath -Force
    
    $installBat = Join-Path -Path $tempExtractedPath -ChildPath "install_all.bat"
    if (Test-Path $installBat) {
        Write-Host "   Запуск установки..."
        # Запуск install_all.bat и ожидание завершения
        Start-Process -FilePath $installBat -WorkingDirectory $tempExtractedPath -Wait -NoNewWindow
        Write-Host "   ✅ Visual C++ Runtimes установлены." -ForegroundColor Green
    } else {
        Write-Host "   ❌ Не найден install_all.bat в архиве." -ForegroundColor Red
    }
    
    # Очистка
    Remove-Item -Path $tempExtractedPath -Recurse -Force | Out-Null
} else {
    Write-Host "   ⚠️  Архив $vcZip не найден. Пропуск." -ForegroundColor Yellow
}

# ============================================================
# 2. УСТАНОВКА ПРОГРАММ ЧЕРЕЗ WINGET
# ============================================================
Write-Host ""
Write-Host "📥 Установка программ через Winget..." -ForegroundColor White

$wingetApps = @(
    "Bitwarden.Bitwarden",
    "Rclone.Rclone",
    "kapitainsky.RcloneBrowser",
    "Microsoft.Sysinternals.Autoruns",
    "EpicGames.EpicGamesLauncher",
    "PeterPawlowski.foobar2000",
    "Daum.PotPlayer",
    "mcmilk.7zip-zstd",
    "c0re100.qBittorrent-Enhanced-Edition",
    "DuongDieuPhap.ImageGlass",
    "yt-dlp.yt-dlp",
    "Git.Git",
    "Notepad++.Notepad++",
    "Google.Chrome",
    "Mozilla.Firefox",
    "AdrienAllard.FileConverter",
    "Telegram.TelegramDesktop",
    "LocalSend.LocalSend",
    "SumatraPDF.SumatraPDF",
    "AntibodySoftware.WizTree",
    "voidtools.Everything.Lite",
    "Gyan.FFmpeg.Shared",
    "aria2.aria2"
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
