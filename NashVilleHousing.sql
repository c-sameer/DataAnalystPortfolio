/* clean the data in sql queries */


/* populate the address data */

select *
from public."NashvilleHousing"
where "PropertyAddress" is null

select *
from public."NashvilleHousing"
order by "ParcelID"

/* we see that the property address can be same if the parcel id is the same
so we can do a self join on the table and update it */
select A."ParcelID", A."PropertyAddress", B."ParcelID", B."PropertyAddress", COALESCE(A."PropertyAddress",B."PropertyAddress")
from "NashvilleHousing" A
join "NashvilleHousing" B
on A."ParcelID" = B."ParcelID"
and A."UniqueID" <> B."UniqueID"
where A."PropertyAddress" is null

/* update using a self join based on Parcel ID*/
with t as (
select  A."UniqueID" as NewUniqueID, COALESCE(A."PropertyAddress",B."PropertyAddress") as newaddress
from "NashvilleHousing" A
join "NashvilleHousing" B
on A."ParcelID" = B."ParcelID"
and A."UniqueID" <> B."UniqueID"
where A."PropertyAddress" is null)
update "NashvilleHousing"
set "PropertyAddress" = t.newaddress
from t
where "UniqueID" = t.NewUniqueID


/* breaking out the individual columns  Address, City, State for PropertyAddress*/
alter table public."NashvilleHousing" add "PropertySplitAddress" character varying(250)

alter table  public."NashvilleHousing" add "PropertySplitCity"  character varying(250)

with t as (
select "UniqueID" as NewUniqueID, split_part("PropertyAddress",',',1) as splitAddress
from public."NashvilleHousing"
)
update public."NashvilleHousing"
set "PropertySplitAddress" = t.splitAddress
from t
where "UniqueID" = t.NewUniqueID

with t as (
select "UniqueID" as NewUniqueID, split_part("PropertyAddress",',',2) as splitCity
from public."NashvilleHousing"
)
update public."NashvilleHousing"
set "PropertySplitCity" = t.splitCity
from t
where "UniqueID" = t.NewUniqueID


alter table public."NashvilleHousing" add "OwnerSplitAddress" character varying(250)

alter table  public."NashvilleHousing" add "OwnerSplitCity"  character varying(250)

alter table  public."NashvilleHousing" add "OwnerSplitState"  character varying(250)


with t as (
select "UniqueID" as NewUniqueID, split_part("OwnerAddress",',',1) as splitAddress
from public."NashvilleHousing"
)
update public."NashvilleHousing"
set "OwnerSplitAddress" = t.splitAddress
from t
where "UniqueID" = t.NewUniqueID

with t as (
select "UniqueID" as NewUniqueID, split_part("OwnerAddress",',',2) as splitCity
from public."NashvilleHousing"
)
update public."NashvilleHousing"
set "OwnerSplitCity" = t.splitCity
from t
where "UniqueID" = t.NewUniqueID

with t as (
select "UniqueID" as NewUniqueID, split_part("OwnerAddress",',',2) as splitState
from public."NashvilleHousing"
)
update public."NashvilleHousing"
set "OwnerSplitState" = t.splitState
from t
where "UniqueID" = t.NewUniqueID


/* now let us check the data */
select *
from public."NashvilleHousing"

/* Change the sold as vacant field as Y / N instead of Yes and No */
select "SoldAsVacant",
case 
  when "SoldAsVacant" = 'Yes' then 'Y'
  when "SoldAsVacant" = 'No' then 'N'
end
from public."NashvilleHousing"


update public."NashvilleHousing"
set "SoldAsVacant" = 
case 
  when "SoldAsVacant" = 'Yes' then 'Y'
  when "SoldAsVacant" = 'No' then 'N'
end



/* remove duplicates */

WITH t AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY "ParcelID",
				 "PropertyAddress",
				 "SalePrice",
				 "SaleDate",
				 "LegalReference"
				 ORDER BY
					"UniqueID"
					) row_num

From Public."NashvilleHousing"
)
DELETE FROM Public."NashvilleHousing"
WHERE "UniqueID" IN (SELECT "UniqueID" FROM t Where row_num > 1)

/* delete where owneraddress and acreage is null */
select count(*)
from public."NashvilleHousing"
where "OwnerAddress" is null

delete
from public."NashvilleHousing"
where "OwnerAddress" is null

/*drop unused columns*/

alter table public."NashvilleHousing" drop "OwnerAddress"

alter table public."NashvilleHousing" drop "PropertyAddress"

alter table public."NashvilleHousing"  drop "TaxDistrict"

select *
from public."NashvilleHousing"
order by "ParcelID"

