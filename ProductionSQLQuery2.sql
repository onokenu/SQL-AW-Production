SELECT 
       CONVERT(DATE,GETDATE()) 'ReportDate'
      ,PBA.BusinessEntityID 'AddressBusinessEntityID', PV.BusinessEntityID 'VendorBusinessEntityID',  PA.AddressID, SP.StateProvinceID
      ,POH.PurchaseOrderID, POH.VendorID,POH.EmployeeID, POD.PurchaseOrderDetailID, PP.ProductID, PP.ProductSubcategoryID, ShipMethodID
      ,POH.[status] 'OrderStatus', POH.SubTotal, POH.TaxAmt, POH.Freight, POH.TotalDue
      ,POD.OrderQty, POD.UnitPrice, POD.LineTotal, POD.ReceivedQty, POD.RejectedQty, POD.StockedQty
      ,PP.[Name] 'ProductName', PP.ProductNumber, PP.SafetyStockLevel
	  ,PP.ReorderPoint, CASE WHEN PP.ReorderPoint < 200 THEN 'Red' 
						     WHEN PP.ReorderPoint <300 THEN 'Yellow' 
						     ELSE 'Green' 
						     END as ReorderPoint_Bucket
	  ,PP.StandardCost, CASE WHEN PP.FinishedGoodsFlag = 0 THEN 'No' 
							 ELSE 'Yes' 
							 END as'IsProductSalable'
      ,ISNULL(PSC.[Name],'No SubCategory') 'ProductSubcategoryName'     
      ,PV.[Name] 'VendorName', PV.CreditRating
	  ,CONVERT(DATE,OrderDate) OrderDate, CONVERT(DATE,ShipDate) ShipDate
	  ,DATEDIFF(day, OrderDate, ShipDate) 'HandlingTime'
      ,PA.City, SP.[Name] 'StateProvinceName',CR.CountryRegionCode
	  ,SYSTEM_USER 'Batch_User', CURRENT_TIMESTAMP 'Batch_DateTime'
FROM [AdventureWorks2019].[Purchasing].[PurchaseOrderHeader] POH 
       INNER JOIN [Purchasing].[PurchaseOrderDetail] POD ON POD.PurchaseOrderDetailID = POH.PurchaseOrderID
       INNER JOIN [Production].[Product] PP ON PP.ProductID = POD.ProductID
       LEFT JOIN [Production].[ProductSubcategory] PSC ON PSC.ProductSubcategoryID = PP.ProductSubcategoryID
       INNER JOIN [Purchasing].[Vendor] PV ON PV.BusinessEntityID = POH.VendorID
       INNER JOIN [Person].[BusinessEntityAddress] PBA ON PBA.BusinessEntityID = POH.EmployeeID
       INNER JOIN [Person].[Address] PA ON PA.[AddressID] = PBA.[AddressID]
       INNER JOIN [Person].[StateProvince] SP ON SP.[StateProvinceID] = PA.[StateProvinceID]
       INNER JOIN [Person].[CountryRegion] CR ON CR.[CountryRegionCode] = SP.[CountryRegionCode]


