---
title: API Reference
layout: default
---

# API Reference

## WebKitGTK APIs

### WebKitWebView

#### Core Methods
```c
// Create web view
WebKitWebView *webkit_web_view_new(void);
WebKitWebView *webkit_web_view_new_with_settings(WebKitSettings *settings);

// Load content
void webkit_web_view_load_uri(WebKitWebView *webview, const gchar *uri);
void webkit_web_view_load_html(WebKitWebView *webview, const gchar *content, const gchar *base_uri);

// Get accessibility object
AtkObject *webkit_web_view_get_accessible(WebKitWebView *webview);
```

#### Accessibility Configuration
```c
// Enable accessibility
WebKitSettings *settings = webkit_web_view_get_settings(webview);
webkit_settings_set_enable_accessibility(settings, TRUE);
webkit_settings_set_enable_javascript(settings, TRUE);
webkit_settings_set_enable_plugins(settings, FALSE);

// Debug accessibility
webkit_settings_set_enable_developer_extras(settings, TRUE);
```

#### Event Handling
```c
// Connect signals
g_signal_connect(webview, "load-changed", G_CALLBACK(on_load_changed), NULL);
g_signal_connect(webview, "resource-load-started", G_CALLBACK(on_resource_load), NULL);

// Focus handling
g_signal_connect(webview, "focus-in", G_CALLBACK(on_focus_in), NULL);
g_signal_connect(webview, "focus-out", G_CALLBACK(on_focus_out), NULL);
```

### WebKitSettings

#### Accessibility Settings
```c
// Enable accessibility features
void webkit_settings_set_enable_accessibility(WebKitSettings *settings, gboolean enabled);
gboolean webkit_settings_get_enable_accessibility(WebKitSettings *settings);

// JavaScript settings
void webkit_settings_set_enable_javascript(WebKitSettings *settings, gboolean enabled);
void webkit_settings_set_enable_javascript_mark_as_safe(WebKitSettings *settings, gboolean enabled);

// Media settings
void webkit_settings_set_enable_media(WebKitSettings *settings, gboolean enabled);
void webkit_settings_set_enable_media_stream(WebKitSettings *settings, gboolean enabled);
```

#### Debug Settings
```c
// Developer extras
void webkit_settings_set_enable_developer_extras(WebKitSettings *settings, gboolean enabled);
gboolean webkit_settings_get_enable_developer_extras(WebKitSettings *settings);

// Debugging
void webkit_settings_set_enable_javascript_markup(WebKitSettings *settings, gboolean enabled);
void webkit_settings_set_enable_page_cache(WebKitSettings *settings, gboolean enabled);
```

## ATK APIs

### AtkObject

#### Base Object Methods
```c
// Object properties
const gchar *atk_object_get_name(AtkObject *accessible);
const gchar *atk_object_get_description(AtkObject *accessible);
AtkRole atk_object_get_role(AtkObject *accessible);

// Object hierarchy
gint atk_object_get_n_children(AtkObject *accessible);
AtkObject *atk_object_ref_child(AtkObject *accessible, gint i);
AtkObject *atk_object_get_parent(AtkObject *accessible);

// Object state
AtkStateSet *atk_object_ref_state_set(AtkObject *accessible);
gboolean atk_object_state_contains(AtkObject *accessible, AtkStateType state);
```

#### Role Constants
```c
// Common roles
ATK_ROLE_PUSH_BUTTON    // <button>
ATK_ROLE_LINK          // <a href>
ATK_ROLE_ENTRY         // <input>, <textarea>
ATK_ROLE_HEADING       // <h1>, <h2>, etc.
ATK_ROLE_TABLE         // <table>
ATK_ROLE_TABLE_ROW    // <tr>
ATK_ROLE_TABLE_CELL   // <td>, <th>
ATK_ROLE_LIST          // <ul>, <ol>
ATK_ROLE_LIST_ITEM    // <li>
ATK_ROLE_DOCUMENT_WEB  // <html>, <body>
```

