
-- Cleaning data in SQL

SELECT *
FROM HousingData

-- Correct SaleDate column formatting

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM HousingData

ALTER TABLE HousingData
Add SaleDateConverted Date;

UPDATE HousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address data


SELECT *
FROM HousingData
Where PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData a
JOIN HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData a
JOIN HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Seperating address into multiple columns: Address, City, State

SELECT PropertyAddress
FROM HousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM HousingData

ALTER TABLE HousingData
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255);

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM HousingData





SELECT OwnerAddress
FROM HousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
FROM HousingData

ALTER TABLE HousingData
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


-- Change Y and N to Yes and No in SoldAsVacant column

SELECT Distinct(SoldAsVacant)
From HousingData

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Remove Duplicates


WITH RowNumCTE as ( 
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From HousingData )

--DELETE
SELECT *
From RowNumCTE
Where row_num > 1


-- Delete unused columns

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE HousingData
DROP COLUMN SaleDate

SELECT *
FROM HousingData
