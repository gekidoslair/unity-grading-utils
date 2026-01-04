#usage: .\02_OpenProjectsFromList.ps1 -UnityExe "C:\Program Files\Unity\Hub\Editor\6000.3.2f1\Editor\Unity.exe" -ListFile ".\assignment1_projects.txt" -MaxParallel 5

param(
  [Parameter(Mandatory=$true)]
  [string]$UnityExe,

  [Parameter(Mandatory=$true)]
  [string]$ListFile,

  [int]$MaxParallel = 5,

  [int]$LaunchDelaySeconds = 2
)

$unityPath = (Resolve-Path $UnityExe).Path
$listPath  = (Resolve-Path $ListFile).Path

Write-Host "Unity: $unityPath"
Write-Host "List : $listPath"
Write-Host "Max parallel: $MaxParallel"
Write-Host ""

$raw = Get-Content $listPath -Encoding UTF8

# Allow comments and blank lines in the list file
$projects = $raw |
  ForEach-Object { $_.Trim() } |
  Where-Object { $_ -ne "" -and -not $_.StartsWith("#") }

if ($projects.Count -eq 0) {
  Write-Host "List file contains no project paths (after removing blanks/comments)." -ForegroundColor Yellow
  exit 0
}

$running = New-Object System.Collections.Generic.List[System.Diagnostics.Process]

function Prune-Exited {
  param([System.Collections.Generic.List[System.Diagnostics.Process]]$Procs)
  for ($i = $Procs.Count - 1; $i -ge 0; $i--) {
    if ($Procs[$i].HasExited) { $Procs.RemoveAt($i) }
  }
}

foreach ($p in $projects) {
  $proj = $p

  if (-not (Test-Path $proj)) {
    Write-Host "Skipping (path not found): $proj" -ForegroundColor Yellow
    continue
  }

  if (-not (Test-Path (Join-Path $proj "Assets"))) {
    Write-Host "Skipping (not a Unity project - no Assets folder): $proj" -ForegroundColor Yellow
    continue
  }

  while ($running.Count -ge $MaxParallel) {
    Start-Sleep -Seconds 2
    Prune-Exited $running
  }

  Write-Host "Launching: $proj"
  $proc = Start-Process -FilePath $unityPath -ArgumentList @("-projectPath", $proj) -PassThru
  $running.Add($proc)

  Start-Sleep -Seconds $LaunchDelaySeconds
}

Write-Host ""
Write-Host "All launches queued. Currently running: $($running.Count)"
