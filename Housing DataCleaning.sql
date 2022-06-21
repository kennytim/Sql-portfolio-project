--Data cleaning using sql

select * 
from dbo.house_sheet

--- walkthrough for cleaning the housing dataset

--- Standardize the date format

select saledateconverted ,convert(date,saledate)
from dbo.house_sheet

update  dbo.house_sheet
set saledate = convert(date,saledate);

alter table dbo.house_sheet
add saledateconverted date;

update  dbo.house_sheet
set saledateconverted = convert(date,saledate);

----------------------------------------------------------------------------------------------------------------------------------

--- Populate the propertyaddress

select a.parcelid ,a.propertyaddress, b.parcelid ,b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from dbo.house_sheet as a 
join dbo.house_sheet as b
 on a.parcelid = b.parcelid
 and a.uniqueid <> b.uniqueid
 where a.propertyaddress is null

 update a 
 set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
 from dbo.house_sheet as a 
join dbo.house_sheet as b
 on a.parcelid = b.parcelid
 and a.uniqueid <> b.uniqueid
 where a.propertyaddress is null;
 ----------------------------------------------------------------------------------------------------------------
-- Breaking/splitting out the property address into individual columns
select 
SUBSTRING(propertyaddress, 1,charindex(',',propertyaddress)-1)as address,
SUBSTRING(propertyaddress, charindex(',',propertyaddress)+1,len(propertyaddress)) as city
from dbo.house_sheet

alter table dbo.house_sheet
add propertySplitAddress varchar(255)

update dbo.house_sheet
set propertySplitAddress = SUBSTRING(propertyaddress, 1,charindex(',',propertyaddress)-1);


alter table dbo.house_sheet
add propertySplitTown varchar(255)

update dbo.house_sheet
set propertySplitTown = SUBSTRING(propertyaddress, charindex(',',propertyaddress)+1,len(propertyaddress)) 





--Breaking the owner address into individual columns using a different method

select *
from dbo.house_sheet;

select 
parsename(replace(owneraddress,',','.'),3)as address,
parsename(replace(owneraddress,',','.'),2) as town,
parsename(replace(owneraddress,',','.'),1) as state
from dbo.house_sheet;

Alter table dbo.house_sheet  
add owner_address varchar(255)

update dbo.house_sheet 
set owner_address = parsename(replace(owneraddress,',','.'),3)

Alter table dbo.house_sheet 
add owners_town varchar(255)

update dbo.house_sheet   
set owners_town = parsename(replace(owneraddress,',','.'),2)

Alter table dbo.house_sheet  
add owners_state varchar(255)

update dbo.house_sheet  
set owners_state  = parsename(replace(owneraddress,',','.'),1)

-----------------------------------------------------------------------------------------------------------
---Changing Y and N to yes or no in sold as vacant
select soldasvacant, count(soldasvacant) as No
from dbo.house_sheet
group by SoldAsVacant
order by 2;

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end 
	 from dbo.house_sheet;

	update dbo.house_sheet
	set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end 

	 -----------------------------------------------------------------------------------------------------------------------------------------------
	 --removing duplicates, note that its not advisable to delete data
	 with rownumcte as (
	 select *,
	 row_number() over( partition by parcelid ,propertyaddress,saleprice,saledate,legalreference order by uniqueid) as row_num
	 from dbo.house_sheet
	 --order by parcelid
	 )
	 delete
	 from rownumcte
	 where row_num >1;
	 --order by PropertyAddress;

	 -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	 --Deleting  unused columns 
	 

	 alter table dbo.house_sheet
	 drop column owneraddress,taxdistrict,saledate,fullbath,halfbath


	 select * from dbo.house_sheet

	 ----------------------------------------------------------------------------------------------------------------------------------------------------
	 --Bringing back the split addresses back together
	 select propertysplitaddress,propertysplittown,
	 CONCAT(propertysplitaddress,' ',propertysplittown) as propertyAddress
	 from dbo.house_sheet;

	 --thanks




