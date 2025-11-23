# GitHub Repository Setup Guide

This guide explains how to set up and push the IAC repository to GitHub.

## Prerequisites

1. **GitHub Account**: Ensure you have a GitHub account
2. **Git Installed**: Verify git is installed (`git --version`)
3. **GitHub CLI (Optional)**: For automated setup (`gh --version`)

---

## Option 1: Automated Setup (Recommended)

### Using GitHub CLI

If you have GitHub CLI installed:

```bash
# Install GitHub CLI (if not installed)
brew install gh

# Authenticate
gh auth login

# Run setup script
./scripts/setup-github-repo.sh [username] [repo-name]

# Example
./scripts/setup-github-repo.sh dwivediv industrial-openapi-iac
```

This will:
- Create the repository on GitHub
- Add remote origin
- Push all branches (main, dev, stage)

---

## Option 2: Manual Setup

### Step 1: Create Repository on GitHub

1. Go to [GitHub.com](https://github.com)
2. Click "New repository"
3. Repository name: `industrial-openapi-iac`
4. Description: "Infrastructure as Code (IAC) for Industrial Equipment Marketplace"
5. Visibility: Public (or Private)
6. **DO NOT** initialize with README, .gitignore, or license
7. Click "Create repository"

### Step 2: Add Remote and Push

#### Option A: Using the push script

```bash
# Run push script (will add remote and push all branches)
./scripts/push-to-github.sh [username] [repo-name]

# Example
./scripts/push-to-github.sh dwivediv industrial-openapi-iac
```

#### Option B: Manual commands

```bash
# Add remote
git remote add origin https://github.com/dwivediv/industrial-openapi-iac.git

# Verify remote
git remote -v

# Push main branch (with upstream tracking)
git checkout main
git push -u origin main

# Push dev branch
git checkout dev
git push -u origin dev

# Push stage branch
git checkout stage
git push -u origin stage

# Switch back to main
git checkout main
```

---

## Option 3: Using SSH (If configured)

If you have SSH keys configured with GitHub:

```bash
# Add remote with SSH URL
git remote add origin git@github.com:dwivediv/industrial-openapi-iac.git

# Push all branches
git push -u origin main
git push -u origin dev
git push -u origin stage
```

---

## Verify Setup

After pushing, verify:

```bash
# Check remote
git remote -v

# List all remote branches
git branch -r

# View repository on GitHub
open https://github.com/dwivediv/industrial-openapi-iac
```

---

## Branch Protection Setup (Recommended)

After pushing, set up branch protection rules on GitHub:

### For `main` Branch:
1. Go to Settings → Branches
2. Add rule for `main`:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1)
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators

### For `stage` Branch:
1. Add rule for `stage`:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1)
   - ✅ Require status checks to pass

### For `dev` Branch:
1. Optional: Add rule for `dev`:
   - ✅ Require status checks to pass (optional)

---

## Troubleshooting

### Error: Repository Already Exists

```bash
# Remove existing remote
git remote remove origin

# Add correct remote
git remote add origin https://github.com/dwivediv/industrial-openapi-iac.git

# Push again
git push -u origin main
```

### Error: Authentication Failed

```bash
# Update remote URL with token
git remote set-url origin https://YOUR_TOKEN@github.com/dwivediv/industrial-openapi-iac.git

# Or use SSH
git remote set-url origin git@github.com:dwivediv/industrial-openapi-iac.git
```

### Error: Branch Not Found

```bash
# Check local branches
git branch -a

# Create missing branch
git checkout -b dev
git checkout -b stage

# Then push
git push -u origin dev
git push -u origin stage
```

### Error: Permission Denied

- Ensure you have push access to the repository
- Check your GitHub credentials
- Verify repository visibility (public/private)

---

## Scripts Available

1. **`scripts/push-to-github.sh`**: Push all branches to GitHub
   ```bash
   ./scripts/push-to-github.sh [username] [repo-name]
   ```

2. **`scripts/setup-github-repo.sh`**: Create repo and push (requires gh CLI)
   ```bash
   ./scripts/setup-github-repo.sh [username] [repo-name]
   ```

---

## Next Steps

After successfully pushing to GitHub:

1. ✅ Enable branch protection rules
2. ✅ Set up GitHub Actions secrets (if needed)
3. ✅ Configure repository settings
4. ✅ Add collaborators (if needed)
5. ✅ Create initial issues/tasks
6. ✅ Update README with repository-specific information

---

## Repository URLs

After setup, your repository will be available at:

- **Main**: https://github.com/dwivediv/industrial-openapi-iac
- **Branches**:
  - https://github.com/dwivediv/industrial-openapi-iac/tree/main
  - https://github.com/dwivediv/industrial-openapi-iac/tree/dev
  - https://github.com/dwivediv/industrial-openapi-iac/tree/stage

---

## References

- [GitHub Documentation](https://docs.github.com/)
- [GitHub CLI Documentation](https://cli.github.com/)
- [Git Push Documentation](https://git-scm.com/docs/git-push)