#### State Constants
```c
// Common states
ATK_STATE_VISIBLE      // Element is visible
ATK_STATE_SHOWING      // Element is being shown
ATK_STATE_VISIBLE      // Element is visible
ATK_STATE_FOCUSABLE    // Element can receive focus
ATK_STATE_FOCUSED      // Element has focus
ATK_STATE_ENABLED      // Element is enabled
ATK_STATE_SENSITIVE    // Element is sensitive
ATK_STATE_REQUIRED     // Element is required
ATK_STATE_INVALID      // Element has invalid content
ATK_STATE_CHECKED      // Checkbox is checked
ATK_STATE_EXPANDED    // Element is expanded
```

### AtkAction Interface

#### Action Methods
```c
// Action information
gint atk_action_get_n_actions(AtkAction *action);
const gchar *atk_action_get_name(AtkAction *action, gint i);
const gchar *atk_action_get_description(AtkAction *action, gint i);

// Action execution
gboolean atk_action_do_action(AtkAction *action, gint i);
gboolean atk_action_set_description(AtkAction *action, gint i, const gchar *description);

// Key bindings
const gchar *atk_action_get_keybinding(AtkAction *action, gint i);
```

#### Action Implementation
```c
// Example: Button action implementation
static gboolean webkit_button_do_action(AtkAction *action, gint i) {
    WebKitAccessibleButton *button = WEBKIT_ACCESSIBLE_BUTTON(action);
    
    if (i == 0) { // Default action
        // Simulate button click
        webkit_dom_element_click(button->dom_element);
        return TRUE;
    }
    
    return FALSE;
}

static const gchar *webkit_button_get_name(AtkAction *action, gint i) {
    if (i == 0) {
        return "click";
    }
    return NULL;
}
```

### AtkText Interface

#### Text Methods
```c
// Text content
gchar *atk_text_get_text(AtkText *text, gint start_offset, gint end_offset);
gchar *atk_text_get_text_after_offset(AtkText *text, gint offset, AtkTextBoundary boundary_type, gint *start_offset, gint *end_offset);
gchar *atk_text_get_text_before_offset(AtkText *text, gint offset, AtkTextBoundary boundary_type, gint *start_offset, gint *end_offset);

// Text properties
gint atk_text_get_character_count(AtkText *text);
gint atk_text_get_caret_offset(AtkText *text);
gboolean atk_text_set_caret_offset(AtkText *text, gint offset);

// Text selection
gint atk_text_get_n_selections(AtkText *text);
gboolean atk_text_get_selection(AtkText *text, gint selection_num, gint *start_offset, gint *end_offset);
gboolean atk_text_add_selection(AtkText *text, gint start_offset, gint end_offset);
gboolean atk_text_remove_selection(AtkText *text, gint selection_num);
```

#### Text Boundaries
```c
// Boundary types
typedef enum {
    ATK_TEXT_BOUNDARY_CHAR,
    ATK_TEXT_BOUNDARY_WORD_START,
    ATK_TEXT_BOUNDARY_WORD_END,
    ATK_TEXT_BOUNDARY_SENTENCE_START,
    ATK_TEXT_BOUNDARY_SENTENCE_END,
    ATK_TEXT_BOUNDARY_LINE_START,
    ATK_TEXT_BOUNDARY_LINE_END
} AtkTextBoundary;
```

#### Text Implementation
```c
// Example: Input field text implementation
static gchar *webkit_input_get_text(AtkText *text, gint start_offset, gint end_offset) {
    WebKitAccessibleInput *input = WEBKIT_ACCESSIBLE_INPUT(text);
    
    // Get value from DOM element
    gchar *value = webkit_dom_html_input_element_get_value(input->dom_element);
    
    // Extract requested range
    gint length = strlen(value);
    if (start_offset < 0) start_offset = 0;
    if (end_offset < 0 || end_offset > length) end_offset = length;
    
    return g_strndup(value + start_offset, end_offset - start_offset);
}
```

### AtkTable Interface

#### Table Methods
```c
// Table dimensions
gint atk_table_get_n_rows(AtkTable *table);
gint atk_table_get_n_columns(AtkTable *table);
AtkObject *atk_table_ref_at(AtkTable *table, gint row, gint column);

// Table headers
AtkObject *atk_table_get_row_header_at(AtkTable *table, gint row);
AtkObject *atk_table_get_column_header_at(AtkTable *table, gint column);
gboolean atk_table_get_row_header_at(AtkTable *table, gint row);
gboolean atk_table_get_column_header_at(AtkTable *table, gint column);

// Table selection
gboolean atk_table_add_row_selection(AtkTable *table, gint row);
gboolean atk_table_add_column_selection(AtkTable *table, gint column);
gboolean atk_table_is_row_selected(AtkTable *table, gint row);
gboolean atk_table_is_column_selected(AtkTable *table, gint column);
```

#### Table Implementation
```c
// Example: HTML table implementation
static AtkObject *webkit_table_ref_at(AtkTable *table, gint row, gint column) {
    WebKitAccessibleTable *atable = WEBKIT_ACCESSIBLE_TABLE(table);
    
    // Find cell at specified position
    DOMElement *cell = webkit_dom_html_table_element_get_cell_at(atable->table_element, row, column);
    
    if (cell) {
        return get_accessible_for_dom_element(cell);
    }
    
    return NULL;
}

static gint atk_table_get_n_rows(AtkTable *table) {
    WebKitAccessibleTable *atable = WEBKIT_ACCESSIBLE_TABLE(table);
    
    DOMHTMLCollection *rows = webkit_dom_html_table_element_get_rows(atable->table_element);
    return webkit_dom_html_collection_get_length(rows);
}
```

### AtkValue Interface

#### Value Methods
```c
// Value properties
gdouble atk_value_get_current_value(AtkValue *value);
gdouble atk_value_get_minimum_value(AtkValue *value);
gdouble atk_value_get_maximum_value(AtkValue *value);
gdouble atk_value_get_minimum_increment(AtkValue *value);

// Value manipulation
gboolean atk_value_set_current_value(AtkValue *value, gdouble new_value);
```

#### Value Implementation
```c
// Example: Progress bar implementation
static gdouble atk_progress_get_current_value(AtkValue *value) {
    WebKitAccessibleProgress *progress = WEBKIT_ACCESSIBLE_PROGRESS(value);
    
    // Get value from DOM element
    return webkit_dom_html_progress_element_get_value(progress->dom_element);
}

static gdouble atk_progress_get_maximum_value(AtkValue *value) {
    WebKitAccessibleProgress *progress = WEBKIT_ACCESSIBLE_PROGRESS(value);
    
    return webkit_dom_html_progress_element_get_max(progress->dom_element);
}
```

## OpenDeck APIs

### Role Mapping

#### ARIA to ATK Mapping
```c
// Role mapping function
AtkRole opendeck_map_aria_role(const char *aria_role) {
    if (!aria_role) return ATK_ROLE_UNKNOWN;
    
    static const struct {
        const char *aria;
        AtkRole atk;
    } role_map[] = {
        // Landmark roles
        {"banner", ATK_ROLE_LANDMARK},
        {"navigation", ATK_ROLE_LANDMARK},
        {"main", ATK_ROLE_LANDMARK},
        {"complementary", ATK_ROLE_LANDMARK},
        {"contentinfo", ATK_ROLE_LANDMARK},
        {"search", ATK_ROLE_LANDMARK},
        
        // Widget roles
        {"button", ATK_ROLE_PUSH_BUTTON},
        {"link", ATK_ROLE_LINK},
        {"textbox", ATK_ROLE_ENTRY},
        {"searchbox", ATK_ROLE_ENTRY},
        {"textarea", ATK_ROLE_ENTRY},
        {"combobox", ATK_ROLE_COMBO_BOX},
        {"listbox", ATK_ROLE_LIST},
        {"option", ATK_ROLE_LIST_ITEM},
        {"radio", ATK_ROLE_RADIO_BUTTON},
        {"checkbox", ATK_ROLE_CHECK_BOX},
        {"slider", ATK_ROLE_SLIDER},
        {"spinbutton", ATK_ROLE_SPIN_BUTTON},
        
        // Structure roles
        {"heading", ATK_ROLE_HEADING},
        {"list", ATK_ROLE_LIST},
        {"listitem", ATK_ROLE_LIST_ITEM},
        {"table", ATK_ROLE_TABLE},
        {"row", ATK_ROLE_TABLE_ROW},
        {"cell", ATK_ROLE_TABLE_CELL},
        {"columnheader", ATK_ROLE_TABLE_COLUMN_HEADER},
        {"rowheader", ATK_ROLE_TABLE_ROW_HEADER},
        
        // Document roles
        {"document", ATK_ROLE_DOCUMENT_WEB},
        {"article", ATK_ROLE_DOCUMENT_WEB},
        {"region", ATK_ROLE_PANE},
        {"group", ATK_ROLE_PANEL},
        {"note", ATK_ROLE_SECTION},
        {"tooltip", ATK_ROLE_TOOL_TIP},
        {"dialog", ATK_ROLE_DIALOG},
        {"alert", ATK_ROLE_ALERT},
        {"status", ATK_ROLE_STATUSBAR}
    };
    
    for (int i = 0; i < G_N_ELEMENTS(role_map); i++) {
        if (strcmp(aria_role, role_map[i].aria) == 0) {
            return role_map[i].atk;
        }
    }
    
    return ATK_ROLE_UNKNOWN;
}
```

