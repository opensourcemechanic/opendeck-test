#!/bin/bash

# VNC Setup Script for Codespaces
echo "Setting up VNC environment..."

# Log file for debugging
LOG_FILE="/tmp/vnc-setup.log"
echo "Setup started at $(date)" > $LOG_FILE

# Unset any existing display
unset DISPLAY
echo "Unset existing DISPLAY" >> $LOG_FILE

# Start Xvfb
echo "Starting Xvfb on :99..." >> $LOG_FILE
Xvfb :99 -screen 0 1024x768x24 >> $LOG_FILE 2>&1 &
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
export DISPLAY=:99
echo "Set DISPLAY to :99" >> $LOG_FILE

# Start fluxbox
echo "Starting fluxbox..." >> $LOG_FILE
fluxbox >> $LOG_FILE 2>&1 &
FLUXBOX_PID=$!
sleep 2

# Check if fluxbox started
if ! kill -0 $FLUXBOX_PID 2>/dev/null; then
    echo "WARNING: fluxbox may not have started properly" >> $LOG_FILE
fi

# Create VNC password directory
mkdir -p ~/.vnc
echo "test123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
echo "VNC password set" >> $LOG_FILE

# Start x11vnc
echo "Starting x11vnc..." >> $LOG_FILE
x11vnc -display :99 -forever -passwd test123 -rfbport 5900 -bg >> $LOG_FILE 2>&1 &
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
if netstat -tlnp 2>/dev/null | grep -q ":5900"; then
    echo "SUCCESS: VNC server is listening on port 5900" >> $LOG_FILE
else
    echo "WARNING: VNC server may not be listening on port 5900" >> $LOG_FILE
fi

echo "VNC setup completed at $(date)" >> $LOG_FILE
echo "VNC server ready! Connect via port 5900 (password: test123)"
echo "Debug log available at: $LOG_FILE"
