# ============================================================
#  Unreal Engine Environment Setup
#  Запускать от имени Администратора (Run as Administrator)
# ============================================================

# Проверка прав администратора
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Скрипт требует прав Администратора. Запусти через ПКМ → 'Запуск от имени администратора'." -ForegroundColor Red
    pause
    exit
}

# ============================================================
# 0. БАЗОВЫЕ СИСТЕМНЫЕ НАСТРОЙКИ
# ============================================================
Write-Host ""
Write-Host "⚙️ Базовые системные настройки..." -ForegroundColor White

# Настройка политики выполнения PowerShell
try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force
    Write-Host "   ✅ Политика выполнения PowerShell установлена на Bypass" -ForegroundColor Green
}
catch {
    Write-Host "   ❌ Ошибка настройки политики выполнения: $_" -ForegroundColor Red
}

# Отключение гибернации
try {
    powercfg.exe /hibernate off
    Write-Host "   ✅ Гибернация отключена (освобождено место на SSD)" -ForegroundColor Green
}
catch {
    Write-Host "   ❌ Ошибка отключения гибернации: $_" -ForegroundColor Red
}

# Включение режима разработчика (Developer Mode)
try {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-Not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $regPath -Name "AllowAllTrustedApps" -Value 1 -Type DWord -Force
    Write-Host "   ✅ Режим разработчика (Developer Mode) включён" -ForegroundColor Green
}
catch {
    Write-Host "   ❌ Ошибка включения режима разработчика: $_" -ForegroundColor Red
}

# ============================================================
# 1. СОЗДАНИЕ ПАПОК
# ============================================================
Write-Host ""
Write-Host "📁 Создание папок..." -ForegroundColor White

$folders = @(
    "C:\Unreal\Projects",
    "C:\Unreal\Engines",
    "C:\Unreal\DDC",
    "C:\Bin",
    "C:\Opt"
)

foreach ($folder in $folders) {
    if (-Not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "   ✅ Создана: $folder" -ForegroundColor Green
    }
    else {
        Write-Host "   ⚠️  Уже существует: $folder" -ForegroundColor Yellow
    }
}

# ============================================================
# 2. СИСТЕМНЫЕ ПЕРЕМЕННЫЕ СРЕДЫ
# ============================================================
Write-Host ""
Write-Host "🔧 Настройка переменных окружения..." -ForegroundColor White

[System.Environment]::SetEnvironmentVariable(
    "UE-LocalDataCachePath",
    "C:\Unreal\DDC",
    [System.EnvironmentVariableTarget]::Machine
)
Write-Host "   ✅ UE-LocalDataCachePath = C:\Unreal\DDC" -ForegroundColor Green

[System.Environment]::SetEnvironmentVariable(
    "UE-SharedDataCachePath",
    "None",
    [System.EnvironmentVariableTarget]::Machine
)
Write-Host "   ✅ UE-SharedDataCachePath = None" -ForegroundColor Green

# ============================================================
# 3. ДЛИННЫЕ ПУТИ (Long Path Support)
# ============================================================
Write-Host ""
Write-Host "📏 Включение поддержки длинных путей..." -ForegroundColor White

try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
        -Name "LongPathsEnabled" -Value 1 -Type DWord -Force
    Write-Host "   ✅ Long Path Support включён (LongPathsEnabled = 1)" -ForegroundColor Green
}
catch {
    Write-Host "   ❌ Ошибка включения длинных путей: $_" -ForegroundColor Red
}

# ============================================================
# 4. TDR — GPU TIMEOUT DETECTION AND RECOVERY
# ============================================================
Write-Host ""
Write-Host "🎮 Настройка TDR (GPU Timeout Detection and Recovery)..." -ForegroundColor White

# TdrDelay  — сколько секунд ждать до сброса драйвера GPU (default: 2s → 60s)
# TdrDdiDelay — сколько секунд ждать перед ошибкой потока драйвера  (default: 5s → 60s)
# Источник: https://dev.epicgames.com/documentation/en-us/unreal-engine/how-to-fix-a-gpu-driver-crash-when-using-unreal-engine

try {
    $tdrPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"

    Set-ItemProperty -Path $tdrPath -Name "TdrDelay"    -Value 60 -Type DWord -Force
    Write-Host "   ✅ TdrDelay    = 60 сек (было 2 сек по умолчанию)" -ForegroundColor Green

    Set-ItemProperty -Path $tdrPath -Name "TdrDdiDelay" -Value 60 -Type DWord -Force
    Write-Host "   ✅ TdrDdiDelay = 60 сек (было 5 сек по умолчанию)" -ForegroundColor Green
}
catch {
    Write-Host "   ❌ Ошибка настройки TDR: $_" -ForegroundColor Red
}

# ============================================================
# 5. ИСКЛЮЧЕНИЯ WINDOWS DEFENDER (Антивирус)
# ============================================================
Write-Host ""
Write-Host "🛡️  Добавление исключений в Windows Defender..." -ForegroundColor White


$exclusionPaths = @(
    "C:\Unreal",
    "C:\Bin",
    "C:\Opt"
)

foreach ($path in $exclusionPaths) {
    try {
        Add-MpPreference -ExclusionPath $path -ErrorAction Stop
        Write-Host "   ✅ Исключение добавлено: $path" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Ошибка для $path : $_" -ForegroundColor Red
    }
}

# Исключение процессов компиляции UE
$exclusionProcesses = @(
    "UnrealBuildTool.exe",
    "UE4Editor.exe",
    "UE5Editor.exe",
    "UnrealEditor.exe",
    "cl.exe",
    "link.exe"
)

foreach ($proc in $exclusionProcesses) {
    try {
        Add-MpPreference -ExclusionProcess $proc -ErrorAction Stop
        Write-Host "   ✅ Процесс исключён: $proc" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Ошибка для $proc : $_" -ForegroundColor Red
    }
}

# ============================================================
# 6. ДОБАВЛЕНИЕ C:\Bin В СИСТЕМНЫЙ PATH
# ============================================================
Write-Host ""
Write-Host "📂 Добавление C:\Bin в системный PATH..." -ForegroundColor White

try {
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
    $pathParts = $currentPath -split ";"
    if ($pathParts -notcontains "C:\Bin") {
        $newPath = $currentPath.TrimEnd(";") + ";C:\Bin"
        [System.Environment]::SetEnvironmentVariable("PATH", $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "   ✅ C:\Bin добавлен в PATH" -ForegroundColor Green
    }
    else {
        Write-Host "   ⚠️  C:\Bin уже есть в PATH" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "   ❌ Ошибка добавления в PATH: $_" -ForegroundColor Red
}

# ============================================================
# 7. ОТКЛЮЧЕНИЕ ИНДЕКСАЦИИ ДЛЯ ПАПКИ DDC
# ============================================================
Write-Host ""
Write-Host "🔍 Отключение индексации для C:\Unreal\DDC..." -ForegroundColor White


try {
    $ddcPath = "C:\Unreal\DDC"
    $folder = Get-Item $ddcPath

    # Получаем текущие атрибуты и добавляем NotContentIndexed
    $folder.Attributes = $folder.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed
    Write-Host "   ✅ Индексация отключена для: $ddcPath" -ForegroundColor Green

    # Применяем ко всем вложенным файлам и папкам
    Get-ChildItem -Path $ddcPath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed
        }
        catch {}
    }
    Write-Host "   ✅ Индексация отключена для вложенных элементов" -ForegroundColor Green
}
catch {
    Write-Host "   ❌ Ошибка отключения индексации: $_" -ForegroundColor Red
}



# ============================================================
# ИТОГ
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🎉 Настройка завершена!" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Рекомендуется перезагрузить компьютер," -ForegroundColor White
Write-Host "  чтобы все изменения вступили в силу." -ForegroundColor White
Write-Host ""
pause
