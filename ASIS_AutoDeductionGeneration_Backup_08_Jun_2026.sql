 
/****** Object:  StoredProcedure [dbo].[ASIS_AutoDeductionGeneration]    Script Date: 6/8/2026 5:58:00 PM ******/
DROP PROCEDURE [dbo].[ASIS_AutoDeductionGeneration]
GO

/****** Object:  StoredProcedure [dbo].[ASIS_AutoDeductionGeneration]    Script Date: 6/8/2026 5:58:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		U.Harish
-- Create date: 2017-09-26 
-- Description:	Autogeneration of Deduction Generation on 5th date of every month
-- =============================================


CREATE PROCEDURE [dbo].[ASIS_AutoDeductionGeneration]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @error nvarchar(max)
    -- Insert statements for procedure here
	Begin try
					declare @year int,@month int,@serviceID int,@groupID int,@HospitalId int,@CompanyId int,@fmsmonthlyServiceFee decimal(12,2) 
					,@femsmonthlyServiceFee decimal(12,2) ,@bemsmonthlyServiceFee decimal(12,2) ,@clsmonthlyServiceFee decimal(12,2) 
					,@llsmonthlyServiceFee decimal(12,2) ,@hwmsmonthlyServiceFeea  decimal(12,2) 
					 ,@hwmsmonthlyServiceFeeb  decimal(12,2)
					  ,@hwmsmonthlyServiceFeec  decimal(12,2),@id int
					declare @dedgendate int
					declare @execqry nvarchar(max)
					set @year=datepart(yyyy,getdate())
					set @month=datepart(mm,getdate())
					declare @DedGenerationType int
					set @DedGenerationType=null

				
									
					declare curdedgen cursor for 
					select  CompanyId,HospitalId,datediff(dd,dbo.FmsNthworkingDay(HospitalId,
					convert(
					date,
					'1/'+cast(@month as varchar(5))+'/'+cast(@year as varchar(5))
					,105)
					--,5),getdate()) from GMHospitalMst where IsDeleted=0 and Status=413
					,5),GETDATE()) from GMHospitalMst where IsDeleted=0 and Status=413 --and HospitalId  in(2)

					--set @month=@month-1
							if(@month = 1)
						begin
							set @year = @year - 1
							set @month = 12
						end
					 else if (@month > 1)
						begin
							set @month=@month-1
						end

					open curdedgen
					fetch next from curdedgen into @companyid,@hospitalid,@dedgendate

					while @@FETCH_STATUS=0
					begin 

								--CREATE TABLE #dedgenfetch (IndicatorDetId INT,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameterDetId int,SubParameter NVARCHAR(500),
								--TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),TotalParameters decimal(12,2),DeductionValue decimal(12,2),
								--DeductionPer decimal(12,2),subparametervalue decimal(12,2),keyIndicatorValue decimal(12,2),Ringittequivalent decimal(12,2),GearingRatio decimal(12,2),Weightage decimal(6,2))
								CREATE TABLE #dedfmsgenparam	(indicatorname varchar(100),parameter varchar(500),parametervalue int)
								CREATE TABLE #dedfemsgenparam	(indicatorname varchar(100),parameter varchar(500),parametervalue int,BreakUpId varchar(500))
								CREATE TABLE #dedbemsgenparam	(indicatorname varchar(100),parameter varchar(500),parametervalue int)
								CREATE TABLE #dedclsgenparam	(indicatorname varchar(100),parameter varchar(500),parametervalue int)
								CREATE TABLE #dedllsgenparam	(indicatorname varchar(100),parameter varchar(500),parametervalue int)
								CREATE TABLE #dedhwms1genparam	(indicatorname varchar(100),parameter varchar(500),parametervalue int)
								CREATE TABLE #dedhwms2genparam	(indicatorname varchar(100),parameter varchar(500),parametervalue int)
								CREATE TABLE #dedhwms3genparam	(indicatorname varchar(100),parameter varchar(500),parametervalue int)

								CREATE TABLE #dedgenfetch (IndicatorDetId INT,SubParameterDetId int,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),
								TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),Weightage decimal(6,2),TotalParameters decimal(12,2),DeductionValue decimal(12,2),
								DeductionPer decimal(12,2),GearingRatio decimal(24,4),Ringittequivalent decimal(24,4),keyIndicatorValue decimal(24,4))

								CREATE TABLE #dedgenFems (IndicatorDetId INT,SubParameterDetId int,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),
								TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),Weightage decimal(6,2),TotalParameters decimal(12,2),DeductionValue decimal(12,2),DeductionPer decimal(12,2),GearingRatio decimal(24,4),Ringittequivalent decimal(24,4),
								keyIndicatorValue decimal(24,4)	)

								CREATE TABLE #dedgenlls (IndicatorDetId INT,SubParameterDetId int,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),
								TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),Weightage decimal(6,2),TotalParameters decimal(12,2),DeductionValue decimal(12,2),DeductionPer decimal(12,2),GearingRatio decimal(24,4),Ringittequivalent decimal(24,4),
								keyIndicatorValue decimal(24,4)	)

								CREATE TABLE #dedgen (IndicatorDetId INT,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),SubParameterDetId int,
								TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),Weightage decimal(6,2),GearingRatio decimal(24,4),Ringittequivalent decimal(24,4),
								keyIndicatorValue decimal(24,4),TotalParameters decimal(12,2),DeductionValue decimal(12,2),DeductionPer decimal(12,2)	)

								CREATE TABLE #dedgencls (IndicatorDetId INT,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),SubParameterDetId int,
								TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),Weightage decimal(6,2),GearingRatio decimal(24,4),Ringittequivalent decimal(24,4),
								keyIndicatorValue decimal(24,4),TotalParameters decimal(12,2),DeductionValue decimal(12,2),DeductionPer decimal(12,2)	)
								
								CREATE TABLE #dedgenhwms1 (IndicatorDetId INT,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),SubParameterDetId int,
								TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),Weightage decimal(6,2),GearingRatio decimal(24,4),Ringittequivalent decimal(24,4),
								keyIndicatorValue decimal(24,4),TotalParameters decimal(12,2),DeductionValue decimal(12,2),DeductionPer decimal(12,2)	)

								CREATE TABLE #dedgenhwms2 (IndicatorDetId INT,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),SubParameterDetId int,
								TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),Weightage decimal(6,2),GearingRatio decimal(24,4),Ringittequivalent decimal(24,4),
								keyIndicatorValue decimal(24,4),TotalParameters decimal(12,2),DeductionValue decimal(12,2),DeductionPer decimal(12,2)	)


								CREATE TABLE #dedgenhwms3 (IndicatorDetId INT,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),SubParameterDetId int,
								TransDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),Weightage decimal(6,2),GearingRatio decimal(24,4),Ringittequivalent decimal(24,4),
								keyIndicatorValue decimal(24,4),TotalParameters decimal(12,2),DeductionValue decimal(12,2),DeductionPer decimal(12,2)	)


								CREATE TABLE #dedgenParameter (IndicatorName varchar(500),Parameter varchar(500),ParameterValue decimal(12,2))
								
								CREATE TABLE #dedgenbems (IndicatorDetId INT,IndicatorNo NVARCHAR(50),IndicatorName NVARCHAR(300),SubParameter NVARCHAR(500),SubParameterDetId int,
								TransDemeritPoints decimal(12,2),TotalDemeritPoints decimal(12,2),NCRDemeritPoints decimal(12,2),DeductionValue decimal(12,2),DeductionPer decimal(12,2)	)

						if(@dedgendate=1)
						begin
								select @femsmonthlyServiceFee=FemsPercent,@bemsmonthlyServiceFee=BemsPercent,@llsmonthlyServiceFee=LLSPercent,
								@clsmonthlyServiceFee=CLSpercent,--@hwmsmonthlyServiceFee=HWMSCWPercent,@hwmsmonthlyServiceFee=HWMSOSWPercent,
								@hwmsmonthlyServiceFeea=HWMSCWPercent,
								@hwmsmonthlyServiceFeeb=HWMSOSWPercent,
								@hwmsmonthlyServiceFeec=HWMSCSWPercent,@fmsmonthlyServiceFee=FMS from FinMonthlyFeeTxn a 
								inner join FinMonthlyFeeTxnDet b on a.MonthlyFeeId=b.MonthlyFeeId
								where a.IsDeleted=0 and b.IsDeleted=0 and a.HospitalId=@HospitalId
								and a.Year=@year and b.Month=@month

								
	
								if exists(select 1 from FinMonthlyFeeTxn a 
								inner join FinMonthlyFeeTxnDet b on a.MonthlyFeeId=b.MonthlyFeeId
								where a.IsDeleted=0 and b.IsDeleted=0 and a.HospitalId=@HospitalId
								and a.Year=@year and b.Month=@month)
								begin
										if (@fmsmonthlyServiceFee!=0 )
										begin 
												
												/* Added new conditon to check whether reports and records submitted or not, if not there FMS deduction should not run*/
												if exists (select * from WpmReportRecordsTxn where IsDeleted = 0 and HospitalId = @HospitalId and Year = @year and Month = @month and Status in (5754,5755))
												begin

													/*FMS*/
													--exec DeductionGenerationFetch 2017,9,6,null,85,100
													Set @serviceid=6
													set @groupid=2416
													set @execqry=N'exec DeductionGenerationFetch '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@fmsmonthlyServiceFee  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')
													print @execqry

													EXEC InsertResultSetsToTables
														@sourceQuery = @execqry
														,@targetTableList = N'#dedgenfetch';
				
													print '1'
													if not exists(SELECT 1 FROM #dedgenfetch)
													begin 
													delete from #dedgen
														set @execqry=N'exec FMSDeductionGeneration '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@fmsmonthlyServiceFee  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

														EXEC InsertResultSetsToTables
															@sourceQuery = @execqry
															,@targetTableList = N'#dedgen,#dedfmsgenparam';

															--select * from #dedgen
														insert into DedGenerationTxn(HospitalId,CompanyId,[Month],[Year],[Service],CreatedBy,CreatedDate,[Group],MonthlyServiceFee,DeductionStatus)
														select @HospitalId,@companyid,@month,@year,@serviceid,1,getdate(),@groupid,@fmsmonthlyServiceFee,'G'
														select @id=SCOPE_IDENTITY();
		
														insert into DedGenerationTxndet(DedGenerationId,IndicatorDetId,TotalParameter,DeductionValue,DeductionPercentage
														,CreatedBy,CreatedDate,TransactionDemeritPoint,NcrDemeritPoint,SubParameterDetId,
														keyIndicatorValue,Ringittequivalent,GearingRatio)									
														SELECT distinct @id,IndicatorDetId,TotalParameters,DeductionValue,DeductionPer,1,getdate(),
														TransDemeritPoints,NCRDemeritPoints,null,
														keyIndicatorValue,Ringittequivalent,GearingRatio FROM #dedgen where IndicatorDetId!=0 and TotalParameters is not null
														and indicatordetid in (21,22,23,24,25,26,27,28);

														insert into DedGenerationParameterTxndet(DedGenerationId,IndicatorDetId,Parameter,CreatedBy,CreatedDate,ParameterValue)
														select distinct @id,indicatordetid,Parameter,1,getdate(),ParameterValue from #dedfmsgenparam a 
														inner join DedIndicatorMstDet(nolock) b on a.indicatorname=b.indicatorno and b.isdeleted=0
														where b.indicatordetid in (21,22,23,24,25,26,27,28)


														insert into DedGenerationSubParamterTxndet(DedGenerationId,IndicatorDetId,TransactionDemeritPoint,SubParameterDetId
																									,CreatedBy,CreatedDate,NCRDemeritPoint,DeductionValue,DeductionPercentage)
														Select distinct @id,IndicatorDetId,TransDemeritPoints,SubParameterDetId
														,1,GETDATE(),NCRDemeritPoints,DeductionValue,DeductionPer FROM #dedgen where SubParameterDetId!=0 and IndicatorDetId!=0;


														/*Commented seperate and called common sp for using NCR calculation also*/
														exec FMSDeductionDemeritMappingSave @Id,@HospitalId,@month,@serviceID,@year,1,@DedGenerationType

														
														--exec FMSDeductionDemeritMappingSaveFM1 @Id,@HospitalId,@month,@year,@serviceID,1,@DedGenerationType
														--exec FMSDeductionDemeritMappingSaveFM2 @Id,@HospitalId,@month,@year,@serviceID,1,@DedGenerationType
														--exec FMSDeductionDemeritMappingSaveFM3 @Id,@HospitalId,@month,@year,@serviceID,1,@DedGenerationType
														--exec FMSDeductionDemeritMappingSaveFM4 @Id,@HospitalId,@month,@year,@serviceID,1,@DedGenerationType
														--exec FMSDeductionDemeritMappingSaveFM5 @Id,@HospitalId,@month,@year,@serviceID,1,@DedGenerationType
														--exec FMSDeductionDemeritMappingSaveFM6 @Id,@HospitalId,@month,@year,@serviceID,1,@DedGenerationType
														--exec FMSDeductionDemeritMappingSaveFM7 @Id,@HospitalId,@month,@year,@serviceID,1,@DedGenerationType
														--exec FMSDeductionDemeritMappingSaveFM8 @Id,@HospitalId,@month,@year,@serviceID,1,@DedGenerationType

														insert into AsisErrorLog(Spname,ErrorMessage,createddate)
														values('ASIS_AutoDeductionGeneration','FMS Deduction submitted for HospitalId='+cast(@hospitalid as varchar(500))+' Month = '+cast(@month as varchar(500))+' Year = '+cast(@year as varchar(500)),getdate())
													end
												end
										end
										/*FEMS*/
										delete from #dedgenfetch
										if (@femsmonthlyServiceFee!=0 )
										begin
												Set @serviceid=1
												set @groupid=2409
												set @execqry=N'exec DeductionGenerationFetch '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@femsmonthlyServiceFee   as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

												EXEC InsertResultSetsToTables
													@sourceQuery = @execqry
													,@targetTableList = N'#dedgenfetch';
												print '2'
				
												if not exists(SELECT 1 FROM #dedgenfetch)
												begin 
												delete from #dedgenfems
													set @execqry=N'exec FeMSDeductionGeneration '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@femsmonthlyServiceFee  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

													EXEC InsertResultSetsToTables
														@sourceQuery = @execqry
														,@targetTableList = N'#dedgenFems,#dedfemsgenparam';

													insert into DedGenerationTxn(HospitalId,CompanyId,[Month],[Year],[Service],CreatedBy,CreatedDate,[Group],MonthlyServiceFee,DeductionStatus)
													select @HospitalId,@companyid,@month,@year,@serviceid,1,getdate(),@groupid,@femsmonthlyServiceFee,'G'
													select @id=SCOPE_IDENTITY();

													insert into DedGenerationTxndet(DedGenerationId,IndicatorDetId,TotalParameter,DeductionValue,DeductionPercentage
													,CreatedBy,CreatedDate,TransactionDemeritPoint,NcrDemeritPoint,SubParameterDetId,
													keyIndicatorValue,Ringittequivalent,GearingRatio)									
													SELECT distinct @id,IndicatorDetId,TotalParameters,DeductionValue,DeductionPer,1,getdate(),
													TransDemeritPoints,NCRDemeritPoints,null,
													keyIndicatorValue,Ringittequivalent,GearingRatio FROM #dedgenFems where IndicatorDetId!=0 and TotalParameters is not null
													and indicatordetid in (2,3,4,5,6,7,8,9);

													insert into DedGenerationParameterTxndet(DedGenerationId,IndicatorDetId,Parameter,CreatedBy,CreatedDate,ParameterValue)
														select distinct @id,indicatordetid,Parameter,1,getdate(),ParameterValue from #dedfemsgenparam a 
														inner join DedIndicatorMstDet(nolock) b on a.indicatorname=b.indicatorno and b.isdeleted=0
														where b.indicatordetid in (2,3,4,5,6,7,8,9)

													insert into DedGenerationSubParamterTxndet(DedGenerationId,IndicatorDetId,TransactionDemeritPoint,SubParameterDetId
																								,CreatedBy,CreatedDate,NCRDemeritPoint,DeductionValue,DeductionPercentage)
													Select distinct @id,IndicatorDetId,TransDemeritPoints,SubParameterDetId
													,1,GETDATE(),NCRDemeritPoints,DeductionValue,DeductionPer FROM #dedgenFems where SubParameterDetId!=0 and IndicatorDetId!=0;


													exec FEMSDeductionGenerationDemeritPopupSave @ServiceId,@HospitalId,@Month,@Year,@DedGenerationType
													--exec [FEMSDeductionGenerationDemeritPopupSaveF1] @ServiceId,@HospitalId,@Month,@Year,@DedGenerationType
													--exec [FEMSDeductionGenerationDemeritPopupSaveF2] @ServiceId,@HospitalId,@Month,@Year,@DedGenerationType
													--exec [FEMSDeductionGenerationDemeritPopupSaveF3] @ServiceId,@HospitalId,@Month,@Year,@DedGenerationType
													--exec [FEMSDeductionGenerationDemeritPopupSaveF4] @ServiceId,@HospitalId,@Month,@Year,@DedGenerationType
													--exec [FEMSDeductionGenerationDemeritPopupSaveF5] @ServiceId,@HospitalId,@Month,@Year,@DedGenerationType
													--exec [FEMSDeductionGenerationDemeritPopupSaveF6] @ServiceId,@HospitalId,@Month,@Year,@DedGenerationType
													--exec [FEMSDeductionGenerationDemeritPopupSaveF7] @ServiceId,@HospitalId,@Month,@Year,@DedGenerationType
												
																											insert into AsisErrorLog(Spname,ErrorMessage,createddate)
														values('ASIS_AutoDeductionGeneration','FEMS Deduction submitted for HospitalId='+cast(@hospitalid as varchar(500))+' Month = '+cast(@month as varchar(500))+' Year = '+cast(@year as varchar(500)),getdate())
												end
										end
										/*BEMS*/
										delete from #dedgenfetch
										if (@bemsmonthlyServiceFee!=0 )
										begin
												Set @serviceid=2
												set @groupid=2410
												set @execqry=N'exec DeductionGenerationFetch '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@BemsmonthlyServiceFee   as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

												EXEC InsertResultSetsToTables
													@sourceQuery = @execqry
													,@targetTableList = N'#dedgenfetch';
												print '3'
					
												if not exists(SELECT 1 FROM #dedgenfetch)
												begin 
												delete from #dedgenbems
													set @execqry=N'exec beMSDeductionGeneration '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@BemsmonthlyServiceFee   as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

													EXEC InsertResultSetsToTables
														@sourceQuery = @execqry
														,@targetTableList = N'#dedgenbems';

													insert into DedGenerationTxn(HospitalId,CompanyId,[Month],[Year],[Service],CreatedBy,CreatedDate,[Group],MonthlyServiceFee,DeductionStatus)
													select @HospitalId,@companyid,@month,@year,@serviceid,1,getdate(),@groupid,@bemsmonthlyServiceFee,'G'
													select @id=SCOPE_IDENTITY();

													insert into DedGenerationTxndet(DedGenerationId,IndicatorDetId,DeductionValue,DeductionPercentage
													,CreatedBy,CreatedDate,TransactionDemeritPoint,NcrDemeritPoint,SubParameterDetId)									
													--SELECT @id,IndicatorDetId,TotalParameters,DeductionValue,DeductionPer,3,getdate(),
													--TransDemeritPoints,NCRDemeritPoints,null,
													--keyIndicatorValue,Ringittequivalent,GearingRatio FROM #dedgenbems where IndicatorDetId!=0;
													SELECT distinct @id,IndicatorDetId,DeductionValue,DeductionPer,1,getdate(),
													TransDemeritPoints,NCRDemeritPoints,null FROM #dedgenbems where IndicatorDetId!=0
													and indicatordetid in (10,11,12,13,14);-- and TotalParameters is not null;

													--insert into DedGenerationParameterTxndet(DedGenerationId,IndicatorDetId,Parameter,CreatedBy,CreatedDate,ParameterValue)
													--	select distinct @id,indicatordetid,Parameter,1,getdate(),ParameterValue from #dedBemsgenparam a 
													--	inner join DedIndicatorMstDet(nolock) b on a.indicatorname=b.indicatorno and b.isdeleted=0
													--	where b.indicatordetid in (10,11,12,13,14)

													--insert into DedGenerationSubParamterTxndet(DedGenerationId,IndicatorDetId,TransactionDemeritPoint,SubParameterDetId
													--											,CreatedBy,CreatedDate,NCRDemeritPoint,DeductionValue,DeductionPercentage)
													--Select distinct @id,IndicatorDetId,TransDemeritPoints,SubParameterDetId
													--,1,GETDATE(),NCRDemeritPoints,DeductionValue,DeductionPer FROM #dedgenbems where IndicatorDetId!=0 and SubParameterDetId!=0;

													exec BEMSDeductionDemeritMappingSaveB1 @Id,@HospitalId,@ServiceId,@Month,@Year,1,@DedGenerationType
													exec BEMSDeductionDemeritMappingSaveB2 @Id,@HospitalId,@ServiceId,@Month,@Year,1,@DedGenerationType
													exec BEMSDeductionDemeritMappingSaveB3 @Id,@HospitalId,@ServiceId,@Month,@Year,1,@DedGenerationType
													exec BEMSDeductionDemeritMappingSaveB4 @Id,@HospitalId,@ServiceId,@Month,@Year,1,@DedGenerationType
													exec BEMSDeductionDemeritMappingSaveB5 @Id,@HospitalId,@ServiceId,@Month,@Year,1,@DedGenerationType
												
																										insert into AsisErrorLog(Spname,ErrorMessage,createddate)
														values('ASIS_AutoDeductionGeneration','BEMS Deduction submitted for HospitalId='+cast(@hospitalid as varchar(500))+' Month = '+cast(@month as varchar(500))+' Year = '+cast(@year as varchar(500)),getdate())
												end
										end
										/*CLS*/
										delete from #dedgenfetch
										if (@clsmonthlyServiceFee!=0 )
										begin
												Set @serviceid=3
												set @groupid=2411
												set @execqry=N'exec DeductionGenerationFetch '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@clsmonthlyServiceFee   as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

												EXEC InsertResultSetsToTables
													@sourceQuery = @execqry
													,@targetTableList = N'#dedgenfetch';
				
												print '4'
												if not exists(SELECT 1 FROM #dedgenfetch)
												begin 
												delete from #dedgencls
													set @execqry=N'exec clSDeductionGeneration '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@clsmonthlyServiceFee   as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

													EXEC InsertResultSetsToTables
														@sourceQuery = @execqry
														,@targetTableList = N'#dedgencls,#dedclsgenparam';

													insert into DedGenerationTxn(HospitalId,CompanyId,[Month],[Year],[Service],CreatedBy,CreatedDate,[Group],MonthlyServiceFee,DeductionStatus)
													select @HospitalId,@companyid,@month,@year,@serviceid,1,getdate(),@groupid,@clsmonthlyServiceFee,'G'
													select @id=SCOPE_IDENTITY();

													insert into DedGenerationTxndet(DedGenerationId,IndicatorDetId,TotalParameter,DeductionValue,DeductionPercentage
													,CreatedBy,CreatedDate,TransactionDemeritPoint,NcrDemeritPoint,SubParameterDetId,
													keyIndicatorValue,Ringittequivalent,GearingRatio)									
													SELECT distinct @id,IndicatorDetId,TotalParameters,DeductionValue,DeductionPer,1,getdate(),
													TransDemeritPoints,NCRDemeritPoints,null,
													keyIndicatorValue,Ringittequivalent,GearingRatio FROM #dedgencls where IndicatorDetId!=0 and TotalParameters is not null
													and indicatordetid in (15,16,17,18,19,20);

													insert into DedGenerationParameterTxndet(DedGenerationId,IndicatorDetId,Parameter,CreatedBy,CreatedDate,ParameterValue)
														select distinct @id,indicatordetid,Parameter,1,getdate(),ParameterValue from #dedclsgenparam a 
														inner join DedIndicatorMstDet(nolock) b on a.indicatorname=b.indicatorno and b.isdeleted=0
														where b.indicatordetid in (15,16,17,18,19,20)

													insert into DedGenerationSubParamterTxndet(DedGenerationId,IndicatorDetId,TransactionDemeritPoint,SubParameterDetId
																								,CreatedBy,CreatedDate,NCRDemeritPoint,DeductionValue,DeductionPercentage)
													Select distinct @id,IndicatorDetId,TransDemeritPoints,SubParameterDetId
													,1,GETDATE(),NCRDemeritPoints,DeductionValue,DeductionPer FROM #dedgencls where IndicatorDetId!=0 and SubParameterDetId!=0;

													--exec CLSDeductionGenerationDemeritPopupSave @HospitalId,@month,@year,@ServiceId,@Id,1,@DedGenerationType
												exec ClsDeductionGenerationDemeritInsert @id,@HospitalId,@month,@year,@ServiceId,1,@DedGenerationType
																											insert into AsisErrorLog(Spname,ErrorMessage,createddate)
														values('ASIS_AutoDeductionGeneration','CLS Deduction submitted for HospitalId='+cast(@hospitalid as varchar(500))+' Month = '+cast(@month as varchar(500))+' Year = '+cast(@year as varchar(500)),getdate())
												end
										end
										/*LLS*/
										delete from #dedgenfetch
										if (@llsmonthlyServiceFee!=0 )
										begin
												Set @serviceid=4
												set @groupid=2412
												set @execqry=N'exec DeductionGenerationFetch '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@llsmonthlyServiceFee  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

												EXEC InsertResultSetsToTables
													@sourceQuery = @execqry
													,@targetTableList = N'#dedgenfetch';
				
												print '5'
												if not exists(SELECT 1 FROM #dedgenfetch)
												begin 
												delete from #dedgenlls
													set @execqry=N'exec llSDeductionGeneration '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@llsmonthlyServiceFee  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')
													--exec llSDeductionGeneration 2017,9,4,null,85,100
													print '5.1'
													EXEC InsertResultSetsToTables
														@sourceQuery = @execqry
														,@targetTableList = N'#dedgenlls,#dedllsgenparam';
														print 'err'
													insert into DedGenerationTxn(HospitalId,CompanyId,[Month],[Year],[Service],CreatedBy,CreatedDate,[Group],MonthlyServiceFee,DeductionStatus)
													select @HospitalId,@companyid,@month,@year,@serviceid,1,getdate(),@groupid,@llsmonthlyServiceFee,'G'
													select @id=SCOPE_IDENTITY();

													insert into DedGenerationTxndet(DedGenerationId,IndicatorDetId,TotalParameter,DeductionValue,DeductionPercentage
													,CreatedBy,CreatedDate,TransactionDemeritPoint,NcrDemeritPoint,SubParameterDetId,
													keyIndicatorValue,Ringittequivalent,GearingRatio)									
													SELECT distinct @id,IndicatorDetId,TotalParameters,DeductionValue,DeductionPer,1,getdate(),
													TransDemeritPoints,NCRDemeritPoints,null,
													keyIndicatorValue,Ringittequivalent,GearingRatio FROM #dedgenlls where IndicatorDetId!=0 and TotalParameters is not null
													and indicatordetid in (29,30,31,32,33,34,35,36);

													insert into DedGenerationParameterTxndet(DedGenerationId,IndicatorDetId,Parameter,CreatedBy,CreatedDate,ParameterValue)
														select distinct @id,indicatordetid,Parameter,1,getdate(),ParameterValue from #dedllsgenparam a 
														inner join DedIndicatorMstDet(nolock) b on a.indicatorname=b.indicatorno and b.isdeleted=0
														where b.indicatordetid in (29,30,31,32,33,34,35,36)

													insert into DedGenerationSubParamterTxndet(DedGenerationId,IndicatorDetId,TransactionDemeritPoint,SubParameterDetId
																								,CreatedBy,CreatedDate,NCRDemeritPoint,DeductionValue,DeductionPercentage)
													Select distinct @id,IndicatorDetId,TransDemeritPoints,SubParameterDetId
													,1,GETDATE(),NCRDemeritPoints,DeductionValue,DeductionPer FROM #dedgenlls where IndicatorDetId!=0 and SubParameterDetId!=0;

													
													exec LLSDeductionGenerationDemeritPointPopupSave @HospitalId,@month,@year,@ServiceId,@Id,1,@DedGenerationType

																											insert into AsisErrorLog(Spname,ErrorMessage,createddate)
														values('ASIS_AutoDeductionGeneration','LLS Deduction submitted for HospitalId='+cast(@hospitalid as varchar(500))+' Month = '+cast(@month as varchar(500))+' Year = '+cast(@year as varchar(500)),getdate())
												end
										end
										/*HWMS-A*/
										delete from #dedgenfetch
										if (@hwmsmonthlyServiceFeea!=0 )
										begin
												Set @serviceid=5
												set @groupid=2413
												set @execqry=N'exec DeductionGenerationFetch '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@hwmsmonthlyServiceFeea  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

												EXEC InsertResultSetsToTables
													@sourceQuery = @execqry
													,@targetTableList = N'#dedgenfetch';
												print '6'
				
												if not exists(SELECT 1 FROM #dedgenfetch)
												begin 
												delete from #dedgenhwms1
													set @execqry=N'exec hwmsDeductionGeneration '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@hwmsmonthlyServiceFeea  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

													EXEC InsertResultSetsToTables
														@sourceQuery = @execqry
														,@targetTableList = N'#dedgenhwms1,#dedhwms1genparam';

													insert into DedGenerationTxn(HospitalId,CompanyId,[Month],[Year],[Service],CreatedBy,CreatedDate,[Group],MonthlyServiceFee,DeductionStatus)
													select @HospitalId,@companyid,@month,@year,@serviceid,1,getdate(),@groupid,@hwmsmonthlyServiceFeea,'G'
													select @id=SCOPE_IDENTITY();

													insert into DedGenerationTxndet(DedGenerationId,IndicatorDetId,TotalParameter,DeductionValue,DeductionPercentage
													,CreatedBy,CreatedDate,TransactionDemeritPoint,NcrDemeritPoint,SubParameterDetId,
													keyIndicatorValue,Ringittequivalent,GearingRatio)									
													SELECT distinct @id,IndicatorDetId,TotalParameters,DeductionValue,DeductionPer,1,getdate(),
													TransDemeritPoints,NCRDemeritPoints,null,
													keyIndicatorValue,Ringittequivalent,GearingRatio FROM #dedgenhwms1 where IndicatorDetId!=0 and TotalParameters is not null
													and indicatordetid in (37,38,39,40,41);

													insert into DedGenerationParameterTxndet(DedGenerationId,IndicatorDetId,Parameter,CreatedBy,CreatedDate,ParameterValue)
														select distinct @id,indicatordetid,Parameter,1,getdate(),ParameterValue from #dedhwms1genparam a 
														inner join DedIndicatorMstDet(nolock) b on a.indicatorname=b.indicatorno and b.isdeleted=0
														where b.indicatordetid in (37,38,39,40,41)

													insert into DedGenerationSubParamterTxndet(DedGenerationId,IndicatorDetId,TransactionDemeritPoint,SubParameterDetId
																								,CreatedBy,CreatedDate,NCRDemeritPoint,DeductionValue,DeductionPercentage)
													Select distinct @id,IndicatorDetId,TransDemeritPoints,SubParameterDetId
													,1,GETDATE(),NCRDemeritPoints,DeductionValue,DeductionPer FROM #dedgenhwms1 where IndicatorDetId!=0 and SubParameterDetId!=0;

													exec HWMSDeductionGenerationSaveHC1 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHC2 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHC3 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHC4 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHC5 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													
																											insert into AsisErrorLog(Spname,ErrorMessage,createddate)
														values('ASIS_AutoDeductionGeneration','HWMS 1 Deduction submitted for HospitalId='+cast(@hospitalid as varchar(500))+' Month = '+cast(@month as varchar(500))+' Year = '+cast(@year as varchar(500)),getdate())
													end
										end
										/*HWMS-B*/
										delete from #dedgenfetch
										if (@hwmsmonthlyServiceFeeb!=0 )
										begin
												Set @serviceid=5
												set @groupid=2414
												set @execqry=N'exec DeductionGenerationFetch '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@hwmsmonthlyServiceFeeb  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

												EXEC InsertResultSetsToTables
													@sourceQuery = @execqry
													,@targetTableList = N'#dedgenfetch';
												print '6'
				
												if not exists(SELECT 1 FROM #dedgenfetch)
												begin 
												delete from #dedgenhwms2
													set @execqry=N'exec hwmsDeductionGeneration '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@hwmsmonthlyServiceFeeb  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

													EXEC InsertResultSetsToTables
														@sourceQuery = @execqry
														,@targetTableList = N'#dedgenhwms2,#dedhwms2genparam';

													insert into DedGenerationTxn(HospitalId,CompanyId,[Month],[Year],[Service],CreatedBy,CreatedDate,[Group],MonthlyServiceFee,DeductionStatus)
													select @HospitalId,@companyid,@month,@year,@serviceid,1,getdate(),@groupid,@hwmsmonthlyServiceFeeb,'G'
													select @id=SCOPE_IDENTITY();

													insert into DedGenerationTxndet(DedGenerationId,IndicatorDetId,TotalParameter,DeductionValue,DeductionPercentage
													,CreatedBy,CreatedDate,TransactionDemeritPoint,NcrDemeritPoint,SubParameterDetId,
													keyIndicatorValue,Ringittequivalent,GearingRatio)									
													SELECT distinct @id,IndicatorDetId,TotalParameters,DeductionValue,DeductionPer,1,getdate(),
													TransDemeritPoints,NCRDemeritPoints,null,
													keyIndicatorValue,Ringittequivalent,GearingRatio FROM #dedgenhwms2 where IndicatorDetId!=0 and TotalParameters is not null
													and indicatordetid in (42,43,44,45);

													insert into DedGenerationParameterTxndet(DedGenerationId,IndicatorDetId,Parameter,CreatedBy,CreatedDate,ParameterValue)
														select distinct @id,indicatordetid,Parameter,1,getdate(),ParameterValue from #dedhwms2genparam a 
														inner join DedIndicatorMstDet(nolock) b on a.indicatorname=b.indicatorno and b.isdeleted=0
														where b.indicatordetid in (42,43,44,45)

													insert into DedGenerationSubParamterTxndet(DedGenerationId,IndicatorDetId,TransactionDemeritPoint,SubParameterDetId
																								,CreatedBy,CreatedDate,NCRDemeritPoint,DeductionValue,DeductionPercentage)
													Select distinct @id,IndicatorDetId,TransDemeritPoints,SubParameterDetId
													,1,GETDATE(),NCRDemeritPoints,DeductionValue,DeductionPer FROM #dedgenhwms2 where IndicatorDetId!=0 and SubParameterDetId!=0;

													exec HWMSDeductionGenerationSaveHO1 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHO2 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHO3 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHO4 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
												
																										insert into AsisErrorLog(Spname,ErrorMessage,createddate)
														values('ASIS_AutoDeductionGeneration','HWMS 2 Deduction submitted for HospitalId='+cast(@hospitalid as varchar(500))+' Month = '+cast(@month as varchar(500))+' Year = '+cast(@year as varchar(500)),getdate())
												end
										end
										/*HWMS-C*/
										delete from #dedgenfetch
										if (@hwmsmonthlyServiceFeec!=0 )
										begin
													Set @serviceid=5
													set @groupid=2415
													set @execqry=N'exec DeductionGenerationFetch '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@hwmsmonthlyServiceFeec  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

													EXEC InsertResultSetsToTables
														@sourceQuery = @execqry
														,@targetTableList = N'#dedgenfetch';
													print '6'
				
													if not exists(SELECT 1 FROM #dedgenfetch)
													begin 
													delete from #dedgenhwms3
														set @execqry=N'exec hwmsDeductionGeneration '+cast(@year as varchar(4))+','+cast(@month as varchar(2))+','+cast(@serviceid as varchar(1))+','+cast(@groupid as varchar(4))+','+cast(@hospitalid as varchar(4))+','+cast(@hwmsmonthlyServiceFeec  as varchar(50))+','+coalesce(cast(@DedGenerationType as varchar(10)),'null')

														EXEC InsertResultSetsToTables
															@sourceQuery = @execqry
															,@targetTableList = N'#dedgenhwms3,#dedhwms3genparam';

														insert into DedGenerationTxn(HospitalId,CompanyId,[Month],[Year],[Service],CreatedBy,CreatedDate,[Group],MonthlyServiceFee,DeductionStatus)
														select @HospitalId,@companyid,@month,@year,@serviceid,1,getdate(),@groupid,@hwmsmonthlyServiceFeec,'G'
														select @id=SCOPE_IDENTITY();

														insert into DedGenerationTxndet(DedGenerationId,IndicatorDetId,TotalParameter,DeductionValue,DeductionPercentage
														,CreatedBy,CreatedDate,TransactionDemeritPoint,NcrDemeritPoint,SubParameterDetId,
														keyIndicatorValue,Ringittequivalent,GearingRatio)									
														SELECT distinct @id,IndicatorDetId,TotalParameters,DeductionValue,DeductionPer,1,getdate(),
														TransDemeritPoints,NCRDemeritPoints,null,
														keyIndicatorValue,Ringittequivalent,GearingRatio FROM #dedgenhwms3 where IndicatorDetId!=0 and TotalParameters is not null
														and indicatordetid in (46,47,48);

														insert into DedGenerationParameterTxndet(DedGenerationId,IndicatorDetId,Parameter,CreatedBy,CreatedDate,ParameterValue)
														select distinct @id,indicatordetid,Parameter,1,getdate(),ParameterValue from #dedhwms3genparam a 
														inner join DedIndicatorMstDet(nolock) b on a.indicatorname=b.indicatorno and b.isdeleted=0
														where b.indicatordetid in (46,47,48)

														insert into DedGenerationSubParamterTxndet(DedGenerationId,IndicatorDetId,TransactionDemeritPoint,SubParameterDetId
																									,CreatedBy,CreatedDate,NCRDemeritPoint,DeductionValue,DeductionPercentage)
														Select distinct @id,IndicatorDetId,TransDemeritPoints,SubParameterDetId
														,1,GETDATE(),NCRDemeritPoints,DeductionValue,DeductionPer FROM #dedgenhwms3 where IndicatorDetId!=0 and SubParameterDetId!=0;

													exec HWMSDeductionGenerationSaveHS1 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHS2 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
													exec HWMSDeductionGenerationSaveHS3 @Id,@HospitalId,@month,@year,@serviceID,@groupID,1,@DedGenerationType
												
																										insert into AsisErrorLog(Spname,ErrorMessage,createddate)
														values('ASIS_AutoDeductionGeneration','HWMS 3 Deduction submitted for HospitalId='+cast(@hospitalid as varchar(500))+' Month = '+cast(@month as varchar(500))+' Year = '+cast(@year as varchar(500)),getdate())
													end
										end
								end--servicee fee exists check
						end--work calendar check

						DROP TABLE #dedgen;
						DROP TABLE #dedgencls;
						DROP TABLE #dedgenlls;
						DROP TABLE #dedgenhwms1;
						DROP TABLE #dedgenhwms2;
						DROP TABLE #dedgenhwms3;
						DROP TABLE #dedgenParameter;
						DROP TABLE #dedgenfetch
						DROP TABLE #dedgenbems
						DROP TABLE #dedgenFems
						DROP TABLE #dedfmsgenparam	
						DROP TABLE #dedfemsgenparam	
						DROP TABLE #dedbemsgenparam	
						DROP TABLE #dedclsgenparam	
						DROP TABLE #dedllsgenparam	
						DROP TABLE #dedhwms1genparam	
						DROP TABLE #dedhwms2genparam	
						DROP TABLE #dedhwms3genparam	
						--drop table #dedgenparam
						fetch next from curdedgen into @companyid,@hospitalid,@dedgendate
					end--cursor end
					close curdedgen
					deallocate curdedgen


	End try
	Begin Catch
			print error_message()
			set @error= error_message()
			insert into AsisErrorLog(Spname,ErrorMessage,createddate)
			values('ASIS_AutoDeductionGeneration',@error,getdate())
	End Catch
END


GO