#### Property Mapping
```c
// Map ARIA properties to ATK properties
void opendeck_map_properties(DOMElement *element, AtkObject *atk_obj) {
    // Map aria-label
    const char *label = get_attribute(element, "aria-label");
    if (label) {
        atk_object_set_name(atk_obj, label);
    }
    
    // Map aria-describedby
    const char *describedby = get_attribute(element, "aria-describedby");
    if (describedby) {
        DOMElement *desc_element = get_element_by_id(describedby);
        if (desc_element) {
            gchar *desc_text = get_element_text_content(desc_element);
            atk_object_set_description(atk_obj, desc_text);
            g_free(desc_text);
        }
    }
    
    // Map aria-required
    const char *required = get_attribute(element, "aria-required");
    if (required && strcmp(required, "true") == 0) {
        atk_object_add_state(atk_obj, ATK_STATE_REQUIRED);
    }
    
    // Map aria-disabled
    const char *disabled = get_attribute(element, "aria-disabled");
    if (disabled && strcmp(disabled, "true") == 0) {
        atk_object_add_state(atk_obj, ATK_STATE_DISABLED);
    }
}
```

### Event Handling

#### Event Types
```c
// Event type enumeration
typedef enum {
    OPENDECK_EVENT_FOCUS,
    OPENDECK_EVENT_BLUR,
    OPENDECK_EVENT_CHANGE,
    OPENDECK_EVENT_SELECT,
    OPENDECK_EVENT_ACTIVATE,
    OPENDECK_EVENT_TEXT_CHANGED,
    OPENDECK_EVENT_VALUE_CHANGED,
    OPENDECK_EVENT_STATE_CHANGED
} OpenDeckEventType;
```

#### Event Processing
```c
// Process DOM event
void opendeck_process_dom_event(DOMEvent *dom_event) {
    OpenDeckEvent *event = g_new0(OpenDeckEvent, 1);
    
    // Determine event type
    event->type = classify_dom_event(dom_event);
    event->target = get_atk_object_for_element(dom_event->target);
    event->data = extract_event_data(dom_event);
    
    // Forward to ATK
    forward_to_atk(event);
    
    g_free(event);
}

// Forward event to ATK
void forward_to_atk(OpenDeckEvent *event) {
    switch (event->type) {
        case OPENDECK_EVENT_FOCUS:
            g_signal_emit_by_name(event->target, "focus-event", TRUE);
            break;
            
        case OPENDECK_EVENT_BLUR:
            g_signal_emit_by_name(event->target, "focus-event", FALSE);
            break;
            
        case OPENDECK_EVENT_CHANGE:
            if (has_text_interface(event->target)) {
                g_signal_emit_by_name(event->target, "text-changed");
            }
            break;
            
        case OPENDECK_EVENT_ACTIVATE:
            if (has_action_interface(event->target)) {
                atk_action_do_action(ATK_ACTION(event->target), 0);
            }
            break;
    }
}
```

## Orca APIs

### Script System

#### Script Base Class
```python
class Script:
    def __init__(self, app):
        self.app = app
        self.name = "WebKitGTK Script"
        
    def get_name(self):
        return self.name
        
    def get_app_name(self):
        return self.app.name
        
    def get_app_version(self):
        return self.app.version
```

