--Cleaning data in SQL


SELECT *
FROM NashvilleHousing nh 
WHERE PropertyAddress = ''


--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing nh 


UPDATE NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address Data 

SELECT *
FROM NashvilleHousing nh 
--WHERE PropertyAddress is NULL 
ORDER BY ParcelID 


SELECT nh.ParcelID, nh.PropertyAddress, nh2.ParcelID , nh2.PropertyAddress
FROM NashvilleHousing nh 
JOIN NashvilleHousing nh2 
	ON nh.ParcelID = nh2.ParcelID 
	AND nh.[UniqueID ]  <> nh2.[UniqueID ] 
WHERE nh.PropertyAddress = ''

UPDATE nh
SET PropertyAddress = nh2.PropertyAddress 
FROM NashvilleHousing nh 
JOIN NashvilleHousing nh2 
	ON nh.ParcelID = nh2.ParcelID 
	AND nh.[UniqueID ]  <> nh2.[UniqueID ] 
WHERE nh.PropertyAddress = ''

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM NashvilleHousing nh 
--WHERE PropertyAddress is NULL 
--ORDER BY ParcelID 

SELECT  
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing nh 


ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




SELECT OwnerAddress 
FROM NashvilleHousing nh 

UPDATE NashvilleHousing 
SET OwnerAddress = 'NULL' WHERE OwnerAddress = ''

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM NashvilleHousing nh 


ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) 
FROM NashvilleHousing nh
group by SoldAsVacant 
ORDER BY 2


SELECT SoldAsVacant
, CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing nh

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--Remove Duplicates

		
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 	UniqueID
				 	) row_num
			
	
FROM NashvilleHousing nh
--Order by ParcelID		
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress
		
		
--Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate







		
		
		