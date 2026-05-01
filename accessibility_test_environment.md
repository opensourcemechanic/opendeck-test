# Accessibility Stack Test Environment Guide

## Overview

Test environments for WebKitGTK + OpenDeck + ATK + Orca accessibility stack.

## 1. Docker Container (Recommended)

### Dockerfile
```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    webkit2gtk-4.0 \
    libatk-bridge2.0-0 \
    at-spi2-core \
    orca \
    accerciser \
    xvfb \
    python3-gi \
    python3-dbus \
    dbus-x11 \
    gsettings-desktop-schemas \
    && rm -rf /var/lib/apt/lists/*

# Set up environment
ENV DISPLAY=:99
ENV XDG_RUNTIME_DIR=/tmp/runtime-root
ENV DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-root/bus

# Create startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Create test application
COPY test_app.py /test_app.py
RUN chmod +x /test_app.py

EXPOSE 5900
CMD ["/start.sh"]
```

### Docker Compose
```yaml
version: '3.8'
services:
  accessibility-test:
    build: .
    ports:
      - "5900:5900"
      - "6080:6080"
    environment:
      - DISPLAY=:99
      - DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-root/bus
    volumes:
      - ./test_data:/app/test_data
    cap_add:
      - SYS_ADMIN
    security_opt:
      - seccomp:unconfined

  vnc:
    image: danielkaiser/baseimage-vnc:ubuntu-22.04
    ports:
      - "5901:5900"
    environment:
      - VNC_PASSWORD=test123
```

### Startup Script (start.sh)
```bash
#!/bin/bash

# Start virtual display
Xvfb :99 -screen 0 1024x768x24 &

# Start D-Bus
mkdir -p /tmp/runtime-root
dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --fork

# Wait for services
sleep 2

# Enable accessibility
gsettings set org.gnome.desktop.interface toolkit-accessibility true

# Start AT-SPI
at-spi-bus-launcher &

# Start Orca in background
orca --replace --disable-speech --disable-braille &

# Start VNC server for GUI access
x11vnc -display :99 -forever -passwd test123 &

# Run test application
python3 /test_app.py

# Keep container running
tail -f /dev/null
```

### Test Application (test_app.py)
```python
#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('WebKit2', '4.0')

from gi.repository import Gtk, WebKit2, Gdk
import threading
import time

class AccessibilityTestApp:
    def __init__(self):
        self.window = Gtk.Window(title="Accessibility Test")
        self.window.set_default_size(800, 600)
        
        # Create web view
        self.webview = WebKit2.WebView()
        
        # Load test content
        self.load_test_content()
        
        # Add to window
        self.window.add(self.webview)
        self.window.connect("destroy", Gtk.main_quit)
        self.window.show_all()
        
    def load_test_content(self):
        html_content = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Accessibility Test</title>
            <style>
                body { font-family: Arial, sans-serif; padding: 20px; }
                button { margin: 10px; padding: 10px; }
                input { margin: 10px; padding: 5px; }
                .live-region { 
                    border: 1px solid #ccc; 
                    padding: 10px; 
                    margin: 10px 0;
                    min-height: 50px;
                }
            </style>
        </head>
        <body>
            <h1>Accessibility Test Page</h1>
            
            <nav aria-label="Main navigation">
                <button onclick="updateStatus('Home clicked')" aria-label="Home page">Home</button>
                <button onclick="updateStatus('About clicked')" aria-label="About page">About</button>
                <button onclick="updateStatus('Contact clicked')" aria-label="Contact page">Contact</button>
            </nav>
            
            <main>
                <section>
                    <h2>Form Test</h2>
                    <form>
                        <label for="name">Name:</label>
                        <input type="text" id="name" aria-required="true" 
                               placeholder="Enter your name">
                        
                        <label for="email">Email:</label>
                        <input type="email" id="email" aria-required="true"
                               placeholder="Enter your email">
                        
                        <button type="submit" aria-label="Submit form">Submit</button>
                    </form>
                </section>
                
                <section>
                    <h2>Dynamic Content Test</h2>
                    <button onclick="updateStatus('Status updated!')">Update Status</button>
                    <div id="status" class="live-region" aria-live="polite" aria-label="Status updates">
                        Initial status
                    </div>
                </section>
                
                <section>
                    <h2>Table Test</h2>
                    <table aria-label="Sample data table">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Price</th>
                                <th>Stock</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Widget A</td>
                                <td>$10.00</td>
                                <td>25</td>
                            </tr>
                            <tr>
                                <td>Widget B</td>
                                <td>$15.00</td>
                                <td>12</td>
                            </tr>
                        </tbody>
                    </table>
                </section>
            </main>
            
            <script>
                function updateStatus(message) {
                    var status = document.getElementById('status');
                    status.textContent = message;
                    console.log('Status updated:', message);
                }
                
                // Test dynamic content
                setTimeout(function() {
                    updateStatus('Auto-updated after 3 seconds');
                }, 3000);
            </script>
        </body>
        </html>
        """
        
        self.webview.load_html(html_content, "file:///")
        
    def run(self):
        Gtk.main()

if __name__ == "__main__":
    app = AccessibilityTestApp()
    app.run()
```

## 2. Kubernetes Deployment

### Kubernetes Manifest
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: accessibility-test
  labels:
    app: accessibility-test
spec:
  containers:
  - name: accessibility-test
    image: accessibility-test:latest
    ports:
    - containerPort: 5900
    env:
    - name: DISPLAY
      value: ":99"
    - name: DBUS_SESSION_BUS_ADDRESS
      value: "unix:path=/tmp/runtime-root/bus"
    volumeMounts:
    - name: test-data
      mountPath: /app/test_data
    securityContext:
      privileged: true
  volumes:
  - name: test-data
    emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: accessibility-test-service
spec:
  selector:
    app: accessibility-test
  ports:
  - port: 5900
    targetPort: 5900
  type: LoadBalancer
```

## 3. Online Test Environments

### GitHub Codespaces
```yaml
# .devcontainer/devcontainer.json
{
  "name": "Accessibility Test Environment",
  "dockerFile": "Dockerfile",
  "settings": {
    "terminal.integrated.shell.linux": "/bin/bash"
  },
  "forwardPorts": [5900, 6080],
  "postCreateCommand": "python3 /test_app.py"
}
```

### Gitpod Configuration
```yaml
# .gitpod.yml
image:
  file: Dockerfile

ports:
  - port: 5900
    onOpen: notify
  - port: 6080
    onOpen: open

tasks:
  - name: Start Accessibility Test
    command: python3 /test_app.py
```

## 4. Local Development Setup

### Vagrantfile
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y webkit2gtk-4.0 libatk-bridge2.0-0 at-spi2-core orca accerciser
    
    # Set up user environment
    echo 'export DISPLAY=:99' >> /home/vagrant/.bashrc
    echo 'export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-root/bus' >> /home/vagrant/.bashrc
    
    # Enable accessibility
    sudo -u vagrant gsettings set org.gnome.desktop.interface toolkit-accessibility true
  SHELL
  
  config.vm.network "forwarded_port", guest: 5900, host: 5900
end
```

## 5. Cloud Test Platforms

### AWS EC2 Setup
```bash
# User data script
#!/bin/bash
apt-get update
apt-get install -y webkit2gtk-4.0 libatk-bridge2.0-0 at-spi2-core orca accerciser xvfb

# Start services
Xvfb :99 -screen 0 1024x768x24 &
export DISPLAY=:99
gsettings set org.gnome.desktop.interface toolkit-accessibility true
at-spi-bus-launcher &
orca --replace --disable-speech --disable-braille &
```

### Google Cloud Platform
```yaml
# cloud-config
packages:
  - webkit2gtk-4.0
  - libatk-bridge2.0-0
  - at-spi2-core
  - orca
  - accerciser
  - xvfb

runcmd:
  - export DISPLAY=:99
  - Xvfb :99 -screen 0 1024x768x24 &
  - gsettings set org.gnome.desktop.interface toolkit-accessibility true
  - at-spi-bus-launcher &
  - orca --replace --disable-speech --disable-braille &
```

## 6. Testing Scripts

