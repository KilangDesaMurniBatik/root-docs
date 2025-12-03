# PowerShell script to pull updates from all Git repositories in niaga-platform

Write-Host "=== Niaga Platform - Pull All Repositories ===" -ForegroundColor Cyan
Write-Host ""

# Get all subdirectories
$repositories = Get-ChildItem -Directory -Path $PSScriptRoot

$successCount = 0
$failCount = 0
$skippedCount = 0
$results = @()

foreach ($repo in $repositories) {
    $repoPath = $repo.FullName
    $repoName = $repo.Name
    
    # Check if it's a git repository
    if (Test-Path "$repoPath\.git") {
        Write-Host "[$repoName]" -ForegroundColor Yellow -NoNewline
        Write-Host " Pulling updates..." -NoNewline
        
        Push-Location $repoPath
        
        try {
            # Fetch updates first
            $fetchOutput = git fetch 2>&1
            
            # Check if there are updates
            $status = git status -uno
            
            if ($status -match "Your branch is up to date") {
                Write-Host " Up to date" -ForegroundColor Green
                $results += [PSCustomObject]@{
                    Repository = $repoName
                    Status = "Up to date"
                    Details = ""
                }
                $successCount++
            }
            elseif ($status -match "Your branch is behind") {
                # Pull the updates
                $pullOutput = git pull 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host " Updated successfully" -ForegroundColor Green
                    $results += [PSCustomObject]@{
                        Repository = $repoName
                        Status = "Updated"
                        Details = ($pullOutput | Select-String -Pattern "file.*changed|insertion|deletion" | Out-String).Trim()
                    }
                    $successCount++
                }
                else {
                    Write-Host " Failed" -ForegroundColor Red
                    $results += [PSCustomObject]@{
                        Repository = $repoName
                        Status = "Failed"
                        Details = $pullOutput -join "`n"
                    }
                    $failCount++
                }
            }
            elseif ($status -match "have diverged") {
                Write-Host " Diverged (manual merge needed)" -ForegroundColor Magenta
                $results += [PSCustomObject]@{
                    Repository = $repoName
                    Status = "Diverged"
                    Details = "Local and remote branches have diverged. Manual merge required."
                }
                $failCount++
            }
            elseif ($status -match "Your branch is ahead") {
                Write-Host " Ahead of remote" -ForegroundColor Cyan
                $results += [PSCustomObject]@{
                    Repository = $repoName
                    Status = "Ahead"
                    Details = "Local branch is ahead of remote. No pull needed."
                }
                $skippedCount++
            }
            else {
                # Try to pull anyway
                $pullOutput = git pull 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host " Pulled" -ForegroundColor Green
                    $results += [PSCustomObject]@{
                        Repository = $repoName
                        Status = "Pulled"
                        Details = ($pullOutput | Select-String -Pattern "file.*changed|insertion|deletion" | Out-String).Trim()
                    }
                    $successCount++
                }
                else {
                    Write-Host " Failed" -ForegroundColor Red
                    $results += [PSCustomObject]@{
                        Repository = $repoName
                        Status = "Failed"
                        Details = $pullOutput -join "`n"
                    }
                    $failCount++
                }
            }
        }
        catch {
            Write-Host " Error: $($_.Exception.Message)" -ForegroundColor Red
            $results += [PSCustomObject]@{
                Repository = $repoName
                Status = "Error"
                Details = $_.Exception.Message
            }
            $failCount++
        }
        finally {
            Pop-Location
        }
    }
    else {
        Write-Host "[$repoName]" -ForegroundColor DarkGray -NoNewline
        Write-Host " Not a git repository, skipping" -ForegroundColor DarkGray
        $skippedCount++
    }
}

Write-Host ""
Write-Host "=== Pull Summary ===" -ForegroundColor Cyan
Write-Host "Total repositories checked: $($repositories.Count)" -ForegroundColor White
Write-Host "Successfully updated/up to date: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red
Write-Host "Skipped (not git repos): $skippedCount" -ForegroundColor DarkGray

if ($failCount -gt 0) {
    Write-Host ""
    Write-Host "=== Repositories with Issues ===" -ForegroundColor Yellow
    $results | Where-Object { $_.Status -in @("Failed", "Diverged", "Error") } | Format-Table -AutoSize
}

if ($results | Where-Object { $_.Status -eq "Updated" }) {
    Write-Host ""
    Write-Host "=== Updated Repositories ===" -ForegroundColor Green
    $results | Where-Object { $_.Status -eq "Updated" } | Format-Table -AutoSize
}

Write-Host ""
Write-Host "Pull operation completed!" -ForegroundColor Cyan
