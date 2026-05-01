# GitHub Pages Setup Instructions

## 🚀 Enable GitHub Pages

### Step 1: Enable GitHub Pages in Repository

1. **Go to Repository**: https://github.com/opensourcemechanic/opendeck-test
2. **Click Settings** tab
3. **Scroll down to "Pages" section**
4. **Source**: Select "Deploy from a branch"
5. **Branch**: Select "main"
6. **Folder**: Select "/docs"
7. **Click "Save"**

### Step 2: Wait for Deployment

- GitHub Pages will automatically build and deploy
- Takes 1-2 minutes for first deployment
- Check for "Your site is published at:" message

### Step 3: Access the Documentation

**Site URL**: https://opensourcemechanic.github.io/opendeck_test/

## 📚 Documentation Structure

### Main Pages
- **Home**: `/` - Overview and quick start
- **Codespace Guide**: `/codespace-guide/` - Step-by-step usage
- **Technical Overview**: `/technical-overview/` - Architecture details
- **API Reference**: `/api-reference/` - Complete API documentation
- **Test Cases**: `/test-cases/` - Comprehensive test scenarios

### Navigation
All pages include:
- Navigation menu
- Quick reference sections
- Troubleshooting guides
- Code examples

## 🔧 Local Development (Optional)

### Run Documentation Locally

```bash
# Install Ruby dependencies
cd docs
bundle install

# Serve locally
bundle exec jekyll serve

# Access at http://localhost:4000/opendeck_test/
```

### Update Documentation

1. Edit files in `/docs` directory
2. Commit and push changes
3. GitHub Pages automatically rebuilds

## 📋 Verification Checklist

### After Setup
- [ ] GitHub Pages enabled in repository settings
- [ ] Site builds successfully (no build errors)
- [ ] Navigation works between pages
- [ ] All links are functional
- [ ] Code examples display correctly

### Test the Site
1. Visit: https://opensourcemechanic.github.io/opendeck_test/
2. Navigate through all pages
3. Test all external links
4. Verify code formatting

## 🐛 Troubleshooting

### Common Issues

#### Build Errors
```bash
# Check GitHub Pages build logs
# Go to repository → Settings → Pages → Build error
```

#### Missing Pages
- Verify files are in `/docs` directory
- Check file names (lowercase, no spaces)
- Ensure proper front matter in Markdown files

#### Broken Links
- Check link URLs in Markdown files
- Verify relative paths are correct
- Test external links manually

#### Styling Issues
- Verify Jekyll theme is loading
- Check CSS files in `_config.yml`
- Clear browser cache

### Reset GitHub Pages
If issues persist:
1. Disable GitHub Pages in settings
2. Wait 1 minute
3. Re-enable with same settings
4. Wait for rebuild

## 🔄 Maintenance

### Regular Updates
- Update Jekyll dependencies: `bundle update`
- Review content for accuracy
- Test with new codespace features

### Content Updates
1. Edit Markdown files in `/docs`
2. Add new pages to navigation in `_config.yml`
3. Commit and push changes

---

## Quick Start Summary

1. **Enable GitHub Pages**: Repository → Settings → Pages → Deploy from branch → main/docs
2. **Wait 2 minutes** for deployment
3. **Visit**: https://opensourcemechanic.github.io/opendeck_test/
4. **Test navigation** and functionality

The documentation provides comprehensive guidance for using the WebKitGTK + OpenDeck + ATK + Orca accessibility test environment in GitHub Codespaces.
