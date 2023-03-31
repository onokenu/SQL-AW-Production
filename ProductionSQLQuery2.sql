SELECT 
--Get the report date for audit purpose
       CONVERT(DATE,GETDATE()) 'ReportDate'

      ,PBA.BusinessEntityID 'AddressBusinessEntityID', PV.BusinessEntityID 'VendorBusinessEntityID',  PA.AddressID, SP.StateProvinceID
      ,POH.PurchaseOrderID, POH.VendorID,POH.EmployeeID, POD.PurchaseOrderDetailID, PP.ProductID, PP.ProductSubcategoryID, ShipMethodID
      ,POH.[status] 'OrderStatus', POH.SubTotal, POH.TaxAmt, POH.Freight, POH.TotalDue
      ,POD.OrderQty, POD.UnitPrice, POD.LineTotal, POD.ReceivedQty, POD.RejectedQty, POD.StockedQty
      ,PP.[Name] 'ProductName', PP.ProductNumber, PP.SafetyStockLevel
      
--Place reorder point is buckets for monitoring
	  ,PP.ReorderPoint, CASE WHEN PP.ReorderPoint < 200 THEN 'Red' 
						     WHEN PP.ReorderPoint <300 THEN 'Yellow' 
						     ELSE 'Green' 
						     END as ReorderPoint_Bucket
	  ,PP.StandardCost, CASE WHEN PP.FinishedGoodsFlag = 0 THEN 'No' 
							 ELSE 'Yes' 
							 END as'IsProductSalable'

--Where the product subcategory has no records, insert "No subcategory"
      ,ISNULL(PSC.[Name],'No SubCategory') 'ProductSubcategoryName'     
      ,PV.[Name] 'VendorName', PV.CreditRating

-- Convert Order date and Ship date from DateTime format to Date format
	  ,CONVERT(DATE,OrderDate) OrderDate, CONVERT(DATE,ShipDate) ShipDate

-- Get the difference between the Order date and the Ship date and insert in a new column names "HandlingTime"
	  ,DATEDIFF(day, OrderDate, ShipDate) 'HandlingTime'
      ,PA.City, SP.[Name] 'StateProvinceName',CR.CountryRegionCode

-- Insert new columns Batch_user and Batch_DateTime that shows the system Id of the employee who ran the query and also the date the query was run.
	  ,SYSTEM_USER 'Batch_User', CURRENT_TIMESTAMP 'Batch_DateTime'

-- Bring in other tables/columns that are relevant to the query/project
FROM   [Purchasing].[PurchaseOrderHeader] POH WITH (NOLOCK) 
       INNER JOIN [Purchasing].[PurchaseOrderDetail] POD WITH (NOLOCK) ON POD.PurchaseOrderDetailID = POH.PurchaseOrderID
       INNER JOIN [Production].[Product] PP WITH (NOLOCK) ON PP.ProductID = POD.ProductID
       LEFT JOIN [Production].[ProductSubcategory] PSC WITH (NOLOCK) ON PSC.ProductSubcategoryID = PP.ProductSubcategoryID
       INNER JOIN [Purchasing].[Vendor] PV WITH (NOLOCK) ON PV.BusinessEntityID = POH.VendorID
       INNER JOIN [Person].[BusinessEntityAddress] PBA WITH (NOLOCK) ON PBA.BusinessEntityID = POH.EmployeeID
       INNER JOIN [Person].[Address] PA WITH (NOLOCK) ON PA.[AddressID] = PBA.[AddressID]
       INNER JOIN [Person].[StateProvince] SP WITH (NOLOCK) ON SP.[StateProvinceID] = PA.[StateProvinceID]
       INNER JOIN [Person].[CountryRegion] CR WITH (NOLOCK) ON CR.[CountryRegionCode] = SP.[CountryRegionCode]
