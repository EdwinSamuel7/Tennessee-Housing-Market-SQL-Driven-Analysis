---------------- FILLING PROPERTY ADDRESS WHEREVER MISSING ---------------------------------

-- Fill the Property Address column based on the idea that same parcel ids always have the same property address 


-- Select the properties where address is null and also return the address to be filled there using COALESCE

SELECT a.uniqueid, a.parcelid, a.propertyaddress, b.uniqueid, b.parcelid, b.propertyaddress,
        COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
    ON a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL
ORDER BY a.parcelid;


-- Create a common table expression (CTE) to store the all addresses which has also filled the missing address

WITH miss_address(a_uniqueid, a_parcelid, a_propertyaddress, b_uniqueid, b_parcelid, b_propertyaddress, filled_address) AS
(
    SELECT a.uniqueid, a.parcelid, a.propertyaddress, b.uniqueid, b.parcelid, b.propertyaddress,
           COALESCE(a.propertyaddress, b.propertyaddress)
    FROM nashville_housing a
    JOIN nashville_housing b
        ON a.parcelid = b.parcelid
        AND a.uniqueid <> b.uniqueid
    -- WHERE a.propertyaddress IS NULL --or b.propertyaddress is null
    -- ORDER BY a.parcelid;
)


-- Update the nashville_housing table with the filled addresses from the CTE

UPDATE nashville_housing
SET propertyaddress = miss_address.filled_address
FROM miss_address
WHERE nashville_housing.uniqueid = miss_address.a_uniqueid;



---------------------- BREAKING DIFFERENT COMPONENTS OF ADDRESS -------------------------


---------- First for propertyaddress , we split the address & city ----------



-- Find the position of the comma in the propertyaddress

SELECT POSITION(',' IN propertyaddress)
FROM nashville_housing;


-- Extract the substring up to the comma for the address part

SELECT substring(propertyaddress, 1, POSITION(',' IN propertyaddress))
FROM nashville_housing;


-- Exclude comma from the above

SELECT substring(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1)
FROM nashville_housing;


-- Extract the substring after the comma for the city part

SELECT substring(propertyaddress, POSITION(',' IN propertyaddress) + 1, length(propertyaddress))
FROM nashville_housing;


-- Add new columns for the split address and city

ALTER TABLE nashville_housing
ADD COLUMN propertysplitaddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN propertysplitcity VARCHAR(255);


-- Update the new columns with the split address and city

UPDATE nashville_housing
SET propertysplitaddress = substring(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1);

UPDATE nashville_housing
SET propertysplitcity = substring(propertyaddress, POSITION(',' IN propertyaddress) + 1, length(propertyaddress));


-- [charindex() ----> position() ]




----------------  Then for owneraddress where we split address, city, and state ----------


-- Extract the address, city, and state parts using split_part

SELECT split_part(owneraddress, ',', 1)
FROM nashville_housing;

SELECT split_part(owneraddress, ',', 2)
FROM nashville_housing;

SELECT split_part(owneraddress, ',', 3)
FROM nashville_housing;


-- Add new columns for the split owner address, city, and state

ALTER TABLE nashville_housing
ADD COLUMN ownersplitaddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN ownersplitcity VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN ownersplitstate VARCHAR(255);


-- Update the new columns with the split address, city, and state

UPDATE nashville_housing
SET ownersplitaddress = split_part(owneraddress, ',', 1);

UPDATE nashville_housing
SET ownersplitcity = split_part(owneraddress, ',', 2);

UPDATE nashville_housing
SET ownersplitstate = split_part(owneraddress, ',', 3);


-- [parsename() ---> splitpart() ]



----------------------- CHANGE Y and N to Yes and No in "Sold as Vacant" field -----------------------


-- Distinct values of the soldasvacant column

SELECT DISTINCT(soldasvacant)
FROM nashville_housing;


-- Count Occurrence of each unique value in the soldasvacant column

SELECT soldasvacant, COUNT(*)
FROM nashville_housing
GROUP BY soldasvacant;


-- Standardize the values in soldasvacant column to Yes and No & Checking if they are standardized

SELECT sav_updated, COUNT(*)
FROM
(
    SELECT
        CASE soldasvacant
            WHEN 'Yes' THEN 'Yes'
            WHEN 'No' THEN 'No'
            WHEN 'Y' THEN 'Yes'
            WHEN 'N' THEN 'No'
        END AS sav_updated
    FROM nashville_housing
)
GROUP BY sav_updated;


-- Update the nashville_housing table with standardized values of Yes & No

UPDATE nashville_housing
SET soldasvacant = CASE soldasvacant
    WHEN 'Yes' THEN 'Yes'
    WHEN 'No' THEN 'No'
    WHEN 'Y' THEN 'Yes'
    WHEN 'N' THEN 'No'
END;



---------------------- REMOVING DUPLICATES  ------------------------


-- Although generally we don’t delete duplicate rows through SQL.



-- If in 2 rows , if all the columns convey the same information (except uniqueid ofcourse)
-- then , it means they are just duplicates and so we try to remove them



-- Row number partitioned by relevant columns to identify duplicates

SELECT *, 
       ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY parcelid) AS row_num
FROM nashville_housing;


-- Select records that are duplicates based on the row number after partitioning

SELECT *
FROM
(
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY parcelid) AS row_num
    FROM nashville_housing
)
WHERE row_num > 1;


-- Select only unique IDs of duplicate records from above , later used for deleting based on them

SELECT uniqueid
FROM
(
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY parcelid) AS row_num
    FROM nashville_housing
)
WHERE row_num > 1;


-- Delete duplicate records of the above unique IDs , which are just duplicate rows

DELETE FROM nashville_housing
WHERE uniqueid IN (
    SELECT uniqueid
    FROM
    (
        SELECT *, 
               ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY parcelid) AS row_num
        FROM nashville_housing
    )
    WHERE row_num > 1
);


-- Check to see if any duplicates remain

SELECT *
FROM
(
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY parcelid) AS row_num
    FROM nashville_housing
)
WHERE row_num > 1;



-- Instead of the subquery method like above , if we try to do with CTE , problem is we cant delete
-- CTEs are primarily used for SELECT, UPDATE, and INSERT operations, but direct deletion from a CTE is not allowed.]



----------------------- DELETE UNUSED COLUMNS ------------------------


-- Although we generally don’t delete unused columns in the original table itself.
-- We may delete unused columns in our views.


-- Drop unused columns

ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;

-- Select all remaining columns to verify changes
SELECT * FROM nashville_housing;



-- Drop column command should be specified individually for each column
