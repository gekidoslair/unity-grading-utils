# usage: .\01_GenerateProjectsList.ps1 -Root "D:\projects\VFS\GD80\Assignment1" -OutFile ".\assignment1_projects.txt" -ReportCsv ".\assignment1_report.csv"
param(
  [Parameter(Mandatory=$true)]
  [string]$Root,

  [string]$OutFile = ".\projects.txt",

  [string]$ReportCsv = ".\projects_report.csv",

  [switch]$IncludeMultiplePerStudent
)

$rootPath = (Resolve-Path $Root).Path

Write-Host "Scanning top-level folders under: $rootPath"
Write-Host "Writing list:  $OutFile"
Write-Host "Writing report: $ReportCsv"
Write-Host ""

$topLevel = Get-ChildItem -Path $rootPath -Directory -ErrorAction SilentlyContinue

if ($topLevel.Count -eq 0) {
  Write-Host "No top-level folders found under $rootPath" -ForegroundColor Yellow
  exit 0
}

$foundProjects = New-Object System.Collections.Generic.List[string]
$reportRows = New-Object System.Collections.Generic.List[object]

function IsUnityProjectRoot([string]$path) {
  return (Test-Path (Join-Path $path "Assets")) -and
         (Test-Path (Join-Path $path "ProjectSettings"))
}

function GetRelativeDepth([string]$basePath, [string]$fullPath) {
  if ($fullPath.Length -le $basePath.Length) { return 0 }
  $rel = $fullPath.Substring($basePath.Length).TrimStart([IO.Path]::DirectorySeparatorChar)
  if ([string]::IsNullOrWhiteSpace($rel)) { return 0 }
  return $rel.Split([IO.Path]::DirectorySeparatorChar).Count
}

foreach ($studentFolder in $topLevel) {
  Write-Host "Student folder: $($studentFolder.Name)"

  $dirsToCheck = @($studentFolder.FullName) + @(
    Get-ChildItem -Path $studentFolder.FullName -Directory -Recurse -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty FullName
  )

  $candidates = @(
    $dirsToCheck |
      Where-Object { IsUnityProjectRoot $_ } |
      Sort-Object { GetRelativeDepth $studentFolder.FullName $_ }
  )

  if ($candidates.Count -eq 0) {
    Write-Host "  -> No Unity project found" -ForegroundColor Yellow
    $reportRows.Add([pscustomobject]@{
      StudentFolder = $studentFolder.Name
      ProjectPath   = ""
      Status        = "No Unity project found"
    })
    continue
  }

  if ($IncludeMultiplePerStudent) {
    foreach ($proj in $candidates) {
      Write-Host "  -> Found: $proj" -ForegroundColor Green
      $foundProjects.Add($proj)
      $reportRows.Add([pscustomobject]@{
        StudentFolder = $studentFolder.Name
        ProjectPath   = $proj
        Status        = "Found"
      })
    }
  } else {
    $proj = $candidates[0]
    Write-Host "  -> Using: $proj" -ForegroundColor Green
    $foundProjects.Add($proj)
    $reportRows.Add([pscustomobject]@{
      StudentFolder = $studentFolder.Name
      ProjectPath   = $proj
      Status        = "Found (selected)"
    })

    if ($candidates.Count -gt 1) {
      for ($i = 1; $i -lt $candidates.Count; $i++) {
        $reportRows.Add([pscustomobject]@{
          StudentFolder = $studentFolder.Name
          ProjectPath   = $candidates[$i]
          Status        = "Found (additional)"
        })
      }
    }
  }
}

$unique = $foundProjects | Sort-Object -Unique
$unique | Set-Content -Path $OutFile -Encoding UTF8
$reportRows | Export-Csv -Path $ReportCsv -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Done. Unity projects written: $($unique.Count)"
Write-Host "List:   $OutFile"
Write-Host "Report: $ReportCsv"