#### Event Handlers
```python
def on_focus_changed(self, event):
    """Handle focus events"""
    obj = event.source
    role = obj.get_role()
    
    if role == Atk.Role.LINK:
        text = "Link: %s" % obj.get_name()
    elif role == Atk.Role.ENTRY:
        text = "Text field: %s" % obj.get_name()
    elif role == Atk.Role.PUSH_BUTTON:
        text = "Button: %s" % obj.get_name()
    else:
        text = obj.get_name() or "Element"
    
    speech.speak(text)

def on_text_changed(self, event):
    """Handle text changes"""
    obj = event.source
    if obj.get_role() == Atk.Role.ENTRY:
        text = obj.get_text(0, -1)
        if text:
            speech.speak(text)

def on_state_changed(self, event):
    """Handle state changes"""
    obj = event.source
    if event.type == "checked":
        if event.enabled:
            speech.speak("Checked")
        else:
            speech.speak("Not checked")
    elif event.type == "expanded":
        if event.enabled:
            speech.speak("Expanded")
        else:
            speech.speak("Collapsed")
```

#### Speech Output
```python
import speech

def speak_text(text, priority=1):
    """Speak text with specified priority"""
    try:
        speech.speak(text, priority)
    except Exception as e:
        debug.println("Speech error: %s" % e)

def speak_character(char):
    """Speak individual character"""
    if char.isalnum():
        speech.speak(char.upper())
    elif char == ' ':
        speech.speak("space")
    elif char == '\n':
        speech.speak("new line")
    else:
        speech.speak("character %s" % char)
```

### Configuration

#### Orca Settings
```python
# Default settings
DEFAULT_SETTINGS = {
    'speechRate': 50,
    'speechPitch': 50,
    'speechVolume': 1.0,
    'verbosityLevel': 'verbose',
    'enableSpeech': True,
    'enableBraille': False,
    'enableMagnification': False,
    'keyEchoMode': 'words'
}

def load_settings():
    """Load Orca settings"""
    settings = DEFAULT_SETTINGS.copy()
    
    # Load from file if exists
    settings_file = os.path.expanduser('~/.local/share/orca/orca-settings.py')
    if os.path.exists(settings_file):
        exec(open(settings_file).read())
        settings.update(locals())
    
    return settings

def save_settings(settings):
    """Save Orca settings"""
    settings_file = os.path.expanduser('~/.local/share/orca/orca-settings.py')
    with open(settings_file, 'w') as f:
        f.write("# Orca settings\n")
        for key, value in settings.items():
            f.write("%s = %r\n" % (key, value))
```

## Python GTK APIs

### WebKit2 Python Bindings

#### WebView Creation
```python
import gi
gi.require_version('WebKit2', '4.0')
gi.require_version('Gtk', '3.0')

from gi.repository import WebKit2, Gtk

class AccessibilityTestApp:
    def __init__(self):
        self.window = Gtk.Window()
        self.webview = WebKit2.WebView()
        
        # Configure settings
        settings = self.webview.get_settings()
        settings.set_enable_javascript(True)
        settings.set_enable_accessibility(True)
        settings.set_enable_developer_extras(True)
        
        # Connect signals
        self.webview.connect('load-changed', self.on_load_changed)
        self.webview.connect('focus-in-event', self.on_focus_in)
        self.webview.connect('focus-out-event', self.on_focus_out)
```

#### Content Loading
```python
def load_test_content(self):
    """Load test HTML content"""
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Accessibility Test</title>
    </head>
    <body>
        <button aria-label="Test button">Click me</button>
        <input type="text" aria-required="true" placeholder="Enter text">
    </body>
    </html>
    """
    
    self.webview.load_html(html_content, "file:///")

def on_load_changed(self, webview, load_event):
    """Handle load events"""
    if load_event == WebKit2.LoadEvent.FINISHED:
        # Page loaded, run accessibility tests
        self.run_accessibility_tests()
```

### ATK Python Bindings

#### Accessibility Object Access
```python
import gi
gi.require_version('Atk', '1.0')

from gi.repository import Atk

def get_accessibility_info(self):
    """Get accessibility information for webview"""
    accessible = self.webview.get_accessible()
    
    info = {
        'role': accessible.get_role(),
        'name': accessible.get_name(),
        'description': accessible.get_description(),
        'children_count': accessible.get_n_children()
    }
    
    # Get child information
    children = []
    for i in range(accessible.get_n_children()):
        child = accessible.get_ref_child(i)
        child_info = {
            'role': child.get_role(),
            'name': child.get_name(),
            'description': child.get_description()
        }
        children.append(child_info)
    
    info['children'] = children
    return info
```

