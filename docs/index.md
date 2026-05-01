---
title: WebKitGTK + OpenDeck + ATK + Orca Test Environment
layout: default
---

> **⚠️ IMPORTANT NOTICE**: This is an **alpha proof of concept** and is **NOT production ready**. This framework has not been thoroughly tested and should only be used for experimental and development purposes. Use at your own risk.

# WebKitGTK + OpenDeck + ATK + Orca Test Environment

A comprehensive accessibility testing environment for WebKitGTK, OpenDeck, ATK, and Orca integration, deployed via GitHub Codespaces.

## 🚀 Quick Start

### Launch Test Environment

1. **Visit Repository**: [github.com/opensourcemechanic/opendeck-test](https://github.com/opensourcemechanic/opendeck-test)
2. **Create Codespace**: Code → Codespaces → Create codespace on main
3. **Wait 2-3 minutes** for build completion
4. **Access via port 6080** (auto-opens in browser)

### Access Methods

| Method | Port | Description |
|--------|------|-------------|
| **Web VNC** | 6080 | Browser-based access (recommended) |
| **VNC Client** | 5900 | External VNC client (password: `test123`) |
| **Terminal** | - | VS Code terminal access |

## 🧪 Test Features

### Accessibility Stack
- **WebKitGTK**: Web content rendering with ARIA support
- **OpenDeck**: Web-to-desktop accessibility bridge
- **ATK**: Cross-platform accessibility framework
- **Orca**: Screen reader with speech synthesis

### Test Application
- **Form Accessibility**: Required fields, validation, error handling
- **Dynamic Content**: Live regions, status updates, auto-changes
- **Table Navigation**: Headers, cell relationships, keyboard navigation
- **Interactive Elements**: Buttons, tabs, progress indicators
- **ARIA Implementation**: Landmarks, roles, states, properties

## 📋 Testing Scenarios

### Form Testing
- Navigate with Tab/Shift+Tab
- Verify field announcements
- Test validation messages
- Check required field handling

### Dynamic Content Testing
- Click status update buttons
- Listen for live region announcements
- Verify error message handling
- Test timed content changes

### Table Navigation
- Use arrow keys for cell navigation
- Verify header relationships
- Test table captions
- Check data table structure

### Interactive Elements
- Tab panel navigation
- Progress indicator updates
- Button state changes
- Link descriptions

## 🛠️ Advanced Usage

### Custom Test Content
```bash
# Edit test application
nano /root/test_app.py

# Restart application
pkill -f test_app.py
python3 /root/test_app.py
```

### Accessibility Inspection
```bash
# Launch ATK inspector
accerciser &

# Monitor AT-SPI events
at-spi-registryd --monitor &
```

### Screen Reader Testing
```bash
# Start Orca with speech
orca --replace --enable-speech

# Test different settings
orca --replace --enable-speech --speech-rate=50
```

## 🔧 Troubleshooting

### Common Issues

#### VNC Connection Problems
```bash
# Check VNC status
pgrep -f vncserver

# Restart VNC
vncserver :99 -kill
vncserver :99 -geometry 1024x768 -depth 24
```

#### Screen Reader Not Working
```bash
# Restart Orca
pkill orca
orca --replace --enable-speech

# Check audio
aplay /usr/share/sounds/alsa/Front_Left.wav
```

#### Accessibility Events Missing
```bash
# Restart AT-SPI
pkill -f at-spi-bus-launcher
at-spi-bus-launcher &
```

## 📚 Documentation

- [Detailed Instructions](codespace-guide.md) - Complete usage guide
- [Technical Overview](technical-overview.md) - Architecture and integration
- [API Reference](api-reference.md) - ATK and WebKitGTK APIs
- [Test Cases](test-cases.md) - Comprehensive test scenarios

## 🤝 Contributing

### Adding Test Features
1. Fork the repository
2. Edit `test_app.py`
3. Add your test scenarios
4. Submit a pull request

### Reporting Issues
- Use GitHub Issues for bug reports
- Include detailed reproduction steps
- Specify environment details
- Provide expected vs actual behavior

## 📞 Support

### Getting Help
- **GitHub Issues**: Report problems and request features
- **Documentation**: Check detailed guides
- **Community**: Join accessibility discussions

### Resources
- [WebKitGTK Accessibility](https://webkitgtk.org/accessibility.html)
- [ATK Documentation](https://developer.gnome.org/atk/)
- [Orca Manual](https://help.gnome.org/users/orca/stable/)
- [WCAG Guidelines](https://www.w3.org/TR/WCAG21/)

---

## Quick Reference

### Essential Commands
```bash
# Start test app
python3 /root/test_app.py

# Start screen reader
orca --replace --enable-speech

# Launch inspector
accerciser

# Health check
/root/health_check.sh
```

### Access Details
- **Repository**: https://github.com/opensourcemechanic/opendeck-test
- **VNC Password**: test123
- **Ports**: 5900 (VNC), 6080 (Web)
- **Documentation**: This site

This environment provides comprehensive accessibility testing capabilities for web applications using the GNOME accessibility stack.
