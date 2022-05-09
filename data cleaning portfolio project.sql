/*
  cleaning data in sql queries using Nashville dataset
*/
select * from NashvilleHousing

-- changing saleData format
select SaleDate, CONVERT(DATE, SaleDate) AS SaleDate
from NashvilleHousing

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

select saledateconverted from NashvilleHousing

-----------------------------------------------------------------------
--populate property address data
-- it contains some null value; we can get them the same address where they have a same parcelId.

select * from NashvilleHousing
where PropertyAddress is null

select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------

-- breaking out address into individual columns (address, city, state)
select PropertyAddress from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS A
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



---------------------------------------------------------------------------
-- CLEANING owner address

select OwnerAddress from NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------
-- CHANGE Y AND N TO YES AND NO IN 'SoldAsVacant'

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant,
case
	when SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END AS CASE_I

from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = case
	when SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END

---------------------------------
-- REMOVING DUPLICATES WITHTHE HELP OF ROWNUM


WITH RowNumCTE as (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SaleDate,
SalePrice,LegalReference
ORDER BY UniqueID
) row_num

FROM NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------
--DELETE UNUSED COLUMNS

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN  OwnerAddress, PropertyAddress,SaleDate