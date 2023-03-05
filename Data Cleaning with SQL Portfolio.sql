select *
from PortfolioProject..NashvilleHousing
order by ParcelID

-- STANDARDIZE SaleDate DATE FORMAT

select saledate -- it is currently in datetime format hence it displays in data and time. 
from PortfolioProject..NashvilleHousing

select saledate, convert(date, SaleDate) as dateconvert -- converting it to only date format
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing -- ading a new column to reflect the newly converted dates
add Saledate2 date;

update NashvilleHousing  -- updating the table to reflect the new date format
set Saledate2 = convert(date, SaleDate)


select Saledate2  
from PortfolioProject..NashvilleHousing

--POPULATE PROPERTY ADDRESS DATA

select *  
from PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL -- looking up to see where the column has null values to decide what measures to take


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..nashvillehousing a JOIN PortfolioProject..nashvillehousing b
ON
a.ParcelID = b.ParcelID -- here we did a 'self JOIN' (because we have only one table) to be able to see the columns that have null values on PropertyAddress where the ParceID was thesame. This is to help us assign appropriate PropertyAddress where it id null. 
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --using the ISNULL function to replace null value with values from 'b.PropertyAddress'
FROM PortfolioProject..nashvillehousing a JOIN PortfolioProject..nashvillehousing b
ON
a.ParcelID = b.ParcelID  
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) -- Updating the table to effect the changes 
FROM PortfolioProject..nashvillehousing a 
JOIN PortfolioProject..nashvillehousing b
ON
a.ParcelID = b.ParcelID  
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) -- character index (CHARINDEX) is used here to specify the position of the substring
from PortfolioProject..NashvilleHousing

select 
substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address -- remocing the comma sign, we have to go back one step behind','
from PortfolioProject..NashvilleHousing

select  -- caving the last part of the initial column into a new column using the substring, charindex and len functions
substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, SUBSTRING (propertyaddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress)) as Address
from PortfolioProject..NashvilleHousing

--adding the newly splited columns to the main table using the alter and update table functions 

alter table nashvillehousing
add Propertysplitaddress nvarchar (255);

update NashvilleHousing
set Propertysplitaddress = substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table nashvillehousing
add PropertySplitCity nvarchar (255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING (propertyaddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress))

-- Spliting the column "OwnerAddress" using the Parsename function instead of the substring function as used above 

select OwnerAddress
from NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) -- note that PARSENAME looks for periods (.) not commas as in the case of the substring seen previously and it starts splitting from behind.
from NashvilleHousing

					--applying same format into getting the three new columns 
select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from NashvilleHousing

					-- Altering and updating the table to include the new columns in the main table

alter table Portfolioproject..nashvilleHousing 
add OwnerSplitAddress nvarchar(255)

update  Portfolioproject..nashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

alter table Portfolioproject..nashvilleHousing 
add OwnerSplitCity nvarchar(255)

update  Portfolioproject..nashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


alter table Portfolioproject..nashvilleHousing 
add OwnerSplitState nvarchar(255)

update  Portfolioproject..nashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

select *
from NashvilleHousing

-- CHANGE 'Y' AND 'N' TO 'YES' AND 'N0' IN 'Sold as Vacant' COLUMN 

select distinct SoldAsVacant, count (SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by  2 desc

SELECT SoldAsVacant,
case
	when SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END as SoldAsVacant2
from NashvilleHousing

update NashvilleHousing -- updating the table to reflect the changes in the column
set 
SoldAsVacant = case
	when SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

	select  distinct SoldAsVacant, count(*) -- checking to verify if changes had been effected
	from NashvilleHousing
	group by SoldAsVacant


	--REMOVING DUPLICATES

	WITH RowNumCTE AS (
	select *,
	ROW_NUMBER() OVER (partition by ParcelID, PropertyAddress, Saleprice, saledate, legalreference --using CTE to identify the duplicates and ROW_NUMBER() to number the rows
	order by uniqueid) row_num	

	from NashvilleHousing
	) 
	select *
	from RowNumCTE
	where row_num > 1
	order by propertyaddress 

			-- deleting the identified duplicates using the delete function

	WITH RowNumCTE AS (
	select *,
	ROW_NUMBER() OVER (partition by ParcelID, PropertyAddress, Saleprice, saledate, legalreference --using CTE to identify the duplicates and ROW_NUMBER() to number the rows
	order by uniqueid) row_num	

	from NashvilleHousing
	) 
	--select *
	--from RowNumCTE
	--where row_num > 1
	--order by propertyaddress 
	
	delete 
	from RowNumCTE
	where row_num > 1

--Delete unused columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress
