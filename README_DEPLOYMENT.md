# Accessibility Test Environment Deployment Guide

## Quick Start Options

### 1. Docker (Local) - Fastest
```bash
# Build and run
docker build -t accessibility-test .
docker run -p 5900:5900 -p 6080:6080 accessibility-test

# Or use docker-compose
docker-compose up -d
```

**Access**: VNC client to `localhost:5900` (password: `test123`)

### 2. GitHub Codespaces (Free Tier) - Recommended
**GitHub Codespaces supports this in the free tier!**

#### Setup:
1. Push this code to a GitHub repository
2. Click "Code" → "Codespaces" → "Create codespace on main"
3. Wait for build to complete (2-3 minutes)
4. Connect via forwarded port 5900

#### Access Methods:
- **VNC Client**: Connect to forwarded port 5900
- **Browser**: Port 6080 will auto-open in browser
- **VS Code**: Full development environment included

### 3. Gitpod (Free Tier) - Alternative
**Gitpod also supports this in the free tier!**

#### Setup:
1. Push this code to a GitHub repository
2. Visit `https://gitpod.io/#https://github.com/yourusername/yourrepo`
3. Wait for workspace to build
4. Access via automatically opened browser

## Deployment Instructions

### GitHub Codespaces Deployment

#### Step 1: Push to GitHub
```bash
git init
git add .
git commit -m "Add accessibility test environment"
git remote add origin https://github.com/yourusername/accessibility-test.git
git push -u origin main
```

#### Step 2: Create Codespace
1. Go to your GitHub repository
2. Click "Code" button
3. Select "Codespaces" tab
4. Click "Create codespace on main"
5. Wait for build (2-3 minutes)

#### Step 3: Access the Environment
- **VNC**: Use any VNC client to connect to the forwarded port 5900
- **Web**: Port 6080 will open automatically in your browser
- **Terminal**: Full bash access in VS Code terminal

#### Step 4: Run Tests
```bash
# In the VS Code terminal
python3 /root/test_app.py

# Check health
/root/health_check.sh

# Test accessibility
accerciser &
```

### Gitpod Deployment

#### Step 1: Push to GitHub
Same as above

#### Step 2: Open in Gitpod
1. Visit: `https://gitpod.io/#https://github.com/yourusername/accessibility-test`
2. Gitpod will automatically build the environment
3. Wait for setup to complete

#### Step 3: Access the Environment
- **Web VNC**: Opens automatically in browser
- **Terminal**: Full bash access in IDE
- **Ports**: 5900 and 6080 are automatically forwarded

### Docker Local Deployment

#### Step 1: Build Image
```bash
docker build -t accessibility-test .
```

#### Step 2: Run Container
```bash
# Basic run
docker run -p 5900:5900 -p 6080:6080 accessibility-test

# With data persistence
docker run -d \
  -p 5900:5900 \
  -p 6080:6080 \
  -v $(pwd)/test_data:/app/test_data \
  -v $(pwd)/logs:/app/logs \
  --name accessibility-test \
  accessibility-test
```

#### Step 3: Access
- **VNC Client**: Connect to `localhost:5900` (password: `test123`)
- **Web**: If using noVNC, access `http://localhost:6080`

#### Step 4: Use Docker Compose (Recommended)
```bash
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Access Methods

### VNC Client Setup
1. **Recommended clients**:
   - **Windows**: RealVNC Viewer, TightVNC
   - **macOS**: RealVNC Viewer, Screen Sharing
   - **Linux**: Remmina, TigerVNC

2. **Connection details**:
   - **Host**: `localhost` (or Codespace/Gitpod URL)
   - **Port**: `5900`
   - **Password**: `test123`

### Web Access
- **Port 6080**: Opens web-based VNC client
- **No additional software needed**
- **Works in any modern browser**

## Testing the Environment

### Basic Tests
```bash
# Check if everything is running
/root/health_check.sh

# Run the test application
python3 /root/test_app.py

# Test with accessibility tools
accerciser &
```

### Accessibility Tests
The test application includes:

1. **Form Navigation**: Test ARIA labels, required fields
2. **Dynamic Content**: Live regions, status updates
3. **Table Navigation**: Headers, cell coordinates
4. **Interactive Elements**: Buttons, tabs, progress bars
5. **Screen Reader Integration**: Orca announcements

### Manual Testing
1. **Keyboard Navigation**: Tab through elements
2. **Screen Reader**: Verify Orca announcements
3. **AT-SPI Events**: Monitor with Accerciser
4. **Focus Management**: Test focus indicators

## Troubleshooting

### Common Issues

#### VNC Connection Failed
```bash
# Check if VNC is running
docker exec accessibility-test pgrep -f vncserver

# Restart VNC
docker exec accessibility-test vncserver :99 -kill
docker exec accessibility-test vncserver :99 -geometry 1024x768 -depth 24
```

#### ATK Not Working
```bash
# Check ATK installation
docker exec accessibility-test python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk
print('ATK working')
"

# Restart accessibility services
docker exec accessibility-test pkill -f orca
docker exec accessibility-test pkill -f at-spi
docker exec accessibility-test at-spi-bus-launcher &
docker exec accessibility-test orca --replace &
```

#### WebKitGTK Issues
```bash
# Check WebKitGTK installation
docker exec accessibility-test ldconfig -p | grep webkit

# Test WebKitGTK directly
docker exec accessibility-test python3 -c "
import gi
gi.require_version('WebKit2', '4.0')
from gi.repository import WebKit2
print('WebKitGTK working')
"
```

### Performance Issues
- **Increase memory**: Codespaces with 2GB+ RAM recommended
- **Use release builds**: Optimize for performance
- **Reduce logging**: Set appropriate log levels

### Network Issues
- **Check port forwarding**: Ensure ports 5900/6080 are forwarded
- **Firewall**: Allow VNC connections
- **Proxy**: Configure if behind corporate firewall

## Advanced Configuration

### Custom Test Content
Edit `/root/test_app.py` to add custom accessibility tests:

```python
# Add your own test content
def load_custom_content(self):
    html_content = """
    <!-- Your custom accessibility tests -->
    """
    self.webview.load_html(html_content, "file:///")
```

### Additional Tools
```bash
# Install more accessibility tools
docker exec accessibility-test apt-get update
docker exec accessibility-test apt-get install -y \
    accerciser \
    caribou \
    gnome-orca \
    at-spi2-core
```

### Performance Monitoring
```bash
# Monitor resource usage
docker stats accessibility-test

# Check logs
docker logs accessibility-test
```

## Security Considerations

### VNC Security
- **Change password**: Modify `VNC_PASSWORD` environment variable
- **Use SSH tunnel**: For remote access
- **Limit exposure**: Only expose necessary ports

### Container Security
- **Read-only filesystem**: Where possible
- **Minimal privileges**: Reduce container capabilities
- **Regular updates**: Keep base image updated

## Production Deployment

### Kubernetes
```yaml
# Use the provided Kubernetes manifest
kubectl apply -f k8s-manifest.yaml
```

### Cloud Services
- **AWS ECS**: Use Docker Compose definition
- **Google Cloud Run**: Container-based deployment
- **Azure Container Instances**: Quick deployment

## Summary

| Platform | Free Tier | Setup Time | GUI Access | Best For |
|----------|-----------|------------|------------|----------|
| GitHub Codespaces | ✅ | 2-3 min | Browser + VNC | Development |
| Gitpod | ✅ | 2-3 min | Browser + VNC | Development |
| Docker Local | ✅ | 5-10 min | VNC only | Testing |
| Kubernetes | ❌ | 10-15 min | Configurable | Production |

**GitHub Codespaces is recommended** for free tier usage - it provides the best experience with minimal setup and excellent browser-based access.
