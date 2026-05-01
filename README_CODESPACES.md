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
- **Run commands directly**: `python3 /root/test_app.py`

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
- Standardized accessibility interfaces
- Object roles, actions, and properties

#### **Orca**
- Screen reader for GNOME
- Speech synthesis output
- Braille display support

### Test Application Features

#### **Form Accessibility Tests**
- **Required field validation**: ARIA `aria-required` attributes
- **Field descriptions**: ARIA `aria-describedby` relationships
- **Error handling**: Dynamic error announcements
- **Input types**: Text, email, phone, password fields

#### **Dynamic Content Tests**
- **Live regions**: ARIA `aria-live` announcements
- **Status updates**: Real-time content changes
- **Error messages**: Assertive vs polite announcements
- **Auto-updates**: Timed content changes

#### **Navigation Tests**
- **Landmark navigation**: ARIA landmarks (nav, main, section)
- **Tab navigation**: Keyboard accessibility
- **Focus management**: Visual and programmatic focus
- **Skip links**: Bypass navigation options

#### **Table Accessibility**
- **Headers**: Proper `th` elements with `scope` attributes
- **Captions**: Table descriptions
- **Cell relationships**: Row/column associations
- **Data tables**: Complex table structures

#### **Interactive Elements**
- **Buttons**: Various button types and states
- **Tabs**: Tab panel navigation
- **Progress indicators**: Loading and completion states
- **Links**: Link text and descriptions

## Using the Test Environment

### Basic Testing Workflow

#### **1. Launch the Test Application**
```bash
# In the Codespace terminal
python3 /root/test_app.py
```

#### **2. Enable Screen Reader**
```bash
# Start Orca with speech enabled
orca --replace --enable-speech

# Or restart with specific settings
pkill orca
orca --replace --enable-speech --enable-braille
```

#### **3. Test with Keyboard Navigation**
- **Tab**: Move between interactive elements
- **Shift+Tab**: Navigate backwards
- **Enter/Space**: Activate buttons and links
- **Arrow keys**: Navigate within tables and lists

#### **4. Monitor Accessibility Events**
```bash
# Launch Accerciser for ATK inspection
accerciser &

# Monitor AT-SPI events
at-spi-registryd --monitor &
```

### Specific Test Scenarios

#### **Form Validation Testing**
1. **Navigate to the form section**
2. **Tab through each field**
3. **Listen for announcements**:
   - "Name, text field, required"
   - "Email, text field, required"
   - "Phone, text field, optional"
4. **Test validation**:
   - Enter invalid data (short name)
   - Listen for error announcements
   - Verify error messages are announced

#### **Dynamic Content Testing**
1. **Click "Update Status" button**
2. **Listen for live region announcement**
3. **Click "Add Error" button**
4. **Verify assertive announcement**
5. **Wait for auto-update** (3 seconds)
6. **Listen for timed announcement**

#### **Table Navigation Testing**
1. **Navigate to the table**
2. **Use arrow keys** to move between cells
3. **Listen for announcements**:
   - "Widget A, column 1, row 1"
   - "$10.00, column 2, row 1"
   - "25, column 3, row 1"
4. **Test header relationships**

#### **Interactive Elements Testing**
1. **Navigate tabs**:
   - Tab to tab buttons
   - Use arrow keys to switch tabs
   - Listen for panel content changes
2. **Test progress indicators**:
   - Click "Update Progress"
   - Listen for percentage announcements
   - Verify completion states

### Advanced Testing

#### **Custom Test Content**
To add your own test content:

1. **Edit the test application**:
```bash
nano /root/test_app.py
```

2. **Modify the `load_test_content()` method**:
```python
def load_custom_content(self):
    html_content = """
    <!-- Your custom accessibility tests -->
    <button aria-label="Custom button">Test</button>
    """
    self.webview.load_html(html_content, "file:///")
```

3. **Restart the application**:
```bash
pkill -f test_app.py
python3 /root/test_app.py
```

#### **Accessibility API Testing**
```python
# Test ATK interfaces directly
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

# Get webview accessibility object
accessible = webview.get_accessible()

# Test specific interfaces
if hasattr(accessible, 'get_n_children'):
    child_count = accessible.get_n_children()
    print(f"Found {child_count} accessible children")
```

#### **Screen Reader Testing**
```bash
# Test Orca with different settings
orca --replace --enable-speech --speech-rate=50
orca --replace --enable-speech --speech-pitch=50
orca --replace --enable-speech --speech-volume=1.0

# Test with different verbosity levels
orca --replace --enable-speech --verbosity-level=verbose
orca --replace --enable-speech --verbosity-level=brief
```

## Troubleshooting

### Common Issues

#### **VNC Connection Problems**
```bash
# Check if VNC is running
pgrep -f vncserver

# Restart VNC server
vncserver :99 -kill
vncserver :99 -geometry 1024x768 -depth 24

# Check VNC password
cat /root/.vnc/passwd
```

#### **Screen Reader Not Working**
```bash
# Check if Orca is running
pgrep -f orca

# Restart Orca
pkill orca
orca --replace --enable-speech

# Check audio output
aplay /usr/share/sounds/alsa/Front_Left.wav
```

#### **Accessibility Events Not Firing**
```bash
# Check AT-SPI is running
pgrep -f at-spi-bus-launcher

# Restart AT-SPI
pkill -f at-spi-bus-launcher
at-spi-bus-launcher &

# Test with Accerciser
accerciser
```