### Automated Test Script
```python
#!/usr/bin/env python3
import gi
gi.require_version('Atk', '1.0')
gi.require_version('WebKit2', '4.0')

from gi.repository import Atk, WebKit2, Gtk
import time

def test_accessibility():
    # Initialize GTK
    Gtk.init(None)
    
    # Create test webview
    webview = WebKit2.WebView()
    
    # Load test content
    webview.load_html("""
    <button id="test-btn" aria-label="Test button">Click me</button>
    <input type="text" id="test-input" aria-label="Test input">
    """, "file:///")
    
    # Wait for load
    time.sleep(2)
    
    # Get accessibility object
    accessible = webview.get_accessible()
    
    # Test accessibility features
    test_button_accessibility(accessible)
    test_input_accessibility(accessible)
    
    print("Accessibility tests completed")

def test_button_accessibility(accessible):
    """Test button accessibility"""
    # Find button
    for i in range(accessible.get_n_children()):
        child = accessible.get_ref_child(i)
        if child.get_role() == Atk.Role.PUSH_BUTTON:
            print(f"Button found: {child.get_name()}")
            print(f"Button role: {child.get_role()}")
            print(f"Button description: {child.get_description()}")
            
            # Test action interface
            if hasattr(child, 'do_action'):
                print("Button has action interface")
                child.do_action(0)  # Click button
            return True
    return False

def test_input_accessibility(accessible):
    """Test input field accessibility"""
    # Find input
    for i in range(accessible.get_n_children()):
        child = accessible.get_ref_child(i)
        if child.get_role() == Atk.Role.ENTRY:
            print(f"Input found: {child.get_name()}")
            print(f"Input role: {child.get_role()}")
            
            # Test text interface
            if hasattr(child, 'get_text'):
                text = child.get_text(0, -1)
                print(f"Input text: {text}")
            return True
    return False

if __name__ == "__main__":
    test_accessibility()
```

### Orca Integration Test
```python
#!/usr/bin/env python3
import subprocess
import time
import dbus

def test_orca_integration():
    """Test Orca screen reader integration"""
    
    # Start Orca
    orca_process = subprocess.Popen(['orca', '--replace', '--disable-speech'])
    
    try:
        # Connect to AT-SPI
        bus = dbus.SessionBus()
        atspi = bus.get_object('org.a11y.atspi.Registry', '/org/a11y/atspi/registry')
        
        # Test event listening
        def event_handler(event):
            print(f"AT-SPI Event: {event}")
            
        # Register listener
        atspi.RegisterEventListener(['object:state-changed:focused'], 
                                  event_handler, 
                                  dbus_interface='org.a11y.atspi.Registry')
        
        # Run for test duration
        time.sleep(30)
        
    finally:
        orca_process.terminate()

if __name__ == "__main__":
    test_orca_integration()
```

## 7. Quick Start Commands

### Docker Quick Start
```bash
# Build container
docker build -t accessibility-test .

# Run with VNC access
docker run -p 5900:5900 -p 6080:6080 accessibility-test

# Connect with VNC client
# Host: localhost:5900
# Password: test123
```

### Local Quick Start
```bash
# Install dependencies
sudo apt install webkit2gtk-4.0 libatk-bridge2.0-0 at-spi2-core orca accerciser

# Start virtual display
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 &

# Enable accessibility
gsettings set org.gnome.desktop.interface toolkit-accessibility true

# Start services
at-spi-bus-launcher &
orca --replace &

# Run test app
python3 test_app.py

# Test with Accerciser
accerciser &
```

## 8. Monitoring and Debugging

### Health Check Script
```bash
#!/bin/bash
echo "Checking accessibility stack..."

# Check AT-SPI
if pgrep -f "at-spi-bus-launcher" > /dev/null; then
    echo "✓ AT-SPI running"
else
    echo "✗ AT-SPI not running"
fi

# Check Orca
if pgrep -f "orca" > /dev/null; then
    echo "✓ Orca running"
else
    echo "✗ Orca not running"
fi

# Check WebKitGTK
if ldconfig -p | grep webkit2gtk > /dev/null; then
    echo "✓ WebKitGTK installed"
else
    echo "✗ WebKitGTK not found"
fi

# Test accessibility
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk
print('✓ ATK accessible')
" 2>/dev/null && echo "✓ ATK working" || echo "✗ ATK not working"
```

### Log Collection
```bash
# Collect accessibility logs
mkdir -p logs

# AT-SPI logs
at-spi-bus-launcher --verbose &> logs/atspi.log &

# Orca logs
orca --debug --disable-speech &> logs/orca.log &

# WebKitGTK logs
export WEBKIT_DEBUG=all
python3 test_app.py &> logs/webkit.log &
```

## Summary

| Environment | Setup Time | Persistence | GUI Access | Best For |
|-------------|-------------|-------------|-------------|----------|
| Docker | 5-10 min | Container | VNC/Web | Quick testing |
| Kubernetes | 10-15 min | Persistent | Load balancer | Production |
| Codespaces | 2-5 min | Session | Browser | Development |
| Local | 2-5 min | Permanent | Native | Daily use |

Docker is the most straightforward for quick testing, while local setup is best for ongoing development work.
