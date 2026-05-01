# GitHub Pages 404 Troubleshooting

## 🔍 Common Causes and Solutions

### 1. GitHub Pages Not Enabled

**Problem**: GitHub Pages hasn't been enabled for the repository.

**Solution**:
1. Go to: https://github.com/opensourcemechanic/opendeck-test
2. Click **Settings** tab
3. Scroll to **Pages** section
4. Under **Source**, select **"Deploy from a branch"**
5. Select **"main"** branch
6. Select **"/docs"** folder
7. Click **"Save"**
8. Wait 2-5 minutes for deployment

### 2. Build Errors

**Problem**: Jekyll build is failing.

**Check Build Status**:
1. Go to repository **Settings** → **Pages**
2. Look for build error messages
3. Click on build error link for details

**Common Build Issues**:
- Invalid front matter in Markdown files
- Missing required Jekyll files
- Syntax errors in configuration

### 3. File Structure Issues

**Problem**: Files not in correct location or named incorrectly.

**Verify Structure**:
```
opendeck_test/
├── docs/
│   ├── _config.yml
│   ├── index.md
│   ├── codespace-guide.md
│   ├── technical-overview.md
│   ├── api-reference.md
│   └── test-cases.md
└── README.md
```

### 4. Front Matter Issues

**Problem**: Markdown files missing or have invalid front matter.

**Check Front Matter**:
```yaml
---
title: Page Title
layout: default
---
```

### 5. GitHub Pages Domain Propagation

**Problem**: DNS/domain propagation delay.

**Solution**: Wait 10-15 minutes after enabling Pages.

## 🛠️ Diagnostic Steps

### Step 1: Check Pages Status
```bash
# Check if Pages is enabled
curl -I https://opensourcemechanic.github.io/opendeck_test/

# Expected: 200 OK or 404 (if not enabled)
```

### Step 2: Verify Repository Structure
```bash
# Check docs directory exists
ls -la docs/

# Check key files exist
ls docs/index.md docs/_config.yml
```

### Step 3: Test Local Jekyll Build
```bash
cd docs
bundle install
bundle exec jekyll build --dry-run
```

### Step 4: Check GitHub Actions
1. Go to repository **Actions** tab
2. Look for "pages" workflow
3. Check for build errors

## 🚀 Quick Fix Checklist

### ✅ Pre-Deployment Checklist
- [ ] GitHub Pages enabled (Settings → Pages)
- [ ] Source: Deploy from branch → main → /docs
- [ ] docs/_config.yml exists and is valid
- [ ] docs/index.md exists with proper front matter
- [ ] No build errors in Pages section

### ✅ Post-Deployment Checklist
- [ ] Wait 5-10 minutes for deployment
- [ ] Check https://opensourcemechanic.github.io/opendeck_test/
- [ ] Test navigation between pages
- [ ] Verify all links work

## 🔧 Alternative Solutions

### Solution 1: Use Root Directory
If /docs folder doesn't work, try root directory:

1. **Move docs to root**:
```bash
mv docs/* ./
mv docs/.* ./ 2>/dev/null || true
rmdir docs
```

2. **Update Pages settings**:
   - Source: Deploy from branch → main → **/(root)**

### Solution 2: Create GitHub Action
Create `.github/workflows/pages.yml`:
```yaml
name: Deploy GitHub Pages

on:
  push:
    branches: [ main ]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/configure-pages@v3
    - uses: actions/upload-pages-artifact@v2
      with:
        path: docs/_site

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
    - id: deployment
      uses: actions/deploy-pages@v2
```

## 📞 Getting Help

### GitHub Support
- Check GitHub Status: https://www.githubstatus.com/
- GitHub Pages Documentation: https://docs.github.com/en/pages

### Community Support
- GitHub Community Forums
- Stack Overflow (github-pages tag)

## 🔄 Reset GitHub Pages

If all else fails:
1. **Disable Pages**: Settings → Pages → None
2. **Wait 1 minute**
3. **Re-enable**: Settings → Pages → Deploy from branch → main → /docs
4. **Wait for deployment**

---

## 🎯 Most Likely Fix

The most common issue is **GitHub Pages not being enabled**. 

**Quick Fix**:
1. Go to https://github.com/opensourcemechanic/opendeck-test/settings/pages
2. Set Source to "Deploy from a branch"
3. Select "main" branch
4. Select "/docs" folder
5. Click Save
6. Wait 5 minutes

This should resolve the 404 error in 90% of cases.
