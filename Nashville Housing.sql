-- Cleaning Data in SQL Queries --

SELECT	
	*
FROM
	dbo.NashvilleHousing as nh
---------------------------------------------------

-- Standardize Date Format --

SELECT	
	nh.SaleDate,
	CONVERT(Date, nh.SaleDate)
FROM
	dbo.NashvilleHousing as nh

-- Add new column SaleDateConverted --
ALTER TABLE 
	dbo.NashvilleHousing
ADD
	SaleDateConverted Date

-- Update SaleDateConverted to Date of SaleDate --
UPDATE 
	dbo.NashvilleHousing
SET
	SaleDateConverted = CONVERT(Date, SaleDate)


SELECT	
	nh.SaleDateConverted,
	CONVERT(Date, nh.SaleDate)
FROM
	dbo.NashvilleHousing as nh
---------------------------------------------------

-- Populate Property Adress data --

SELECT	
	*
FROM
	dbo.NashvilleHousing as nh
--WHERE
--	nh.PropertyAddress IS NULL
ORDER BY
	nh.ParcelID

-- Looking Adress for NULL values with ParcelID
SELECT	
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	dbo.NashvilleHousing as a
JOIN
	dbo.NashvilleHousing as b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress IS NULL

-- UPDATE PropertyAddress when is NULL --
UPDATE a
SET
	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	dbo.NashvilleHousing as a
JOIN
	dbo.NashvilleHousing as b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress IS NULL

-- Cheking NULL values -- 
SELECT	
	*
FROM
	dbo.NashvilleHousing as nh
WHERE
	nh.PropertyAddress IS NULL


-- Breaking out Address into individual columns (Address, City and State) --
SELECT	
	nh.PropertyAddress
FROM
	dbo.NashvilleHousing as nh


SELECT
	SUBSTRING(nh.PropertyAddress, 1, CHARINDEX(',', nh.PropertyAddress)-1) as Address,
	SUBSTRING(nh.PropertyAddress, CHARINDEX(',', nh.PropertyAddress)+1, LEN(nh.PropertyAddress)) as City
FROM
	dbo.NashvilleHousing as nh

-- Add new column PropertySplitAddress and Update his values --
ALTER TABLE 
	dbo.NashvilleHousing
ADD
	PropertySplitAddress Nvarchar(255)

UPDATE 
	dbo.NashvilleHousing
SET
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


-- Add new column PropertySplitCity and Update his values --
ALTER TABLE 
	dbo.NashvilleHousing
ADD
	PropertySplitCity  Nvarchar(255)

UPDATE 
	dbo.NashvilleHousing
SET
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Cheking new columns -- 
SELECT	
	*
FROM
	dbo.NashvilleHousing as nh


-- Now for OwnerAddress --
SELECT	
	nh.OwnerAddress
FROM
	dbo.NashvilleHousing as nh

SELECT	
	PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'),2),
	PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'),1)
FROM
	dbo.NashvilleHousing as nh
ORDER BY
	nh.ParcelID ASC


-- Add new column OwnerSplitAddress and Update his values --
ALTER TABLE 
	dbo.NashvilleHousing
ADD
	OwnerSplitAddress Nvarchar(255)

UPDATE 
	dbo.NashvilleHousing
SET
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


-- Add new column OwnerSplitCity and Update his values --
ALTER TABLE 
	dbo.NashvilleHousing
ADD
	OwnerSplitCity Nvarchar(255)

UPDATE 
	dbo.NashvilleHousing
SET
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

-- Add new column OwnerSplitCity and Update his values --
ALTER TABLE 
	dbo.NashvilleHousing
ADD
	OwnerSplitState Nvarchar(255)

UPDATE 
	dbo.NashvilleHousing
SET
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Cheking new columns -- 
SELECT	
	*
FROM
	dbo.NashvilleHousing as nh
ORDER BY
	nh.ParcelID ASC
---------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field -- 

SELECT	
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM
	dbo.NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	2

SELECT
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END
FROM
	dbo.NashvilleHousing
WHERE
	-- SoldAsVacant = 'Y'
	SoldAsVacant = 'N'

UPDATE 
	dbo.NashvilleHousing
SET
	SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END

SELECT	
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM
	dbo.NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	2
---------------------------------------------------

-- Remove Duplicates -- 

WITH RowNumCTE AS (
SELECT	
	*,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference
	ORDER BY
		UniqueID
		) row_num
FROM
	dbo.NashvilleHousing
)

DELETE
--SELECT 
--	*
FROM
	RowNumCTE
WHERE
	row_num >= 2
--ORDER BY
--	PropertyAddress
	

-- Checking if works

WITH RowNumCTE AS (
SELECT	
	*,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference
	ORDER BY
		UniqueID
		) row_num
FROM
	dbo.NashvilleHousing
)

SELECT 
	*
FROM
	RowNumCTE
WHERE
	row_num >= 2
ORDER BY
	PropertyAddress
---------------------------------------------------

-- Delete Unused Columns --
SELECT	
	*
FROM
	dbo.NashvilleHousing


ALTER TABLE
	dbo.NashvilleHousing
DROP COLUMN
	OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
