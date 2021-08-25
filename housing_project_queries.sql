--Explore the data set

Select *
FROM housing_project.dbo.nashville_housing

--Standardize date format

ALTER TABLE housing_project.dbo.nashville_housing
ALTER COLUMN [SaleDate] date

SELECT SaleDate
FROM housing_project.dbo.nashville_housing

--Populate property address where initially property address is Null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_project.dbo.nashville_housing AS a
JOIN housing_project.dbo.nashville_housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_project.dbo.nashville_housing AS a
JOIN housing_project.dbo.nashville_housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Break out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM housing_project.dbo.nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM housing_project.dbo.nashville_housing

ALTER TABLE housing_project.dbo.nashville_housing
ADD property_split_address nvarchar(255)

UPDATE nashville_housing
SET property_split_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE housing_project.dbo.nashville_housing
ADD property_split_city nvarchar(255)

UPDATE nashville_housing
SET property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- adjust owner address

SELECT
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
FROM dbo.nashville_housing

ALTER TABLE housing_project.dbo.nashville_housing
ADD owner_split_address nvarchar(255)

UPDATE housing_project.dbo.nashville_housing
SET owner_split_address = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE housing_project.dbo.nashville_housing
ADD owner_split_city nvarchar(255)

UPDATE housing_project.dbo.nashville_housing
SET owner_split_city = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE housing_project.dbo.nashville_housing
ADD owner_split_state nvarchar(255)

UPDATE housing_project.dbo.nashville_housing
SET owner_split_state= PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


--change "Y" and "N" values in SoldAsVacant column for consistency

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM housing_project.dbo.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM housing_project.dbo.nashville_housing

UPDATE housing_project.dbo.nashville_housing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--remove duplicates

WITH row_num_CTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM housing_project.dbo.nashville_housing
)

SELECT *
FROM row_num_CTE
WHERE row_num > 1

--delete unused columns

SELECT *
FROM housing_project.dbo.nashville_housing

ALTER TABLE housing_project.dbo.nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict
