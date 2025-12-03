# Multi-Repo Push Scripts

This directory contains scripts to help manage the multi-repository structure of the Niaga Platform.

## 📁 Repository Structure

The Niaga Platform uses a **mono-folder, multi-repo** approach where each folder is a separate Git repository:

```
niaga-platform/
├── infra-platform/         # Infrastructure (Docker, Traefik)
├── infra-database/         # Database schemas & migrations
├── lib-common/             # Shared Go library
├── lib-ui/                 # Shared UI components
├── service-auth/           # Authentication service (Go)
├── service-catalog/        # Product catalog service (Go)
├── service-inventory/      # Inventory management (Go)
├── service-order/          # Order & cart service (Go)
├── service-customer/       # Customer service (Go)
├── service-notification/   # Notification service (Go)
├── service-agent/          # Agent/reseller service (Go)
├── service-reporting/      # Reporting service (Go)
├── frontend-storefront/    # Customer-facing website (Next.js)
├── frontend-admin/         # Admin dashboard (Next.js)
├── frontend-warehouse/     # Warehouse management (Next.js)
└── frontend-agent/         # Agent dashboard (Next.js)
```

Each folder has its own remote repository.

---

## 🚀 Push All Script

### Overview

The `push-all` script automates the process of pushing code changes across all repositories. It:

1. ✅ Scans all repository folders
2. ✅ Checks for uncommitted changes
3. ✅ Automatically commits changes (if any)
4. ✅ Checks for unpushed commits
5. ✅ Pushes to the remote repository
6. ✅ Provides detailed colored output
7. ✅ Shows a summary of all operations

### Available Scripts

- **`push-all.ps1`** - PowerShell version (Windows)
- **`push-all.sh`** - Bash version (Linux/Mac/WSL)

---

## 📖 Usage

### PowerShell (Windows)

#### Basic usage - Push all changes
```powershell
.\push-all.ps1
```

#### Dry run - Preview what would be pushed
```powershell
.\push-all.ps1 -DryRun
```

#### Custom commit message
```powershell
.\push-all.ps1 -CommitMessage "Updated all repos with new feature"
```

#### Combined options
```powershell
.\push-all.ps1 -DryRun -CommitMessage "Test commit message"
```

### Bash (Linux/Mac/WSL)

First, make the script executable:
```bash
chmod +x push-all.sh
```

#### Basic usage - Push all changes
```bash
./push-all.sh
```

#### Dry run - Preview what would be pushed
```bash
./push-all.sh --dry-run
```

#### Custom commit message
```bash
./push-all.sh -m "Updated all repos with new feature"
# or
./push-all.sh --message "Updated all repos with new feature"
```

#### Combined options
```bash
./push-all.sh --dry-run -m "Test commit message"
```

---

## 🎯 Features

### 1. **Automatic Change Detection**
   - Detects uncommitted changes in each repo
   - Detects unpushed commits
   - Skips repos that are already up to date

### 2. **Smart Commit & Push**
   - Auto-commits changes with timestamp (or custom message)
   - Pushes to the current branch
   - Only processes repos with actual changes

### 3. **Safety Features**
   - **Dry Run Mode**: Preview changes before pushing
   - Skips non-Git directories
   - Skips repos without remotes
   - Error handling for failed pushes

### 4. **Beautiful Output**
   - Color-coded status messages
   - Progress counter (`[1/16]`, `[2/16]`, etc.)
   - Clear summary at the end
   - Lists all pushed repositories

### 5. **Detailed Summary**
   - Total repositories scanned
   - Successfully pushed
   - Skipped (no changes)
   - Errors (if any)
   - List of affected repositories

---

## 📊 Example Output

```
╔═══════════════════════════════════════════════════════╗
║   NIAGA PLATFORM - Multi-Repo Push Script            ║
╚═══════════════════════════════════════════════════════╝

Scanning 16 repositories...

────────────────────────────────────────────────────────────

[1/16] infra-platform
    Branch: main
    ✓ Already up to date

[2/16] lib-common
    Branch: main
    ✓ Uncommitted changes detected
    → Adding all changes...
    → Committing with message: 'Auto-commit: 2025-12-01 20:24:14'
    ✓ Unpushed commits detected
    → Pushing to origin/main...
    ✓ Successfully pushed!

[3/16] service-auth
    Branch: main
    ✓ Already up to date

...

════════════════════════════════════════════════════════════

Summary:

  Total repositories: 16
  Successfully pushed: 3
  Skipped:            12
  Errors:             1

Pushed repositories:
  ✓ lib-common
  ✓ service-catalog
  ✓ frontend-storefront

✓ All done!
```

---

## ⚠️ Important Notes

### Before First Use

1. **Set up Git remotes** for each repository:
   ```bash
   cd <repo-folder>
   git remote add origin <remote-url>
   ```

2. **Ensure you're on the correct branch** in each repo

3. **Run with `--dry-run`** first to see what will happen

### Best Practices

1. **Review changes** before running the script
2. **Use meaningful commit messages** with the `-m` flag
3. **Run dry-run mode** when unsure
4. **Check the summary** after execution
5. **Handle errors** listed in the summary

---

## 🔧 Customization

### Adding/Removing Repositories

Edit the `$REPOS` array (PowerShell) or `REPOS` array (Bash) in the script:

```powershell
# PowerShell
$REPOS = @(
    "infra-platform",
    "infra-database",
    # Add your new repos here
)
```

```bash
# Bash
REPOS=(
    "infra-platform"
    "infra-database"
    # Add your new repos here
)
```

---

## 🐛 Troubleshooting

### Script won't run (PowerShell)
```powershell
# Enable script execution
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Script won't run (Bash)
```bash
# Make executable
chmod +x push-all.sh
```

### "No remote configured" error
```bash
cd <repo-folder>
git remote add origin <your-remote-url>
```

### "Push failed" error
- Check if you have push access to the remote
- Ensure your branch is not behind the remote (pull first)
- Check for merge conflicts

---

## 💡 Tips

1. **Daily workflow**: Run `push-all.ps1 -DryRun` to check status
2. **End of day**: Run `push-all.ps1 -CommitMessage "EOD commit"`
3. **Before deployment**: Run to ensure all repos are synchronized
4. **Integration**: Add to your CI/CD pipeline

---

## 📝 License

Part of the Niaga Platform project.
