/*
Cleaning data in sql queries 

*/
select *
from Project.dbo.nashvillehousing




--Standardize sale date

select saledateconverted, CONVERT(Date,SaleDate)
from Project.dbo.nashvillehousing

update nashvillehousing
set SaleDate=CONVERT(Date,SaleDate)


alter table [dbo].[nashvillehousing]
add saledateconverted Date;

update nashvillehousing
set saledateconverted= CONVERT(date, SaleDate)

--populate property adress

select *
from Project.dbo.nashvillehousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, isnull (a.PropertyAddress,b.PropertyAddress)
from Project.dbo.nashvillehousing a
join Project.dbo.nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress=isnull (a.PropertyAddress,b.PropertyAddress)
from Project.dbo.nashvillehousing a
join Project.dbo.nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--breaking out adress into individual columns(Adress, city, state)

select PropertyAddress
from Project.dbo.nashvillehousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
  
from Project.dbo.nashvillehousing


alter table [dbo].[nashvillehousing]
add propertysplitaddress nvarchar(255);

update nashvillehousing
set propertysplitaddress= SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


alter table [dbo].[nashvillehousing]
add propertysplitcity  nvarchar(255);

update nashvillehousing
set  propertysplitcity= SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select*
from Project.dbo.nashvillehousing




select OwnerAddress
from Project.dbo.nashvillehousing


select 
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from Project.dbo.nashvillehousing


alter table [dbo].[nashvillehousing]
add ownersplitaddress nvarchar(255);

update nashvillehousing
set ownersplitaddress= PARSENAME(replace(OwnerAddress,',','.'),3)

alter table [dbo].[nashvillehousing]
add ownersplitcity  nvarchar(255);

update nashvillehousing
set ownersplitcity= PARSENAME(replace(OwnerAddress,',','.'),2)

alter table [dbo].[nashvillehousing]
add ownersplitstate  nvarchar(255);

update nashvillehousing
set ownersplitstate= PARSENAME(replace(OwnerAddress,',','.'),1)

select*
from Project.dbo.nashvillehousing

--Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Project.dbo.nashvillehousing
group by SoldAsVacant
order by 2


select SoldAsVacant
,case when SoldAsVacant='Y' THEN 'Yes'
when SoldAsVacant='N'THEN 'NO'
ELSE SoldAsVacant
END 
from Project.dbo.nashvillehousing




UPDATE nashvillehousing
SET SoldAsVacant=case when SoldAsVacant='Y' THEN 'Yes'
when SoldAsVacant='N'THEN 'NO'
ELSE SoldAsVacant
END



--Remove duplicates

with RowNumCTE AS(
select*,
ROW_NUMBER()over(
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			  UniqueID
			  )row_num

from Project.dbo.nashvillehousing
--order by ParcelID
)
SELECT *
from RowNumCTE

WHERE row_num>1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS
select*
from Project.dbo.nashvillehousing


ALTER TABLE Project.dbo.nashvillehousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Project.dbo.nashvillehousing
DROP COLUMN SaleDate