/*
CREATED BY: Froylan Avila
CREATE DATE: 02-06-2024
DESCRIPTION: Data Cleaning in SQL
*/
USE PortfolioProject

SELECT * FROM [PortfolioProject].[dbo].[NashvilleHousing];
---------------------------------------------------------------------------------------------

-- Standardize Date Format --

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [PortfolioProject].[dbo].[NashvilleHousing]

UPDATE [dbo].[NashvilleHousing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [dbo].[NashvilleHousing]
Add SaleDateConverted Date;

UPDATE [dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)



-----------------------------------------------------------------------------------------------

-- Populate Property Address Data --

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]
ORDER BY ParcelID
--WHERE PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] A
JOIN [PortfolioProject].[dbo].[NashvilleHousing] B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


UPDATE A
SET PropertyAddress =  ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] A
JOIN [PortfolioProject].[dbo].[NashvilleHousing] B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


---------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) --

SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing]


SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

FROM [PortfolioProject].[dbo].[NashvilleHousing]


ALTER TABLE [dbo].[NashvilleHousing]
Add PropertySplitAddress NVarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) 


ALTER TABLE [dbo].[NashvilleHousing]
Add PropertySplitCity NVarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) 

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]


/*
Using Parse Name
*/

SELECT OwnerAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing]

SELECT
 PARSENAME(REPLACE(owneraddress, ',' , '.'), 3)
,PARSENAME(REPLACE(owneraddress, ',' , '.'), 2)
,PARSENAME(REPLACE(owneraddress, ',' , '.'), 1)
FROM [PortfolioProject].[dbo].[NashvilleHousing]



ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitAddress NVarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitAddress =  PARSENAME(REPLACE(owneraddress, ',' , '.'), 3)


ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitCity NVarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',' , '.'), 2)

ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitState NVarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',' , '.'), 1)

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]



-----------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field--
--Adding a CASE Statement

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM [PortfolioProject].[dbo].[NashvilleHousing]
 GROUP BY SoldAsVacant
 ORDER BY 2;

 SELECT SoldAsVacant
 CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END 
 FROM [PortfolioProject].[dbo].[NashvilleHousing];
 

 UPDATE [dbo].[NashvilleHousing]
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END 
 FROM [PortfolioProject].[dbo].[NashvilleHousing]



 ---------------------------------------------------------------------------------------------------------


 --Removing Duplicates --
 WITH RowNumCTE AS(
 SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				)   row_num
 FROM PortfolioProject.dbo.Sheet1$
 )
 SELECT *
 FROM RowNumCTE
 WHERE row_num > 1
 ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------

--Delete Unused Columns--
SELECT * FROM PortfolioProject.dbo.Sheet1$

ALTER TABLE 
PortfolioProject.dbo.Sheet1$
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress;

ALTER TABLE 
PortfolioProject.dbo.Sheet1$
DROP COLUMN SaleDate;