<#Requires -Version 5.1>
<#
.SYNOPSIS
  Instaluje testowy profil UV (TEST1/2/3) dla RTX 3070 Ti (DEV_2482) na zasilacz Dell 12V @ 18A.
.DESCRIPTION
  Znajduje LIVE plik profilu karty w MSI Afterburner\Profiles (po DEV_2482, nie po sztywnej
  nazwie - koncowka BUS_x zalezy od slotu PCIe), robi backup z timestampem i wgrywa
  zawartosc wybranego testu z tego repo, ZACHOWUJAC lokalna nazwe pliku.
  Uruchamiac PRZY ZAMKNIETYM MSI Afterburner i RTSS.
.PARAMETER Test
  1 = 1830 MHz @ 825 mV, Mem +0, PL 70% (baza)
  2 = 1845 MHz @ 825 mV, Mem +0, PL 70%
  3 = 1860 MHz @ 825 mV, Mem +500, PL 70% (max)
.EXAMPLE
  .\Install-GpuProfile.ps1 -Test 1
#>
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet(1, 2, 3)]
  [int]$Test
)

$ErrorActionPreference = 'Stop'

$map = @{
  1 = 'TEST1_1830MHz_825mV_MEM+0_PL70'
  2 = 'TEST2_1845MHz_825mV_MEM+0_PL70'
  3 = 'TEST3_1860MHz_825mV_MEM+500_PL70'
}

if (Get-Process -Name 'MSIAfterburner' -ErrorAction SilentlyContinue) {
  throw 'MSI Afterburner jest uruchomiony. Zamknij go (i RTSS) i uruchom skrypt ponownie.'
}

$candidates = @(
  (Join-Path ${env:ProgramFiles(x86)} 'MSI Afterburner\Profiles'),
  (Join-Path $env:ProgramFiles 'MSI Afterburner\Profiles')
) | Where-Object { $_ -and (Test-Path $_) }

if (-not $candidates) { throw 'Nie znaleziono katalogu MSI Afterburner\Profiles.' }
$profilesDir = $candidates[0]
Write-Host "Profiles: $profilesDir"

$live = Get-ChildItem -Path $profilesDir -Filter 'VEN_10DE*DEV_2482*.cfg' -File |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $live) { throw 'Brak pliku VEN_*DEV_2482*.cfg - to nie jest PC z RTX 3070 Ti. Nic nie podmieniam.' }
Write-Host "Live plik karty: $($live.Name)"

$src = Join-Path $PSScriptRoot ($map[$Test] + '\VEN_10DE&DEV_2482&SUBSYS_146A10DE&REV_A1&BUS_1&DEV_0&FN_0.cfg')
# awaryjnie: wez jedyny .cfg z folderu testu (gdyby nazwa BUS sie roznila)
if (-not (Test-Path $src)) {
  $src = Get-ChildItem -Path (Join-Path $PSScriptRoot $map[$Test]) -Filter '*.cfg' -File |
    Select-Object -First 1 -ExpandProperty FullName
}
if (-not $src -or -not (Test-Path $src)) { throw "Nie znaleziono pliku testu w folderze $($map[$Test])." }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $profilesDir ($live.BaseName + ".bak-$stamp.cfg")
Copy-Item -Path $live.FullName -Destination $backup
Write-Host "Backup: $(Split-Path $backup -Leaf)"

Copy-Item -Path $src -Destination $live.FullName -Force
Write-Host "Wgrano $($map[$Test]) jako $($live.Name)"
Write-Host 'Dalej: otworz Afterburner > kliknij profil 1 > Apply > Curve Editor (plasko od 825 mV) > test z AGENTS.md.'
