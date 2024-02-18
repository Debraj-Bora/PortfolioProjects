/*

Cleaning Data in SQL queries

*/

Select *
From PortfolioProjects..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------

-- Standardize Date format

Select SaleDate2, CONVERT(Date, SaleDate)
From PortfolioProjects..NashvilleHousing

Update PortfolioProjects.dbo.NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

--If it doesn't Update properly

Alter Table NashvilleHousing
Add SaleDate2 Date;

Update PortfolioProjects.dbo.NashvilleHousing
Set SaleDate2 = CONVERT(Date, SaleDate);


----------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From PortfolioProjects..NashvilleHousing
--where PropertyAddress is Null
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

----------------------------------------------------------------------------------------------------------------

--Breaking out address into Individual columns(Address, City, State)

-- Breaking the Property Address(Address, City)

Select PropertyAddress
From PortfolioProjects..NashvilleHousing
--where PropertyAddress is Null
--Order By ParcelID

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as Address
From PortfolioProjects..NashvilleHousing


Alter Table PortfolioProjects.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

Alter Table PortfolioProjects.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress));


Select *
From PortfolioProjects.dbo.NashvilleHousing


-- Breaking the owner address(Address,City,State)

Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
		PARSENAME(REPLACE(OwnerAddress,',','.'),2),
		PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProjects.dbo.NashvilleHousing


ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
From PortfolioProjects.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From PortfolioProjects.dbo.NashvilleHousing


Update PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant = 	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


------------------------------------------------------------------------------------------------------------------

-- Remove duplicates

With RowNumCTE AS(
Select *,
	   ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY
					UniqueID
	   ) row_num


From PortfolioProjects.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
where row_num >1
Order by PropertyAddress

Select *
From PortfolioProjects.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------

-- Delete unused columns

Select * 
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, TaxDistrict