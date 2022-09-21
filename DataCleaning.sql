/*
Cleaning Data in SQL Queries 
*/
Select *
From PortfolioProject..NashvilleforDataCleaning

-- Standardize Date Format 
Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject..NashvilleforDataCleaning

Update NashvilleforDataCleaning
set SaleDateConverted = Convert(Date,SaleDate)

ALTER TABLE NashvilleforDataCleaning
Add SaleDateConverted date

-- Populate Property Adress Data 
-- Null in Property Adress 
Select *
From PortfolioProject..NashvilleforDataCleaning
--Where PropertyAddress is null 
order by ParcelID

-- We found that there is duplicate ParceID, so we join ParcelID and Property Address for the missing Data Adress 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleforDataCleaning a
join PortfolioProject..NashvilleforDataCleaning b
	On a.ParcelID = b.ParcelID
	AND  a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL 

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleforDataCleaning a
join PortfolioProject..NashvilleforDataCleaning b
	On a.ParcelID = b.ParcelID
	AND  a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL 

-- Breaking out Adress into Individual columns ( Adress, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleforDataCleaning
--Where PropertyAddress is null 
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Adress
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Adress

From PortfolioProject..NashvilleforDataCleaning

ALTER TABLE NashvilleforDataCleaning
Add PropertySplitAdress Nvarchar(255);
Update NashvilleforDataCleaning 
set PropertySplitAdress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleforDataCleaning
Add PropertySplitCity Nvarchar(255);
Update NashvilleforDataCleaning
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

Select * 
From PortfolioProject..NashvilleforDataCleaning


-- Same Thing for OwnerAdress with diffrent Queries 
Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleforDataCleaning

ALTER TABLE NashvilleforDataCleaning
Add OwnerSplitAdress Nvarchar(255);
Update NashvilleforDataCleaning 
set OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleforDataCleaning
Add OwnerSplitCity Nvarchar(255);
Update NashvilleforDataCleaning
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleforDataCleaning
Add OwnerSplitState Nvarchar(255);
Update NashvilleforDataCleaning
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject..NashvilleforDataCleaning

--Change Y and X to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleforDataCleaning
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
	From PortfolioProject..NashvilleforDataCleaning

Update NashvilleforDataCleaning
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		Else SoldAsVacant
		END 

--Remove Duplicates
WITH Row_numCTE AS ( 
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference 
				ORDER BY 
					UniqueID 
				) row_num

From PortfolioProject..NashvilleforDataCleaning
--Order by ParcelID
)
SELECT *
from Row_numCTE
Where row_num >1
ORDER BY PropertyAddress

-- Delete Unamed Columns 
Select *
From PortfolioProject..NashvilleforDataCleaning


ALTER TABLE PortfolioProject..NashvilleforDataCleaning
DROP COLUMN  OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject..NashvilleforDataCleaning
DROP COLUMN  SaleDate

