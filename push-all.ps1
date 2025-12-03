# Multi-Repo Git Push Script for Niaga Platform
# This script pushes all changes to GitHub for all repositories

$repos = @(
    "frontend-admin",
    "frontend-agent",
    "frontend-storefront",
    "frontend-warehouse",
    "infra-database",
    "infra-platform",
    "lib-common",
    "lib-ui",
    "niaga-docs",
    "service-agent",
    "service-auth",
    "service-catalog",
    "service-customer",
    "service-inventory",
    "service-notification",
    "service-order",
    "service-reporting"
)

$rootPath = "c:\Users\PC CUSTOM\Desktop\niaga-platform"
$githubOrg = "MuhammadLuqman-99"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Niaga Platform - Multi-Repo Push Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($repo in $repos) {
    $repoPath = Join-Path $rootPath $repo
    
    if (-not (Test-Path $repoPath)) {
        Write-Host "Skipping $repo - directory not found" -ForegroundColor Yellow
        $skippedCount++
        continue
    }
    
    if (-not (Test-Path (Join-Path $repoPath ".git"))) {
        Write-Host "Skipping $repo - not a git repository" -ForegroundColor Yellow
        $skippedCount++
        continue
    }
    
    Write-Host "Processing: $repo" -ForegroundColor Green
    Push-Location $repoPath
    
    try {
        # Check if there are any changes
        $status = git status --porcelain
        
        if ($status) {
            Write-Host "   Changes detected, staging files..." -ForegroundColor White
            git add .
            git commit -m "Update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        }
        else {
            Write-Host "   No changes to commit" -ForegroundColor Gray
        }
        
        # Check if remote exists
        $remote = git remote get-url origin 2>$null
        
        if (-not $remote) {
            Write-Host "   No remote found, creating GitHub repository..." -ForegroundColor Yellow
            gh repo create "$githubOrg/$repo" --private --source=. --remote=origin --push
            Write-Host "   Created and pushed to new repository" -ForegroundColor Green
        }
        else {
            Write-Host "   Pushing to GitHub..." -ForegroundColor White
            git push origin HEAD
            Write-Host "   Pushed successfully" -ForegroundColor Green
        }
        
        $successCount++
    }
    catch {
        Write-Host "   Error: $_" -ForegroundColor Red
        $failCount++
    }
    finally {
        Pop-Location
    }
    
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Success: $successCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor Red
Write-Host "  Skipped: $skippedCount" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan
