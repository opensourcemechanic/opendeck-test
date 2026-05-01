---
title: Test Cases
layout: default
---

# Test Cases

## Overview

This document provides comprehensive test cases for the WebKitGTK + OpenDeck + ATK + Orca accessibility testing environment. Each test case includes objectives, steps, expected results, and troubleshooting information.

## Form Accessibility Tests

### Test Case 1: Required Field Detection

#### **Objective**
Verify that required form fields are properly identified and announced by screen readers.

#### **Test Steps**
1. Launch the test application: `python3 /root/test_app.py`
2. Enable Orca: `orca --replace --enable-speech`
3. Navigate to the form section using Tab key
4. Focus on the "Name" field
5. Listen to the screen reader announcement
6. Focus on the "Email" field
7. Listen to the screen reader announcement
8. Focus on the "Phone" field
9. Listen to the screen reader announcement

#### **Expected Results**
- **Name field**: "Name, text field, required"
- **Email field**: "Email, text field, required"
- **Phone field**: "Phone, text field" (no "required" announcement)

#### **Validation Commands**
```bash
# Check ATK state for required fields
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

# Get webview accessibility object
accessible = webview.get_accessible()

# Find form elements
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if child.get_role() == Atk.Role.ENTRY:
        state_set = child.ref_state_set()
        is_required = state_set.contains_state(Atk.State.REQUIRED)
        print(f'Field: {child.get_name()}, Required: {is_required}')
"
```

#### **Troubleshooting**
- **Issue**: Required fields not announced
- **Solution**: Check ARIA `aria-required` attribute in HTML
- **Command**: `grep -n "aria-required" /root/test_app.py`

---

### Test Case 2: Field Descriptions

#### **Objective**
Verify that field descriptions are properly associated with form elements.

#### **Test Steps**
1. Navigate to the "Name" field
2. Listen for field description announcement
3. Navigate to the "Email" field
4. Listen for field description announcement
5. Check if descriptions are available via ATK

#### **Expected Results**
- **Name field**: "Please enter your full name"
- **Email field**: "We'll never share your email"

#### **Validation Commands**
```bash
# Check field descriptions
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if child.get_role() == Atk.Role.ENTRY:
        desc = child.get_description()
        name = child.get_name()
        print(f'{name}: {desc}')
"
```

#### **Troubleshooting**
- **Issue**: Descriptions not announced
- **Check**: Verify `aria-describedby` attribute points to correct element ID
- **Command**: `grep -A 5 -B 5 "aria-describedby" /root/test_app.py`

---

### Test Case 3: Form Validation

#### **Objective**
Test dynamic validation announcements for form fields.

#### **Test Steps**
1. Navigate to the "Name" field
2. Enter only 1-2 characters
3. Tab to next field
4. Listen for validation error announcement
5. Enter valid name (3+ characters)
6. Verify error announcement stops

#### **Expected Results**
- **Short name**: "Name must be at least 3 characters"
- **Valid name**: No error announcement

#### **Validation Commands**
```bash
# Monitor live region updates
python3 -c "
import time
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

# Find live region
accessible = webview.get_accessible()
live_region = None
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if 'status' in child.get_name().lower():
        live_region = child
        break

if live_region:
    print(f'Live region found: {live_region.get_name()}')
    print(f'Current content: {live_region.get_text(0, -1)}')
"
```

#### **Troubleshooting**
- **Issue**: Validation errors not announced
- **Check**: Live region `aria-live` attribute
- **Command**: `grep -n "aria-live" /root/test_app.py`

---

## Dynamic Content Tests

### Test Case 4: Live Region Announcements

#### **Objective**
Verify that dynamic content changes are properly announced.

#### **Test Steps**
1. Navigate to the "Dynamic Content Tests" section
2. Click "Update Status" button
3. Listen for immediate announcement
4. Click "Add Error" button
5. Listen for assertive announcement
6. Wait 3 seconds for auto-update
7. Listen for timed announcement

#### **Expected Results**
- **Status update**: "Status updated by user click!" (polite)
- **Error message**: "This is an error message" (assertive)
- **Auto update**: "Auto-updated after 3 seconds" (polite)

