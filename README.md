# Nashville Housing Data Cleaning
This project focuses on cleaning and transforming Nashville housing data using PostgreSQL. The goal is to preprocess the data and address specific data quality issues.

## Data Import
The initial step involves importing the Nashville Housing Data for Data Cleaning CSV file into a PostgreSQL table named housing. The table is created with columns that align with the structure of the CSV file. Notably, the SalePrice column is set as VARCHAR(50) to accommodate numbers separated by commas in the original data.

## Cleaning Steps
Missing Property Address Handling
The project identifies rows with null values in the propertyaddress column (29 rows). To fill these null values, a self-join method is employed by matching the rows with null values to other rows with the same parcel ID but different unique IDs. The property addresses from the matching rows are used to update the null values.

### Address Splitting
To break down the propertyaddress column into separate address and city columns, the SUBSTRING function is used. The address is extracted as a substring before the first comma, and the city is extracted as a substring after the first comma. Two new columns, address and city, are added to the housing table.

### Owner Address Splitting
The owner address in the owneraddress column is split into three parts: state, city, and address. The split_part function is utilized to split the modified string using commas as the delimiter and extract the corresponding parts. A new column named state is added to the housing table to store the state information extracted from the owner address.

### Formatting Sold as Vacant Column
The soldasvacant column values are reformatted to replace 'Y' with 'Yes' and 'N' with 'No'. The CASE statement is used to perform the conditional replacement. If the value is 'Y', it is changed to 'Yes'; if it is 'N', it is changed to 'No'. The values remain unchanged for any other value.

### Removing Duplicate Records
A virtual table named duplicate_info is created to identify and keep track of duplicate records in the housing table. The ROW_NUMBER function is used to assign a unique row number to each record within specific columns (parcelid, propertyaddress, saleprice, saledate, and legalreference). Duplicate records (rows with row_num greater than 1) are filtered out, and the resulting virtual table is renamed as housing_no_duplicates.

### Column Renaming
In the housing_no_duplicates virtual table, the column address is renamed to ownersplitaddress, city is renamed to ownersplitcity, and state is renamed to ownersplitstate. These column name changes reflect the transformed nature of the data.

## Conclusion
The code presented here demonstrates a series of steps to clean and preprocess the Nashville housing data. By addressing missing values, splitting address components, formatting columns, removing duplicates, and renaming columns, the data is made more structured and suitable for further analysis or usage.

## Acknowledgements
This project was inspired by the work of Alex the Analyst, specifically the project titled "Nashville Housing Data Cleaning". 