#### Event Monitoring
```python
def monitor_accessibility_events(self):
    """Monitor accessibility events"""
    accessible = self.webview.get_accessible()
    
    # Connect to focus events
    accessible.connect('focus-event', self.on_focus_event)
    
    # Connect to text events if available
    if hasattr(accessible, 'connect'):
        try:
            accessible.connect('text-changed', self.on_text_changed)
        except:
            pass

def on_focus_event(self, obj, focus_in):
    """Handle focus events"""
    role = obj.get_role()
    name = obj.get_name() or "Element"
    
    if focus_in:
        print(f"Focused: {role} - {name}")
    else:
        print(f"Unfocused: {role} - {name}")
```

## Testing APIs

### Test Framework

#### Test Case Structure
```python
class AccessibilityTestCase:
    def __init__(self, name, description):
        self.name = name
        self.description = description
        self.results = []
        
    def run_test(self, webview):
        """Run accessibility test"""
        raise NotImplementedError
        
    def add_result(self, passed, message, details=None):
        """Add test result"""
        result = {
            'passed': passed,
            'message': message,
            'details': details,
            'timestamp': time.time()
        }
        self.results.append(result)
        
    def get_summary(self):
        """Get test summary"""
        passed = sum(1 for r in self.results if r['passed'])
        total = len(self.results)
        return {
            'passed': passed,
            'total': total,
            'success_rate': passed / total if total > 0 else 0
        }
```

#### Specific Test Cases
```python
class FormAccessibilityTest(AccessibilityTestCase):
    def __init__(self):
        super().__init__(
            "Form Accessibility",
            "Test form field accessibility features"
        )
        
    def run_test(self, webview):
        """Run form accessibility tests"""
        accessible = webview.get_accessible()
        
        # Find form elements
        form_elements = self.find_form_elements(accessible)
        
        for element in form_elements:
            self.test_required_fields(element)
            self.test_field_labels(element)
            self.test_field_descriptions(element)
            
    def test_required_fields(self, element):
        """Test required field detection"""
        if self.is_required_field(element):
            has_required_state = element.ref_state_set().contains_state(Atk.State.REQUIRED)
            self.add_result(
                has_required_state,
                "Required field has ATK_STATE_REQUIRED",
                f"Element: {element.get_name()}"
            )
            
    def test_field_labels(self, element):
        """Test field labels"""
        name = element.get_name()
        self.add_result(
            name is not None and len(name) > 0,
            "Field has accessible name",
            f"Name: {name}"
        )
```

### Validation APIs

#### Accessibility Validator
```python
class AccessibilityValidator:
    def __init__(self):
        self.issues = []
        
    def validate_element(self, element):
        """Validate single element"""
        issues = []
        
        # Check for accessible name
        if not element.get_name():
            issues.append({
                'type': 'missing_name',
                'severity': 'error',
                'message': 'Element missing accessible name',
                'element': element
            })
            
        # Check for proper role
        if element.get_role() == Atk.Role.UNKNOWN:
            issues.append({
                'type': 'unknown_role',
                'severity': 'warning',
                'message': 'Element has unknown accessibility role',
                'element': element
            })
            
        # Check for proper states
        self.validate_states(element, issues)
        
        return issues
        
    def validate_states(self, element, issues):
        """Validate element states"""
        state_set = element.ref_state_set()
        
        # Check focusable elements
        if state_set.contains_state(Atk.State.FOCUSABLE):
            if not element.get_name():
                issues.append({
                    'type': 'focusable_no_name',
                    'severity': 'error',
                    'message': 'Focusable element missing accessible name',
                    'element': element
                })
                
    def generate_report(self):
        """Generate validation report"""
        return {
            'total_issues': len(self.issues),
            'errors': len([i for i in self.issues if i['severity'] == 'error']),
            'warnings': len([i for i in self.issues if i['severity'] == 'warning']),
            'issues': self.issues
        }
```

---

This API reference provides comprehensive documentation for all major APIs used in the WebKitGTK + OpenDeck + ATK + Orca accessibility testing environment.