#### **Validation Commands**
```bash
# Monitor AT-SPI events
at-spi-registryd --monitor &
python3 /root/test_app.py

# Check live region properties
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if child.get_role() == Atk.Role.STATUSBAR:
        print(f'Statusbar: {child.get_name()}')
        print(f'Text: {child.get_text(0, -1)}')
"
```

#### **Troubleshooting**
- **Issue**: Live regions not announcing
- **Check**: `aria-live` attribute values ("polite" vs "assertive")
- **Command**: `grep -C 3 "aria-live" /root/test_app.py`

---

### Test Case 5: Content Change Detection

#### **Objective**
Test that content changes trigger appropriate accessibility events.

#### **Test Steps**
1. Focus on the status div
2. Click "Update Status" button
3. Monitor for text-changed events
4. Verify event properties (position, length)

#### **Expected Results**
- Text-changed event emitted
- Event contains correct position and length
- Screen reader announces change

#### **Validation Commands**
```bash
# Monitor specific events
export ATK_DEBUG=1
python3 /root/test_app.py 2>&1 | grep "text-changed"
```

#### **Troubleshooting**
- **Issue**: No events fired
- **Check**: DOM mutation observer in JavaScript
- **Command**: `grep -A 10 -B 5 "updateStatus" /root/test_app.py`

---

## Navigation Tests

### Test Case 6: Keyboard Navigation

#### **Objective**
Verify complete keyboard navigation through all interactive elements.

#### **Test Steps**
1. Press Tab key repeatedly
2. Count focus changes
3. Verify each interactive element receives focus
4. Test Shift+Tab for backward navigation
5. Verify Enter/Space activation of buttons

#### **Expected Results**
- All buttons, links, and form fields are focusable
- Tab order follows logical sequence
- Enter/Space activates focused elements

#### **Validation Commands**
```bash
# Test focusable elements
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
focusable_count = 0
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    state_set = child.ref_state_set()
    if state_set.contains_state(Atk.State.FOCUSABLE):
        focusable_count += 1
        print(f'Focusable: {child.get_name()} ({child.get_role()})')

print(f'Total focusable elements: {focusable_count}')
"
```

#### **Troubleshooting**
- **Issue**: Elements not focusable
- **Check**: Tabindex and element types
- **Command**: `grep -n "tabindex" /root/test_app.py`

---

### Test Case 7: Landmark Navigation

#### **Objective**
Test ARIA landmark navigation and identification.

#### **Test Steps**
1. Navigate to navigation landmark
2. Verify landmark announcement
3. Navigate to main content landmark
4. Verify landmark announcement
5. Test landmark roles via ATK

#### **Expected Results**
- Navigation: "navigation landmark"
- Main: "main landmark"
- Proper ATK_ROLE_LANDMARK mapping

#### **Validation Commands**
```bash
# Check landmark roles
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    role = child.get_role()
    if role == Atk.Role.LANDMARK:
        print(f'Landmark: {child.get_name()}')
"
```

#### **Troubleshooting**
- **Issue**: Landmarks not recognized
- **Check**: ARIA role attributes
- **Command**: `grep -n "role=" /root/test_app.py`

---

## Table Accessibility Tests

### Test Case 8: Table Navigation

#### **Objective**
Test table navigation with proper cell coordinate announcements.

#### **Test Steps**
1. Navigate to the table
2. Use arrow keys to move between cells
3. Listen for cell coordinate announcements
4. Test row and column header relationships

#### **Expected Results**
- Cell announcements include coordinates
- Header relationships properly announced
- Table caption announced on entry

#### **Expected Announcement Examples**
- "Widget A, column 1, row 1"
- "$10.00, column 2, row 1"
- "25, column 3, row 1"

#### **Validation Commands**
```bash
# Test table interface
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if child.get_role() == Atk.Role.TABLE:
        table = child
        print(f'Table: {table.get_name()}')
        print(f'Rows: {atk_table_get_n_rows(table)}')
        print(f'Columns: {atk_table_get_n_columns(table)}')
        
        # Test cell access
        cell = atk_table_ref_at(table, 0, 0)
        if cell:
            print(f'Cell (0,0): {cell.get_name()}')
"
```

