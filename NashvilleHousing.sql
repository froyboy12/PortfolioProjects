/*
CREATED BY: Froylan Avila
CREATE DATE: 02-05-2024
DESCRIPTION: Data Cleaning in SQL
*/
USE PortfolioProject
SELECT *
FROM [PortfolioProject].[dbo].[Sheet1$];

---------------------------------------------------------------------------------------------

-- Standardize Date Format --

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [PortfolioProject].[dbo].[Sheet1$]

UPDATE [dbo].[Sheet1$]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [dbo].[Sheet1$]
Add SaleDateConverted Date;

UPDATE [dbo].[Sheet1$]
SET SaleDateConverted = CONVERT(Date,SaleDate)



-----------------------------------------------------------------------------------------------

-- Populate Property Address Data --

SELECT *
FROM [PortfolioProject].[dbo].[Sheet1$]
ORDER BY ParcelID
--WHERE PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [PortfolioProject].[dbo].[Sheet1$] A
JOIN [PortfolioProject].[dbo].[Sheet1$] B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


UPDATE A
SET PropertyAddress =  ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [PortfolioProject].[dbo].[Sheet1$] A
JOIN [PortfolioProject].[dbo].[Sheet1$] B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


---------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) --

SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[Sheet1$]


SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

FROM [PortfolioProject].[dbo].[Sheet1$]



ALTER TABLE [dbo].[Sheet1$]
Add PropertySplitAddress NVarchar(255);

UPDATE [dbo].[Sheet1$]
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) 


ALTER TABLE [dbo].[Sheet1$]
Add PropertySplitCity NVarchar(255);

UPDATE [dbo].[Sheet1$]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) 

SELECT *
FROM [PortfolioProject].[dbo].[Sheet1$]


/*
Using Parse Name
*/

SELECT OwnerAddress
FROM PortfolioProject.dbo.Sheet1$

SELECT
 PARSENAME(REPLACE(owneraddress, ',' , '.'), 3)
,PARSENAME(REPLACE(owneraddress, ',' , '.'), 2)
,PARSENAME(REPLACE(owneraddress, ',' , '.'), 1)
FROM PortfolioProject.dbo.Sheet1$;



ALTER TABLE [dbo].[Sheet1$]
Add OwnerSplitAddress NVarchar(255);

UPDATE [dbo].[Sheet1$]
SET OwnerSplitAddress =  PARSENAME(REPLACE(owneraddress, ',' , '.'), 3)


ALTER TABLE [dbo].[Sheet1$]
Add OwnerSplitCity NVarchar(255);

UPDATE [dbo].[Sheet1$]
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',' , '.'), 2)

ALTER TABLE [dbo].[Sheet1$]
Add OwnerSplitState NVarchar(255);

UPDATE [dbo].[Sheet1$]
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',' , '.'), 1)

SELECT *
FROM PortfolioProject.dbo.Sheet1$;




-----------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field--
--Adding a CASE Statement

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM PortfolioProject.dbo.Sheet1$
 GROUP BY SoldAsVacant
 ORDER BY 2;

 SELECT SoldAsVacant
 CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END 
 FROM [PortfolioProject].[dbo].[Sheet1$];
 

 UPDATE Sheet1$
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END 
 FROM PortfolioProject.dbo.Sheet1$;



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