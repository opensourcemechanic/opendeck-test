#!/bin/bash

# WSL Accessibility Test Environment Setup with Web VNC
echo "Setting up accessibility test environment in WSL with Web VNC..."

# Check for --force flag to skip WSL detection
if [ "$1" = "--force" ]; then
    echo "Force mode: skipping WSL detection"
else
    # Check if running in WSL
    if ! grep -q -i "microsoft\|wsl" /proc/version 2>/dev/null && ! [ -d /mnt/c ]; then
        echo "This script is designed for WSL. Please run it in WSL."
        echo "Current system: $(uname -a)"
        echo "Debug info:"
        echo "  /proc/version: $(cat /proc/version 2>/dev/null || echo 'not found')"
        echo "  /mnt/c exists: $([ -d /mnt/c ] && echo 'yes' || echo 'no')"
        echo ""
        echo "If you're sure you're in WSL, run with --force flag:"
        echo "  ./setup-wsl-web.sh --force"
        exit 1
    fi
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
    net-tools \
    git \
    make

# Install Python packages
echo "Installing Python packages..."
pip3 install --no-cache-dir \
    pyatspi2 \
    dbus-python \
    websockify

# Install noVNC for web access
echo "Installing noVNC for web access..."
cd ~
if [ ! -d "noVNC" ]; then
    git clone https://github.com/novnc/noVNC.git
fi
cd noVNC
git pull origin master

# Download websockify if not present
if [ ! -d "websockify" ]; then
    git clone https://github.com/novnc/websockify.git
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p ~/.vnc
mkdir -p /tmp/runtime-root

# Create VNC password
echo "Creating VNC password..."
echo "test123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Create startup script with web VNC
echo "Creating startup script..."
cat > ~/start-accessibility-web.sh << 'EOF'
#!/bin/bash

# WSL Accessibility Environment Startup with Web VNC
echo "Starting accessibility test environment with Web VNC..."

# Environment variables
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime-root
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-root/bus

# Kill existing processes
echo "Cleaning up existing processes..."
pkill -f "Xvfb\|x11vnc\|fluxbox\|Xtigervnc\|dbus-daemon\|at-spi\|websockify" 2>/dev/null
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

# Start websockify for web VNC
echo "Starting websockify for web VNC..."
cd ~/noVNC
python3 ~/noVNC/websockify/run --web ~/noVNC --target-config ~/.vnc/config 6080 &
WEBSOCKIFY_PID=$!
sleep 2

# Show connection info
echo ""
echo "=== Accessibility Environment Ready ==="
echo "VNC Server: localhost:5901"
echo "Web VNC: http://localhost:6080/vnc.html"
echo "Password: test123"
echo "Display: :1"
echo ""
echo "Connect with:"
echo "  VNC Client: vncviewer localhost:5901"
echo "  Web Browser: http://localhost:6080/vnc.html"
echo ""
echo "Press Ctrl+C to stop the environment"
echo ""

# Keep script running
trap 'echo "Stopping environment..."; pkill -f "Xvfb\|x11vnc\|fluxbox\|Xtigervnc\|dbus-daemon\|at-spi\|orca\|websockify"; tigervncserver -kill :1 2>/dev/null; exit' INT

# Show status
echo "Environment status:"
ps aux | grep -E "(Xvfb|Xtigervnc|fluxbox|at-spi|orca|websockify)" | grep -v grep

echo ""
echo "Environment is running. Press Ctrl+C to stop."

# Wait indefinitely
while true; do
    sleep 10
    # Check if critical processes are still running
    if ! pgrep -f "Xvfb :1" > /dev/null; then
        echo "Xvfb stopped unexpectedly!"
        break
    fi
    if ! pgrep -f "websockify" > /dev/null; then
        echo "websockify stopped unexpectedly!"
        break
    fi
done
EOF

chmod +x ~/start-accessibility-web.sh

echo ""
echo "=== WSL Web VNC Setup Complete ==="
echo ""
echo "To start the accessibility environment with web VNC:"
echo "  ~/start-accessibility-web.sh"
echo ""
echo "To connect:"
echo "  VNC Client: vncviewer localhost:5901"
echo "  Web Browser: http://localhost:6080/vnc.html"
echo "  Password: test123"
echo ""
echo "The web VNC setup script is ready to use!"
