
-- Task 1: Populate Propert Address data (29 rows with NULL value)
---- Join the table by itself (on ParcelID & <> UniqueID)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) --ISNULL(a,b): if a is null then b 
FROM [dbo].[Nashville Housing Data] a
JOIN [dbo].[Nashville Housing Data] b
	ON  a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

---- Update Table (Column PropertyAddress)
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[Nashville Housing Data] a
JOIN [dbo].[Nashville Housing Data] b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL
--------------------------------------------------------------------------------------------------------------------

-- Task 2: Breaking out Address into Individual Columns (Address, City, State)
---- Split Address, City from PropertyAddress
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, --CHARINDEX(a,b):a-search key, b-text to be searched
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM [dbo].[Nashville Housing Data]

---- Adding column for Address, City split from PropertyAddress
ALTER TABLE [dbo].[Nashville Housing Data]
ADD PropertySplitAddress Nvarchar(255); --DROP COLUMN if needed
UPDATE [dbo].[Nashville Housing Data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [dbo].[Nashville Housing Data]
ADD PropertySplitCity Nvarchar(255);
UPDATE [dbo].[Nashville Housing Data]
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

---- Split Address, City, and State from OwnerAddress
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) --PARSENAME(a,b):a-search key, b-text to be searched
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [dbo].[Nashville Housing Data]

---- Adding column for Address, City, and State from OwnerAddress
ALTER TABLE [dbo].[Nashville Housing Data]
ADD OwnerSplitAddress Nvarchar(255);
UPDATE [dbo].[Nashville Housing Data]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [dbo].[Nashville Housing Data]
ADD OwnerSplitCity Nvarchar(255);
UPDATE [dbo].[Nashville Housing Data]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [dbo].[Nashville Housing Data]
ADD OwnerSplitState Nvarchar(255);
UPDATE [dbo].[Nashville Housing Data]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
--------------------------------------------------------------------------------------------------------------------

-- Task 3: Change Y and N to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM [PortfolioProject].[dbo].[Nashville Housing Data]
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE [PortfolioProject].[dbo].[Nashville Housing Data]
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
--------------------------------------------------------------------------------------------------------------------

-- Task 4: Remove Duplicates
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
					) row_num
FROM [PortfolioProject].[dbo].[Nashville Housing Data]
)
SELECT * --DELETE 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
--------------------------------------------------------------------------------------------------------------------

-- Task 5: Delete Unused Columns (OwnerAddress, TaxDistrict, PropertyAddress)
SELECT *
FROM [PortfolioProject].[dbo].[Nashville Housing Data]

ALTER TABLE [PortfolioProject].[dbo].[Nashville Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT* FROM [PortfolioProject].[dbo].[Nashville Housing Data]