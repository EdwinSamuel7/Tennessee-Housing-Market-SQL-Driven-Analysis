# Nashville's-Housing-Market-SQL-Driven-Analysis

## Overview
Developed a data cleaning pipeline for the Nashville housing dataset using SQL to standardize and optimize data fields. This project involved filling missing property addresses based on ID matches, splitting address components into structured fields , standardizing categorical values , removing duplicate records, and dropping unused columns to streamline the data for further analysis.

## Features
- **Address Completion:** Fills missing property addresses based on parcel ID matching, ensuring all records have accurate address information.
- **Address Parsing:** Splits address fields into separate components (address, city, and state) for both property and owner addresses, enhancing data clarity.
- **Standardization of Values:** Standardizes values in the "Sold as Vacant" field by converting 'Y'/'N' entries to 'Yes'/'No' for consistency.
- **Duplicate Removal:**  Identifies and removes duplicate records based on unique combinations of parcel ID, address, sale price, sale date, and legal reference to maintain dataset integrity.
- **Unused Column Removal:** Drops unnecessary columns to streamline the dataset, making it easier to analyze and interpret.

## Tools and Technologies
- **SQL:** Used for data manipulation, including joining, updating, and transforming data in the dataset.
- **Data Transformation:** Implemented SQL commands to modify and clean the dataset, ensuring data accuracy.

## Impact
- Provides a clean and consistent dataset, ready for further analysis and visualization.
- Enhances data accuracy by filling missing values and standardizing formats.
- Reduces data redundancy by removing duplicate records.
- Facilitates advanced analysis by restructuring address fields for easier geographical and property insights.

## Getting Started
1. **Prerequisites:** Ensure you have access to a SQL environment (e.g., PostgreSQL, MySQL) and import the Nashville Housing dataset into a database.
2. **Dataset:** The Nashville Housing dataset includes details such as property address, owner address, sale information, and more.
3. **SQL File:** Use the provided SQL file containing the cleaning commands to execute each step in sequence and clean the dataset.
4. **Customization:** Modify SQL commands as needed to adapt to any variations in data structure or additional data preparation steps.

## Usage
- Run the SQL commands sequentially to clean the Nashville Housing dataset.
- Review the dataset after each stage to verify the applied changes, such as filled addresses, split fields, standardized values, and removal of duplicates.
- Utilize the clean data for further analysis or visualization in other tools.
