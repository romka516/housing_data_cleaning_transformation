-- Create table that the column names align with the csv file.

CREATE TABLE housing(
	UniqueID VARCHAR(50) PRIMARY KEY,
	ParcelID VARCHAR(50),
	LandUse VARCHAR(50),
	PropertyAddress VARCHAR(100),
	SaleDate DATE,
	SalePrice VARCHAR(100),
	LegalReference VARCHAR(50),
	SoldAsVacant VARCHAR(3),
	OwnerName VARCHAR(100),
	OwnerAddress VARCHAR(100),
	Acreage FLOAT,
	TaxDistrict VARCHAR(100),
	LandValue INT,
	BuildingValue INT,
	TotalValue INT,
	YearBuilt SMALLINT,
	Bedrooms SMALLINT,
	FullBath SMALLINT,
	HalfBath SMALLINT)

/*I did not set the "SalePrice" column as INT, I set it as VARCHAR(50) because 
some numbers are separated by commas, which caused an error during import.*/

-- Nashville Housing Data for Data Cleaning csv file has been imported into housing table successfully

-- Property Address Data

SELECT * FROM housing
WHERE propertyaddress IS NULL;

/* There are 29 rows with a null value in the property address column.
We can fill these null values by matching them with parcel IDs.*/

-- Finding the property addresses of null values by self-join method with the help of parcel id.

SELECT h1.uniqueid, h2.uniqueid,
h1.parcelid, h2.parcelid,
h1.propertyaddress, h2.propertyaddress
FROM housing AS h1
INNER JOIN housing AS h2
    ON h1.parcelid = h2.parcelid
	    AND h1.uniqueid != h2.uniqueid
WHERE h1.propertyaddress IS NULL;

/* Creating a virtual table that contains unique IDs of rows with null property addresses
and the corresponding property addresses that will replace these null values. */

CREATE VIEW not_null_address AS

SELECT h1.uniqueid, h2.propertyaddress
FROM housing AS h1
INNER JOIN housing AS h2
    ON h1.parcelid = h2.parcelid
	    AND h1.uniqueid != h2.uniqueid
WHERE h1.propertyaddress IS NULL;

-- Assigning the property addresses of null values

UPDATE housing
SET propertyaddress = not_null_address.propertyaddress
FROM not_null_address
WHERE housing.uniqueid = not_null_address.uniqueid;

-- Breaking Down the propertyaddress to address and city

SELECT propertyaddress, 
SUBSTRING(propertyaddress,1, POSITION(',' IN propertyaddress) - 1) AS address,
SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress)+1, 1000) AS city
FROM housing;

ALTER TABLE housing
ADD COLUMN address VARCHAR(100);

ALTER TABLE housing
ADD COLUMN city VARCHAR(100);

UPDATE housing
SET address = SUBSTRING(propertyaddress,1, POSITION(',' IN propertyaddress) - 1);

UPDATE housing
SET city = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress)+1, 1000);

SELECT split_part(owneraddress, ',', 3),
split_part(owneraddress, ',', 2),
split_part(owneraddress, ',', 1),
owneraddress
FROM housing;

-- The split_part function is used to split the modified string using commas as the delimiter and extract the first part.
-- It is much easier than substring function.
/* We have already separated the city and address columns with the substring function. 
Now we will create the state column using the split_part function. */

ALTER TABLE housing
ADD COLUMN state varchar(100);	

UPDATE housing
SET state = SPLIT_PART(owneraddress, ',', 3);

-- Formatting soldasvacant column

SELECT soldasvacant, 
CASE WHEN soldasvacant= 'Y' THEN 'Yes'
	WHEN soldasvacant ='N' THEN 'No'
	ELSE soldasvacant
	END
FROM housing;

UPDATE housing
SET soldasvacant = CASE WHEN soldasvacant= 'Y' THEN 'Yes'
	WHEN soldasvacant ='N' THEN 'No'
	ELSE soldasvacant
	END;

--  the values are replaced with "Yes" or "No" if they are equal to 'Y' or 'N', respectively, and remain unchanged otherwise.

-- REMOVING DUPLICATES

CREATE VIEW duplicate_info AS
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
				 	uniqueid) AS row_num
					
FROM housing
ORDER BY parcelid;

SELECT * FROM duplicate_info
WHERE row_num > 1;

CREATE OR REPLACE VIEW housing_no_duplicates AS
SELECT * FROM duplicate_info
WHERE row_num = 1;
					
-- Here, virtual table have created to keep housing data without duplicates.

-- Renaming Columns in the virtual table.

ALTER TABLE housing_no_duplicates
RENAME COLUMN address TO ownersplitaddreess;
					
ALTER TABLE housing_no_duplicates
RENAME COLUMN city TO ownersplitcity;

ALTER TABLE housing_no_duplicates
RENAME COLUMN state TO ownersplitstate;

					
					


