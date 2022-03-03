/** 
Cleaning the data
**/

SELECT *
FROM PorfolioProject..NashvillHousing

---------------------------------------------------------------------------------------------------------

-- Standardizing the date formate

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PorfolioProject..NashvillHousing

ALTER TABLE NashvillHousing
ADD SaleDateConverted Date;

UPDATE NashvillHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------------------
-- Populate Property address data

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PorfolioProject..NashvillHousing a
JOIN PorfolioProject..NashvillHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PorfolioProject..NashvillHousing a
JOIN PorfolioProject..NashvillHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual column ( Address, city, state)

SELECT SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM PorfolioProject..NashvillHousing

ALTER TABLE NashvillHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvillHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvillHousing
SET PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM PorfolioProject..NashvillHousing

SELECT OwnerAddress
FROM PorfolioProject..NashvillHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PorfolioProject..NashvillHousing

ALTER TABLE NashvillHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvillHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvillHousing
ADD OwnerSplitstate NVARCHAR(255);

UPDATE NashvillHousing
SET OwnerSplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PorfolioProject..NashvillHousing

-------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in SoldAsVacant Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PorfolioProject..NashvillHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PorfolioProject..NashvillHousing

UPDATE NashvillHousing
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-----------------------------------------------------------------------------------------------------------------------------

-- Rmoving Duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				   ) rowNum 
FROM PorfolioProject..NashvillHousing
)

--DELETE
--FROM RowNumCTE
--WHERE rowNum >1

SELECT *
FROM RowNumCTE
WHERE rowNum >1
ORDER BY PropertyAddress

-------------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Icons

SELECT *
FROM PorfolioProject..NashvillHousing

ALTER TABLE PorfolioProject..NashvillHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict