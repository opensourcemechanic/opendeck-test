---
title: Codespace Usage Guide
layout: default
---

# GitHub Codespace Usage Guide

## 🚀 Getting Started

### Creating Your Codespace

1. **Navigate to Repository**
   - Visit https://github.com/opensourcemechanic/opendeck-test
   - Ensure you're logged into GitHub

2. **Launch Codespace**
   - Click the green **"Code"** button
   - Select **"Codespaces"** tab
   - Click **"Create codespace on main"**
   - Choose machine type (standard is fine)

3. **Wait for Build**
   - Build process takes 2-3 minutes
   - Monitor progress in the build log
   - Wait for "Ready" notification

### Understanding the Environment

#### Container Architecture
```
GitHub Codespace
├── Ubuntu 22.04 Container
├── WebKitGTK + OpenDeck + ATK + Orca
├── VNC Server (port 5900)
├── Web VNC (port 6080)
├── Test Application
└── Accessibility Tools
```

#### Access Points
- **VS Code Editor**: Full development environment
- **Terminal**: Bash shell access
- **Ports**: Forwarded for external access
- **File System**: Persistent during session

## 🖥️ Accessing the Test Environment

### Web-Based Access (Recommended)

1. **Automatic Port Forwarding**
   - Port 6080 automatically opens in browser
   - No additional software required
   - Full VNC experience in browser tab

2. **Using Web VNC**
   - Wait for VNC interface to load
   - Enter password: `test123`
   - Access desktop environment
   - Launch test applications

### External VNC Client

1. **Port Forwarding Setup**
   - Find forwarded port 5900 in Codespace
   - Note the external URL provided
   - Use this URL in your VNC client

2. **VNC Client Configuration**
   ```
   Host: [codespace-url].github.dev
   Port: 5900
   Password: test123
   ```

3. **Recommended Clients**
   - **Windows**: RealVNC Viewer, TightVNC
   - **macOS**: RealVNC Viewer, built-in Screen Sharing
   - **Linux**: Remmina, TigerVNC

### Terminal Access

1. **VS Code Terminal**
   - Click terminal tab in VS Code
   - Full bash shell access
   - Pre-configured environment

2. **SSH Access (Advanced)**
   - Get SSH command from Codespace
   - Use for local development tools
   - Port forwarding included

## 🧪 Running Tests

### Basic Test Workflow

#### 1. Start the Test Application
```bash
# In VS Code terminal
python3 /root/test_app.py
```

#### 2. Enable Screen Reader
```bash
# Start Orca with speech
orca --replace --enable-speech

# Verify it's working
orca --version
```

#### 3. Launch Accessibility Tools
```bash
# ATK inspector
accerciser &

# Event monitor
at-spi-registryd --monitor &
```

### Testing Scenarios

#### Form Accessibility Testing
1. **Navigate to Test Application**
   - Find the GTK window in VNC
   - Click on form elements
   - Use keyboard navigation

2. **Test Required Fields**
   - Tab to "Name" field
   - Listen for: "Name, text field, required"
   - Enter short text (1-2 characters)
   - Listen for validation error

3. **Test Field Descriptions**
   - Focus each input field
   - Listen for descriptive text
   - Verify aria-describedby relationships

#### Dynamic Content Testing
1. **Status Updates**
   - Click "Update Status" button
   - Listen for live region announcement
   - Verify polite announcement type

2. **Error Messages**
   - Click "Add Error" button
   - Listen for assertive announcement
   - Verify immediate announcement

3. **Auto Updates**
   - Wait 3 seconds for automatic update
   - Listen for timed announcement
   - Verify content change detection

#### Table Navigation Testing
1. **Basic Navigation**
   - Tab to the table
   - Use arrow keys to move cells
   - Listen for cell coordinates

2. **Header Relationships**
   - Navigate to data cells
   - Verify header announcements
   - Test row/column associations

#### Interactive Elements Testing
1. **Tab Navigation**
   - Tab to tab buttons
   - Use arrow keys to switch
   - Listen for panel changes

