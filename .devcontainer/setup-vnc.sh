#!/bin/bash

# VNC Setup Script for Codespaces (using noVNC web approach)
echo "Setting up VNC environment for Codespaces..."

# Log file for debugging
LOG_FILE="/tmp/vnc-setup.log"
echo "Setup started at $(date)" > $LOG_FILE

# Kill any existing processes
pkill -f "Xvfb\|x11vnc\|fluxbox\|Xtigervnc\|websockify" 2>/dev/null
sleep 1

# Unset any existing display
unset DISPLAY
echo "Unset existing DISPLAY" >> $LOG_FILE

# Clean up any existing locks and sessions
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null
tigervncserver -kill :1 2>/dev/null

# Create VNC password directory
mkdir -p ~/.vnc
echo "test123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
echo "VNC password set" >> $LOG_FILE

# Start Xvfb first
echo "Starting Xvfb on display :1..." >> $LOG_FILE
Xvfb :1 -screen 0 1024x768x24 -ac >> $LOG_FILE 2>&1 &
XVFB_PID=$!
sleep 2

# Check if Xvfb started
if ! kill -0 $XVFB_PID 2>/dev/null; then
    echo "ERROR: Xvfb failed to start" >> $LOG_FILE
    cat $LOG_FILE
    exit 1
fi

echo "Xvfb started successfully" >> $LOG_FILE

# Set DISPLAY
export DISPLAY=:1
echo "Set DISPLAY to :1" >> $LOG_FILE

# Start fluxbox
echo "Starting fluxbox..." >> $LOG_FILE
fluxbox >> $LOG_FILE 2>&1 &
FLUXBOX_PID=$!
sleep 3

# Wait for X server to be ready
echo "Waiting for X server to be ready..." >> $LOG_FILE
timeout 10 sh -c "until xdpyinfo -display :1 >/dev/null 2>&1; do sleep 1; done" || echo "X server may not be fully ready" >> $LOG_FILE

# Start x11vnc for web access
echo "Starting x11vnc for web access..." >> $LOG_FILE
x11vnc -display :1 -forever -passwdfile ~/.vnc/passwd -rfbport 5901 -bg -noxdamage -wait 30 -shared >> $LOG_FILE 2>&1 &
X11VNC_PID=$!
sleep 3

# Check if x11vnc started
if ! kill -0 $X11VNC_PID 2>/dev/null; then
    echo "ERROR: x11vnc failed to start" >> $LOG_FILE
    cat $LOG_FILE
    exit 1
fi

echo "x11vnc started successfully" >> $LOG_FILE

# Verify port is listening
sleep 2
if netstat -tlnp 2>/dev/null | grep -q ":5901"; then
    echo "SUCCESS: VNC server is listening on port 5901" >> $LOG_FILE
else
    echo "WARNING: VNC server may not be listening on port 5901" >> $LOG_FILE
fi

echo "VNC setup completed at $(date)" >> $LOG_FILE
echo "VNC server ready! Access via:"
echo "  - Web Browser: port 6080 (Codespaces automatic forwarding)"
echo "  - VNC Client: port 5901 (password: test123)"
echo "Debug log available at: $LOG_FILE"
