#!/bin/bash

# VNC Setup Script for Codespaces (using standard display :99)
echo "Setting up VNC environment for Codespaces..."

# Log file for debugging
LOG_FILE="/tmp/vnc-setup.log"
echo "Setup started at $(date)" > $LOG_FILE

# Kill any existing processes
pkill -f "Xvfb\|x11vnc\|fluxbox\|Xtigervnc" 2>/dev/null
sleep 1

# Unset any existing display
unset DISPLAY
echo "Unset existing DISPLAY" >> $LOG_FILE

# Clean up any existing locks and sessions
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null
tigervncserver -kill :99 2>/dev/null

# Create VNC password directory
mkdir -p ~/.vnc
echo "test123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
echo "VNC password set" >> $LOG_FILE

# Start tigervnc server on display :99 (standard Codespaces VNC port)
echo "Starting tigervnc server on display :99..." >> $LOG_FILE
tigervncserver :99 -geometry 1024x768 -depth 24 -localhost no >> $LOG_FILE 2>&1 &
sleep 3

# Check if vncserver started
if pgrep -f "Xtigervnc :99" > /dev/null; then
    echo "tigervnc started successfully on :99" >> $LOG_FILE
else
    echo "ERROR: tigervnc failed to start" >> $LOG_FILE
    cat $LOG_FILE
    exit 1
fi

# Set DISPLAY
export DISPLAY=:99
echo "Set DISPLAY to :99" >> $LOG_FILE

# Start fluxbox in the VNC session
echo "Starting fluxbox..." >> $LOG_FILE
export DISPLAY=:99
fluxbox >> $LOG_FILE 2>&1 &
sleep 2

# Verify port is listening
sleep 2
if netstat -tlnp 2>/dev/null | grep -q ":5900"; then
    echo "SUCCESS: VNC server is listening on port 5900" >> $LOG_FILE
else
    echo "WARNING: VNC server may not be listening on port 5900" >> $LOG_FILE
fi

echo "VNC setup completed at $(date)" >> $LOG_FILE
echo "VNC server ready! Access via:"
echo "  - VNC Client: port 5900 (password: test123)"
echo "  - Web Browser: port 6080 (Codespaces automatic forwarding)"
echo "Debug log available at: $LOG_FILE"