2. **Progress Indicators**
   - Click "Update Progress"
   - Listen for percentage changes
   - Verify completion states

## 🛠️ Advanced Usage

### Custom Test Development

#### Creating New Test Content
```python
# Edit the test application
nano /root/test_app.py

# Add custom HTML content
def load_custom_tests(self):
    html = """
    <section aria-label="Custom tests">
        <h2>My Custom Tests</h2>
        <button aria-label="Custom action">Test Button</button>
        <div aria-live="polite" id="custom-status">
            Ready for testing
        </div>
    </section>
    """
    self.webview.load_html(html, "file:///")
```

#### Adding Accessibility Validators
```python
# Add validation methods
def validate_custom_element(self, element):
    """Validate custom accessibility features"""
    issues = []
    
    # Check for proper ARIA attributes
    if not element.get_attribute('aria-label'):
        issues.append("Missing aria-label")
    
    return issues
```

### Performance Monitoring

#### System Resource Monitoring
```bash
# Check CPU usage
top -p $(pgrep -f test_app.py)

# Monitor memory
ps aux --sort=-%mem | grep python3

# Check VNC performance
ps aux | grep vnc
```

#### Accessibility Performance
```bash
# Monitor AT-SPI events
export ATK_DEBUG=1
python3 /root/test_app.py

# Profile WebKitGTK
export WEBKIT_DEBUG=accessibility
python3 /root/test_app.py
```

### Debugging Techniques

#### Accessibility Event Debugging
```bash
# Monitor all AT-SPI events
at-spi-registryd --monitor &
python3 /root/test_app.py

# Filter specific events
at-spi-registryd --monitor | grep focus
```

#### WebKitGTK Debugging
```bash
# Enable WebKitGTK debugging
export WEBKIT_DEBUG=all
python3 /root/test_app.py

# Check for accessibility issues
export WEBKIT_DEBUG=accessibility
python3 /root/test_app.py
```

#### Screen Reader Debugging
```bash
# Verbose Orca output
orca --replace --enable-speech --debug

# Test speech synthesis
espeak "Testing speech output"

# Check audio system
aplay /usr/share/sounds/alsa/Front_Left.wav
```

## 🔧 Environment Configuration

### Customizing the Environment

#### Adding New Tools
```bash
# Install additional packages
sudo apt-get update
sudo apt-get install -y package-name

# Python packages
pip3 install new-package

# Verify installation
which package-name
python3 -c "import package_name"
```

#### Configuration Files
```bash
# Edit Orca settings
nano ~/.local/share/orca/orca-settings.py

# Modify ATK behavior
export ATK_DEBUG=1

# Customize VNC
nano ~/.vnc/xstartup
```

### Environment Variables

#### Common Variables
```bash
# Display settings
export DISPLAY=:99

# Debugging
export WEBKIT_DEBUG=accessibility
export ATK_DEBUG=1

# Audio
export PULSE_SERVER=auto
```

#### Persistent Variables
```bash
# Add to .bashrc
echo 'export WEBKIT_DEBUG=accessibility' >> ~/.bashrc
echo 'export ATK_DEBUG=1' >> ~/.bashrc

# Reload shell
source ~/.bashrc
```

## 📊 Test Results and Reporting

### Generating Test Reports

#### Automated Test Results
```python
# Create test report generator
def generate_test_report():
    results = {
        'form_accessibility': test_form_features(),
        'dynamic_content': test_dynamic_content(),
        'table_navigation': test_table_navigation(),
        'screen_reader': test_screen_reader_integration()
    }
    
    # Save report
    with open('/tmp/test_report.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    return results
```

#### Manual Test Documentation
```bash
# Create test log
mkdir -p /tmp/accessibility_tests
echo "Test Session $(date)" > /tmp/accessibility_tests/session.log

# Add test results
echo "Form tests: PASSED" >> /tmp/accessibility_tests/session.log
echo "Dynamic content: PASSED" >> /tmp/accessibility_tests/session.log
```

### Exporting Results

#### Download from Codespace
1. **Open VS Code Explorer**
2. **Navigate to `/tmp/` directory**
3. **Right-click files**
4. **Select "Download"**

#### Using GitHub CLI
```bash
# Save results to repository
cp /tmp/test_report.json ./
git add test_report.json
git commit -m "Add test results"
git push
```

## 🔄 Session Management

### Saving Your Work

#### Persistent Storage
- **Files in repository**: Saved automatically
- **Temporary files**: Lost when session ends
- **Configuration**: Reset each session

#### Best Practices
```bash
# Save custom tests to repository
cp /root/custom_tests.py ./my_tests.py
git add my_tests.py
git commit -m "Add custom tests"

# Save configuration
cp ~/.local/share/orca/orca-settings.py ./orca-config.py
git add orca-config.py
git commit -m "Save Orca configuration"
```

### Session Recovery

#### Restarting Services
```bash
# Restart accessibility stack
pkill -f orca
pkill -f at-spi-bus-launcher
pkill -f test_app.py

# Restart in correct order
at-spi-bus-launcher &
sleep 2
orca --replace --enable-speech &
sleep 2
python3 /root/test_app.py
```

#### Environment Reset
```bash
# Full environment reset
/root/health_check.sh

# Restart VNC if needed
vncserver :99 -kill
vncserver :99 -geometry 1024x768 -depth 24
```

## 🚨 Troubleshooting

### Common Codespace Issues

#### Build Failures
```bash
# Check build logs
cat /tmp/codespace-build.log

# Rebuild container
# (Delete and recreate codespace)
```

#### Port Forwarding Problems
```bash
# Check forwarded ports
netstat -tlnp | grep :590
netstat -tlnp | grep :608

# Test port accessibility
curl -I http://localhost:6080
```

#### Performance Issues
```bash
# Check system resources
free -h
df -h
top

# Restart services
pkill -f python3
python3 /root/test_app.py
```

### Accessibility-Specific Issues

#### Screen Reader Problems
```bash
# Check Orca status
pgrep -f orca

# Restart with debug
orca --replace --enable-speech --debug

# Test audio output
paplay /usr/share/sounds/alsa/Front_Left.wav
```

#### ATK Issues
```bash
# Check AT-SPI
pgrep -f at-spi-bus-launcher

# Test ATK functionality
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk
print('ATK working')
"
```

#### WebKitGTK Issues
```bash
# Check WebKitGTK
ldconfig -p | grep webkit

# Test with debug
export WEBKIT_DEBUG=accessibility
python3 /root/test_app.py
```

## 📚 Additional Resources

### Documentation
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [VS Code in Codespaces](https://code.visualstudio.com/docs/codespaces)
- [WebKitGTK Accessibility Guide](https://webkitgtk.org/accessibility.html)

### Community
- [GitHub Discussions](https://github.com/opensourcemechanic/opendeck-test/discussions)
- [Accessibility Community](https://www.w3.org/WAI/Community/)
- [GNOME Accessibility](https://wiki.gnome.org/Accessibility)

### Tools and Extensions
- [VS Code Extensions](https://marketplace.visualstudio.com/)
- [Accessibility Testing Tools](https://www.w3.org/WAI/ER/tools/)
- [Screen Reader Extensions](https://addons.mozilla.org/en-US/firefox/)

---

## Quick Reference

### Essential Commands
```bash
# Start testing
python3 /root/test_app.py
orca --replace --enable-speech
accerciser &

# Debugging
export WEBKIT_DEBUG=accessibility
export ATK_DEBUG=1

# Health check
/root/health_check.sh

# Restart services
pkill -f orca && orca --replace --enable-speech
```

### Access Information
- **VNC Password**: test123
- **Web Access**: Port 6080 (auto-opens)
- **VNC Client**: Port 5900
- **Repository**: github.com/opensourcemechanic/opendeck-test

### Test Checklist
- [ ] Codespace created successfully
- [ ] VNC access working
- [ ] Test application running
- [ ] Screen reader enabled
- [ ] Accessibility tools launched
- [ ] Test scenarios executed
- [ ] Results documented

This guide provides comprehensive instructions for using the accessibility test environment in GitHub Codespaces.
