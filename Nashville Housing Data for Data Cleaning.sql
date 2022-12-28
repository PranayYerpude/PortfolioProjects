-->> Cleaning Data in SQL Queries 
Select *
From PortfolioProject.dbo.NashvilleHousing


-->> Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate); -- Not Working so we are going to use ALTER method

ALTER TABLE	NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing


-->> Populate Property Address data
Select *
FROM NashvilleHousing
--WHERE PropertyAddress is Null
order by ParcelID

Select self_join_a.ParcelID, self_join_a.PropertyAddress, self_join_b.ParcelID, self_join_b.PropertyAddress, ISNULL(self_join_a.PropertyAddress, self_join_b.PropertyAddress)
FROM NashvilleHousing self_join_a
JOIN NashvilleHousing self_join_b
	ON self_join_a.ParcelID = self_join_b.ParcelID
	AND self_join_a.[UniqueID ] <> self_join_b.[UniqueID ]
WHERE self_join_a.PropertyAddress IS NULL

UPDATE self_join_a
SET PropertyAddress = ISNULL(self_join_a.PropertyAddress, self_join_b.PropertyAddress)
FROM NashvilleHousing self_join_a
JOIN NashvilleHousing self_join_b
	ON self_join_a.ParcelID = self_join_b.ParcelID
	AND self_join_a.[UniqueID ] <> self_join_b.[UniqueID ]
WHERE self_join_a.PropertyAddress IS NULL


-->> Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
FROM NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
FROM NashvilleHousing


-->> Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-->> Remove Duplicates
WITH RowNumCTE AS(
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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

DELETE
From RowNumCTE
Where row_num > 1

Select *
From PortfolioProject.dbo.NashvilleHousing


-->> Delete Unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate