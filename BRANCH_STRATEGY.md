# Branch Strategy

## Branch Structure

This repository follows a three-branch strategy for infrastructure deployment:

### 1. `main` Branch (Production)
- **Purpose**: Production-ready infrastructure code
- **Deploy To**: Production environments (us-east-1, us-west-2)
- **Protection**: Protected branch, requires PR approval
- **Merges From**: `stage` branch only
- **Deployment**: Manual approval required for production deployments

### 2. `stage` Branch (Integration/Staging)
- **Purpose**: Pre-production testing infrastructure
- **Deploy To**: Integration environment
- **Protection**: Protected branch, requires PR approval
- **Merges From**: `dev` branch
- **Deployment**: Automated deployment to integration environment

### 3. `dev` Branch (Development)
- **Purpose**: Active development infrastructure code
- **Deploy To**: Development and Test environments
- **Protection**: Open for direct pushes (developers)
- **Merges From**: Feature branches (`feature/*`)
- **Deployment**: Automated deployment to dev/test environments

## Workflow

```
Feature Branch → dev → stage → main
     ↓           ↓      ↓       ↓
   Local    Dev/Test  Integration  Production
```

### Development Flow

1. **Create Feature Branch**
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes & Test Locally**
   ```bash
   make localstack-start
   make validate
   make plan-local
   ```

3. **Commit & Push Feature Branch**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin feature/your-feature-name
   ```

4. **Create Pull Request to `dev`**
   - PR is reviewed and merged to `dev`
   - Automated deployment to dev/test environments

5. **Merge `dev` → `stage`**
   - Create PR from `dev` to `stage`
   - Review and approve
   - Automated deployment to integration environment

6. **Merge `stage` → `main`**
   - Create PR from `stage` to `main`
   - Requires additional review and approval
   - Manual approval for production deployment

## Branch Protection Rules

### `main` Branch
- Require pull request reviews before merging
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Include administrators
- Restrict who can push to matching branches

### `stage` Branch
- Require pull request reviews before merging
- Require status checks to pass before merging
- Allow force pushes (limited to admins)
- Restrict who can push to matching branches

### `dev` Branch
- Allow force pushes (developers)
- Allow deletions (developers)
- Require status checks to pass before merging (optional)

## Environment Mapping

| Branch | Environments | AWS Account |
|--------|-------------|-------------|
| `dev` | dev, test | Account 1 (Dev/Test) |
| `stage` | integration | Account 2 (Integration/Prod) |
| `main` | production (us-east-1, us-west-2) | Account 2 (Integration/Prod) |

## Best Practices

1. **Never commit secrets** - Use environment variables or secrets management
2. **Always test locally** - Use LocalStack before pushing
3. **Validate before PR** - Run `make validate` before creating PR
4. **Review carefully** - Infrastructure changes affect all environments
5. **Document changes** - Update documentation with infrastructure changes
6. **Use descriptive commits** - Clear commit messages for tracking
7. **Test in order** - Always test in dev → stage → production order

## Hotfix Workflow

For urgent production fixes:

```bash
# Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/issue-description

# Make fix and test
make validate
make plan-local

# Create PR to main (bypass stage for urgent fixes)
# Requires admin approval

# After merge to main, cherry-pick to stage and dev
git checkout stage
git cherry-pick <hotfix-commit>
git checkout dev
git cherry-pick <hotfix-commit>
```

## Release Process

1. **Tag Releases**: Tag `main` branch after production deployment
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

2. **Version Numbering**: Use semantic versioning (MAJOR.MINOR.PATCH)
   - MAJOR: Breaking changes
   - MINOR: New features
   - PATCH: Bug fixes

3. **Release Notes**: Document changes in release notes

## CI/CD Integration

- **dev branch**: Auto-deploy to dev/test on merge
- **stage branch**: Auto-deploy to integration on merge
- **main branch**: Manual deployment to production (requires approval)

---

## Quick Reference

```bash
# Start new feature
git checkout dev && git pull && git checkout -b feature/my-feature

# Test locally
make localstack-start && make validate && make plan-local

# Push and create PR
git push origin feature/my-feature

# Update from dev
git checkout dev && git pull && git checkout feature/my-feature && git merge dev

# Clean up
git checkout dev && git branch -d feature/my-feature
```

