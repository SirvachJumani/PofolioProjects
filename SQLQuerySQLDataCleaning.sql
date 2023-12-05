/*

Cleaning Data in SQL Queries

*/

select	*
from PortfolioProject..[NashvilleHousing ]

-- Standardize Date Format

update [NashvilleHousing ]
set SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

Alter table NashvilleHousing
add SaleDateConverted Date;

Update [NashvilleHousing ]
set SaleDateConverted = Convert(date,SaleDate)

select	SaleDateConverted, Convert(date, SaleDate)
from PortfolioProject..[NashvilleHousing ] 


-- Populate Property Address data
select	*
from PortfolioProject..[NashvilleHousing ] 
--Where PropertyAddress is null


select	Nas1.ParcelID, Nas1.PropertyAddress, Nas2.ParcelID, Nas2.PropertyAddress, isnull(Nas1.PropertyAddress, Nas2.PropertyAddress)
from PortfolioProject..[NashvilleHousing ] Nas1
JOIN PortfolioProject..[NashvilleHousing ] Nas2
	on  Nas1.ParcelID = Nas2.ParcelID
	and Nas1.[UniqueID ] != Nas2.[UniqueID ]
Where Nas1.PropertyAddress is null

update Nas1
	set PropertyAddress = isnull(Nas1.PropertyAddress, Nas2.PropertyAddress)
from PortfolioProject..[NashvilleHousing ] Nas1
JOIN PortfolioProject..[NashvilleHousing ] Nas2
	on  Nas1.ParcelID = Nas2.ParcelID
	and Nas1.[UniqueID ] != Nas2.[UniqueID ]
Where Nas1.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select	PropertyAddress
from PortfolioProject..[NashvilleHousing ] 
--Where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

from PortfolioProject..[NashvilleHousing ] 


ALter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [NashvilleHousing ]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [NashvilleHousing ]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


select	PropertyAddress, PropertySplitAddress, PropertySplitCity
from PortfolioProject..[NashvilleHousing ] 



select	OwnerAddress
from PortfolioProject..[NashvilleHousing ] 

select	
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject..[NashvilleHousing ] 

ALter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [NashvilleHousing ]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [NashvilleHousing ]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [NashvilleHousing ]
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


select	*
from PortfolioProject..[NashvilleHousing ] 

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..[NashvilleHousing ] 
Group By SoldAsVacant
Order By 2

select SoldAsVacant
, Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
from PortfolioProject..[NashvilleHousing ] 


Update [NashvilleHousing ]
set SoldAsVacant = Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates

With RowNumCTE as (
select *,
	ROW_NUMBER() Over(
	Partition by 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate,
		LegalReference
		Order by 
		UniqueID
		) row_num
from PortfolioProject..[NashvilleHousing ]
--order by ParcelID
)
select *
FROM RowNumCTE
WHERE row_num > 1
--Order by PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleHousing


-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO


USE PortfolioProject 
GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 
GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

GO 


---- Using BULK INSERT

USE PortfolioProject;
GO
BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
WITH (
     FIELDTERMINATOR = ',',
     ROWTERMINATOR = '\n'
);
GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO