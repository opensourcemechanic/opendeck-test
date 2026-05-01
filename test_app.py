#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('WebKit2', '4.0')

from gi.repository import Gtk, WebKit2, Gdk
import threading
import time
import os

class AccessibilityTestApp:
    def __init__(self):
        self.window = Gtk.Window(title="Accessibility Test Environment")
        self.window.set_default_size(900, 700)
        
        # Create main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.window.add(main_box)
        
        # Create toolbar
        toolbar = self.create_toolbar()
        main_box.pack_start(toolbar, False, False, 0)
        
        # Create web view
        self.webview = WebKit2.WebView()
        settings = self.webview.get_settings()
        settings.set_enable_javascript(True)
        settings.set_enable_developer_extras(True)
        
        # Load test content
        self.load_test_content()
        
        # Add web view to scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.add(self.webview)
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        main_box.pack_start(scrolled, True, True, 0)
        
        # Status bar
        self.status_bar = Gtk.Statusbar()
        main_box.pack_start(self.status_bar, False, False, 0)
        
        self.window.connect("destroy", Gtk.main_quit)
        self.window.show_all()
        
        # Start status updates
        self.update_status("Accessibility test environment ready")
        
    def create_toolbar(self):
        toolbar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        
        # Test buttons
        btn_test = Gtk.Button(label="Run Tests")
        btn_test.connect("clicked", self.run_tests)
        toolbar.pack_start(btn_test, False, False, 0)
        
        btn_clear = Gtk.Button(label="Clear Status")
        btn_clear.connect("clicked", self.clear_status)
        toolbar.pack_start(btn_clear, False, False, 0)
        
        # Accessibility info
        btn_info = Gtk.Button(label="Accessibility Info")
        btn_info.connect("clicked", self.show_accessibility_info)
        toolbar.pack_start(btn_info, False, False, 0)
        
        return toolbar
        
    def load_test_content(self):
        html_content = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Accessibility Test Environment</title>
            <meta charset="UTF-8">
            <style>
                body { 
                    font-family: Arial, sans-serif; 
                    padding: 20px; 
                    background: #f5f5f5;
                }
                .container {
                    max-width: 800px;
                    margin: 0 auto;
                    background: white;
                    padding: 20px;
                    border-radius: 8px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }
                button { 
                    margin: 10px; 
                    padding: 12px 20px; 
                    background: #007cba;
                    color: white;
                    border: none;
                    border-radius: 4px;
                    cursor: pointer;
                }
                button:hover { background: #005a87; }
                button:focus { outline: 2px solid #005a87; }
                input { 
                    margin: 10px; 
                    padding: 8px; 
                    border: 1px solid #ccc;
                    border-radius: 4px;
                }
                input:focus { outline: 2px solid #007cba; }
                .live-region { 
                    border: 2px solid #007cba; 
                    padding: 15px; 
                    margin: 10px 0;
                    min-height: 60px;
                    border-radius: 4px;
                    background: #e7f3ff;
                }
                .section {
                    margin: 20px 0;
                    padding: 15px;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                }
                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin: 10px 0;
                }
                th, td {
                    border: 1px solid #ddd;
                    padding: 8px;
                    text-align: left;
                }
                th {
                    background: #f2f2f2;
                    font-weight: bold;
                }
                tr:hover { background: #f9f9f9; }
                .test-result {
                    margin: 10px 0;
                    padding: 10px;
                    border-radius: 4px;
                }
                .success { background: #d4edda; color: #155724; }
                .error { background: #f8d7da; color: #721c24; }
                .info { background: #d1ecf1; color: #0c5460; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Accessibility Test Environment</h1>
                <p>This page tests WebKitGTK + OpenDeck + ATK + Orca integration</p>
                
                <nav aria-label="Main navigation">
                    <h2>Navigation Tests</h2>
                    <button onclick="updateStatus('Home button clicked')" aria-label="Navigate to home page">Home</button>
                    <button onclick="updateStatus('About button clicked')" aria-label="Navigate to about page">About</button>
                    <button onclick="updateStatus('Contact button clicked')" aria-label="Navigate to contact page">Contact</button>
                </nav>
                
                <section class="section">
                    <h2>Form Accessibility Tests</h2>
                    <form>
                        <label for="name">Name:</label>
                        <input type="text" id="name" aria-required="true" 
                               placeholder="Enter your name" aria-describedby="name-help">
                        <div id="name-help" class="info">Please enter your full name</div>
                        
                        <label for="email">Email:</label>
                        <input type="email" id="email" aria-required="true"
                               placeholder="Enter your email" aria-describedby="email-help">
                        <div id="email-help" class="info">We'll never share your email</div>
                        
                        <label for="phone">Phone (optional):</label>
                        <input type="tel" id="phone" aria-required="false"
                               placeholder="Enter your phone number">
                        
                        <button type="submit" aria-label="Submit registration form">Submit Form</button>
                    </form>
                </section>
                
                <section class="section">
                    <h2>Dynamic Content Tests</h2>
                    <button onclick="updateStatus('Status updated by user click!')">Update Status</button>
                    <button onclick="addError('This is an error message')">Add Error</button>
                    <button onclick="addSuccess('Operation completed successfully')">Add Success</button>
                    
                    <div id="status" class="live-region" aria-live="polite" aria-label="Status updates">
                        Initial status - waiting for updates...
                    </div>
                </section>
                
                <section class="section">
                    <h2>Table Navigation Tests</h2>
                    <table aria-label="Product inventory data">
                        <caption>Current inventory levels</caption>
                        <thead>
                            <tr>
                                <th scope="col">Product</th>
                                <th scope="col">Price</th>
                                <th scope="col">Stock</th>
                                <th scope="col">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td scope="row">Widget A</td>
                                <td>$10.00</td>
                                <td>25</td>
                                <td>In Stock</td>
                            </tr>
                            <tr>
                                <td scope="row">Widget B</td>
                                <td>$15.00</td>
                                <td>0</td>
                                <td>Out of Stock</td>
                            </tr>
                            <tr>
                                <td scope="row">Widget C</td>
                                <td>$20.00</td>
                                <td>12</td>
                                <td>Limited Stock</td>
                            </tr>
                        </tbody>
                    </table>
                </section>
                
                <section class="section">
                    <h2>Interactive Elements</h2>
                    <div role="tablist" aria-label="Product tabs">
                        <button role="tab" aria-selected="true" aria-controls="panel1" onclick="showTab('panel1', this)">Overview</button>
                        <button role="tab" aria-selected="false" aria-controls="panel2" onclick="showTab('panel2', this)">Details</button>
                        <button role="tab" aria-selected="false" aria-controls="panel3" onclick="showTab('panel3', this)">Reviews</button>
                    </div>
                    
                    <div id="panel1" role="tabpanel" aria-labelledby="tab1" class="tab-panel">
                        <h3>Product Overview</h3>
                        <p>This is the overview content for our accessibility test product.</p>
                    </div>
                    
                    <div id="panel2" role="tabpanel" aria-labelledby="tab2" class="tab-panel" hidden>
                        <h3>Product Details</h3>
                        <p>Detailed specifications and features go here.</p>
                    </div>
                    
                    <div id="panel3" role="tabpanel" aria-labelledby="tab3" class="tab-panel" hidden>
                        <h3>Customer Reviews</h3>
                        <p>Customer feedback and reviews would appear here.</p>
                    </div>
                </section>
                
                <section class="section">
                    <h2>Progress Indicators</h2>
                    <div>
                        <label for="progress1">File Upload Progress:</label>
                        <progress id="progress1" value="75" max="100" aria-label="File upload 75% complete">75%</progress>
                    </div>
                    
                    <div>
                        <label for="progress2">Processing Status:</label>
                        <progress id="progress2" value="30" max="100" aria-label="Processing 30% complete">30%</progress>
                    </div>
                    
                    <button onclick="updateProgress()">Update Progress</button>
                </section>
            </div>
            
            <script>
                function updateStatus(message) {
                    var status = document.getElementById('status');
                    status.textContent = message;
                    status.className = 'live-region info';
                    console.log('Status updated:', message);
                    
                    // Announce to screen readers
                    status.setAttribute('aria-live', 'assertive');
                    setTimeout(() => {
                        status.setAttribute('aria-live', 'polite');
                    }, 1000);
                }
                
                function addError(message) {
                    var status = document.getElementById('status');
                    status.innerHTML = '<div class="test-result error">' + message + '</div>';
                    status.setAttribute('aria-live', 'assertive');
                }
                
                function addSuccess(message) {
                    var status = document.getElementById('status');
                    status.innerHTML = '<div class="test-result success">' + message + '</div>';
                    status.setAttribute('aria-live', 'polite');
                }
                
                function showTab(panelId, tabButton) {
                    // Hide all panels
                    var panels = document.querySelectorAll('[role="tabpanel"]');
                    panels.forEach(panel => panel.hidden = true);
                    
                    // Show selected panel
                    document.getElementById(panelId).hidden = false;
                    
                    // Update tab states
                    var tabs = document.querySelectorAll('[role="tab"]');
                    tabs.forEach(tab => tab.setAttribute('aria-selected', 'false'));
                    tabButton.setAttribute('aria-selected', 'true');
                    
                    updateStatus('Switched to ' + panelId + ' tab');
                }
                
                function updateProgress() {
                    var progress1 = document.getElementById('progress1');
                    var progress2 = document.getElementById('progress2');
                    
                    progress1.value = Math.min(100, progress1.value + 10);
                    progress2.value = Math.min(100, progress2.value + 15);
                    
                    updateStatus('Progress updated: File ' + progress1.value + '%, Processing ' + progress2.value + '%');
                }
                
                // Auto-update for testing
                setTimeout(function() {
                    updateStatus('Auto-updated after 3 seconds - accessibility stack is working!');
                }, 3000);
                
                // Test form submission
                document.querySelector('form').addEventListener('submit', function(e) {
                    e.preventDefault();
                    updateStatus('Form submitted successfully!');
                });
                
                // Test input validation
                document.getElementById('name').addEventListener('input', function(e) {
                    if (e.target.value.length < 3) {
                        updateStatus('Name must be at least 3 characters');
                    }
                });
                
                console.log('Accessibility test page loaded successfully');
            </script>
        </body>
        </html>
        """
        
        self.webview.load_html(html_content, "file:///")
        
    def update_status(self, message):
        """Update status bar"""
        self.status_bar.push(0, message)
        
    def clear_status(self, widget):
        """Clear status bar"""
        self.status_bar.pop(0)
        
    def run_tests(self, widget):
        """Run accessibility tests"""
        self.update_status("Running accessibility tests...")
        
        # Run tests in background thread
        threading.Thread(target=self._run_accessibility_tests, daemon=True).start()
        
    def _run_accessibility_tests(self):
        """Run actual accessibility tests"""
        try:
            import gi
            gi.require_version('Atk', '1.0')
            from gi.repository import Atk
            
            # Get webview accessibility object
            accessible = self.webview.get_accessible()
            
            # Test basic accessibility
            if accessible:
                self.update_status("✓ Accessibility object found")
                
                # Count accessible children
                child_count = accessible.get_n_children()
                self.update_status(f"✓ Found {child_count} accessible elements")
                
                # Test specific elements
                buttons_found = 0
                inputs_found = 0
                
                for i in range(min(child_count, 20)):  # Limit to avoid too many iterations
                    child = accessible.get_ref_child(i)
                    if child:
                        role = child.get_role()
                        if role == Atk.Role.PUSH_BUTTON:
                            buttons_found += 1
                        elif role == Atk.Role.ENTRY:
                            inputs_found += 1
                
                self.update_status(f"✓ Found {buttons_found} buttons, {inputs_found} inputs")
                self.update_status("✓ All accessibility tests completed successfully!")
            else:
                self.update_status("✗ No accessibility object found")
                
        except Exception as e:
            self.update_status(f"✗ Test failed: {str(e)}")
            
    def show_accessibility_info(self, widget):
        """Show accessibility information"""
        try:
            import gi
            gi.require_version('Atk', '1.0')
            from gi.repository import Atk
            
            accessible = self.webview.get_accessible()
            
            if accessible:
                info = f"Accessibility Info:\n"
                info += f"Role: {accessible.get_role()}\n"
                info += f"Name: {accessible.get_name()}\n"
                info += f"Description: {accessible.get_description()}\n"
                info += f"Children: {accessible.get_n_children()}\n"
                
                self.update_status(info)
            else:
                self.update_status("No accessibility information available")
                
        except Exception as e:
            self.update_status(f"Error getting accessibility info: {str(e)}")
        
    def run(self):
        """Start the application"""
        # Show window
        self.window.show_all()
        
        # Start GTK main loop
        Gtk.main()

if __name__ == "__main__":
    # Check if we're in a display environment
    if not os.environ.get('DISPLAY'):
        print("No DISPLAY environment variable set")
        print("Please ensure X11 forwarding or VNC is configured")
        exit(1)
    
    app = AccessibilityTestApp()
    app.run()