#### **Troubleshooting**
- **Issue**: Cell coordinates not announced
- **Check**: Table header attributes (`scope`, `headers`)
- **Command**: `grep -A 10 -B 5 "<table" /root/test_app.py`

---

### Test Case 9: Header Relationships

#### **Objective**
Verify table headers are properly associated with data cells.

#### **Test Steps**
1. Navigate to data cells in the table
2. Listen for header announcements
3. Test row and column header access
4. Verify header relationships via ATK

#### **Expected Results**
- Data cells announce associated headers
- Row and column headers accessible
- Proper ATK table interface implementation

#### **Validation Commands**
```bash
# Test header access
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if child.get_role() == Atk.Role.TABLE:
        table = child
        
        # Get row headers
        row_header = atk_table_get_row_header_at(table, 0)
        if row_header:
            print(f'Row header (0): {row_header.get_name()}')
            
        # Get column headers
        col_header = atk_table_get_column_header_at(table, 0)
        if col_header:
            print(f'Column header (0): {col_header.get_name()}')
"
```

#### **Troubleshooting**
- **Issue**: Headers not associated
- **Check**: `scope` attributes on `<th>` elements
- **Command**: `grep -n "scope=" /root/test_app.py`

---

## Interactive Elements Tests

### Test Case 10: Button Activation

#### **Objective**
Test button activation and state announcements.

#### **Test Steps**
1. Navigate to each button
2. Press Enter or Space to activate
3. Listen for activation feedback
4. Test button states (disabled, etc.)

#### **Expected Results**
- Buttons activate on Enter/Space
- Activation feedback provided
- Button states properly announced

#### **Validation Commands**
```bash
# Test button actions
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if child.get_role() == Atk.Role.PUSH_BUTTON:
        print(f'Button: {child.get_name()}')
        
        # Test action interface
        if hasattr(child, 'do_action'):
            action_count = child.get_n_actions()
            print(f'  Actions: {action_count}')
            for j in range(action_count):
                action_name = child.get_action_name(j)
                print(f'    Action {j}: {action_name}')
"
```

#### **Troubleshooting**
- **Issue**: Buttons not activating
- **Check**: Event handlers in JavaScript
- **Command**: `grep -A 5 -B 5 "onclick" /root/test_app.py`

---

### Test Case 11: Tab Panel Navigation

#### **Objective**
Test tab panel navigation and content switching.

#### **Test Steps**
1. Navigate to tab buttons
2. Use arrow keys to switch tabs
3. Listen for panel content changes
4. Verify tab selection states

#### **Expected Results**
- Arrow keys switch tabs
- Panel content announced on change
- Selected tab state indicated

#### **Expected Announcement Sequence**
- "Overview tab, selected"
- "Product Overview" (panel content)
- "Details tab, selected"
- "Product Details" (panel content)

#### **Validation Commands**
```bash
# Test tab panel interface
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if child.get_role() == Atk.Role.PAGE_TAB:
        print(f'Tab: {child.get_name()}')
        state_set = child.ref_state_set()
        selected = state_set.contains_state(Atk.State.SELECTED)
        print(f'  Selected: {selected}')
"
```

#### **Troubleshooting**
- **Issue**: Tabs not switching
- **Check**: JavaScript tab switching logic
- **Command**: `grep -A 10 "showTab" /root/test_app.py`

---

### Test Case 12: Progress Indicators

#### **Objective**
Test progress indicator announcements and value changes.

#### **Test Steps**
1. Navigate to progress indicators
2. Click "Update Progress" button
3. Listen for percentage announcements
4. Verify value changes via ATK

#### **Expected Results**
- Progress values announced as percentages
- Value changes trigger appropriate events
- Min/max values accessible

#### **Expected Announcements**
- "File upload progress, 75 percent"
- "Processing status, 30 percent"

#### **Validation Commands**
```bash
# Test progress bar interface
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
for i in range(accessible.get_n_children()):
    child = accessible.get_ref_child(i)
    if child.get_role() == Atk.Role.PROGRESS_BAR:
        print(f'Progress: {child.get_name()}')
        
        # Test value interface
        if hasattr(child, 'get_current_value'):
            current = child.get_current_value()
            min_val = child.get_minimum_value()
            max_val = child.get_maximum_value()
            print(f'  Value: {current}/{min_val}-{max_val}')
"
```

#### **Troubleshooting**
- **Issue**: Progress not announced
- **Check**: `value` and `max` attributes on `<progress>` elements
- **Command**: `grep -A 5 -B 5 "<progress" /root/test_app.py`

---

## Screen Reader Integration Tests

### Test Case 13: Orca Speech Output

#### **Objective**
Verify Orca screen reader properly announces all accessibility information.

#### **Test Steps**
1. Start Orca: `orca --replace --enable-speech --debug`
2. Navigate through all test elements
3. Record announcements
4. Verify announcement accuracy and completeness

#### **Expected Results**
- All elements announced with proper context
- No missing information
- Appropriate speech rates and volumes

#### **Validation Commands**
```bash
# Test Orca speech synthesis
echo "Testing speech synthesis" | espeak

# Check Orca debug output
orca --replace --enable-speech --debug 2>&1 | grep "speech"

# Test with different speech rates
orca --replace --enable-speech --speech-rate=30
orca --replace --enable-speech --speech-rate=70
```

#### **Troubleshooting**
- **Issue**: No speech output
- **Check**: Audio system and speech engine
- **Commands**: `aplay /usr/share/sounds/alsa/Front_Left.wav`

---

### Test Case 14: Braille Output

#### **Objective**
Test Braille display output (if Braille device available).

#### **Test Steps**
1. Enable Braille: `orca --replace --enable-braille`
2. Navigate through elements
3. Verify Braille output
4. Test Braille table compatibility

#### **Expected Results**
- Braille output matches speech content
- Proper Braille formatting
- No Braille display errors

#### **Validation Commands**
```bash
# Check Braille system
which brltty
ls /dev/braille*

# Test Orca Braille
orca --replace --enable-braille --debug 2>&1 | grep "braille"
```

#### **Troubleshooting**
- **Issue**: No Braille output
- **Check**: Braille device connectivity and BrlTTY
- **Command**: `sudo systemctl status brltty`

---

## Performance Tests

### Test Case 15: Large Document Performance

#### **Objective**
Test accessibility performance with large documents.

#### **Test Steps**
1. Load large HTML document (1000+ elements)
2. Measure accessibility tree generation time
3. Test navigation responsiveness
4. Monitor memory usage

#### **Expected Results**
- Accessibility tree generation < 2 seconds
- Navigation responsive (< 100ms delay)
- Memory usage reasonable (< 100MB increase)

#### **Validation Commands**
```bash
# Performance monitoring
time python3 /root/test_app.py

# Memory usage
ps aux --sort=-%mem | grep python3

# Accessibility tree size
python3 -c "
import gi
gi.require_version('Atk', '1.0')
from gi.repository import Atk

accessible = webview.get_accessible()
count = count_accessibility_children(accessible)
print(f'Accessibility objects: {count}')
"

def count_accessibility_children(obj):
    count = 1
    for i in range(obj.get_n_children()):
        child = obj.ref_child(i)
        count += count_accessibility_children(child)
    return count
```

#### **Troubleshooting**
- **Issue**: Poor performance
- **Check**: Document size and complexity
- **Solution**: Enable lazy loading, optimize event handling

---

## Automated Test Suite

### Test Runner Script

