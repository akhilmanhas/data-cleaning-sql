-- Data Cleaning in SQl

select*
from Portfolioproject..Nashvillehousing

-- Standardize date format

select saleDate, CONVERT(Date,saleDate) 
from Portfolioproject..Nashvillehousing

update Nashvillehousing
set saleDate = CONVERT(Date,saleDate) 

alter table Nashvillehousing
add converted_sale_date date

update Nashvillehousing
set converted_sale_date= CONVERT(Date,saleDate)

select converted_sale_date
from Portfolioproject..Nashvillehousing

select *
from Portfolioproject..Nashvillehousing

--Populate Property Address data
/*
as we checked there are some entries where property address is missing but in other rows Propertyaddress is available with same parcel id.
So, we are extracting the data by joining 
*/

select*
from Portfolioproject..Nashvillehousing
where PropertyAddress is null
order by ParcelID

select a.PropertyAddress, a.ParcelID,b.PropertyAddress,b.ParcelID
from Portfolioproject..Nashvillehousing as a
join Portfolioproject..Nashvillehousing as b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--After this query, there is 35 rows with same ParcelID but PropertyAddress is not updated in a.PropertyAddress
-- Updating address 

select a.PropertyAddress, a.ParcelID,b.PropertyAddress,b.ParcelID, isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolioproject..Nashvillehousing as a
join Portfolioproject..Nashvillehousing as b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolioproject..Nashvillehousing as a
join Portfolioproject..Nashvillehousing as b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

select*
from Portfolioproject..Nashvillehousing
where PropertyAddress is null

--Breaking out address into individual column Address,City,State

select Propertyaddress
from Portfolioproject..Nashvillehousing

select Propertyaddress, SUBSTRING(Propertyaddress,1, CHARINDEX(',', Propertyaddress)-1) as address
from Portfolioproject..Nashvillehousing

select Propertyaddress, SUBSTRING(Propertyaddress,CHARINDEX(',', Propertyaddress)+1, len(Propertyaddress)+1) as address1
from Portfolioproject..Nashvillehousing 

Alter table Nashvillehousing
add newpropertyaddress nvarchar(255)

update Nashvillehousing
set newpropertyaddress= SUBSTRING(Propertyaddress,1, CHARINDEX(',', Propertyaddress)-1)

alter table Nashvillehousing
add propertyaddresscity nvarchar(255)

update Nashvillehousing
set propertyaddresscity= SUBSTRING(Propertyaddress,CHARINDEX(',', Propertyaddress)+1, len(Propertyaddress)+1)

select*
from Portfolioproject..Nashvillehousing

select OwnerAddress
from Portfolioproject..Nashvillehousing

select OwnerAddress,
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from Portfolioproject..Nashvillehousing

alter table Nashvillehousing
add newownersaddress nvarchar(255)

update Nashvillehousing
set newownersaddress= parsename(replace(OwnerAddress,',','.'),3)

alter table Nashvillehousing
add owneraddresscity nvarchar(255)

update Nashvillehousing
set owneraddresscity= parsename(replace(OwnerAddress,',','.'),2)

alter table Nashvillehousing
add owneraddressstate nvarchar(255)

update Nashvillehousing
set owneraddressstate= parsename(replace(OwnerAddress,',','.'),1)

select*
from Portfolioproject..Nashvillehousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldasVacant),count(SoldasVacant)
from Portfolioproject..Nashvillehousing
group by (SoldasVacant)

--There are four values in sold as vacant : Yes,Y,No,N. Y and N saved as a shortcut for Yes or no. 

select SoldasVacant,
case when SoldasVacant= 'Y' then 'Yes'
     when SoldasVacant= 'N' then 'No'
	 else SoldasVacant
	 end
from Portfolioproject..Nashvillehousing

update Nashvillehousing
set SoldasVacant= case when SoldasVacant= 'Y' then 'Yes'
     when SoldasVacant= 'N' then 'No'
	 else SoldasVacant
	 end

select *
from Portfolioproject..Nashvillehousing

--Deleting duplicates using CTE method witout deleting from raw data

select*,
row_number() over(
partition by PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference	
			 order by UniqueId) as row_num
from Portfolioproject..Nashvillehousing

with row_numCTE as(
select*,
row_number() over(
partition by PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference	
			 order by UniqueId) as row_num
from Portfolioproject..Nashvillehousing
)
select *
from row_numCTE
where row_num>1

with row_numCTE as(
select*,
row_number() over(
partition by PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference	
			 order by UniqueId) as row_num
from Portfolioproject..Nashvillehousing
)
delete
from row_numCTE
where row_num>1

-- removing unused columns

select*
from Portfolioproject..Nashvillehousing

alter table Nashvillehousing
drop column PropertyAddress,OwnerAddress

select*
from Portfolioproject..Nashvillehousing