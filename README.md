# Tennessee-Housing-Market-SQL-Driven-Analysis

## 📌Project Overview
Data Cleaning for the Tennessee housing dataset using SQL to standardize and optimize data fields. This project involved filling missing property addresses based on ID matches, splitting address components into structured fields , standardizing categorical values , removing duplicate records, and dropping unused columns to streamline the data for further analysis.

The code uses SQL joins, CTEs, string functions, window functions, and conditional updates.

## Features
- **Address Completion:** Fills missing property addresses based on parcel ID matching, ensuring all records have accurate address information.
- **Address Parsing:** Splits address fields into separate components (address, city, and state) for both property and owner addresses, enhancing data clarity.
- **Standardization of Values:** Standardizes values in the "Sold as Vacant" field by converting 'Y'/'N' entries to 'Yes'/'No' for consistency.
- **Duplicate Removal:**  Identifies and removes duplicate records based on unique combinations of parcel ID, address, sale price, sale date, and legal reference to maintain dataset integrity.
- **Unused Column Removal:** Drops unnecessary columns to streamline the dataset, making it easier to analyze and interpret.

## 🔍 Data Cleaning Steps

#### 1. Filling Missing Property Addresses
Parcels have a unique parcelid and should share the same propertyaddress.
We join the table to itself to fill missing addresses.

```sql
SELECT a.uniqueid, a.parcelid, a.propertyaddress, 
       b.uniqueid, b.parcelid, b.propertyaddress,
       COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
    ON a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL
ORDER BY a.parcelid;
```

#### Update using CTE:
```sql
WITH miss_address (
    a_uniqueid, a_parcelid, a_propertyaddress,
    b_uniqueid, b_parcelid, b_propertyaddress,
    filled_address
) AS (
    SELECT a.uniqueid, a.parcelid, a.propertyaddress,
           b.uniqueid, b.parcelid, b.propertyaddress,
           COALESCE(a.propertyaddress, b.propertyaddress)
    FROM nashville_housing a
    JOIN nashville_housing b
        ON a.parcelid = b.parcelid
        AND a.uniqueid <> b.uniqueid
)
UPDATE nashville_housing
SET propertyaddress = miss_address.filled_address
FROM miss_address
WHERE nashville_housing.uniqueid = miss_address.a_uniqueid;
```

#### 2. Splitting Property Address into Address & City
```sql
-- Add new columns
ALTER TABLE nashville_housing
ADD COLUMN propertysplitaddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN propertysplitcity VARCHAR(255);

-- Fill split columns
UPDATE nashville_housing
SET propertysplitaddress = substring(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1);

UPDATE nashville_housing
SET propertysplitcity = substring(propertyaddress, POSITION(',' IN propertyaddress) + 1, length(propertyaddress));
```

#### 3. Splitting Owner Address into Address, City, State
Using split_part():
```sql
-- Add new columns
ALTER TABLE nashville_housing
ADD COLUMN ownersplitaddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN ownersplitcity VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN ownersplitstate VARCHAR(255);

-- Fill new columns
UPDATE nashville_housing
SET ownersplitaddress = split_part(owneraddress, ',', 1);

UPDATE nashville_housing
SET ownersplitcity = split_part(owneraddress, ',', 2);

UPDATE nashville_housing
SET ownersplitstate = split_part(owneraddress, ',', 3);
```

## Impact
- Provides a clean and consistent dataset, ready for further analysis and visualization.
- Enhances data accuracy by filling missing values and standardizing formats.
- Reduces data redundancy by removing duplicate records.
- Facilitates advanced analysis by restructuring address fields for easier geographical and property insights.

<!--
## Getting Started
1. **Prerequisites:** Ensure you have access to a SQL environment (e.g., PostgreSQL, MySQL) and import the Nashville Housing dataset into a database.
2. **Dataset:** The Nashville Housing dataset includes details such as property address, owner address, sale information, and more.
3. **SQL File:** Use the provided SQL file containing the cleaning commands to execute each step in sequence and clean the dataset.
4. **Customization:** Modify SQL commands as needed to adapt to any variations in data structure or additional data preparation steps.

## Usage
- Run the SQL commands sequentially to clean the Nashville Housing dataset.
- Review the dataset after each stage to verify the applied changes, such as filled addresses, split fields, standardized values, and removal of duplicates.
- Utilize the clean data for further analysis or visualization in other tools.
-->
