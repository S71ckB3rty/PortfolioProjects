/*

Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.['Nashville Housing Data$']

---------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, Saledate)
From PortfolioProject.dbo.['Nashville Housing Data$']

Update PortfolioProject.dbo.['Nashville Housing Data$']
SET Saledate = CONVERT(Date, Saledate)

ALTER TABLE PortfolioProject.dbo.['Nashville Housing Data$']
Add SaleDateConverted Date

Update PortfolioProject.dbo.['Nashville Housing Data$']
SET SaledateConverted = CONVERT(Date, Saledate)

-- Populate Property Address data

Select *
From PortfolioProject.dbo.['Nashville Housing Data$']
--WHERE PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.['Nashville Housing Data$'] a
JOIN PortfolioProject.dbo.['Nashville Housing Data$'] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET Propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.['Nashville Housing Data$'] a
JOIN PortfolioProject.dbo.['Nashville Housing Data$'] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Replacing Null Property Address values

Update a
SET Propertyaddress = ISNULL(a.PropertyAddress,'No Address')
From PortfolioProject.dbo.['Nashville Housing Data$'] a
JOIN PortfolioProject.dbo.['Nashville Housing Data$'] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Rectifying small descrepency with address labelling for one entry. It is the only entry that has an 
-- address listed under Address but not under PropertyAddress

Update a
SET PropertyAddress = '704  CRESCENT RD', OwnerName = 'Not Registered', PropertyCity = 'NASHVILLE'
From PortfolioProject.dbo.['Nashville Housing Data$'] a
Where a.UniqueID = 43848

-- Replacing remaining null values that didnt fall within the previous update

Update a
SET PropertyAddress = 'Not Registered', PropertyCity = 'Not Registered'
From PortfolioProject.dbo.['Nashville Housing Data$'] a
Where PropertyAddress is null

-------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.['Nashville Housing Data$']
)

-- order by ParcelID

DELETE
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.['Nashville Housing Data$']

ALTER TABLE PortfolioProject.dbo.['Nashville Housing Data$']
DROP COLUMN SaleDate

