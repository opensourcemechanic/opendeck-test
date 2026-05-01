# WebKitGTK + OpenDeck + ATK + Orca Test Environment

> **⚠️ IMPORTANT NOTICE**: This is an **alpha proof of concept** and is **NOT production ready**. This framework has not been thoroughly tested and should only be used for experimental and development purposes. Use at your own risk.

## Overview

This is a comprehensive accessibility testing environment for WebKitGTK, OpenDeck, ATK, and Orca integration. It provides a complete containerized setup with VNC access for testing web accessibility features.

## Quick Start

### 1. Launch GitHub Codespace

1. **Visit the Repository**: https://github.com/opensourcemechanic/opendeck-test
2. **Click "Code"** → **"Codespaces"** → **"Create codespace on main"**
3. **Wait 2-3 minutes** for the build to complete

### 2. Access the Environment

Once the Codespace is ready, you have several access options:

#### **Web Access (Recommended)**
- **Port 6080**: Opens automatically in your browser
- **No software installation required**
- **Full VNC access in browser**

#### **VNC Client Access**
- **Port 5900**: Connect with any VNC client
- **Password**: `test123`
- **Recommended clients**:
  - Windows: RealVNC Viewer, TightVNC
  - macOS: RealVNC Viewer, Screen Sharing
  - Linux: Remmina, TigerVNC

#### **Terminal Access**
- **VS Code Terminal**: Full bash access
- **Run commands directly**: `python3 test_app.py`

## Test Environment Features

### Accessibility Stack Components

#### **WebKitGTK**
- Web content rendering engine
- ARIA support implementation
- DOM accessibility tree generation

#### **OpenDeck**
- Web-to-desktop accessibility bridge
- ARIA role mapping to ATK
- Dynamic content event handling

#### **ATK (Accessibility Toolkit)**
- Cross-platform accessibility framework
- Screen reader integration
- Assistive technology support

#### **Orca Screen Reader**
- Voice output for accessibility testing
- Braille display support
- Magnification features

## Files Included

- `test_app.py` - Main accessibility test application
- `Dockerfile` - Container configuration (for local Docker use)
- `.devcontainer/devcontainer.json` - GitHub Codespaces configuration
- `README_CODESAPCES.md` - Detailed Codespaces setup guide
- `health_check.sh` - Environment health verification

## Running Tests

### Basic Test
```bash
python3 test_app.py
```

### Health Check
```bash
./health_check_codespaces.sh
```

### Simple Test (Codespaces Compatible)
```bash
python3 simple_test.py
```

## Documentation

- **README_CODESPACES.md** - Detailed Codespaces setup and troubleshooting
- **README_DEPLOYMENT.md** - Local Docker deployment guide
- **accessibility_test_environment.md** - Comprehensive technical documentation

## Requirements

- GitHub account (for Codespaces)
- Modern web browser (for VNC web access)
- Optional: VNC client for desktop access

## Support

For issues or questions:
1. Check README_CODESAPCES.md for troubleshooting
2. Verify ports 5900/6080 are accessible
3. Run health_check.sh to diagnose issues
4. Check GitHub Codespaces documentation

## License

This code is provided as-is for educational and experimental use.
