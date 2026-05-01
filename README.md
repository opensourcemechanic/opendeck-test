# Excel Anomaly Detector

A comprehensive Excel macro for detecting and highlighting anomalies between two spreadsheets using multiple analytical methods.

## Files Included

- `ExcelAnomalyDetector.bas` - Complete VBA macro code
- `ExcelAnomalyDetector_Guide.md` - Detailed user guide and documentation
- `README.md` - This file (overview and quick start)

## Quick Start

1. **Install the Macro**
   - Open Excel
   - Press `Alt + F11` to open VBA Editor
   - Insert > Module
   - Copy/paste code from `ExcelAnomalyDetector.bas`
   - Save as macro-enabled workbook (`.xlsm`)

2. **Run Analysis**
   - Press `Alt + F8` to open macro dialog
   - Select `DetectAnomalies` and click Run
   - Follow the prompts to select anomaly type and parameters

## Features

### Four Anomaly Detection Methods:

1. **Individual Percentage Difference** 
   - Highlights cells where change > specified percentage
   - Perfect for finding significant value changes

2. **Group Percentage Difference**
   - Groups nearby anomalies and analyzes combined impact
   - Ideal for detecting regional or clustered patterns

3. **Individual Standard Deviation**
   - Statistical outlier detection using Z-scores
   - Best for quality control and scientific data

4. **Group Standard Deviation**
   - Combines grouping with statistical analysis
   - Excellent for finding systematic issues

### Key Benefits:
- **Visual Highlighting**: Anomalous cells are color-coded
- **Comprehensive Reports**: Detailed results sheets with statistics
- **Flexible Parameters**: Customizable thresholds and grouping
- **Multiple Data Types**: Works with Excel, CSV, and other formats

## Example Usage

### Financial Analysis
```vba
' Find revenue changes > 10%
IndividualPercentageAnomalies()
' Threshold: 10
```

### Quality Control
```vba
' Find measurements > 3 standard deviations
IndividualStdDevAnomalies()
' Std Dev Multiplier: 3
```

### Pattern Detection
```vba
' Find clusters of changes in nearby cells
GroupPercentageAnomalies()
' Individual: 5%, Distance: 2, Group: 15%
```

## Color Coding
- **Light Red**: Individual percentage anomalies
- **Dark Red**: Grouped percentage anomalies  
- **Light Blue**: Individual standard deviation anomalies
- **Dark Blue**: Grouped standard deviation anomalies

## Documentation

See `ExcelAnomalyDetector_Guide.md` for:
- Detailed installation instructions
- Complete parameter explanations
- Best practices and tips
- Troubleshooting guide
- Advanced usage examples

## Requirements

- Microsoft Excel 2007 or later
- Macro security enabled
- Basic understanding of Excel ranges

## Support

For issues or questions:
1. Check the troubleshooting section in the guide
2. Verify data formatting (numeric values only)
3. Ensure both sheets have identical structure
4. Test with small datasets first

## License

This code is provided as-is for educational and commercial use.