#### **WebKitGTK Issues**
```bash
# Check WebKitGTK installation
ldconfig -p | grep webkit

# Test WebKitGTK directly
python3 -c "
import gi
gi.require_version('WebKit2', '4.0')
from gi.repository import WebKit2
print('WebKitGTK working')
"
```

### Performance Issues

#### **Slow Response Times**
```bash
# Check system resources
top
free -h
df -h

# Optimize performance
export WEBKIT_DEBUG=none
python3 /root/test_app.py
```

#### **High Memory Usage**
```bash
# Monitor memory usage
ps aux --sort=-%mem | head

# Restart services
pkill -f python3
python3 /root/test_app.py
```

### Network Issues

#### **Port Forwarding Problems**
```bash
# Check forwarded ports
netstat -tlnp | grep :590
netstat -tlnp | grep :608

# Check Codespace port status
curl -I http://localhost:6080
```

## Development and Customization

### Adding New Test Features

#### **Create Custom Test Modules**
```python
# Add to test_app.py
class CustomAccessibilityTests:
    def __init__(self, webview):
        self.webview = webview
        
    def load_custom_tests(self):
        html = """
        <section aria-label="Custom tests">
            <h2>Custom Accessibility Tests</h2>
            <!-- Your test content -->
        </section>
        """
        self.webview.load_html(html, "file:///")
```

#### **Add Accessibility Validators**
```python
def validate_accessibility(self):
    """Validate accessibility compliance"""
    accessible = self.webview.get_accessible()
    
    # Check for common issues
    issues = []
    
    # Check for missing labels
    if not self.has_proper_labels(accessible):
        issues.append("Missing form labels")
    
    # Check for proper headings
    if not self.has_proper_headings(accessible):
        issues.append("Improper heading structure")
    
    return issues
```

### Integration with External Tools

#### **Automated Testing**
```python
# Automated test runner
def run_accessibility_tests():
    """Run comprehensive accessibility tests"""
    tests = [
        test_form_accessibility,
        test_dynamic_content,
        test_table_navigation,
        test_keyboard_navigation
    ]
    
    results = {}
    for test in tests:
        results[test.__name__] = test()
    
    return results
```

#### **Continuous Integration**
```yaml
# .github/workflows/accessibility.yml
name: Accessibility Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Run accessibility tests
      run: |
        python3 test_accessibility.py
```

## Best Practices

### Testing Guidelines

#### **Comprehensive Testing**
1. **Test all interactive elements**
2. **Verify keyboard navigation**
3. **Check screen reader announcements**
4. **Validate ARIA implementation**
5. **Test dynamic content updates**

#### **User Experience Testing**
1. **Test with different screen reader settings**
2. **Verify focus management**
3. **Test with various input methods**
4. **Check color contrast and visibility**
5. **Test with different zoom levels**

#### **Performance Testing**
1. **Monitor response times**
2. **Check memory usage**
3. **Test with large documents**
4. **Verify smooth scrolling**
5. **Test with slow connections**

### Documentation Standards

#### **Test Documentation**
- Document test scenarios
- Record expected results
- Note any limitations
- Include troubleshooting steps
- Provide example code

#### **Accessibility Reporting**
- Track accessibility issues
- Document compliance status
- Report improvement metrics
- Maintain test history
- Share best practices

## Resources and References

### Documentation
- [WebKitGTK Accessibility Guide](https://webkitgtk.org/accessibility.html)
- [ATK Documentation](https://developer.gnome.org/atk/)
- [Orca Screen Reader Manual](https://help.gnome.org/users/orca/stable/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

### Tools and Utilities
- [Accerciser](https://wiki.gnome.org/Apps/Accerciser) - ATK inspector
- [Firefox Accessibility Inspector](https://developer.mozilla.org/en-US/docs/Tools/Accessibility_inspector)
- [Chrome Accessibility DevTools](https://developer.chrome.com/docs/devtools/accessibility/reference)

### Standards and Guidelines
- [WCAG 2.1 Guidelines](https://www.w3.org/TR/WCAG21/)
- [ARIA 1.1 Specification](https://www.w3.org/TR/wai-aria-1.1/)
- [HTML5 Accessibility](https://www.w3.org/TR/html-aam-1.0/)

## Support and Community

### Getting Help
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check the guides and tutorials
- **Community Forums**: Ask questions and share experiences
- **Mailing Lists**: Join accessibility discussions

### Contributing
- **Code Contributions**: Submit pull requests
- **Documentation**: Improve guides and examples
- **Test Cases**: Add new test scenarios
- **Bug Reports**: Report issues with details

---

## Quick Reference

### Essential Commands
```bash
# Start test application
python3 /root/test_app.py

# Start screen reader
orca --replace --enable-speech

# Launch accessibility inspector
accerciser

# Health check
/root/health_check.sh

# Restart services
pkill -f orca && orca --replace --enable-speech
```

### Access Information
- **VNC Port**: 5900
- **Web VNC**: Port 6080
- **VNC Password**: test123
- **Repository**: https://github.com/opensourcemechanic/opendeck-test

### Test Checklist
- [ ] Form accessibility works
- [ ] Dynamic content announced
- [ ] Table navigation functional
- [ ] Keyboard navigation complete
- [ ] Screen reader integration active
- [ ] ARIA roles properly mapped
- [ ] Focus management correct
- [ ] Error handling implemented

This environment provides everything needed for comprehensive accessibility testing of web applications using the GNOME accessibility stack.
