# NIAGA PLATFORM - Multi-Repo Push Script
# Simple version without ANSI colors

param(
    [switch]$DryRun,
    [string]$CommitMessage = "Auto-commit: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

# Get the script directory
$ROOT_DIR = $PSScriptRoot

# List of all repositories  
$REPOS = @(
    "infra-platform",
    "infra-database",
    "lib-common",
    "lib-ui",
    "service-auth",
    "service-catalog",
    "service-inventory",
    "service-order",
    "service-customer",
    "service-notification",
    "service-agent",
    "service-reporting",
    "frontend-storefront",
    "frontend-admin",
    "frontend-warehouse",
    "frontend-agent"
)

# Statistics
$stats = @{
    Total     = $REPOS.Count
    Processed = 0
    Pushed    = 0
    Skipped   = 0
    Errors    = 0
}
$changedRepos = @()

Write-Host "=========================================================="
Write-Host "  NIAGA PLATFORM - Multi-Repo Push Script"
Write-Host "=========================================================="
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be pushed" -ForegroundColor Yellow
    Write-Host ""
}

function Test-GitRepo {
    param([string]$Path)
    return Test-Path (Join-Path $Path ".git")
}

function Push-Repository {
    param(
        [string]$Name,
        [string]$Path,
        [bool]$IsDryRun
    )
    
    $script:stats.Processed++
    $counter = "[$($script:stats.Processed)/$($script:stats.Total)]"
    
    Write-Host "$counter $Name" -ForegroundColor Cyan
    
    # Check if directory exists
    if (-not (Test-Path $Path)) {
        Write-Host "    Directory not found - skipping" -ForegroundColor Yellow
        $script:stats.Skipped++
        Write-Host ""
        return
    }
    
    # Check if it's a git repo
    if (-not (Test-GitRepo $Path)) {
        Write-Host "    Not a git repository - skipping" -ForegroundColor Yellow
        $script:stats.Skipped++
        Write-Host ""
        return
    }
    
    Push-Location $Path
    
    try {
        # Check if remote exists
        $remotes = git remote 2>$null
        if (-not $remotes) {
            Write-Host "    No remote configured - skipping" -ForegroundColor Yellow
            $script:stats.Skipped++
            Pop-Location
            Write-Host ""
            return
        }
        
        # Get current branch
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        Write-Host "    Branch: $branch" -ForegroundColor Green
        
        # Check for changes
        $hasUncommitted = (git status --porcelain 2>$null).Count -gt 0
        $hasUnpushed = $false
        
        if ($branch) {
            $unpushedCommits = git log origin/$branch..$branch --oneline 2>$null
            $hasUnpushed = $unpushedCommits.Count -gt 0
        }
        
        # Process changes
        if ($hasUncommitted) {
            Write-Host "    Uncommitted changes detected" -ForegroundColor Yellow
            
            if (-not $IsDryRun) {
                Write-Host "    Adding and committing changes..."
                git add -A
                git commit -m $CommitMessage | Out-Null
            }
            else {
                Write-Host "    [DRY RUN] Would add and commit changes"
            }
        }
        
        if ($hasUnpushed -or $hasUncommitted) {
            Write-Host "    Unpushed commits detected" -ForegroundColor Yellow
            
            if (-not $IsDryRun) {
                Write-Host "    Pushing to origin/$branch..."
                
                git push origin $branch 2>&1 | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "    Successfully pushed!" -ForegroundColor Green
                    $script:stats.Pushed++
                    $script:changedRepos += $Name
                }
                else {
                    Write-Host "    Push failed!" -ForegroundColor Red
                    $script:stats.Errors++
                }
            }
            else {
                Write-Host "    [DRY RUN] Would push to origin/$branch"
                $script:changedRepos += $Name
            }
        }
        else {
            Write-Host "    Already up to date" -ForegroundColor Green
            $script:stats.Skipped++
        }
    }
    catch {
        Write-Host "    Error: $_" -ForegroundColor Red
        $script:stats.Errors++
    }
    finally {
        Pop-Location
        Write-Host ""
    }
}

# Main execution
Write-Host "Scanning $($stats.Total) repositories..."
Write-Host ""
Write-Host "----------------------------------------------------------"
Write-Host ""

foreach ($repo in $REPOS) {
    $repoPath = Join-Path $ROOT_DIR $repo
    Push-Repository -Name $repo -Path $repoPath -IsDryRun $DryRun
}

# Print summary
Write-Host "=========================================================="
Write-Host "Summary:"
Write-Host ""
Write-Host "  Total repositories: $($stats.Total)"

if ($DryRun) {
    Write-Host "  Would be pushed:    $($changedRepos.Count)" -ForegroundColor Green
}
else {
    Write-Host "  Successfully pushed: $($stats.Pushed)" -ForegroundColor Green
}

Write-Host "  Skipped:            $($stats.Skipped)" -ForegroundColor Yellow

if ($stats.Errors -gt 0) {
    Write-Host "  Errors:             $($stats.Errors)" -ForegroundColor Red
}

Write-Host ""

if ($changedRepos.Count -gt 0) {
    if ($DryRun) {
        Write-Host "Repositories with changes (would be pushed):"
    }
    else {
        Write-Host "Pushed repositories:"
    }
    
    foreach ($repo in $changedRepos) {
        Write-Host "  âœ“ $repo" -ForegroundColor Green
    }
    Write-Host ""
}

if ($DryRun) {
    Write-Host "This was a dry run. Run without -DryRun to actually push changes." -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host "All done!" -ForegroundColor Green
    Write-Host ""
}

