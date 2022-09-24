/* 

Cleaning Data in SQL Queries

*/

Select *
From PorfolioProject1..NashvilleHousing


-------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT (Date, SaleDate)
From PorfolioProject1..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)


--------------------------------------------

--Populate Property address data

Select *
From PorfolioProject1..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PorfolioProject1..NashvilleHousing a
JOIN PorfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PorfolioProject1..NashvilleHousing a
JOIN PorfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-----------------------------------

--Breaking out address into Individual Columns (Address, City, State)

Select PropertyAddress
From PorfolioProject1..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PorfolioProject1..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar (255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar (255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select *
From PorfolioProject1..NashvilleHousing



Select OwnerAddress
From PorfolioProject1..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
From PorfolioProject1..NashvilleHousing





ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar (255);

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar (255);

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)




-------------------------------------------------------------

--Change Y and N to Yes and No in "sold as Vacant field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PorfolioProject1..NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
	
From PorfolioProject1..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



-----------------------------------------------------

--Remove Duplicates

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
From PorfolioProject1..NashvilleHousing
--order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-------------------------------

--Delete Unused Columns

Select * 
From PorfolioProject1..NashvilleHousing

ALTER TABLE PorfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate