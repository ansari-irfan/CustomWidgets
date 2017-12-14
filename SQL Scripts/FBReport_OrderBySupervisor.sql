USE [FB]
GO

/****** Object:  StoredProcedure [dbo].[FBReport_OrderBySupervisor]    Script Date: 6/13/2017 4:06:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FBReport_OrderBySupervisor] 
       (
	   @ProjectID VARCHAR(MAX) = '',
	   @Search_Value varchar(50)='',
	   @SearchToDate varchar(50)='',
	   @SearchFromDate varchar(50)='',
	   @GroupByFldNum varchar(50)='',
	   @FieldType int =-1
	   )
AS
BEGIN

DECLARE @SQLQuery VARCHAR(MAX);
DECLARE @Query VARCHAR(MAX);

SET @SQLQuery = 'SELECT Field2 as ''Order Number'', Field3 as ''Job Number'', Field17 as ''Order Date'', Field13 as ''Order Amount'', Field7 as ''Job Address'', Field20 as ''Status''' ;
if(@FieldType=3)
SET @SQLQuery = @SQLQuery + ' from Files F Where ProjectID = '+ @ProjectID + ' AND Status = 1 AND cast(Field'+@GroupByFldNum+' as date) BETWEEN cast('''+CONVERT(varchar(10), @SearchFromDate)+''' as date) AND cast('''+CONVERT(varchar(10), @SearchToDate)+''' as date)'
else
SET @SQLQuery = @SQLQuery + ' from Files F Where ProjectID = '+ @ProjectID + ' AND Status = 1 AND Field'+@GroupByFldNum+'= '''+@Search_Value+''''
print @SQLQuery
EXEC(@SQLQuery)

END

GO


