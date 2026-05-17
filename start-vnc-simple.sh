#!/bin/bash

# Simple VNC startup script for WSL
echo "Starting VNC server..."

# Kill existing processes
pkill -f "Xtigervnc" 2>/dev/null
sleep 1

# Fix X socket permissions
sudo chmod 1777 /tmp/.X11-unix 2>/dev/null || true

# Set DISPLAY to :2 (avoid conflict with Xvfb :1)
export DISPLAY=:2

# Create VNC password
mkdir -p ~/.vnc
echo "test123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Start VNC server on display :2 (port 5902)
echo "Starting VNC server on display :2 (port 5902)..."
tigervncserver :2 -geometry 1024x768 -depth 24 -localhost no

# Wait a moment
sleep 2

# Check if VNC is running
if pgrep -f "Xtigervnc :2" > /dev/null; then
    echo "✓ VNC server started successfully"
    echo ""
    echo "=== VNC Connection Info ==="
    echo "Port: 5902"
    echo "Password: test123"
    echo "Display: :2"
    echo ""
    echo "Connect with:"
    echo "  vncviewer localhost:5902"
    echo ""
    echo "Or from Windows:"
    echo "  Connect to: localhost:5902"
    echo "  Password: test123"
else
    echo "✗ VNC server failed to start"
    echo "Check log: ~/.vnc/*.log"
fi

# Start fluxbox in the VNC session
export DISPLAY=:2
fluxbox &

echo ""
echo "VNC server is running. Press Ctrl+C to stop."
echo "To stop: tigervncserver -kill :2"

# Keep running
trap 'echo "Stopping VNC..."; tigervncserver -kill :2; exit' INT
while true; do
    sleep 10
done