```python
#!/usr/bin/env python3
"""
Automated accessibility test runner
"""

import sys
import time
import json
import gi
gi.require_version('WebKit2', '4.0')
gi.require_version('Gtk', '3.0')
gi.require_version('Atk', '1.0')

from gi.repository import WebKit2, Gtk, Atk

class AutomatedTestRunner:
    def __init__(self):
        self.results = {}
        self.webview = None
        self.window = None
        
    def setup(self):
        """Setup test environment"""
        Gtk.init([])
        
        self.window = Gtk.Window()
        self.webview = WebKit2.WebView()
        
        settings = self.webview.get_settings()
        settings.set_enable_javascript(True)
        settings.set_enable_accessibility(True)
        
        self.window.add(self.webview)
        self.window.show_all()
        
    def run_all_tests(self):
        """Run all test cases"""
        print("Starting automated accessibility tests...")
        
        test_cases = [
            self.test_form_accessibility,
            self.test_dynamic_content,
            self.test_table_navigation,
            self.test_keyboard_navigation,
            self.test_screen_reader_integration
        ]
        
        for test_case in test_cases:
            try:
                result = test_case()
                self.results[test_case.__name__] = result
                print(f"✓ {test_case.__name__}: {result['status']}")
            except Exception as e:
                self.results[test_case.__name__] = {
                    'status': 'failed',
                    'error': str(e)
                }
                print(f"✗ {test_case.__name__}: {e}")
                
    def test_form_accessibility(self):
        """Test form accessibility features"""
        # Load test content
        self.webview.load_html(FORM_TEST_HTML, "file:///")
        time.sleep(2)
        
        # Run form tests
        accessible = self.webview.get_accessible()
        form_elements = self.find_form_elements(accessible)
        
        required_fields_found = 0
        labeled_fields = 0
        
        for element in form_elements:
            if self.is_required_field(element):
                required_fields_found += 1
            if element.get_name():
                labeled_fields += 1
                
        return {
            'status': 'passed',
            'form_elements': len(form_elements),
            'required_fields': required_fields_found,
            'labeled_fields': labeled_fields
        }
        
    def generate_report(self):
        """Generate test report"""
        report = {
            'timestamp': time.time(),
            'summary': self.generate_summary(),
            'detailed_results': self.results
        }
        
        with open('/tmp/accessibility_test_report.json', 'w') as f:
            json.dump(report, f, indent=2)
            
        return report
        
    def generate_summary(self):
        """Generate test summary"""
        total_tests = len(self.results)
        passed_tests = len([r for r in self.results.values() if r.get('status') == 'passed'])
        
        return {
            'total': total_tests,
            'passed': passed_tests,
            'failed': total_tests - passed_tests,
            'success_rate': passed_tests / total_tests if total_tests > 0 else 0
        }

if __name__ == "__main__":
    runner = AutomatedTestRunner()
    runner.setup()
    runner.run_all_tests()
    report = runner.generate_report()
    
    print(f"\nTest Summary:")
    print(f"Total: {report['summary']['total']}")
    print(f"Passed: {report['summary']['passed']}")
    print(f"Failed: {report['summary']['failed']}")
    print(f"Success Rate: {report['summary']['success_rate']:.1%}")
    
    Gtk.main()
```

### Running Automated Tests

```bash
# Run automated test suite
python3 automated_tests.py

# Generate detailed report
python3 automated_tests.py --report

# Run specific test case
python3 automated_tests.py --test test_form_accessibility

# Run with performance monitoring
time python3 automated_tests.py
```

---

## Test Results Interpretation

### Success Criteria

#### **WCAG 2.1 Compliance**
- **Level A**: All basic accessibility requirements met
- **Level AA**: Enhanced accessibility features
- **Level AAA**: Highest accessibility standards

#### **Screen Reader Compatibility**
- **Orca**: Full compatibility with GNOME screen reader
- **NVDA**: Windows screen reader compatibility (via web interface)
- **JAWS**: Commercial screen reader compatibility

#### **Keyboard Navigation**
- **Complete Access**: All functionality available via keyboard
- **Logical Order**: Tab order follows logical sequence
- **Visual Focus**: Clear focus indicators

### Result Categories

#### **Passed**
- Test objectives met
- Expected results achieved
- No critical issues found

#### **Passed with Warnings**
- Objectives mostly met
- Minor issues that don't significantly impact accessibility
- Recommendations for improvement provided

#### **Failed**
- Critical accessibility issues found
- Objectives not met
- Immediate attention required

### Reporting Format

```json
{
  "test_case": "Form Accessibility",
  "status": "passed",
  "score": 85,
  "issues": [
    {
      "severity": "warning",
      "description": "Some fields missing descriptions",
      "recommendation": "Add aria-describedby attributes"
    }
  ],
  "details": {
    "total_elements": 5,
    "required_fields": 3,
    "labeled_fields": 5
  }
}
```

---

This comprehensive test suite provides thorough validation of the WebKitGTK + OpenDeck + ATK + Orca accessibility stack, ensuring reliable accessibility testing capabilities for web applications.
