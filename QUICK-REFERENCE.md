# 🚀 Quick Reference - Push All Scripts

## TL;DR

```powershell
# Windows PowerShell
.\push-all.ps1                                    # Push all changes
.\push-all.ps1 -DryRun                           # Preview only
.\push-all.ps1 -CommitMessage "Your message"     # Custom message
```

```bash
# Linux/Mac/WSL
./push-all.sh                                     # Push all changes
./push-all.sh --dry-run                          # Preview only
./push-all.sh -m "Your message"                  # Custom message
```

---

## Common Scenarios

### ✅ End of day - commit and push everything
```powershell
.\push-all.ps1 -CommitMessage "EOD: Completed auth service endpoints"
```

### 🔍 Check which repos have changes (no push)
```powershell
.\push-all.ps1 -DryRun
```

### 🎯 Quick push with auto-generated timestamp
```powershell
.\push-all.ps1
```

### 🔧 Feature branch push
```bash
# Make sure all repos are on the feature branch first
./push-all.sh -m "feat: Added product search functionality"
```

---

## What the script does

1. Scans all 16 repositories
2. For each repo with changes:
   - ✓ Adds all changes (`git add -A`)
   - ✓ Commits with your message (or timestamp)
   - ✓ Pushes to remote
3. Shows a colorful summary

---

## Output Legend

| Symbol | Meaning |
|--------|---------|
| ✓ (green) | Success / Already up to date |
| ✓ (yellow) | Changes detected |
| → (blue) | Action in progress |
| ⊘ (yellow) | Skipped |
| ✗ (red) | Error |

---

## First Time Setup

Each repository needs a remote:

```bash
cd <repo-folder>
git remote add origin https://github.com/yourusername/<repo-name>.git
```

Or using SSH:

```bash
cd <repo-folder>
git remote add origin git@github.com:yourusername/<repo-name>.git
```

---

## All 16 Repositories

1. `infra-platform` - Infrastructure
2. `infra-database` - Database
3. `lib-common` - Shared library
4. `lib-ui` - UI components
5. `service-auth` - Auth service
6. `service-catalog` - Catalog service
7. `service-inventory` - Inventory service
8. `service-order` - Order service
9. `service-customer` - Customer service
10. `service-notification` - Notification service
11. `service-agent` - Agent service
12. `service-reporting` - Reporting service
13. `frontend-storefront` - Storefront
14. `frontend-admin` - Admin panel
15. `frontend-warehouse` - Warehouse app
16. `frontend-agent` - Agent dashboard

---

## Safety Features

- 🛡️ **Dry run mode** - Preview before pushing
- 🛡️ **Skips non-git folders** - Won't break
- 🛡️ **Checks for remotes** - Only pushes if configured
- 🛡️ **Error handling** - Shows which repos failed
- 🛡️ **Summary report** - Clear feedback

---

## Pro Tips

💡 **Always dry-run first**: `.\push-all.ps1 -DryRun`  
💡 **Use meaningful messages**: `-CommitMessage "Fixed login bug"`  
💡 **Review the summary**: Check for errors  
💡 **Commit small, push often**: Don't let changes pile up  
💡 **One feature per commit**: Better git history
