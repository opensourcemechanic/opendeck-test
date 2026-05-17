#!/bin/bash

# WSL Accessibility Test Environment Setup
echo "Setting up accessibility test environment in WSL..."

# Check if running in WSL
if ! grep -q Microsoft /proc/version; then
    echo "This script is designed for WSL. Please run it in WSL."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install system dependencies
echo "Installing system dependencies..."
sudo apt-get install -y \
    webkit2gtk-4.0 \
    libatk-bridge2.0-0 \
    at-spi2-core \
    orca \
    accerciser \
    xvfb \
    python3-gi \
    python3-dbus \
    python3-pip \
    dbus-x11 \
    gsettings-desktop-schemas \
    tigervnc-standalone-server \
    tigervnc-tools \
    fluxbox \
    wget \
    curl \
    net-tools

# Install Python packages
echo "Installing Python packages..."
pip3 install --no-cache-dir \
    pyatspi2 \
    dbus-python

# Create necessary directories
echo "Creating directories..."
mkdir -p ~/.vnc
mkdir -p /tmp/runtime-root

# Create VNC password
echo "Creating VNC password..."
echo "test123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Create startup script
echo "Creating startup script..."
cat > ~/start-accessibility-env.sh << 'EOF'
#!/bin/bash

# WSL Accessibility Environment Startup
echo "Starting accessibility test environment..."

# Environment variables
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime-root
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-root/bus

# Kill existing processes
echo "Cleaning up existing processes..."
pkill -f "Xvfb\|x11vnc\|fluxbox\|Xtigervnc\|dbus-daemon\|at-spi" 2>/dev/null
sleep 2

# Clean up locks
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null
tigervncserver -kill :1 2>/dev/null

# Start D-Bus
echo "Starting D-Bus..."
mkdir -p /tmp/runtime-root
dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --fork

# Wait for D-Bus
sleep 2

# Start Xvfb
echo "Starting Xvfb..."
Xvfb :1 -screen 0 1024x768x24 -ac &
XVFB_PID=$!
sleep 2

# Check if Xvfb started
if ! kill -0 $XVFB_PID 2>/dev/null; then
    echo "ERROR: Xvfb failed to start"
    exit 1
fi

# Wait for X server to be ready
echo "Waiting for X server..."
timeout 10 sh -c "until xdpyinfo -display :1 >/dev/null 2>&1; do sleep 1; done"

# Enable accessibility
echo "Enabling accessibility..."
gsettings set org.gnome.desktop.interface toolkit-accessibility true 2>/dev/null || echo "gsettings command failed (expected in WSL)"

# Start AT-SPI
echo "Starting AT-SPI..."
at-spi-bus-launcher &
sleep 3

# Start Orca (background, no speech/braille for testing)
echo "Starting Orca..."
orca --replace --disable-speech --disable-braille &
sleep 2

# Start window manager
echo "Starting Fluxbox..."
fluxbox &
sleep 2

# Start VNC server
echo "Starting VNC server..."
tigervncserver :1 -geometry 1024x768 -depth 24 -localhost no

# Show connection info
echo ""
echo "=== Accessibility Environment Ready ==="
echo "VNC Server: localhost:5901"
echo "Password: test123"
echo "Display: :1"
echo ""
echo "Connect with VNC client:"
echo "  vncviewer localhost:5901"
echo ""
echo "Or use web VNC (if you have websockify):"
echo "  http://localhost:6080/vnc.html"
echo ""
echo "Press Ctrl+C to stop the environment"
echo ""

# Keep script running
trap 'echo "Stopping environment..."; pkill -f "Xvfb\|x11vnc\|fluxbox\|Xtigervnc\|dbus-daemon\|at-spi\|orca"; tigervncserver -kill :1 2>/dev/null; exit' INT

# Show status
echo "Environment status:"
ps aux | grep -E "(Xvfb|Xtigervnc|fluxbox|at-spi|orca)" | grep -v grep

echo ""
echo "Environment is running. Press Ctrl+C to stop."

# Wait indefinitely
while true; do
    sleep 10
    # Check if critical processes are still running
    if ! pgrep -f "Xvfb :1" > /dev/null; then
        echo "Xvbf stopped unexpectedly!"
        break
    fi
done
EOF

chmod +x ~/start-accessibility-env.sh

# Create test script
echo "Creating test script..."
cat > ~/test-accessibility.sh << 'EOF'
#!/bin/bash

# Test accessibility environment
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime-root
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-root/bus

echo "Testing accessibility environment..."

# Test 1: Check if VNC is running
if pgrep -f "Xtigervnc :1" > /dev/null; then
    echo "✓ VNC server is running"
else
    echo "✗ VNC server is not running"
fi

# Test 2: Check if AT-SPI is running
if pgrep -f "at-spi" > /dev/null; then
    echo "✓ AT-SPI is running"
else
    echo "✗ AT-SPI is not running"
fi

# Test 3: Check if Orca is running
if pgrep -f "orca" > /dev/null; then
    echo "✓ Orca is running"
else
    echo "✗ Orca is not running"
fi

# Test 4: Check Python accessibility
echo ""
echo "Testing Python accessibility..."
python3 -c "
import pyatspi
import dbus
print('✓ Python accessibility modules imported successfully')

# Try to get accessible applications
try:
    registry = pyatspi.Registry
    desktop = pyatspi.Registry.getDesktop(0)
    app_count = desktop.childCount
    print(f'✓ Found {app_count} accessible applications')
except Exception as e:
    print(f'✗ Error accessing applications: {e}')
"

echo ""
echo "Test completed."
EOF

chmod +x ~/test-accessibility.sh

echo ""
echo "=== WSL Setup Complete ==="
echo ""
echo "To start the accessibility environment:"
echo "  ~/start-accessibility-env.sh"
echo ""
echo "To test the environment:"
echo "  ~/test-accessibility.sh"
echo ""
echo "To connect with VNC client:"
echo "  vncviewer localhost:5901"
echo "  Password: test123"
echo ""
echo "The setup script is ready to use!"
