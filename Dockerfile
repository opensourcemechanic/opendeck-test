FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
    pyatspi2 \
    dbus-python

# Set up environment variables
ENV DISPLAY=:99
ENV XDG_RUNTIME_DIR=/tmp/runtime-root
ENV DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-root/bus
ENV HOME=/root
ENV VNC_PASSWORD=test123

# Create necessary directories
RUN mkdir -p /tmp/runtime-root /root/.vnc

# Create VNC startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=:99\n\
export DBUS_SESSION_BUS_ADDRESS=unix:path:/tmp/runtime-root/bus\n\
export XDG_RUNTIME_DIR=/tmp/runtime-root\n\
\n\
# Start D-Bus\n\
mkdir -p /tmp/runtime-root\n\
dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --fork\n\
\n\
# Wait for D-Bus\n\
sleep 2\n\
\n\
# Enable accessibility\n\
gsettings set org.gnome.desktop.interface toolkit-accessibility true\n\
\n\
# Start AT-SPI\n\
at-spi-bus-launcher &\n\
\n\
# Wait for AT-SPI\n\
sleep 3\n\
\n\
# Start Orca (background)\n\
orca --replace --disable-speech --disable-braille &\n\
\n\
# Start window manager\n\
fluxbox &\n\
\n\
# Start VNC server\n\
mkdir -p /root/.vnc\n\
echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd\n\
chmod 600 /root/.vnc/passwd\n\
vncserver :99 -geometry 1024x768 -depth 24\n\
\n\
# Keep container running\n\
tail -f /dev/null' > /root/start.sh && chmod +x /root/start.sh

# Create test application
COPY test_app.py /root/test_app.py
RUN chmod +x /root/test_app.py

# Create health check script
COPY health_check.sh /root/health_check.sh
RUN chmod +x /root/health_check.sh

# Expose VNC port
EXPOSE 5900

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /root/health_check.sh

# Start the services
CMD ["/root/start.sh"]
