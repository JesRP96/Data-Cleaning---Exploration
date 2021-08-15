USE Portfolio_Project

SELECT * FROM NashvilleHousing

--------------------------- Standarizing Sale Date ---------------------------
--- Removing extra zeros (time) after the date; i.e. converting from datetime to date

/* This should work
SELECT SaleDate, CONVERT(date,SaleDate)
FROM NashvilleHousing
Update NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)*/

ALTER TABLE NashvilleHousing --- Adding a column to the table
ADD SaleDateConverted Date;
Update NashvilleHousing ---- Adding values to the new column
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted --- Verifying the new column
FROM NashvilleHousing


--------------------------- Populate Property Address ---------------------------
--- There are NULLs in the property address, we can populate this column with the duplicate parcelID rows (Same ParcelID values have the same PropertyAddress)

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


--- Join the table with itself, then since ParcelID is duplicated we can join with it, and we need to also join it with different UniqueID to not match the 
--- same the rows. This will bring a same ParcelID but different row which will show the PropertyAddress for one and NULL for the other one

SELECT NH1.ParcelID,NH1.PropertyAddress,NH2.ParcelID,NH2.PropertyAddress, NH1.[UniqueID ], NH2.[UniqueID ], ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM NashvilleHousing NH1
JOIN NashvilleHousing NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.[UniqueID ] <>  NH2.[UniqueID ]
WHERE NH1.PropertyAddress is null

UPDATE NH1  --- Update the table (since we are using JOINS we need to use the alias)
SET PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)  --- setting the column to new values using the ISNULL() function
FROM NashvilleHousing NH1
JOIN NashvilleHousing NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.[UniqueID ] <>  NH2.[UniqueID ]
WHERE NH1.PropertyAddress is null

--------------------------- Dividing the PropertyAddress and OwnerAddress columns into individual columns ---------------------------
---- Using the delimiter to divide the column PropertyAddress

SELECT * FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing --- Adding a column to the table
ADD PropertySplitAddress nvarchar(255);
Update NashvilleHousing ---- Adding values to the new column
SET PropertySplitAddress = TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1))

ALTER TABLE NashvilleHousing --- Adding a column to the table
ADD PropertySplitCity nvarchar(255);
Update NashvilleHousing ---- Adding values to the new column
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)))

---- Dividing OwnerAddress using ParseName
SELECT OwnerAddress
FROM NashvilleHousing

SELECT
TRIM(PARSENAME(REPLACE(OwnerAddress,',','.'),3)),  ---- Using ParseName to divide the volumn using the dot delimiter
TRIM(PARSENAME(REPLACE(OwnerAddress,',','.'),2)),
TRIM(PARSENAME(REPLACE(OwnerAddress,',','.'),1))
FROM NashvilleHousing

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = TRIM(PARSENAME(REPLACE(OwnerAddress,',','.'),3)), 
	OwnerSplitCity = TRIM(PARSENAME(REPLACE(OwnerAddress,',','.'),2)), 
	OwnerSplitState = TRIM(PARSENAME(REPLACE(OwnerAddress,',','.'),1))

SELECT * FROM NashvilleHousing

--------------------------- Change Y and N to Yes and No in "SoldAsVacant" field ---------------------------
---- Using the CASE statement

SELECT SoldAsVacant, COUNT(SoldAsVacant) 
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--------------------------- Remove Duplicates ---------------------------

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID) row_num
FROM NashvilleHousing
)--ORDER BY ParcelID

SELECT * FROM RowNumCTE WHERE row_num > 1

--------------------------- Delete unused columns ---------------------------
---- Not done for raw data in real world work

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

