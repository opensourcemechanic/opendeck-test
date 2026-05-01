#!/bin/bash

# Health check script for accessibility test environment

echo "Checking accessibility stack health..."

# Check if X server is running
if pgrep -f "Xvfb" > /dev/null; then
    echo "✓ X server running"
else
    echo "✗ X server not running"
    exit 1
fi

# Check if D-Bus is running
if [ -S "/tmp/runtime-root/bus" ]; then
    echo "✓ D-Bus socket exists"
else
    echo "✗ D-Bus socket not found"
    exit 1
fi

# Check if AT-SPI is running
if pgrep -f "at-spi-bus-launcher" > /dev/null; then
    echo "✓ AT-SPI running"
else
    echo "✗ AT-SPI not running"
    exit 1
fi

# Check if Orca is running
if pgrep -f "orca" > /dev/null; then
    echo "✓ Orca running"
else
    echo "✗ Orca not running"
    exit 1
fi

# Check if VNC server is running
if pgrep -f "vncserver" > /dev/null; then
    echo "✓ VNC server running"
else
    echo "✗ VNC server not running"
    exit 1
fi

# Check if Python test app can access ATK
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk
print('✓ ATK accessible')
" 2>/dev/null && echo "✓ ATK working" || (echo "✗ ATK not working" && exit 1)

# Check if WebKitGTK is available
ldconfig -p | grep webkit2gtk > /dev/null && echo "✓ WebKitGTK installed" || (echo "✗ WebKitGTK not found" && exit 1)

echo "✓ All health checks passed"
exit 0
