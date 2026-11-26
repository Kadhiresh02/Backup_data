 
/****** Object:  StoredProcedure [dbo].[FEMSDeductionGenerationMapping1]    Script Date: 10/30/2026 2:12:30 PM ******/
DROP PROCEDURE [dbo].[FEMSDeductionGenerationMapping1]
GO

/****** Object:  StoredProcedure [dbo].[FEMSDeductionGenerationMapping1]    Script Date: 10/30/2026 2:12:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FEMSDeductionGenerationMapping1]
	@HospitalId int,
	@month int,
	@serviceID int,
	@year int,
	@DedGenerationType int= null

AS 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--select * from DedGenerationPopupFemsTxn where Hospitalid=167 and month =02 and year=2019  and IsDeleted=0
--
--/*** Exec [FEMSDeductionGenerationMapping1] 85,12,1,2019
--	-- Exec [FEMSDeductionGenerationMapping1] 167,12,1,2019
--Exec [FEMSDeductionGenerationMapping1] 167,02,1,2019
-- ****/
--/*=====================================================================================================================
--APPLICATION		: ASIS
--NAME				: FEMSDEDUCTIONMAPPING1
--DESCRIPTION		: FACILITY ENGINEERING Maintenance SERVICES - DEDUCTION INDICATORS
--AUTHORS			: Raguraman J
--DATE				: 05/08/2016
-------------------------------------------------------------------------------------------------------------------------
--VERSION HISTORY 
--------------------:------------:---------------------------------------------------------------------------------------
--Init				: Date       : Details
--------------------:------------:---------------------------------------------------------------------------------------
--Raguraman J       : 07/09/2016 : F1,F4,F5,F7.
-------:------------:----------------------------------------------------------------------------------------------------*/
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRY

	/*
	Declare @HospitalId int=118,
	@month int=1,
	@serviceID int=1,
	@year int=2017
	--*/
	--SET FMTONLY OFF;
    --SET NOCOUNT ON;

	--drop table #tmpAdvisoryAsset_Asset
	--drop table #TechSupportObsolete_Asset
	--drop table #tmpAssertRegall_Asset
	--drop table #tmpSnfAssets_Asset
	--drop table #tmpAssertReg_Asset 
	--drop table #tmpBerRecommend_Asset
	IF OBJECT_ID('tempdb..#tmpBerRecommend_Asset') IS NOT NULL
    DROP TABLE #tmpBerRecommend_Asset
	IF OBJECT_ID('tempdb..#tmpAssertReg_Asset') IS NOT NULL
    DROP TABLE #tmpAssertReg_Asset
	IF OBJECT_ID('tempdb..#tmpSnfAssets_Asset') IS NOT NULL
    DROP TABLE #tmpSnfAssets_Asset

	IF OBJECT_ID('tempdb..#tmpAssertRegall_Asset') IS NOT NULL
    DROP TABLE #tmpAssertRegall_Asset
	IF OBJECT_ID('tempdb..#tmpAdvisoryAsset_Asset') IS NOT NULL
    DROP TABLE #tmpAdvisoryAsset_Asset
	IF OBJECT_ID('tempdb..#TechSupportObsolete_Asset') IS NOT NULL
    DROP TABLE #TechSupportObsolete_Asset

	
	IF OBJECT_ID('tempdb..#GetGMHospitalMstAndGroup') IS NOT NULL
    DROP TABLE #GetGMHospitalMstAndGroup
    create table #GetGMHospitalMstAndGroup (HospitalId int)
    insert into #GetGMHospitalMstAndGroup  
    select * from dbo.FN_GetGMHospitalMstAndGroup(@Year,@Month,@HospitalId,@DedGenerationType)

	DECLARE @serviceKey NVARCHAR(20),@monthSel NVARCHAR(50),@NoOfuserArea INT,@TotalTypeVariance FLOAT, @NoOfItems INT,@NoOfDays INT,
			@Weightage FLOAT,@TransDemeritPoint FLOAT, @TotalParameter FLOAT,@monthval INT,@keyIndicatorValue FLOAT,@TotalParameters FLOAT,
			@Ringittequivalent FLOAT,@GearingRatio FLOAT,@DemeritPoints FLOAT,@DeductionValue FLOAT,@DeductionPer FLOAT,
			@NCRDemeritPoints FLOAT,@TotalNoCollectiONs INT,@TotalCollectiONStatus INT,@TotalNcr INT,@TotalCONsignmentNote INT,
			@NoOfTransportfreqWeek INT,@NoOfTransportfreqMONth INT,@NoOfTransportfreqDaily INT,@TotalParameterDaily FLOAT,
			@TotalParameterWeekly FLOAT,@TotalParameterMONthly FLOAT,@LovValue NVARCHAR(50),@monthlyServiceFeeVal FLOAT,
			@NoOfWeeks FLOAT,@Noofprocedureapplied FLOAT,@spillageincident FLOAT,@procedureapplied FLOAT,@totalcwwrssanitize FLOAT,
			@Bagholderwashing FLOAT,@CollectiONDevicewashing FLOAT,@dmcwrsanitize FLOAT,@totalcwwrssanitizedm FLOAT,
			@dmcwrsanitizedm FLOAT,@NoofWeekscount INT,@treatmenttrolleydm FLOAT,@treatmenttrolleytp FLOAT,
			@TotalPPMRI INT ,@NoOfWoPPMRI INT ,@NoOfUnSchedule INT,@DemeritNCR INT,@DemeritF4 INT,@DemeritF1 INT,
			@StartDate AS DATETIME , @LastDate AS DATETIME

	SELECT  @serviceKey = ServiceKey FROM AsisService  WHERE ServiceID=@serviceID
	
	SET @StartDate= DATEFROMPARTS(@YEAR, @month , 01)
	SET @LastDate  = CASE WHEN MONTH(GETDATE()) = @month and YEAR(GETDATE())=@YEAR THEN GETDATE() 
				ELSE (SELECT CAST(EOMONTH(@StartDate) AS DATETIME)+ '23:59') END

DECLARE @HOSPITALNAME varchar(150),@COMPANYNAME varchar(150),
	@STATENAME varchar(150), @MONTHYEAR varchar(150);

	select @HOSPITALNAME = HospitalName
	FROM GMHospitalMst 
	where HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

	select @COMPANYNAME = c.CompanyName
	from GmCompanyMst c (NOLOCK)
	INNER JOIN GMHospitalMst p (NOLOCK) ON c.CompanyId = p.CompanyId
	where p.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

	select @STATENAME = StateName from AsisStateMst s (NOLOCK)
	INNER JOIN FmsHospitalProfileMst p (NOLOCK) ON s.StateId = p.[State]
	WHERE p.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

	select @MONTHYEAR = CONVERT(varchar(3), DateName( month , DateAdd( month , @MONTH , 0 ) - 1 ))+'/'+CONVERT(varchar(10), @YEAR) 


	declare  @DedGenerationId int

		select @DedGenerationId = a.DedGenerationId
		from dedgenerationtxn a 			
		where a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and a.Service	=	@serviceID
		and a.Year		=	@year 
		and a.Month		=	@month
		and a.IsDeleted	=	0 
		and exists (select 1 from DedGenerationPopupFemsTxn  F where f.DedGenerationId= a.DedGenerationId and f.isdeleted=0)


	SELECT ar.AssetNo 
	INTO #tmpAdvisoryAsset_Asset
	FROM EngAdvisoryTxnDet ad (NOLOCK)
	INNER JOIN EngAdvisoryTxn at (NOLOCK) ON ad.AdvisoryId = at.AdvisoryId AND at.IsDeleted = 0
	INNER JOIN EngAdvisoryConclusionTxnDet adv (NOLOCK) ON ad.AdvisoryDetId = adv.AdvisoryDetId   
					AND adv.IsDeleted = 0 AND ad.IsDeleted=0
	INNER JOIN EngAdvisoryHistoryTxn hs (NOLOCK) on at.AdvisoryId=hs.AdvisoryId and hs.IsDeleted=0	
	INNER JOIN SrServiceRequestMst sr (NOLOCK) ON ad.ServiceRequestId = sr.ServiceRequestId 
					AND sr.IsDeleted = 0 AND sr.[Status] not in  (2315,5887) -- Cancelled Status					
	INNER JOIN EngAssetRegisterMst ar (NOLOCK) ON sr.AssetRegisterId = ar.AssetRegisterId 
	WHERE ISNULL(adv.Conclusion,0) IN (4009,4010)
	and ISNULL(hs.StakeholderType,0)=4016
	AND sr.[Service] = @SERVICEID
	AND sr.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
	AND sr.[DateTime] <= @LastDate
	and CAST(@LastDate AS DATE) >= CAST(hs.date AS DATE)
	GROUP BY ar.AssetNo

	select distinct ar.AssetNo 
	INTO #TechSupportObsolete_Asset
	from EngAssetRegisterMst ar (NOLOCK)
	inner join EngTechSupportLetterTxnDet est (NOLOCK) on ar.Manufacturer = est.Manufacturer and ar.Brand = est.Brand 
	and ar.MadeIn = est.MadeIn and ar.Model = est.Model and est.IsDeleted=  0
	inner join EngTechSupportLetterStatusTxnDet estd (NOLOCK) on est.TechnicalSupportDetId=estd.TechnicalSupportDetId and estd.IsDeleted = 0
	where ar.IsDeleted =0 and estd.[Status]= 2350 and ar.ServiceId = @ServiceId
	and CAST(@LastDate AS DATE) >= CAST(est.EffectiveDate AS DATE)

	
		SELECT wo.AssetNo,  vd.AssetRegisterId AS AssetRegisterId, vd.VariationDate as SNFDate
		INTO #tmpSnfAssets_Asset
		FROM EngAssetRegisterMst AS wo (NOLOCK)
		INNER JOIN VmVariationDetailsTxn AS vd (NOLOCK) on wo.AssetRegisterId = vd.AssetRegisterId	
		AND vd.IsDeleted = 0 AND wo.IsDeleted =0 AND vd.VariationStatus IN 
		(SELECT LovId FROM AsisSysLovMst 		
		WHERE ModuleName = 'FEMS'
		AND LovKey = 'VOStatusValue'  AND FieldCode IN (2,4,5)
		AND vd.VariationApprovedStatus = (SELECT LovId FROM AsisSysLovMst (nolock) 		
		WHERE ModuleName = 'FMS' AND LovKey = 'YesNoValue' AND FieldCode =1))
		WHERE wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) AND wo.ServiceId=@SERVICEID


			SELECT ar.AssetRegisterId, ar.assetno, ful.UserLocationId,fua.FmsUserAreaId, ar.AssetTypeCodeId ,ar.PurchaseCostRM
		,ar.WarrantyEndDate,ar.AssetStatus,ar.AssetClassification, ar.[Authorization], ar.EngUserLocationId, ar.EngUserAreaId
		, ar.RealTimeStatus, ar.CommissioningDate, ar.PurchaseDate, ar.AssetSubClassification,ar.ServiceStartDate
		INTO  #tmpAssertRegall_Asset 
		FROM  EngAssetRegisterMst AS ar (NOLOCK)
		LEFT JOIN EngUserLocationMst eul (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId and  isnull(eul.IsDeleted,0) = 0
		LEFT JOIN FmsUserLocationMst ful (NOLOCK) ON eul.UserLocationId = ful.UserLocationId and isnull(ful.IsDeleted,0) = 0
		LEFT JOIN FmsUserAreaMst fua  (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId and isnull(fua.IsDeleted,0) = 0   
		WHERE ar.ServiceId = @SERVICEID
		AND ar.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		AND ar.IsDeleted = 0
		and ar.[Authorization]=4799
		and ar.AssetStatus = 127
		---- Check Warranty date
		--AND  ar.WarrantyEndDate<@LastDate
		AND (ar.AssetClassification in (2325,2326) or  ( ar.WarrantyEndDate<@LastDate  or (ar.WarrantystartDate is null and  ar.WarrantyEndDate is null) ) )
		
		SELECT ar.AssetRegisterId, ar.assetno, ar.UserLocationId,ar.FmsUserAreaId, ar.AssetTypeCodeId ,ar.PurchaseCostRM
		,ar.WarrantyEndDate,ar.AssetStatus,ar.AssetClassification, ar.[Authorization], ar.EngUserLocationId, ar.EngUserAreaId
		, ar.RealTimeStatus, ar.CommissioningDate, ar.PurchaseDate, ar.AssetSubClassification
		INTO #tmpAssertReg_Asset
		FROM  #tmpAssertRegall_Asset ar 
		where  ((AssetClassification=2326 and ar.ServiceStartDate <=@LastDate ) or ar.CommissioningDate<=@LastDate)



		select distinct arr.AssetNo, ba.assetregisterid
		INTO #tmpBerRecommend_Asset
		from   BerApplicationTxn ba (NOLOCK)
		inner join #tmpAssertReg_Asset ar (NOLOCK) on ba.AssetRegisterId=ar.AssetRegisterId
		inner join EngAssetRegisterMst arr (NOLOCK) on arr.AssetRegisterId=ba.AssetRegisterId
		outer apply ( select top 1 ApplicationId,CreatedDate from BerApplicationHistoryTxn bh (NOLOCK) where ba.ApplicationId=bh.ApplicationId and bh.status in (2634) and bh.IsDeleted=0   ) bh1
		where ba.IsDeleted=0  		
		AND ba.ApplicationDate <= @LastDate
		and ba.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and  (( bh1.applicationid is null  AND  ba.Status  in (2634, 4593,2638,2641,5600,2639,2640,4592,5601,5604,5605,5603) ) or  CAST(@LastDate AS DATE) >= CAST(bh1.CreatedDate AS DATE) )

--select @DedGenerationId =3388
		
IF @DedGenerationId is not null 
BEGIN

	SELECT  Distinct   @HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, case when isncr=1  then ncrno   else isnull(ServiceRequestNo,serviceworkno) end  as ServiceRequestNo
			, case when isncr=1 then SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.NCRDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.NCRDateTime , 113),3,1, '-'),7,1,'-'))-2)
			else case when Indicatorno='F.7' and t.ServiceRequestNo is null then SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'))-2) 
			else case when Indicatorno='F.7' and t.ServiceRequestNo is not null then SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'))-2) 
			else  SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'))-2) end end 
				end as ServiceRequestDate
			
			--, FORMAT(RequestDate, 'dd-MMM-yyyy HH:MM') as ServiceRequestDate
			, case when t.RequestType='2857' then 'Unscheduled' else t.RequestType end as TypeOfServicesRequest
			,  case when t.TypeofWorkOrder='2357' then 'Breakdown Repairs' else t.TypeofWorkOrder end  as MaintenanceType 
			, t.AssetNo
			,t.srDetails as ServiceRequestDetails 
			,t.Requestor as RequestNameDesignation
			,t.UnderWarranty
			,ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus
			, t.VariationStatus
			--, t.ResponseDateTime as ResponseDateTime
			 ,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.ResponseDateTime, 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.ResponseDateTime, 113),3,1, '-'),7,1,'-'))-2) As ResponseDateTime
			, t.RepsonseDurationHrs as ResponseDuration 
			, t.ProvisionDate --FORMAT(ProvisionDate, 'dd-MMM-yyyy HH:MM') 
			, t.ProvisionEndDate as  EndDateTime --FORMAT(EndDateTime, 'dd-MMM-yyyy HH:MM') 	
			, case when isncr=1 then  null else SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.EndDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.EndDateTime , 113),3,1, '-'),7,1,'-'))-2) end as ServiceWorkCompletionDate
			--, FORMAT(CompletedDateTime, 'dd-MMM-yyyy HH:MM')  as ServiceWorkCompletionDate
			--, case when Indicatorno='F.1'  then DemeritPoint else null end as F1
			, case when Indicatorno='F.1'  then Case when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpBerRecommend_Asset a where a.AssetNo = t.AssetNo)
			                                         then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpAdvisoryAsset_Asset a where a.AssetNo = t.AssetNo)
													  then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #TechSupportObsolete_Asset a where a.AssetNo = t.AssetNo)
													 then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpSnfAssets_Asset a where a.AssetNo = t.AssetNo)
													 then 0 
													 else DemeritPoint end
			        
			       else 0 end as F1


			--, case when Indicatorno='F.4'  then DemeritPoint else null end as F4

			, case when Indicatorno='F.4'  then 
													 Case
													 --when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpBerRecommend_Asset a where a.AssetNo = t.AssetNo)
			           --                              then 0 
													 --when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpAdvisoryAsset_Asset a where a.AssetNo = t.AssetNo)
													 --then 0 
													 --when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #TechSupportObsolete_Asset a where a.AssetNo = t.AssetNo)
													 --then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpSnfAssets_Asset a where a.AssetNo = t.AssetNo)
													 then 0 
													 else DemeritPoint end
			        
			       else 0 end as F4
			--, case when Indicatorno='F.5'  then DemeritPoint else null end as  F5
			, case when Indicatorno='F.5'  then Case when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpBerRecommend_Asset a where a.AssetNo = t.AssetNo)
			                                         then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpAdvisoryAsset_Asset a where a.AssetNo = t.AssetNo)
													  then 0 
													 --when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #TechSupportObsolete_Asset a where a.AssetNo = t.AssetNo)
													 --then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpSnfAssets_Asset a where a.AssetNo = t.AssetNo)
													 then 0 
													 else DemeritPoint end
			        
			       else 0 end as F5
			--,  case when Indicatorno='F.7' then DemeritPoint else null end as  F7
			, case when Indicatorno='F.7'  then Case when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpBerRecommend_Asset a where a.AssetNo = t.AssetNo)
			                                         then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpAdvisoryAsset_Asset a where a.AssetNo = t.AssetNo)
													  then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #TechSupportObsolete_Asset a where a.AssetNo = t.AssetNo)
													 then 0 
													 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpSnfAssets_Asset a where a.AssetNo = t.AssetNo)
													 then 0 
													 else DemeritPoint end
			        
			       else 0 end as F7
			,  case when Indicatorno='F.8' then DemeritPoint else null end as  F8
			, case when RequestType = 'Non Conformance' THEN 'Non Conformance' else case when Indicatorno='F.7' and  t.ServiceRequestNo is null  then 'Scheduled Work Order' else case when Indicatorno='F.7' and t.ServiceRequestNo is not null then 'Testing & Commissioning' else 'Service Work (Unscheduled & Others)' end end end as Remarks
			,t.IndicatorNo  as Indicator
			,t.AssetDescription AssetDescription
		    ,Case when t.AssetClassification = '2324' or t.AssetClassification='Building'
			then 'Building'
			when t.AssetClassification='4489' or t.AssetClassification='Equipment'
			then 'Equipment'
			when t.AssetClassification='2296' or t.AssetClassification='Equipment & Vehicles'
			then 'Equipment & Vehicles'
			when t.AssetClassification='4807' or t.AssetClassification='Equipment/System'
			then 'Equipment/System'
			when t.AssetClassification='2326' or t.AssetClassification='Location'
			then 'Location'
			when t.AssetClassification='2297' or t.AssetClassification='System'
			then 'System'
			End as AssetClassification
		
			--,t.AssetClassification
			,t.Workgroup as WOWorkgroup
			,t.BuildingNo
			,t.UserAreaName

			,Case 
			 --when t.AssetClassification = '2324' or t.AssetClassification='Building'-- --Building
			 --then  
			 --(
				--Select  Count(distinct eul.EngUserAreaId)
				--from 
				--EngAssetRegisterLocationMst eul Where eul.AssetRegisterId = ase.AssetRegisterId 
				
			 --)
				When t.AssetClassification = '2297' or t.AssetClassification='System'-- --System
				then 
			(
				Select  Count(distinct se.UserAreaId)
				from 
				EngAssetRegisterServingAreaMst se Where se.AssetRegisterId = ase.AssetRegisterId 
					
			) END as 'CountOfServingArea'	

			,
		
			  CASE WHEN EXISTS (SELECT  
			WOt.WorkOrderId
					FROM EngMaintenanceWorkOrderTxn Wot (NOLOCK) 
					Left JOIN EngMwoCompletionInfoTxn wc (NOLOCK) ON Wot.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
					LEft JOIN EngMwoProcessStatusTxnDet wp (NOLOCK) ON wc.CompletionInfoId = wp.CompletionInfoId AND wp.IsDeleted=0 
					where  wp.AssetProvided = 692 AND wp.ProvideLoaner = 1 and Wot.WorkOrderId=t.ID
					)
				   THEN 'Yes' 
				   ELSE 'No'
			  END AS ProvideLoaner  


			--,CASE WHEN t.ProvisionDate is not null THEN 'Yes'  ELSE  'No'END as ProvideLoaner

			,t.ExcludeDemerit ExcludeDemeritforF1,
 

				case when ExcludeDemerit='Yes' and Reason is null then 'Overlapping/Loaner'+'  ' +ISNULL(',PO Date: '+format(eng.PODate,'dd-MMM-yyyy'),'')
				 when ExcludeDemerit='Yes' and Reason is not null then Reason+'  '+ ISNULL(',PO Date: '+format(eng.PODate,'dd-MMM-yyyy'),'')
			-- else
			--	case when isncr=1 then null else  isnull((select top 1 dtd.Remarks from DeductionTransactionMappingMst dt join DeductionTransactionMappingMstDet dtd on dt.DedTxnMappingId=dtd.DedTxnMappingId
			--	where dt.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and dt.ServiceId=@serviceID and dt.Month=@month and dt.Year=@year 
			--	and dt.IndicatorDetId=2 and dtd.DocumentNo=ServiceRequestNo and dt.IsDeleted=0 and dtd.IsDeleted=0 ),'') +'  '+ ISNULL('PO Date:'+format(eng.PODate,'dd-MMM-yyyy'),'') end
			--end as Reason,
			 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpBerRecommend_Asset a where a.AssetNo = t.AssetNo)
			then 'BER Recommended Assets'
			 when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpAdvisoryAsset_Asset a where a.AssetNo = t.AssetNo)
			then 'Exemption Approved from Advisory service'
			when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #TechSupportObsolete_Asset a where a.AssetNo = t.AssetNo)
			then 'Technical Support Letter Obsolete'

			when t.AssetNo is not null and  t.AssetNo in (select AssetNo from #tmpSnfAssets_Asset a where a.AssetNo = t.AssetNo)
			then 'Variation Status V2, V4 or V5'

			when t.Reason is not null then Isnull(t.Reason ,'')+ ' - ' + case when isncr=1  then ncrno   else isnull(ServiceRequestNo,serviceworkno) end
			--when t.Reason is not null then Isnull(t.Reason ,'')
			
				else 
				case when isncr=1 then null else  isnull((select top 1 dtd.Remarks from DeductionTransactionMappingMst dt (nolock) join DeductionTransactionMappingMstDet dtd (nolock) on dt.DedTxnMappingId=dtd.DedTxnMappingId
				where dt.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and dt.ServiceId=@serviceID and dt.Month=@month and dt.Year=@year 
				and dt.IndicatorDetId=2 and dtd.DocumentNo=ServiceRequestNo and dt.IsDeleted=0 and dtd.IsDeleted=0 ),'') +'  '+ ISNULL('PO Date:'+format(eng.PODate,'dd-MMM-yyyy'),'') end
			end as Reason
			
			,t.SubParameterDetID,--t.Details
			case when   t.ServiceRequestNo is Not null then t.SRdetails else  t.Details end as details
			from DedGenerationPopupFemsTxn t (NOLOCK)
			left join EngMwoRepairStatusTxnDet eng (NOLOCK) on t.ID=eng.WorkOrderId
			left join engassetregistermst ase (NOLOCK) on t.assetNo=ase.AssetNo
			 where t.DedGenerationId  = @DedGenerationId  
			and   t.Hospitalid	in (select HospitalId from #GetGMHospitalMstAndGroup)
			and   t.Indicatorno  in ('F.1','F.4','F.5','F.7','F.8')	
			and t.IsDeleted = 0	 and DemeritPoint>=0
			
			and isnull(t.isncr,0)=0
			order by   
			case when isncr=1 then SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.NCRDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.NCRDateTime , 113),3,1, '-'),7,1,'-'))-2)
			else case when Indicatorno='F.7' and t.ServiceRequestNo is null then SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'))-2) 
			else case when Indicatorno='F.7' and t.ServiceRequestNo is not null then SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'))-2) 
			else  SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), t.ServiceWorkDateTime , 113),3,1, '-'),7,1,'-'))-2) end end 
			end, AssetNo ASC

RETURN
END





	IF OBJECT_ID('tempdb..#dedCalc') IS NOT NULL
	DROP TABLE #dedCalc
	--===========================================--
	-- Create Temp Tables							-------
	--===========================================--
	CREATE TABLE #dedCalc
	(
		IndicatorDetId INT,
		IndicatorNo NVARCHAR(50),
		IndicatorName NVARCHAR(300),
		SubParameterDetId int,
		SubParameter NVARCHAR(500),
		TransDemeritPoints FLOAT,
		NCRDemeritPoints FLOAT,
		TotalDemeritPoints FLOAT,
		TotalParameters FLOAT,
		DeductionValue FLOAT,
		DeductionPer FLOAT,
		SubparameterValue float,
		keyIndicatorValue float,
		Ringittequivalent float,
		GearingRatio float
	)

	IF OBJECT_ID('tempdb..#TotalParameter') IS NOT NULL
	DROP TABLE #TotalParameter

	create table #TotalParameter
	(
		IndicatorName nvarchar(300),
		Parameter nvarchar(300),
		Parametervalue int
	)
--------------------------------------------------------------------------------------------------
	--FEMS Indicator
	IF(@serviceKey='FEMS')
	BEGIN
	
		INSERT INTO #dedCalc(IndicatorDetId,IndicatorNo,IndicatorName,SubParameterDetId,SubParameter)
	
		SELECT  b.IndicatorDetId,b.IndicatorNo,b.IndicatorName,d.SubParameterDetId,d.SubParameter 
		FROM DedIndicatorMst a  (NOLOCK) INNER JOIN DedIndicatorMstDet b   ON a.IndicatorId = b.IndicatorId
		INNER JOIN DedSubParameterMst c  (NOLOCK) ON c.IndicatorDetId = b.IndicatorDetId 
		INNER JOIN DedSubParameterMstDet d  (NOLOCK) ON d.SubParameterId = c.SubParameterId
		WHERE   a.ServiceId=@serviceID and a.IsDeleted = 0 and b.IsDeleted = 0 and c.IsDeleted =0  and d.IsDeleted = 0-- and a.[group] = @groupID
		UNION
		SELECT	b.IndicatorDetId,b.IndicatorNo,b.IndicatorName,'','' 
		FROM DedIndicatorMst a  (nolock)  INNER JOIN DedIndicatorMstDet b  (NOLOCK) ON a.IndicatorId = b.IndicatorId
		WHERE a.ServiceId=@serviceID and a.IsDeleted = 0 and b.IsDeleted = 0 --and a.[group] = @groupID --and c.IsDeleted =0  and d.IsDeleted = 0 
		UNION
		select 0,'Total',null,null,null
	END

	
	--===========================================--
	-- Temp Tables							-------
	--===========================================--

		IF OBJECT_ID('tempdb..#tmpWorkOrder') IS NOT NULL
			DROP TABLE #tmpWorkOrder
		IF OBJECT_ID('tempdb..#tmpWorkOrderF4') IS NOT NULL
			DROP TABLE #tmpWorkOrderF4
			IF OBJECT_ID('tempdb..#tmpWorkOrderF4') IS NOT NULL
			DROP TABLE #tmpWorkOrderF4AB
			
		IF OBJECT_ID('tempdb..#tmpWorkOrderF5') IS NOT NULL
			DROP TABLE #tmpWorkOrderF5
		IF OBJECT_ID('tempdb..#tmpWorkOrderF7') IS NOT NULL
			DROP TABLE #tmpWorkOrderF7
		IF OBJECT_ID('tempdb..#tmpAssetDetails') IS NOT NULL
			DROP TABLE #tmpAssetDetails
		IF OBJECT_ID('tempdb..#tmpWoNonWarranty') IS NOT NULL
			DROP TABLE #tmpWoNonWarranty
		IF OBJECT_ID('tempdb..#tmpWoWarranty') IS NOT NULL
			DROP TABLE #tmpWoWarranty
		IF OBJECT_ID('tempdb..#tmpAssertReg') IS NOT NULL
			DROP TABLE #tmpAssertReg
		IF OBJECT_ID('tempdb..#tmpDiffDaysF1') IS NOT NULL
			DROP TABLE #tmpDiffDaysF1
		IF OBJECT_ID('tempdb..#tmpWorkOrderF4D1') IS NOT NULL
			DROP TABLE #tmpWorkOrderF4D1	
		IF OBJECT_ID('tempdb..#tmpWorkOrderF4E2') IS NOT NULL
			DROP TABLE #tmpWorkOrderF4E2	
	----------------------------------------------------------------------
	IF OBJECT_ID('tempdb..#ImpactedWorkGroupA') IS NOT NULL
    DROP TABLE #ImpactedWorkGroupA
	IF OBJECT_ID('tempdb..#ImpactedWorkGroupB') IS NOT NULL
    DROP TABLE #ImpactedWorkGroupB


	IF OBJECT_ID('tempdb..#tmpAdvisoryAsset') IS NOT NULL
			DROP TABLE #tmpAdvisoryAsset
	IF OBJECT_ID('tempdb..#tmpSnfAssets') IS NOT NULL
		DROP TABLE #tmpSnfAssets

		IF OBJECT_ID('tempdb..#TechSupportObsolete') IS NOT NULL
			DROP TABLE #TechSupportObsolete
		IF OBJECT_ID('tempdb..#tmpBerRecommend') IS NOT NULL
			DROP TABLE #tmpBerRecommend
	IF OBJECT_ID('tempdb..#tmpWorkOrderOp') IS NOT NULL
			DROP TABLE #tmpWorkOrderOp
			
	----------------------------------------------------------------------
	----===============================================================================================
	----The asset is exemption approved/Approved upgrading or reimbursable works and work has commenced 
	----===============================================================================================
	--	 SELECT AssetRegisterid 
	--		 INTO #tmpAdvisoryAsset
	--	 FROM SrServiceRequestMst s
	--	 INNER JOIN EngAdvisoryTxnDet AS ad  ON ad.ServiceRequestId = s.ServiceRequestId AND ad.IsDeleted = 0
	--	 INNER JOIN EngAdvisoryConclusionTxnDet AS adv  ON adv.AdvisoryDetId = ad.AdvisoryDetId
	--															AND adv.IsDeleted = 0	
	--															AND ISNULL(adv.Conclusion,0) IN (4009,4010)

	
	--===========================================
	--Asset Exemption Approved from Advisory service - Get All Assets
	--===========================================
	SELECT sr.AssetRegisterId 
	INTO #tmpAdvisoryAsset
	FROM EngAdvisoryTxnDet ad (NOLOCK) 
	INNER JOIN EngAdvisoryTxn at (NOLOCK) ON ad.AdvisoryId = at.AdvisoryId AND at.IsDeleted = 0
	INNER JOIN EngAdvisoryConclusionTxnDet adv (NOLOCK) ON ad.AdvisoryDetId = adv.AdvisoryDetId   
					AND adv.IsDeleted = 0 AND ad.IsDeleted=0
	INNER JOIN EngAdvisoryHistoryTxn hs (NOLOCK) on at.AdvisoryId=hs.AdvisoryId and hs.IsDeleted=0	
	INNER JOIN SrServiceRequestMst sr (NOLOCK) ON ad.ServiceRequestId = sr.ServiceRequestId 
					AND sr.IsDeleted = 0 AND sr.[Status] not in  (2315,5887) -- Cancelled Status					
	INNER JOIN EngAssetRegisterMst ar (NOLOCK) ON sr.AssetRegisterId = ar.AssetRegisterId 
	WHERE ISNULL(adv.Conclusion,0) IN (4009,4010)
	and ISNULL(hs.StakeholderType,0)=4016
	AND sr.[Service] = @SERVICEID
	AND sr.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
	AND sr.[DateTime] <= @LastDate
	and CAST(@LastDate AS DATE) >= CAST(hs.date AS DATE)
	GROUP BY sr.AssetRegisterId
	--SELECT distinct sr.AssetRegisterId, at.[Date] AS AdvisoryDate
	--INTO #tmpAdvisoryAsset
	--FROM EngAdvisoryTxnDet ad
	--INNER JOIN EngAdvisoryTxn at ON ad.AdvisoryId = at.AdvisoryId AND at.IsDeleted = 0
	--INNER JOIN EngAdvisoryConclusionTxnDet adv (NOLOCK) ON ad.AdvisoryDetId = adv.AdvisoryDetId   
	--AND adv.IsDeleted = 0 AND ad.IsDeleted=0
	--INNER JOIN SrServiceRequestMst sr (NOLOCK) ON ad.ServiceRequestId = sr.ServiceRequestId 
	--AND sr.IsDeleted = 0 AND sr.[Status] NOT IN (2315) -- Cancelled Status					
	--WHERE ISNULL(adv.Conclusion,0) IN (4009,4010)
	--AND sr.[Service] = @SERVICEID AND sr.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
	--AND ((@LastDate = EOMONTH(GETDATE()) AND CAST(at.[Date] AS date) < CAST(getdate() as date))
	--OR (@LastDate != EOMONTH(GETDATE()) AND CAST(at.[Date] AS date) < CAST(@LastDate as date)))

	-- select * from #tmpAdvisoryAsset
	---------------------------------------------
	
	select distinct AssetRegisterId 
	INTO #TechSupportObsolete
	from EngAssetRegisterMst ar (NOLOCK)
	inner join EngTechSupportLetterTxnDet est (NOLOCK) on ar.Manufacturer = est.Manufacturer and ar.Brand = est.Brand 
	and ar.MadeIn = est.MadeIn and ar.Model = est.Model and est.IsDeleted=  0
	inner join EngTechSupportLetterStatusTxnDet estd (NOLOCK) on est.TechnicalSupportDetId=estd.TechnicalSupportDetId and estd.IsDeleted = 0
	where ar.IsDeleted =0 and estd.[Status]= 2350 and ar.ServiceId = @ServiceId
	and CAST(@LastDate AS DATE) >= CAST(est.EffectiveDate AS DATE)
	
	--======================================================================================
	--Asset Below Ememption applied for Variation Status V2, V4 or V5.	
	--======================================================================================
		SELECT vd.AssetRegisterId AS AssetRegisterId, vd.VariationDate as SNFDate
		INTO #tmpSnfAssets
		FROM EngAssetRegisterMst AS wo (NOLOCK) 
		INNER JOIN VmVariationDetailsTxn AS vd (NOLOCK) on wo.AssetRegisterId = vd.AssetRegisterId	
		AND vd.IsDeleted = 0 AND wo.IsDeleted =0 AND vd.VariationStatus IN 
		(SELECT LovId FROM AsisSysLovMst (NOLOCK) 		
		WHERE ModuleName = 'FEMS'
		AND LovKey = 'VOStatusValue'  AND FieldCode IN (2,4,5)
		AND vd.VariationApprovedStatus = (SELECT LovId FROM AsisSysLovMst 		
		WHERE ModuleName = 'FMS' AND LovKey = 'YesNoValue' AND FieldCode =1))
		WHERE wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) AND wo.ServiceId=@SERVICEID
		--AND ((@LastDate = EOMONTH(GETDATE()) AND CAST(vd.VariationDate AS date) < CAST(getdate() as date))
		--OR (@LastDate != EOMONTH(GETDATE()) AND CAST(vd.VariationDate AS date) < CAST(@LastDate as date)))

	SELECT ar.AssetRegisterId, ar.assetno, ful.UserLocationId,fua.FmsUserAreaId, ar.AssetTypeCodeId ,ar.PurchaseCostRM
		,ar.WarrantyEndDate,ar.AssetStatus,ar.AssetClassification, ar.[Authorization], ar.EngUserLocationId, ar.EngUserAreaId
		, ar.RealTimeStatus, ar.CommissioningDate, ar.PurchaseDate, ar.AssetSubClassification,ar.ServiceStartDate
		INTO #tmpAssertRegall
		FROM  EngAssetRegisterMst AS ar (NOLOCK)
		LEFT JOIN EngUserLocationMst eul  (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId and  isnull(eul.IsDeleted,0) = 0
		LEFT JOIN FmsUserLocationMst ful  (NOLOCK) ON eul.UserLocationId = ful.UserLocationId and isnull(ful.IsDeleted,0) = 0
		LEFT JOIN FmsUserAreaMst fua (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId and isnull(fua.IsDeleted,0) = 0   
		WHERE ar.ServiceId = @SERVICEID
		AND ar.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		AND ar.IsDeleted = 0
		and ar.[Authorization]=4799
		and ar.AssetStatus = 127
		---- Check Warranty date
		--AND  ar.WarrantyEndDate<@LastDate
		AND (ar.AssetClassification in (2325,2326) or  ( ar.WarrantyEndDate<@LastDate  or (ar.WarrantystartDate is null and  ar.WarrantyEndDate is null) ) )
		--AND (ar.AssetClassification in (2325,2326) or  ar.WarrantyEndDate<@LastDate)
		--AND ar.CommissioningDate<=@LastDate
		--AND ((AssetClassification=2326 and ar.ServiceStartDate <=@LastDate ) or ar.CommissioningDate<=@LastDate)
		--- The asset is exemption approved / Approved upgrading or reimbursable works and work has commenced
		--AND ar.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpAdvisoryAsset)		
 		----and not exists (SELECT 1 FROM #tmpAdvisoryAsset ta where ar.AssetRegisterId = ta.AssetRegisterId )
		--- Variation Status: V2, V4, V5.
		--AND ar.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpSnfAssets)
		----AND  not exists   (SELECT 1 FROM #tmpSnfAssets ta  where ar.AssetRegisterId = ta.AssetRegisterId)

				
		
	SELECT ar.AssetRegisterId, ar.assetno, ar.UserLocationId,ar.FmsUserAreaId, ar.AssetTypeCodeId ,ar.PurchaseCostRM
		,ar.WarrantyEndDate,ar.AssetStatus,ar.AssetClassification, ar.[Authorization], ar.EngUserLocationId, ar.EngUserAreaId
		, ar.RealTimeStatus, ar.CommissioningDate, ar.PurchaseDate, ar.AssetSubClassification
		INTO #tmpAssertReg
		FROM  #tmpAssertRegall ar
		where  ((AssetClassification=2326 and ar.ServiceStartDate <=@LastDate ) or ar.CommissioningDate<=@LastDate)

		SELECT ar.AssetRegisterId, ar.assetno, ar.UserLocationId,ar.FmsUserAreaId, ar.AssetTypeCodeId ,ar.PurchaseCostRM
		,ar.WarrantyEndDate,ar.AssetStatus,ar.AssetClassification, ar.[Authorization], ar.EngUserLocationId, ar.EngUserAreaId
		, ar.RealTimeStatus, ar.CommissioningDate, ar.PurchaseDate, ar.AssetSubClassification
		INTO #tmpAssertReg_f5
		FROM  #tmpAssertRegall ar
		
	
			   -- BER Recommended Assets
	--------------------------------------------------------------------------------------------------------
	--select Distinct ba.assetregisterid
	--	INTO #tmpBerRecommend
	--	from   BerApplicationTxn ba join BerApplicationHistoryTxn bh on ba.ApplicationId=bh.ApplicationId 
 --       inner join #tmpAssertReg ar on ba.AssetRegisterId=ar.AssetRegisterId
 --       where ba.IsDeleted=0 and bh.IsDeleted=0 and bh.[Status]  IN (2638)
 --       AND ba.ApplicationDate <= @LastDate
	--    and CAST(@LastDate AS DATE) >= CAST(bh.CreatedDate AS DATE) and ba.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
	----and ar.IsDeleted=0 and ar.ServiceId=@SERVICEID and ar.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and ar.[Authorization] = 4799
	--    group by ba.AssetRegisterId

		select distinct ba.assetregisterid
		INTO #tmpBerRecommend
		from   BerApplicationTxn ba (NOLOCK)
		inner join #tmpAssertReg ar (NOLOCK) on ba.AssetRegisterId=ar.AssetRegisterId
		outer apply ( select top 1 ApplicationId,CreatedDate from BerApplicationHistoryTxn bh (NOLOCK) where ba.ApplicationId=bh.ApplicationId and bh.status in (2634) and bh.IsDeleted=0   ) bh1
		where ba.IsDeleted=0  		
		AND ba.ApplicationDate <= @LastDate
		and ba.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and  (( bh1.applicationid is null  AND  ba.Status  in (2634, 4593,2638,2641,5600,2639,2640,4592,5601,5604,5605,5603) ) or  CAST(@LastDate AS DATE) >= CAST(bh1.CreatedDate AS DATE) )
		
		--select Distinct ar.assetregisterid, ba.CreatedDate AS BerDate
		--INTO #tmpBerRecommend
		--from #tmpAssertReg ar
		--INNER JOIN BerApplicationTxn ba ON ar.AssetRegisterId = ba.AssetRegisterId
		--INNER JOIN BerApplicationHistoryTxn bh ON ba.ApplicationId = bh.ApplicationId
		--WHERE ba.IsDeleted = 0 AND bh.[Status] IN (2638)
		--AND ((@LastDate = EOMONTH(GETDATE()) AND CAST(ba.[CreatedDate] AS date) < CAST(getdate() as date))
		--OR (@LastDate != EOMONTH(GETDATE()) AND CAST(ba.[CreatedDate] AS date) < CAST(@LastDate as date)))
			
	---------------------------------------------------------------------------------------------------------
/*
	Declare @wgId int ;
	SET @wgId=(SELECT WorkGroupId FROM GmWorkGroupDetailsMst where WorkGroupCode ='W3');

	SELECT  DISTINCT wo.*
		, ar.AssetNo
		, ar.AssetDescription
		, ful.UserLocationId
		, fua.FmsUserAreaId
		, ar.AssetTypeCodeId 
		, ar.PurchaseCostRM
		, ar.WarrantyEndDate
		, ar.AssetStatus
		, ar.AssetClassification
		, wg.WorkGroupCode
		, wg.WorkGroupDescription
		, fua.UserAreaName
		, fua.UserAreaCode
		,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(2105,49097) ELSE '' END as BuildingNo 
		--,CASE WHEN ar.WorkGroupId = @wgId THEN '' ELSE '' END as BuildingNo 
		INTO #tmpWorkOrderOp
			FROM  dbo.EngMaintenanceWorkOrderTxn AS wo  
			  INNER JOIN EngAssetRegisterMst AS ar  ON wo.AssetRegisterId = wo.AssetRegisterId --and sr.ServiceRequestId=wo.ServiceRequestId
			  INNER JOIN dbo.SrServiceRequestMst AS sr ON sr.AssetRegisterId = ar.AssetRegisterId and sr.ServiceRequestId=wo.ServiceRequestId	
			  INNER JOIN GmWorkGroupDetailsMst AS wg on ar.WorkGroupId = wg.WorkGroupId	
			  LEFT JOIN EngMwoCompletionInfoTxn wc ON wo.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted = 0	
			  LEFT JOIN EngUserLocationMst eul  ON ar.EngUserLocationId = eul.EngUserLocationId
			  LEFT JOIN FmsUserLocationMst ful  ON eul.UserLocationId = ful.UserLocationId
			  LEFT JOIN FmsUserAreaMst fua  ON ful.FmsUserAreaId = fua.FmsUserAreaId			  
		WHERE wo.ServiceId = @SERVICEID
			  AND wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
			  AND (wc.EndDateTime IS NULL OR (MONTH(wc.EndDateTime) = @MONTH AND YEAR(wc.EndDateTime) = @YEAR))
			  AND wo.MaintenanceWorkDateTime <= @LastDate			  
			  AND wo.IsDeleted = 0 AND ar.IsDeleted = 0 
			  --- The asset is exemption approved / Approved upgrading or reimbursable works and work has commenced 
			  AND wo.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpAdvisoryAsset)
			  --- Variation Status: V2, V4, V5.
			  AND ar.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpSnfAssets)		
		-- select * from #tmpWorkOrderOp

		SELECT wo.* 
		INTO #tmpWoWarranty
		FROM #tmpWorkOrderOp AS wo
		INNER JOIN #tmpAssertReg ar on wo.AssetRegisterId = ar.AssetRegisterId
		-- select * from #tmpWoWarranty
	
		

			IF OBJECT_ID('tempdb..#tmpLP1') IS NOT NULL
			drop table #tmpLP1
			IF OBJECT_ID('tempdb..#tmpALT1') IS NOT NULL
			drop table #tmpALT1
				--select * from #tmpDiffDays
		--select * from asissyslovmst where lovid= 692

		SELECT --*
		t.WorkOrderId, 
		t.assetregisterid, lp.ProvisionDateTime StartDate, lp.EndDateTime EndDate , (DATEDIFF(DAY,lp.ProvisionDateTime,lp.EndDateTime)+1) Lpaltdaydiff	 
		INTO #tmpLP1
		FROM #tmpWoWarranty t 
		INNER JOIN EngMwoCompletionInfoTxn wc ON t.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
		INNER JOIN EngMwoProcessStatusTxnDet wp ON wc.CompletionInfoId = wp.CompletionInfoId 
		AND wp.IsDeleted=0 AND wp.AssetProvided = 692 AND wp.ProvideLoaner = 1
		LEFT JOIN EngMwoProcessStatusLpTxnDet lp ON wp.ProcessStatusId = lp.ProcessStatusId AND lp.IsDeleted=0		

		SELECT t.WorkOrderId, t.assetregisterid, alt.StartDateTime StartDate, alt.EndDateTime EndDate, (DATEDIFF(DAY,alt.StartDateTime,alt.EndDateTime)+1) Lpaltdaydiff
		INTO #tmpALT1
		FROM #tmpWoWarranty t 
		INNER JOIN EngMwoCompletionInfoTxn wc ON t.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
		INNER JOIN EngMwoProcessStatusTxnDet wp ON wc.CompletionInfoId = wp.CompletionInfoId 
		AND wp.IsDeleted=0 AND wp.AssetProvided = 692 AND wp.AlternativeServiceProvided = 1
		LEFT JOIN EngMwoProcessStatusAspTxnDet alt ON wp.ProcessStatusId = alt.ProcessStatusId 
		AND alt.IsDeleted=0 		


		SELECT  --DISTINCT wo.*
		wo.WorkOrderId
		, sr.ServiceRequestId
		, sr.RequestNo
		, sr.Details
		, sr.[DateTime] as RequestDate
		, wa.ResponseDateTime 
		, DATEDIFF(MINUTE,wo.MaintenanceWorkDateTime,ISNULL(wa.ResponseDateTime,@lastdate)) as ResponseDuration
		--, CASE WHEN MONTH(wo.MaintenanceWorkDateTime)=MONTH(@LastDate) AND YEAR(wo.MaintenanceWorkDateTime)=YEAR(@LastDate) 
		--	THEN DATEDIFF(DAY,wo.MaintenanceWorkDateTime,ISNULL(c.EndDateTime,@LastDate)+1) 
		--	ELSE DATEDIFF(DAY,@StartDate,ISNULL(c.EndDateTime,@LastDate)+1) END
		, (SUM(DATEDIFF(DAY, (CASE WHEN CAST(wo.MaintenanceWorkDateTime AS DATE)<@StartDate THEN @StartDate ELSE CAST(wo.MaintenanceWorkDateTime AS DATE) END),ISNULL(CAST(c.EndDateTime AS DATE),@LastDate))+1))
			AS F1DemeritPoint
		, 0 F4DemeritPoint
		, 0 F5DemeritPoint
		, 0 F7DemeritPoint
		, c.EndDateTime as CompletedDateTime
		, lov.FieldValue as TypeofRequest
		, req.StaffName+'/'+lpos.FieldValue 
		as RequestorName
		, null UserLocationId
		, null FmsUserAreaId
		, wo.AssetNo
		, wo.AssetTypeCodeId 
		, wo.PurchaseCostRM
		, wo.WarrantyEndDate
		, wo.AssetStatus
		, asl.FieldValue as AssetClassification --wo.AssetClassification
		--, CASE WHEN (SELECT Count(*) FROM #tmpAdvisoryAsset WHERE AssetRegisterId = wo.AssetRegisterId)>0 THEN 'Exemption Approved' END
		--+' / '+ CASE WHEN (SELECT Count(*) FROM #tmpSnfAssets WHERE AssetRegisterId = wo.AssetRegisterId)>0 THEN 'Variation Applied' END
		--+' / '+ CASE WHEN (FP.CurrentPosition IN  (2837, 2840)) THEN 'BER Applied' END
		--SELECT LovId FROM AsisSysLovMst
		--WHERE LovKey = 'GeneralHospitalCurrentPosition' AND (FieldValue='Hospital Director' OR FieldValue='JOHN')
		,'' AS AssetProcessStatus
		, wo.AssetDescription
		,wo.WorkGroupDescription as Workgroup
		,wo.BuildingNo
		,wo.UserAreaName
		,CASE WHEN ISNULL(DATEDIFF(HOUR,wo.MaintenanceWorkDateTime,P.Date),0) > 12 THEN 'Yes'  ELSE  'No'END AS ProvideLoaner
		INTO #tmpWorkOrder
		--select *
		FROM  dbo.#tmpWoWarranty AS wo  
		LEFT JOIN SrServiceRequestMst AS sr ON sr.AssetRegisterId = wo.AssetRegisterId 
													AND sr.ServiceRequestId=wo.ServiceRequestId		
		LEFT JOIN AsisSysLovMst lov  ON wo.MaintenanceWorkCategory = lov.LovId AND lov.IsDeleted = 0
		LEFT JOIN FmsStaffMst req  ON sr.FmsStaffMstId= req.StaffMasterId AND req.IsDeleted = 0 
		LEFT JOIN FmsStaffPositionMstDet dsg  ON req.StaffMasterId=dsg.StaffMasterId AND dsg.IsDeleted=0
		LEFT JOIN AsisSysLovMst lpos  ON dsg.CurrentPosition = lpos.LovId AND lpos.IsDeleted = 0	
		LEFT JOIN EngMwoAssesmentTxn wa on wo.WorkOrderId = wa.WorkOrderId and wa.IsDeleted= 0
		LEFT JOIN EngMwoCompletionInfoTxn c  ON wo.WorkOrderId = c.WorkOrderId and c.IsDeleted = 0
		LEFT JOIN EngMwoCompletionInfoTxnDet d  ON  C.CompletionInfoId = d.CompletionInfoId and d.IsDeleted = 0
		LEFT JOIN EngMwoProcessStatusTxnDet P   ON C.CompletionInfoId = P.CompletionInfoId AND ISNULL(DATEDIFF(HOUR,wo.MaintenanceWorkDateTime,P.Date),0) > 12 
		and p.IsDeleted = 0
		LEFT JOIN #tmpLP1 tl ON wo.WorkOrderId = tl.WorkOrderId 
		LEFT JOIN #tmpALT1 ta ON wo.WorkOrderId = ta.WorkOrderId
		LEFT JOIN AsissyslovMst AS asl ON wo.AssetClassification = asl.LovId
		WHERE    wo.AssetStatus=(SELECT LovId FROM asissyslovmst WHERE LovKey='ContractorAndVendorStatus' and FieldValue='Active')  ----- ASSET Details - Status = Active 
				 AND wo.AssetClassification in (SELECT LovId FROM AsissyslovMst WHERE Lovkey='AssetClassificationValue' and FieldValue in ('Equipment & Vehicles','Building'))									
				 AND wo.AssetRegisterId not in (select AssetRegisterId from #tmpBerRecommend)
		GROUP BY wo.WorkOrderId, sr.ServiceRequestId
		, sr.RequestNo
		, sr.Details
		, sr.[DateTime]
		, wo.MaintenanceWorkDateTime
		, wa.ResponseDateTime , wo.AssetNo
		, wo.AssetTypeCodeId 
		, wo.PurchaseCostRM
		, wo.WarrantyEndDate
		, wo.AssetStatus
		, wo.AssetClassification, c.EndDateTime 
		, lov.FieldValue ,req.StaffName,lpos.FieldValue 
		,asl.FieldValue,wo.AssetDescription
		,wo.WorkGroupDescription
		,wo.BuildingNo
		,wo.UserAreaName,P.Date
		-- select * from #tmpWorkOrder
		-- select * from #tmpWoWarranty
		-- select * from #tmpAdvisoryAsset
		*/



		IF OBJECT_ID('tempdb..#tmpWorkOrdersF1') IS NOT NULL
DROP TABLE #tmpWorkOrdersF1

IF OBJECT_ID('tempdb..#tmpLP1') IS NOT NULL
DROP TABLE #tmpLP1

IF OBJECT_ID('tempdb..#tmpALT1') IS NOT NULL
DROP TABLE #tmpALT1

IF OBJECT_ID('tempdb..#tmpResDays') IS NOT NULL
DROP TABLE #tmpResDays

IF OBJECT_ID('tempdb..#tmpOverlappingWO') IS NOT NULL
DROP TABLE #tmpOverlappingWO

IF OBJECT_ID('tempdb..#tmpTotalDays') IS NOT NULL
DROP TABLE #tmpTotalDays
IF OBJECT_ID('tempdb..#tmpOverlappingWO') IS NOT NULL
DROP TABLE #tmpOverlappingWO
IF OBJECT_ID('tempdb..#tmpfortesting') IS NOT NULL
DROP TABLE #tmpfortesting

IF OBJECT_ID('tempdb..#tmpUnderOverlap') IS NOT NULL
DROP TABLE #tmpUnderOverlap
	

Declare @wgId int ;
SET @wgId=(SELECT TOP 1 WorkGroupId FROM GmWorkGroupDetailsMst (NOLOCK)  where WorkGroupCode ='W3' and isdeleted=0);




select  snf.SNFDate,  wo.WorkOrderId,sr.ServiceRequestId, ar.AssetRegisterId, sr.RequestNo, sr.[DateTime]
,wo.MaintenanceWorkDateTime as RequestDate, al.FieldValue as TypeofReq,alt.FieldValue as MaintenanceType 
,ar.AssetNo, sr.Details, fs.StaffName, 'No' Underwarranty, '' AssetProcessStatus,'' VariationStatus
, wa.ResponseDateTime
, Datediff(Minute,MaintenanceWorkDateTime,wa.ResponseDateTime) as ResponseDuration
,cast(null as datetime) ProvisionDate,cast(null as datetime) as EndDateTime, wc.EndDateTime as ActualCompletionDate
,  case when wc.EndDateTime is not null and  wc.EndDateTime <=@lastdate  then wc.EndDateTime else @lastdate end CompletionDate, ar.AssetTypeCodeId, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus
,ar.AssetClassification, typedec.AssetTypeDescription as AssetDescription
, wg.WorkGroupCode
, wg.WorkGroupDescription
, fua.UserAreaName
, fua.UserAreaCode
,Case when ar.AssetClassification = 2324  --or ar.AssetClassification='Building'-- --Building
		  then  (
			Select  Count(distinct eul.EngUserAreaId)
			from 
			EngAssetRegisterLocationMst eul
			Where eul.AssetRegisterId = ar.AssetRegisterId 
			
		  )
	 When ar.AssetClassification = 2297 --or ar.AssetClassification='System'-- --System
		  then (
		  Select  Count( distinct se.UserAreaId)
			from 
			EngAssetRegisterServingAreaMst se
			Where se.AssetRegisterId = ar.AssetRegisterId 
		   
		  ) 
         END as 'CountOfServingArea'
,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
--,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
, DATEDIFF(DAY, 
	(CASE WHEN Cast(wo.MaintenanceWorkDateTime as date) <@StartDate THEN @StartDate ELSE Cast(wo.MaintenanceWorkDateTime as date) END)
	,cast(ISNULL( case when wc.EndDateTime is not null and  wc.EndDateTime <=@lastdate  then wc.EndDateTime else @lastdate end,@lastdate) as date))+1 F1,
	case when  sr.datetime  <=@startdate then @startdate else sr.datetime  end   as Startdatetime1,
	case when wc.EndDateTime is not null and  wc.EndDateTime <=@lastdate  then wc.EndDateTime else @lastdate end  as Enddatetime1,
				cast( case when  sr.datetime  <=@startdate then @startdate else sr.datetime  end  as date) as Startdate1,
				cast( case when wc.EndDateTime is not null and  wc.EndDateTime <=@lastdate  then wc.EndDateTime else @lastdate end as date) as Enddate1
INTO #tmpWorkOrdersF1
from EngMaintenanceWorkOrderTxn wo (NOLOCK)
inner join EngAssetRegisterMst ar (NOLOCK) on wo.AssetRegisterId = ar.AssetRegisterId
INNER JOIN GmWorkGroupDetailsMst AS wg (NOLOCK) on ar.WorkGroupId = wg.WorkGroupId	
inner join SrServiceRequestMst sr (NOLOCK) on wo.ServiceRequestId = sr.ServiceRequestId
inner join AsisSysLovMst al (NOLOCK) on wo.MaintenanceWorkCategory = al.LovId
inner join AsisSysLovMst alt (NOLOCK) on wo.[Type] = alt.LovId
inner join FmsStaffMst fs (NOLOCK) on sr.FmsStaffMstId = fs.StaffMasterId
LEFT JOIN EngUserLocationMst eul (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId
LEFT JOIN FmsUserLocationMst ful (NOLOCK) ON eul.UserLocationId = ful.UserLocationId
LEFT JOIN FmsUserAreaMst fua (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId	
left join EngMwoAssesmentTxn wa (NOLOCK) on wo.WorkOrderId = wa.WorkOrderId
left join EngMwoCompletionInfoTxn wc (NOLOCK) on wo.WorkOrderId = wc.WorkOrderId and wc.IsDeleted=0
LEFT Join EngAssetTypeCodeMstDet typedec (NOLOCK) on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0	
--left join #tmpBerRecommend ber on wo.AssetRegisterId = ber.AssetRegisterId	--and cast(wo.MaintenanceWorkDateTime as date) < cast(ber.BerDate as date)
left join #tmpSnfAssets snf (NOLOCK) on wo.AssetRegisterId = snf.AssetRegisterId --and cast(wo.MaintenanceWorkDateTime as date) < cast(snf.SNFDate as date)
--left join #tmpAdvisoryAsset Advisory on wo.AssetRegisterId = Advisory.AssetRegisterId --and cast(wo.MaintenanceWorkDateTime as date) < cast(Advisory.AdvisoryDate as date)
where wo.ServiceId=@serviceid and wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
and wo.MaintenanceWorkCategory = 2357
and cast(wo.MaintenanceWorkDateTime as date)<=@lastdate
and ar.AssetStatus = 127 and ar.[Authorization]=4799
--and ar.WarrantyEndDate<@LastDate
--AND (ar.AssetClassification in (2325,2326) or  ar.WarrantyEndDate<@LastDate)
AND (ar.AssetClassification in (2325,2326) or  ( ar.WarrantyEndDate<@LastDate  or (ar.WarrantystartDate is null and  ar.WarrantyEndDate is null) ) )
and ((wc.EndDateTime is null OR wc.EndDateTime>@LastDate) or (year(wc.EndDateTime) = @year and MONTH(wc.EndDateTime)=@month))
and wo.IsDeleted = 0 and ar.IsDeleted = 0 and sr.IsDeleted = 0 and al.IsDeleted = 0 and alt.IsDeleted = 0 
and wo.WorkOrderStatus not in  (2315,5887)
----and not exists ( select 1 from  #tmpBerRecommend ta where ta.AssetRegisterId= ar.AssetRegisterId) 
--and ar.AssetRegisterId not in (select AssetRegisterId from #tmpBerRecommend)
----and not exists ( select 1 from  #tmpAdvisoryAsset ta where ta.AssetRegisterId= ar.AssetRegisterId)
--AND ar.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpAdvisoryAsset)
--AND ar.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpSnfAssets)	
----and not exists ( select 1 from  #TechSupportObsolete ta where ta.AssetRegisterId= ar.AssetRegisterId)
--AND ar.AssetRegisterId not in (select AssetRegisterId from #TechSupportObsolete)
and (SNFDate is null or cast([DateTime] as date) < cast(SNFDate as date))
AND wo.type not in (2859)



		/* Loan Provider  Start */


		SELECT DISTINCT t.WorkOrderId, LP.ProcessStatusId,  ProvideLoaner , 0 as AlternativeServiceProvided, lp.ProvisionDateTime LPStartDate, case when lp.EndDateTime > @lastdate then @lastdate else isnull(lp.EndDateTime,@lastdate) end  LPEndDate 	
		INTO #tmpLP1
		FROM #tmpWorkOrdersF1 t 
		INNER JOIN EngMwoCompletionInfoTxn wc (NOLOCK) ON t.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
		INNER JOIN EngMwoProcessStatusTxnDet wp (NOLOCK) ON wc.CompletionInfoId = wp.CompletionInfoId AND wp.IsDeleted=0 
		outer apply (select top 1 lp1.ProcessStatusId  , lp1.ProvisionDateTime, lp1.EndDateTime from  EngMwoProcessStatusLpTxnDet lp1 where  wp.ProcessStatusId = lp1.ProcessStatusId  AND lp1.IsDeleted=0   order by lp1.ProcessStatusLpId desc ) lp
		where  wp.AssetProvided = 692 AND wp.ProvideLoaner = 1


		SELECT DISTINCT t.WorkOrderId, alt.ProcessStatusId , 0 as ProvideLoaner,AlternativeServiceProvided , alt.StartDateTime ALTStartDate, case when alt.EndDateTime  > @lastdate then @lastdate else isnull(alt.EndDateTime ,@lastdate) end ALTEndDate
		INTO #tmpALT1
		FROM #tmpWorkOrdersF1 t 
		INNER JOIN EngMwoCompletionInfoTxn wc (NOLOCK) ON t.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
		INNER JOIN EngMwoProcessStatusTxnDet wp (NOLOCK) ON wc.CompletionInfoId = wp.CompletionInfoId AND wp.IsDeleted=0 
		outer apply (select top 1 alt1.ProcessStatusId,alt1.StartDateTime, alt1.EndDateTime from  EngMwoProcessStatusAspTxnDet alt1 (NOLOCK)  where  wp.ProcessStatusId = alt1.ProcessStatusId  AND alt1.IsDeleted=0   order by alt1.ProcessStatusAspId desc ) alt
		--LEFT JOIN EngMwoProcessStatusAspTxnDet alt ON wp.ProcessStatusId = alt.ProcessStatusId 
		where  wp.AssetProvided = 692 AND wp.AlternativeServiceProvided = 1
	
			
		select wo.AssetRegisterId,wo.workorderid,wo.Startdatetime1 as Startdatetime,wo.Enddatetime1 as Enddatetime,wo.startdate1 as startdate,wo.enddate1 as enddate,LP.ProcessStatusId as LPProcessStatusId,ALT.ProcessStatusId as ALTProcessStatusId,lp.ProvideLoaner,alt.AlternativeServiceProvided,
				Lp.LPStartDate,Lp.LPEndDate,ALT.ALTStartDate,ALT.ALTEndDate
		into #tmpWorkOrdersF1_NONLOAN
		from #tmpWorkOrdersF1 wo 
		left join #tmpLP1 LP  on LP.WorkOrderId = wo.WorkOrderId
		left join #tmpALT1 ALT  on ALT.WorkOrderId = wo.WorkOrderId
		where  ( LP.ProcessStatusId is null and ALT.ProcessStatusId  is null)


			
		select wo.AssetRegisterId,wo.workorderid,wo.Startdatetime1 as Startdatetime,wo.Enddatetime1 as Enddatetime,wo.startdate1 as startdate,wo.enddate1 as enddate,LP.ProcessStatusId as LPProcessStatusId,ALT.ProcessStatusId as ALTProcessStatusId,lp.ProvideLoaner,alt.AlternativeServiceProvided,
				Lp.LPStartDate,Lp.LPEndDate,ALT.ALTStartDate,ALT.ALTEndDate
		into #tmpWorkOrdersF1_LOAN
		from #tmpWorkOrdersF1 wo 
		left join #tmpLP1 LP  on LP.WorkOrderId = wo.WorkOrderId
		left join #tmpALT1 ALT  on ALT.WorkOrderId = wo.WorkOrderId
		where  ( LP.ProcessStatusId is not null or ALT.ProcessStatusId  is not null)



		select a.AssetRegisterId,a.workorderid,b.ProcessStatusId ,a.Startdatetime,a.Enddatetime,a.startdate,a.enddate,b.ProvisionDateTime as LSTARTdate,  --dateadd(HOUR,-5 , a.Enddatetime ) as LENDdate,
				isnull(b.EndDateTime,@LastDate) as  LENDdate,
				1 LoanType 
		into #tmpWorkOrdersF1_LOAN_1
		from #tmpWorkOrdersF1_LOAN a
		join EngMwoProcessStatusLpTxnDet b (NOLOCK) on   a.LPProcessStatusId=b.ProcessStatusId  and b.IsDeleted = 0
		union all		
		select 	a.AssetRegisterId,a.workorderid,b.ProcessStatusId,a.Startdatetime,a.Enddatetime,a.startdate,a.enddate,b.StartDateTime as LSTARTdate,
				isnull(b.enddatetime,@LastDate) as  LENDdate,
				2 LoanType 
		from #tmpWorkOrdersF1_LOAN a
		join EngMwoProcessStatusAspTxnDet b (NOLOCK) on  a.ALTProcessStatusId=b.ProcessStatusId  and b.IsDeleted = 0

	
		;with CTE_days as 
		(
		select DATEFROMPARTS ( @year,@month,1) as Days 
		union all
		select dateadd(d,1,Days) from CTE_days where Days < EOMONTH(DATEFROMPARTS ( @year,@month,1))
		)	
		select Days, 1 as Eligible_Days into #Temp_Days from CTE_days


		select distinct a.AssetRegisterId,a.workorderid, t.Days,
		case when  DATEDIFF(HOUR,Startdatetime,LSTARTdate)<=12  or  
						t.days between	case when datepart(hour,LSTARTdate)> 10 then  cast(LSTARTdate+1  as date) else   cast(LSTARTdate  as date) end 
								and		case when  dateadd(HOUR,+3 , a.LENDdate )   <  Enddatetime  then cast ( LENDdate-1 as date) else cast ( LENDdate as date)  end
			 then	0 
			 else	t.Eligible_Days 
		end  as Demert_days	
		into #loan_records
		from #tmpWorkOrdersF1_LOAN_1 a
		cross join  #Temp_Days t
		where t.days between   a.startdate and a.enddate

		/*  remove duplicate dates  */

		;with CTE as
		(
		select row_number() over (partition  by AssetRegisterId,workorderid,Days order by Days ) as sno,* from #loan_records
		)
		delete  a from   #loan_records a join CTE c on a.AssetRegisterId=c.AssetRegisterId and a.workorderid=c.workorderid and a.Days=c.Days
		where c.sno=2

		delete  a from   #loan_records a where Demert_days=0


	/* Loan Provider  END */
	

	/* Overlapping workorder Start  */

		  select AssetRegisterId,min(workorderid) as workorderid, Startdate,enddate into #tmp_ForOverlapping from #tmpWorkOrdersF1_NONLOAN 		 
		  group by AssetRegisterId,Startdate,enddate
		  order by enddate desc
 

		  ---For remove overlapwith in another workorder
		  select distinct a.AssetRegisterId ,a.WorkOrderId,a.Startdate,a.enddate into #overlapwithin_notrequired 
		  from #tmp_ForOverlapping a 
		  left join #tmp_ForOverlapping b  on a.AssetRegisterId = b.AssetRegisterId 
		  and a.WorkOrderId<>b.WorkOrderId and ( a.Startdate between b.Startdate and b.enddate  and a.enddate between b.Startdate and b.enddate )
		  where b.WorkOrderId is not null

         create table #overlapwithin_notrequiredWO(assetregisterid int, workorderid int, startdate date, enddate date, OverlapedWOId int) 
		 insert into #overlapwithin_notrequiredWO (assetregisterid, workorderid, startdate, enddate)
		  select assetregisterid, workorderid, startdate, enddate from #overlapwithin_notrequired

		 select assetregisterid,workorderid,startdate,enddate,ROW_NUMBER() over (partition by assetregisterid order by enddate desc) as 'sortOrder' into #overlapMain
		  from #tmp_ForOverlapping n where n.workorderid not in ( select workorderid from  #overlapwithin_notrequired) order by n.enddate desc

 
         UPDATE	WONotReq SET
					WONotReq.OverlapedWOId =(select top 1 Main.workorderid from #overlapMain Main where WONotReq.AssetRegisterId = Main.AssetRegisterId and WONotReq.startdate > Main.startdate  order by sortOrder)
			FROM	#overlapwithin_notrequiredWO AS WONotReq

		  -- days after overlapping
		  ;with CTE_completedays
		  as
		  (
		  SELECT AssetRegisterId,WorkOrderId,Startdate,enddate,LAG(dateadd(day,1,enddate)) OVER (partition by AssetRegisterId ORDER BY AssetRegisterId,Startdate) stdate1 
		  FROM #tmp_ForOverlapping 
		  WHERE WorkOrderId not in (select WorkOrderId from #overlapwithin_notrequired)
		  )
		  select AssetRegisterId,WorkOrderId,case when Startdate <= stdate1 then stdate1 else Startdate end as stdate,  enddate
		  into #completedays
		  from CTE_completedays  
  
	 

		  --update #completedays set  stdate = '2018-02-03'
		  --where workorderid=14818788

		  update #loan_records set Demert_days = 0 
		  from #loan_records  a join #completedays b on a.AssetRegisterId = b.AssetRegisterId and a.Days between stdate and Enddate

			
		  select AssetRegisterId,workorderid, stdate, enddate, datediff(day,stdate,enddate)+1 as demerit 
		  into #DEmerit_final
		  from #completedays 
		  union all 
		  select AssetRegisterId,workorderid, min(Days) as stdate, max(Days) as enddate, count(days) as demerit from #loan_records where Demert_days=1
		  group by AssetRegisterId,workorderid
		  order by AssetRegisterId






create table #tmpWorkOrder(
		  WorkOrderId int
		 , AssetRegisterId int
		, ServiceRequestId int
		, RequestNo varchar(100)
		, Details varchar(1000)
		, RequestDate datetime
		, ResponseDateTime datetime
		, ResponseDuration int
		, F1DemeritPoint int
		, F4DemeritPoint int
		, F5DemeritPoint int
		, F7DemeritPoint int
		, CompletedDateTime datetime
		, TypeofRequest varchar(100)
		, RequestorName varchar(100)
		, UserLocationId int
		, FmsUserAreaId int
		, AssetNo varchar(100)
		, AssetTypeCodeId int
		, PurchaseCostRM decimal(12,2)
		, WarrantyEndDate datetime
		, AssetStatus varchar(100)
		, AssetClassification  varchar(100)
		, AssetProcessStatus varchar(100)
		, AssetDescription varchar(1000)
		, Workgroup varchar(100)
		, BuildingNo varchar(100)
		, UserAreaName varchar(100)
		,CountOfServingArea int
		, ProvideLoaner varchar(10)
		, MaintenanceType varchar(100)
		, provisionDate datetime
		, EndDateTime datetime
		, ExcludeDemerit varchar(10)
		,reason  varchar(2000)
		)

--select * from #tmpWorkOrdersF1
INSERT INTO #tmpWorkOrder
select --* 
		wo.WorkOrderId
		,wo.AssetRegisterId
		, wo.ServiceRequestId
		, wo.RequestNo
		, wo.Details
		, wo.RequestDate 
		, wo.ResponseDateTime 
		, wo.ResponseDuration
		--, ResponseDuration
		--, case when t.workorderid is not null then cast(0 as int) else cast(isnull(wo.F1,0) as int) end	AS F1DemeritPoint
		, case when ar.AssetClassification=2297 then 
				isnull(t.demerit,0)*isnull((select case when count(distinct UserAreaId)> 0 then count(distinct UserAreaId)else 1 end from EngAssetRegisterServingAreaMst where AssetRegisterId=ar.AssetRegisterId),1)
				else isnull(t.demerit,0) end  as F1DemeritPoint
		, 0 F4DemeritPoint
		, 0 F5DemeritPoint
		, 0 F7DemeritPoint
		, wo.ActualCompletionDate as CompletedDateTime
		, TypeofReq as TypeofRequest
		, StaffName	as RequestorName
		, null UserLocationId
		, null FmsUserAreaId
		, wo.AssetNo
		, wo.AssetTypeCodeId 
		, wo.PurchaseCostRM
		, wo.WarrantyEndDate
		, wo.AssetStatus
		, a.fieldvalue as AssetClassification 
		,'-' AssetProcessStatus
		, wo.AssetDescription
		,wo.WorkGroupDescription as Workgroup
		,wo.BuildingNo
		,wo.UserAreaName
	
		,Case when wo.AssetClassification = 2324 --or wo.AssetClassification='Building'-- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = wo.AssetRegisterId 
			
				  )
				When wo.AssetClassification = 2297 --or wo.AssetClassification='System' -- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = wo.AssetRegisterId 
					
		  ) END as 'CountOfServingArea'
		--, CASE WHEN wo.ProvisionDate is not null THEN 'Yes'  ELSE  'No'END AS ProvideLoaner
		 , CASE WHEN EXISTS (SELECT  
			WOt.WorkOrderId
					FROM EngMaintenanceWorkOrderTxn Wot (NOLOCK)
					Left JOIN EngMwoCompletionInfoTxn wc (NOLOCK) ON Wot.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
					LEft JOIN EngMwoProcessStatusTxnDet wp (NOLOCK) ON wc.CompletionInfoId = wp.CompletionInfoId AND wp.IsDeleted=0 
					where  wp.AssetProvided = 692 AND wp.ProvideLoaner = 1 and Wot.WorkOrderId=wo.WorkOrderId
					)
				   THEN 'Yes' 
				   ELSE 'No'
			  END AS ProvideLoaner  
		, MaintenanceType
		, format(wo.provisionDate,'dd-MMM-yyyy') as provisionDate
		, format(wo.EndDateTime,'dd-MMM-yyyy') as EndDateTime
		--, case when t.workordercount>1 then 'Yes' ELSE 'No' END ExcludeDemerit
		--, case when SumDates>MinMaxDates then 'Yes' ELSE 'No' END ExcludeDemerit
		--, case when t.workorderid is not null then 'Yes' ELSE 'No' END ExcludeDemerit
		,case when t.WorkOrderId is null then 'Yes' else 'No' end as ExcludeDemerit,
		case when t.WorkOrderId is null and exists (select 1 from #loan_records l where l.WorkOrderId = wo.WorkOrderId) then 'Loaner'
		 when t.WorkOrderId is null and not exists (select 1 from #loan_records l where l.WorkOrderId = wo.WorkOrderId) then 'NA'--'Service Work' + '-' + wo.RequestNo
		 when wo.WorkOrderId in (select workorderid from #overlapwithin_notrequiredWO l where l.WorkOrderId = wo.WorkOrderId) then 'Overlapped Service Work' + '-' +(select top 1 RequestNo from #tmpWorkOrdersF1 a where a.WorkOrderId = (select OverlapedWOId from #overlapwithin_notrequiredWO where workorderid = wo.WorkOrderId and  OverlapedWOId is not null))		 
		 when t.AssetRegisterId is not null and  exists (select 1 from #tmpSnfAssets l where l.AssetRegisterId = wo.AssetRegisterId) then 'Variation Status V2, V4 or V5'
		  when t.AssetRegisterId is not null and  exists (select 1 from #tmpAdvisoryAsset l where l.AssetRegisterId = wo.AssetRegisterId) then 'Exemption Approved from Advisory service'
		  when t.AssetRegisterId is not null and  exists (select 1 from #TechSupportObsolete l where l.AssetRegisterId = wo.AssetRegisterId) then 'Technical Support Letter Obsolete'
		when t.AssetRegisterId is not null and  exists (select 1 from  #tmpBerRecommend l where l.AssetRegisterId = wo.AssetRegisterId) then 'BER Recommended Assets'
		 else null end reason
		-- select *
from #tmpWorkOrdersF1 wo
join EngAssetRegisterMst ar (NOLOCK) on ar.AssetRegisterId=wo.AssetRegisterId
inner join asissyslovmst a on wo.AssetClassification = a.LovId
left join #DEmerit_final t on wo.WorkOrderId = t.WorkOrderId








--LEFT JOIN #tmpOverlappingWO t on t.assetregisterid=wo.assetregisterid
--LEFT JOIN #tmpUnderOverlap t ON t.workorderid=wo.workorderid
--where MaintenanceType <> 'Warranty Breakdown'

--select * from #tmpTotalDays

		--INSERT INTO #tmpWorkOrder
		--Select 0 WorkOrderId
		--,ar.AssetRegisterId
		--, sr.ServiceRequestId
		--, n.NCRNo as RequestNo
		--, sr.Details
		--, sr.[DateTime] as RequestDate
		--, fb.ResponseDateTime 
		--, DATEDIFF(MINUTE,sr.[DateTime],fb.ResponseDateTime) as ResponseDuration
		--, cast(COUNT(1) as int) as F1DemeritPoint
		--, 0 F4DemeritPoint
		--, cast(0 as int) F5DemeritPoint
		--, 0 F7DemeritPoint
		--, fb.CompletedDateTime
		--, lov.FieldValue as TypeofRequest
		--, req.StaffName+'/'+lpos.FieldValue as RequestorName
		--, ful.UserLocationId
		--, fua.FmsUserAreaId
		--, ar.AssetNo
		--, ar.AssetTypeCodeId 
		--, ar.PurchaseCostRM
		--, ar.WarrantyEndDate
		--, ar.AssetStatus
		--, asl.FieldValue as AssetClassification --, ar.AssetClassification  
		--, isnull(dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
  --      order by ProcessStatusId desc),0)),'-') AS AssetProcessStatus
		----, ar.AssetDescription
		--,typedec.AssetTypeDescription as AssetDescription
		--, '' as Workgroup
		--, '' As BuildingNo
		--,fua.UserAreaName
		--, 'No' ProvideLoaner
		--, '' MaintenanceType
		--, '' provisionDate
		--, '' EndDateTime
		--, 'No' ExcludeDemerit
		--FROM FmsNCREntryTxn AS n 
		--INNER JOIN SrServiceRequestMst AS sr  on n.ServiceRequestId = sr.ServiceRequestId
		--INNER JOIN EngAssetRegisterMst AS ar  on ar.AssetRegisterId = sr.AssetRegisterId
		--INNER JOIN DedIndicatorMstDet AS d  on d.IndicatorDetId = n.IndicatorDetId
		--LEFT JOIN AsissyslovMst AS asl ON ar.AssetClassification = asl.LovId
		--LEFT JOIN SrServiceRequestFemsBemsTxn fb  on sr.ServiceRequestId = fb.ServiceRequestId
		--LEFT JOIN AsisSysLovMst lov  ON fb.TypeOfRequest = lov.LovId AND lov.IsDeleted = 0
		--LEFT JOIN FmsStaffMst req  ON sr.FmsStaffMstId= req.StaffMasterId AND req.IsDeleted = 0 
		--LEFT JOIN FmsStaffPositionMstDet dsg  ON req.StaffMasterId=dsg.StaffMasterId AND dsg.IsDeleted=0
		--LEFT JOIN AsisSysLovMst lpos  ON dsg.CurrentPosition = lpos.LovId AND lpos.IsDeleted = 0		
		--LEFT JOIN EngUserLocationMst eul  ON ar.EngUserLocationId = eul.EngUserLocationId
		--LEFT JOIN FmsUserLocationMst ful  ON eul.UserLocationId = ful.UserLocationId
		--LEFT JOIN FmsUserAreaMst fua  ON ful.FmsUserAreaId = fua.FmsUserAreaId
		--LEFT Join EngAssetTypeCodeMstDet typedec on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0			
		--WHERE d.IndicatorNo='F.1'
		--AND n.[Service] = @serviceID
		--AND n.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		--AND MONTH(n.NCRDateTime) = @month
		--AND YEAR(n.NCRDateTime) = @year
		--AND sr.[Status] != 2315 
		----AND @lastdate > ar.WarrantyEndDate 
		----and ar.WarrantyEndDate<=@LastDate
		--AND n.IsDeleted = 0 AND sr.IsDeleted = 0 AND ar.IsDeleted = 0 AND d.IsDeleted = 0
		
		--GROUP BY sr.ServiceRequestId, ar.AssetRegisterId, n.NCRNo, sr.Details, sr.[DateTime]
		--, fb.ResponseDateTime , sr.[DateTime], fb.CompletedDateTime, lov.FieldValue, req.StaffName
		--, lpos.FieldValue, ful.UserLocationId, fua.FmsUserAreaId, ar.AssetNo, ar.AssetTypeCodeId 
		--, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus, ar.AssetClassification 
		--,asl.FieldValue	,typedec.AssetTypeDescription,fua.UserAreaName,ar.AssetRegisterId


		--=============================================================================================--
		--								FEMS Indicator - F4											 ----
		--=============================================================================================--

		------ Demerit Point (H)
		

		--select wo.WorkOrderId
		--	, sr.ServiceRequestId -- must
		--	, sr.RequestNo
		--	, sr.Details
		--	, sr.[DateTime] as RequestDate
		--	,  wa.ResponseDateTime  
		--	, DATEDIFF(MINUTE,sr.[DateTime],ISNULL(wa.ResponseDateTime,@lastdate)) as ResponseDuration
		--	, 0 F1DemeritPoint
		--	, count(*) as F4DemeritPoint		
		--	, 0 F5DemeritPoint
		--	, 0 F7DemeritPoint
		--	, ISNULL(wc.EndDateTime,@LastDate) as CompletedDateTime
		--	, a12.FieldValue as TypeofRequest
		--	, '' as RequestorName
		--	, 0 UserLocationId
		--	, 0 FmsUserAreaId
		--	, ar.AssetNo
		--	, ar.AssetTypeCodeId 
		--	, ar.PurchaseCostRM
		--	, ar.WarrantyEndDate
		--	, ar.AssetStatus
		--	, ar.AssetClassification 
		--	, '' AS AssetProcessStatus 
		--INTO #tmpWorkOrderF4
		--from EngMaintenanceWorkOrderTxn wo		
		--INNER JOIN dbo.EngAssetRegisterMst AS ar  ON ar.AssetRegisterId=wo.AssetRegisterId 
		--												and ar.IsDeleted=0 and ar.[Authorization]=4799 and ar.AssetStatus=127
		--INNER JOIN dbo.AsisSysLovMst AS A12  ON wo.MaintenanceWorkCategory=A12.LovId and a12.IsDeleted=0
		--left join EngMwoAssesmentTxn wa on wo.WorkOrderId = wa.WorkOrderId and wa.IsDeleted=0
		--LEFT JOIN SrServiceRequestMst sr on wo.ServiceRequestId = sr.ServiceRequestId and sr.IsDeleted = 0
		--left join EngMwoCompletionInfoTxn wc on wo.WorkOrderId = wc.WorkOrderId and wc.IsDeleted = 0
		--where wo.ServiceId = @serviceid and wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		--and wo.IsDeleted = 0 and wo.WorkOrderStatus !=2315
		--and MaintenanceWorkCategory = 2357 --and wo.Type in (2856,2857,2858,2859)
		--and (wa.ResponseDateTime is null or (month(wa.ResponseDateTime)=@month and year(wa.ResponseDateTime) = @year))
		----and (wc.EndDateTime is null or (month(wc.EndDateTime)=9 and year(wc.EndDateTime) = 2016))
		--and wo.MaintenanceWorkDateTime<=@lastdate
		-- AND wo.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpSnfAssets)	
		-- -- demerit
		-- AND wo.Priority in (SELECT LovId FROM AsisSysLovMst  WHERE LovKey='CLOPriorityValue' 
		--										AND ((FieldValue='Normal' AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@lastdate))  >120) 
		--										OR (FieldValue='Emergency' AND DATEDIFF(MINUTE,wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@lastdate)) >15) ))
		----AND wo.AssetClassification in (SELECT LovId FROM AsissyslovMst WHERE Lovkey='AssetClassificationValue' and FieldValue in ('System','Equipment & Vehicles'))
		----AND wo.AssetRegisterId not in (select AssetRegisterId from #tmpBerRecommend)
		--GROUP BY wo.WorkOrderId, sr.ServiceRequestId, sr.RequestNo, sr.Details, sr.[DateTime]
		--	, ResponseDateTime, ResponseDuration, ar.AssetNo, ar.AssetTypeCodeId 
		--	, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus, ar.AssetClassification, wc.EndDateTime,a12.FieldValue




	-------------------------------------#tmpWorkOrderF4--------------------------------------------2856--Breakdown Repairs /--2857--Corrective Maintenance--------------------------------------------------------------------------------------------------------------------------------
			select wo.WorkOrderId
			,ar.AssetRegisterId
			, sr.ServiceRequestId -- must
			, sr.RequestNo
			, sr.Details
			, wo.MaintenanceWorkDateTime as RequestDate
			,  wa.ResponseDateTime  
			, DATEDIFF(MINUTE,wo.MaintenanceWorkDateTime,wa.ResponseDateTime) as ResponseDuration
			, 0 F1DemeritPoint
			, count(*) as F4DemeritPoint		
			, 0 F5DemeritPoint
			, 0 F7DemeritPoint
			, ISNULL(wc.EndDateTime,@LastDate) as CompletedDateTime
			, a12.FieldValue as TypeofRequest
			, fs.StaffName as RequestorName
			, 0 UserLocationId
			, 0 FmsUserAreaId
			, ar.AssetNo
			, ar.AssetTypeCodeId 
			, ar.PurchaseCostRM
			, ar.WarrantyEndDate
			, ar.AssetStatus
			, typedec.AssetTypeDescription as AssetDescription
			, a.FieldValue as AssetClassification 
			, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst (NOLOCK) where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
        order by ProcessStatusId desc),0)) AS AssetProcessStatus
			, fua.UserAreaName
		
			,Case when ar.AssetClassification = 2324 --or ar.AssetClassification='Building' -- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = ar.AssetRegisterId 
			
				  )
				When ar.AssetClassification = 2297 --or ar.AssetClassification='System'-- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = ar.AssetRegisterId 
					
		  ) END as 'CountOfServingArea'
			, alt.FieldValue as MaintenanceType
			, wg.WorkGroupDescription
			--,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
			,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 

		INTO #tmpWorkOrderF4
		from EngMaintenanceWorkOrderTxn wo	(NOLOCK)	
		INNER JOIN dbo.EngAssetRegisterMst AS ar (NOLOCK) ON ar.AssetRegisterId=wo.AssetRegisterId 
														and ar.IsDeleted=0 and ar.[Authorization]=4799 and ar.AssetStatus=127
		LEFT JOIN GmWorkGroupDetailsMst AS wg (NOLOCK) on ar.WorkGroupId = wg.WorkGroupId and wg.IsDeleted = 0
		INNER JOIN dbo.AsisSysLovMst AS A12 (NOLOCK) ON wo.MaintenanceWorkCategory=A12.LovId and a12.IsDeleted=0
		inner join AsisSysLovMst alt (NOLOCK) on wo.[Type] = alt.LovId and alt.IsDeleted = 0
		left join EngMwoAssesmentTxn wa (NOLOCK) on wo.WorkOrderId = wa.WorkOrderId and wa.IsDeleted=0
		LEFT JOIN SrServiceRequestMst sr (NOLOCK) on wo.ServiceRequestId = sr.ServiceRequestId and sr.IsDeleted = 0
		left join FmsStaffMst fs (NOLOCK) on fs.StaffMasterId = sr.FmsStaffMstId --and fs.IsDeleted = 0
		left join EngMwoCompletionInfoTxn wc (NOLOCK) on wo.WorkOrderId = wc.WorkOrderId and wc.IsDeleted = 0
		LEFT JOIN EngUserLocationMst eul (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId
		LEFT JOIN FmsUserLocationMst ful (NOLOCK) ON eul.UserLocationId = ful.UserLocationId
		LEFT JOIN FmsUserAreaMst fua (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId	
		inner join asissyslovmst a (NOLOCK) on ar.AssetClassification = a.LovId
		LEFT Join EngAssetTypeCodeMstDet typedec (NOLOCK) on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0
		where wo.ServiceId = @serviceid and wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and wo.IsDeleted = 0 and wo.WorkOrderStatus not in  (2315,5887)
		and MaintenanceWorkCategory = 2357 --and wo.Type in (2856,2857,2858,2859)
		--and convert(varchar(6),wo.MaintenanceWorkDateTime,112) = convert(varchar(6),@StartDate,112)
		and month(wo.MaintenanceWorkDateTime)=@month and year(wo.MaintenanceWorkDateTime) = @year
		--AND ((wa.ResponseDateTime IS NULL )  or (month(wa.ResponseDateTime)=@month and year(wa.ResponseDateTime) = @year))
		--and (wc.EndDateTime is null or (month(wc.EndDateTime)=9 and year(wc.EndDateTime) = 2016))
		and wo.MaintenanceWorkDateTime<=@LastDate
		-- AND wo.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpSnfAssets)	
		 ----AND not exists (SELECT 1 FROM #tmpSnfAssets ta where ta.AssetRegisterId= wo.AssetRegisterId  )	
		 -- demerit
		 AND ((wo.Priority = 676 AND wo.Type in (2856,2857) AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >15)
		OR (wo.Priority = 675 AND wo.Type in (2856,2857) AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >120))
		 --AND wo.Priority in (SELECT LovId FROM AsisSysLovMst  WHERE LovKey='CLOPriorityValue' 
			--									AND (wo.Type in(SELECT LovId FROM AsisSysLovMst  WHERE LovKey='UnScheduledTypeValue' AND (FieldValue='Corrective Maintenance' OR FieldValue='Breakdown Repairs')) 
			--									AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >120 ) )

		--AND wo.AssetClassification in (SELECT LovId FROM AsissyslovMst WHERE Lovkey='AssetClassificationValue' and FieldValue in ('System','Equipment & Vehicles'))
		--AND wo.AssetRegisterId not in (select AssetRegisterId from #tmpBerRecommend)
		GROUP BY wo.WorkOrderId, ar.AssetRegisterId,sr.ServiceRequestId, sr.RequestNo, sr.Details, sr.[DateTime]
			, ResponseDateTime, ResponseDuration, ar.AssetNo, ar.AssetTypeCodeId 
			, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus, ar.AssetClassification, wc.EndDateTime,a12.FieldValue,ar.WorkGroupId,typedec.AssetTypeDescription, fua.UserAreaName
			, a.FieldValue, fs.StaffName,alt.FieldValue, wg.WorkGroupDescription, wo.MaintenanceWorkDateTime,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId


			--select * from FmsStaffMst where StaffMasterId  =4791
--			select * from SrServiceRequestMst where ServiceRequestId in (913392,
--913455,
--913456,
--913457,
--914807,
--914809)


-----------------------------------------------#tmpWorkOrderF4D1--------------------------------------------------------2859-Warranty Breakdown--------------------------------------------------------------------------------------------------------------------------------

		select wo.WorkOrderId
			,ar.AssetRegisterId
			, sr.ServiceRequestId -- must
			, sr.RequestNo
			, sr.Details
			, wo.MaintenanceWorkDateTime as RequestDate
			,  wa.ResponseDateTime  
			, DATEDIFF(MINUTE,wo.MaintenanceWorkDateTime,wa.ResponseDateTime) as ResponseDuration
			, 0 F1DemeritPoint
			, count(*) as F4DemeritPoint		
			, 0 F5DemeritPoint
			, 0 F7DemeritPoint
			, ISNULL(wc.EndDateTime,@LastDate) as CompletedDateTime
			, a12.FieldValue as TypeofRequest
			, fs.StaffName as RequestorName
			, 0 UserLocationId
			, 0 FmsUserAreaId
			, ar.AssetNo
			, ar.AssetTypeCodeId 
			, ar.PurchaseCostRM
			, ar.WarrantyEndDate
			, ar.AssetStatus
			, typedec.AssetTypeDescription as AssetDescription
			, a.FieldValue as AssetClassification 
			, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
			 order by ProcessStatusId desc),0)) AS AssetProcessStatus 
			, fua.UserAreaName
		
			,Case when ar.AssetClassification = 2324 --or ar.AssetClassification='Building'-- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = ar.AssetRegisterId 
				
				  )
				When ar.AssetClassification = 2297 --or ar.AssetClassification='System' -- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = ar.AssetRegisterId 
				
		  ) END as 'CountOfServingArea'
			,alt.FieldValue as MaintenanceType
			, wg.WorkGroupDescription
			--,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
			,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
		INTO #tmpWorkOrderF4D1
		from EngMaintenanceWorkOrderTxn wo (NOLOCK)	
		INNER JOIN dbo.EngAssetRegisterMst AS ar (NOLOCK)  ON ar.AssetRegisterId=wo.AssetRegisterId 
														and ar.IsDeleted=0 and ar.[Authorization]=4799 and ar.AssetStatus=127
		LEFT JOIN GmWorkGroupDetailsMst AS wg (NOLOCK) on ar.WorkGroupId = wg.WorkGroupId and wg.IsDeleted = 0
		inner join AsisSysLovMst alt (NOLOCK) on wo.[Type] = alt.LovId and alt.IsDeleted = 0
		INNER JOIN dbo.AsisSysLovMst AS A12 (NOLOCK) ON wo.MaintenanceWorkCategory=A12.LovId and a12.IsDeleted=0
		left join EngMwoAssesmentTxn wa (NOLOCK) on wo.WorkOrderId = wa.WorkOrderId and wa.IsDeleted=0
		LEFT JOIN SrServiceRequestMst sr (NOLOCK) on wo.ServiceRequestId = sr.ServiceRequestId and sr.IsDeleted = 0
		left join FmsStaffMst fs (NOLOCK) on fs.StaffMasterId = sr.FmsStaffMstId --and fs.IsDeleted=0
		left join EngMwoCompletionInfoTxn wc (NOLOCK) on wo.WorkOrderId = wc.WorkOrderId and wc.IsDeleted = 0
				LEFT JOIN EngUserLocationMst eul (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId
		LEFT JOIN FmsUserLocationMst ful (NOLOCK) ON eul.UserLocationId = ful.UserLocationId
		LEFT JOIN FmsUserAreaMst fua (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId	
		inner join asissyslovmst a (NOLOCK) on ar.AssetClassification = a.LovId
		LEFT Join EngAssetTypeCodeMstDet typedec (NOLOCK) on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0	
		where wo.ServiceId = @serviceid and wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and wo.IsDeleted = 0 and wo.WorkOrderStatus not in  (2315,5887)
		and MaintenanceWorkCategory = 2357 --and wo.Type in (2856,2857,2858,2859)
		--and convert(varchar(6),wo.MaintenanceWorkDateTime,112) = convert(varchar(6),@StartDate,112)
		and month(wo.MaintenanceWorkDateTime)=@month and year(wo.MaintenanceWorkDateTime) = @year
		--AND ((wa.ResponseDateTime IS NULL )  or (month(wa.ResponseDateTime)=@month and year(wa.ResponseDateTime) = @year))
		--and (wc.EndDateTime is null or (month(wc.EndDateTime)=9 and year(wc.EndDateTime) = 2016))
		and wo.MaintenanceWorkDateTime<=@LastDate
		 --AND wo.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpSnfAssets)	
		 ----AND not exists(select 1 from #tmpSnfAssets ta where ta.AssetRegisterId =  wo.AssetRegisterId )
		 AND ((wo.Priority = 676 AND wo.Type in (2859) AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >15)
		OR (wo.Priority = 675 AND wo.Type in (2859) AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >120))
		 -- demerit
		 --AND wo.Priority in (SELECT LovId FROM AsisSysLovMst  WHERE LovKey='CLOPriorityValue' 
			--									AND (wo.Type in(SELECT LovId FROM AsisSysLovMst  WHERE LovKey='UnScheduledTypeValue' AND (FieldValue='Warranty Breakdown')) 
			--									AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >120 ) )
		--AND wo.AssetClassification in (SELECT LovId FROM AsissyslovMst WHERE Lovkey='AssetClassificationValue' and FieldValue in ('System','Equipment & Vehicles'))
		--AND wo.AssetRegisterId not in (select AssetRegisterId from #tmpBerRecommend)
		GROUP BY wo.WorkOrderId,  ar.AssetRegisterId,sr.ServiceRequestId, sr.RequestNo, sr.Details, sr.[DateTime]
			, ResponseDateTime, ResponseDuration, ar.AssetNo, ar.AssetTypeCodeId 
			, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus, ar.AssetClassification, wc.EndDateTime,a12.FieldValue,ar.WorkGroupId,typedec.AssetTypeDescription,fua.UserAreaName
			, a.FieldValue, fs.StaffName, alt.FieldValue, wg.WorkGroupDescription, wo.MaintenanceWorkDateTime,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId



-------------------------------------------------------------#tmpWorkOrderF4E2--------------------------------------------2858-Emergency Breakdown------------------------------------------------------------------------------------------------------------------------



			select wo.WorkOrderId
			,ar.AssetRegisterId
			, sr.ServiceRequestId -- must
			, sr.RequestNo
			, sr.Details
			, wo.MaintenanceWorkDateTime as RequestDate
			,  wa.ResponseDateTime  
			, DATEDIFF(MINUTE,wo.MaintenanceWorkDateTime,wa.ResponseDateTime) as ResponseDuration
			, 0 F1DemeritPoint
			, count(*) as F4DemeritPoint		
			, 0 F5DemeritPoint
			, 0 F7DemeritPoint
			, ISNULL(wc.EndDateTime,@LastDate) as CompletedDateTime
			, a12.FieldValue as TypeofRequest
			, fs.StaffName as RequestorName
			, 0 UserLocationId
			, 0 FmsUserAreaId
			, ar.AssetNo
			, ar.AssetTypeCodeId 
			, ar.PurchaseCostRM
			, ar.WarrantyEndDate
			, ar.AssetStatus
			,typedec.AssetTypeDescription as AssetDescription
			, a.FieldValue as AssetClassification 
			, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst (NOLOCK)   where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
			 order by ProcessStatusId desc),0)) AS AssetProcessStatus 
			, fua.UserAreaName
		
			,Case when ar.AssetClassification = 2324 --or ar.AssetClassification='Building' -- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = ar.AssetRegisterId 
				
				  )
				When ar.AssetClassification = 2297 --or ar.AssetClassification='System' -- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = ar.AssetRegisterId 
					
		  ) END as 'CountOfServingArea'
			, alt.FieldValue as MaintenanceType
			, wg.WorkGroupDescription
			--,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
			,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
		INTO #tmpWorkOrderF4E2
		from EngMaintenanceWorkOrderTxn wo	(NOLOCK)	
		inner join AsisSysLovMst alt (NOLOCK) on wo.[Type] = alt.LovId and alt.IsDeleted = 0
		INNER JOIN dbo.EngAssetRegisterMst AS ar (NOLOCK) ON ar.AssetRegisterId=wo.AssetRegisterId 
														and ar.IsDeleted=0 and ar.[Authorization]=4799 and ar.AssetStatus=127
		LEFT JOIN GmWorkGroupDetailsMst AS wg (NOLOCK) on ar.WorkGroupId = wg.WorkGroupId	
		INNER JOIN dbo.AsisSysLovMst AS A12 (NOLOCK) ON wo.MaintenanceWorkCategory=A12.LovId and a12.IsDeleted=0
		left join EngMwoAssesmentTxn wa (NOLOCK) on wo.WorkOrderId = wa.WorkOrderId and wa.IsDeleted=0
		LEFT JOIN SrServiceRequestMst sr (NOLOCK) on wo.ServiceRequestId = sr.ServiceRequestId and sr.IsDeleted = 0
		left join FmsStaffMst fs (NOLOCK) on fs.StaffMasterId = sr.FmsStaffMstId --and fs.IsDeleted = 0
		left join EngMwoCompletionInfoTxn wc (NOLOCK) on wo.WorkOrderId = wc.WorkOrderId and wc.IsDeleted = 0
				LEFT JOIN EngUserLocationMst eul (NOLOCK)  ON ar.EngUserLocationId = eul.EngUserLocationId
		LEFT JOIN FmsUserLocationMst ful (NOLOCK) ON eul.UserLocationId = ful.UserLocationId
		LEFT JOIN FmsUserAreaMst fua (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId	
		inner join asissyslovmst a (NOLOCK) on ar.AssetClassification = a.LovId
		LEFT Join EngAssetTypeCodeMstDet typedec (NOLOCK) on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0	
		where wo.ServiceId = @serviceid and wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and wo.IsDeleted = 0 and wo.WorkOrderStatus not in  (2315,5887)
		and MaintenanceWorkCategory = 2357 --and wo.Type in (2856,2857,2858,2859)
		and month(wo.MaintenanceWorkDateTime)=@month and year(wo.MaintenanceWorkDateTime) = @year
		--and convert(varchar(6),wo.MaintenanceWorkDateTime,112) = convert(varchar(6),@StartDate,112)
		--AND ((wa.ResponseDateTime IS NULL )  or (month(wa.ResponseDateTime)=@month and year(wa.ResponseDateTime) = @year))
		--and (wc.EndDateTime is null or (month(wc.EndDateTime)=9 and year(wc.EndDateTime) = 2016))
		and wo.MaintenanceWorkDateTime<=@LastDate
		 --AND wo.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpSnfAssets)	
		 ----AND not exists (SELECT 1 FROM #tmpSnfAssets ta where   ta.AssetRegisterId = wo.AssetRegisterId)	
		 	AND ((wo.Priority = 676 AND wo.Type in (2858) AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >15)
		OR (wo.Priority = 675 AND wo.Type in (2858) AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >120))
		 -- demerit
		 --AND wo.Priority in (SELECT LovId FROM AsisSysLovMst  WHERE LovKey='CLOPriorityValue' 
			--									AND (wo.Type in(SELECT LovId FROM AsisSysLovMst  WHERE LovKey='UnScheduledTypeValue' AND (FieldValue='Emergency Breakdown')) 
			--									AND DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(wa.RespONseDateTime,@LastDate))  >15 ) )
		--AND wo.AssetClassification in (SELECT LovId FROM AsissyslovMst WHERE Lovkey='AssetClassificationValue' and FieldValue in ('System','Equipment & Vehicles'))
		--AND wo.AssetRegisterId not in (select AssetRegisterId from #tmpBerRecommend)
		GROUP BY wo.WorkOrderId,  ar.AssetRegisterId,sr.ServiceRequestId, sr.RequestNo, sr.Details, sr.[DateTime]
			, ResponseDateTime, ResponseDuration, ar.AssetNo, ar.AssetTypeCodeId 
			, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus, ar.AssetClassification, wc.EndDateTime,a12.FieldValue,ar.WorkGroupId,typedec.AssetTypeDescription,fua.UserAreaName
		, a.FieldValue, fs.StaffName, alt.FieldValue,wg.WorkGroupDescription, wo.MaintenanceWorkDateTime,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--		INSERT INTO #tmpWorkOrderF4
		--Select 0 WorkOrderId
		--,ar.AssetRegisterId
		--, sr.ServiceRequestId
		--, n.NCRNo as RequestNo
		--, sr.Details
		--, sr.[DateTime] as RequestDate
		--, n.NCRDateTime as ResponseDateTime 
		--, 0 ResponseDuration
		--, 0 F1DemeritPoint
		--, COUNT(*) as F4DemeritPoint
		--, 0 F5DemeritPoint
		--, 0 F7DemeritPoint
		--, n.NCRDateTime CompletedDateTime
		--, 'NCR' as TypeofRequest
		--, fs.StaffName as RequestorName
		--, 0 UserLocationId
		--, 0 FmsUserAreaId
		--, ar.AssetNo
		--, ar.AssetTypeCodeId 
		--, ar.PurchaseCostRM
		--, ar.WarrantyEndDate
		--, ar.AssetStatus
		--, typedec.AssetTypeDescription as AssetDescription
		--, a.FieldValue as AssetClassification
		--, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
		--  order by ProcessStatusId desc),0)) AS AssetProcessStatus
		--, fua.UserAreaName
		--, '' MaintenanceType
		--, wg.WorkGroupDescription
		----,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo  
		--,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
		--FROM FmsNCREntryTxn AS n 
		--INNER JOIN SrServiceRequestMst AS sr  on n.ServiceRequestId = sr.ServiceRequestId
		--inner join FmsStaffMst fs on fs.StaffMasterId = sr.FmsStaffMstId --and fs.IsDeleted = 0
		--INNER JOIN EngAssetRegisterMst AS ar  on ar.AssetRegisterId = sr.AssetRegisterId		
		--LEFT JOIN GmWorkGroupDetailsMst AS wg on ar.WorkGroupId = wg.WorkGroupId	
		--INNER JOIN DedIndicatorMstDet AS d  on d.IndicatorDetId = n.IndicatorDetId
		--LEFT JOIN EngUserLocationMst eul  ON ar.EngUserLocationId = eul.EngUserLocationId
		--LEFT JOIN FmsUserLocationMst ful  ON eul.UserLocationId = ful.UserLocationId
		--LEFT JOIN FmsUserAreaMst fua  ON ful.FmsUserAreaId = fua.FmsUserAreaId	
		--inner join asissyslovmst a on ar.AssetClassification = a.LovId
		--LEFT Join EngAssetTypeCodeMstDet typedec on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0	
		--WHERE d.IndicatorNo='F.4' AND n.[Service] = @serviceID
		--AND n.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) AND MONTH(n.NCRDateTime) = @MONTH
		--AND YEAR(n.NCRDateTime) = @year
		--AND sr.[Status] != 2315 
		----and ar.WarrantyEndDate<=@LastDate
		--AND n.IsDeleted = 0 AND sr.IsDeleted = 0 AND ar.IsDeleted = 0 AND d.IsDeleted = 0
		--GROUP BY sr.ServiceRequestId, ar.AssetRegisterId, n.NCRNo, sr.Details
		--, sr.[DateTime], ar.AssetNo, ar.AssetTypeCodeId 
		--, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus
		--, ar.AssetClassification,n.NCRDateTime,ar.WorkGroupId, typedec.AssetTypeDescription, fua.UserAreaName
		--, a.FieldValue, fs.StaffName, wg.WorkGroupDescription,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO #tmpWorkOrderF4
		select 
		 0 WorkOrderId
		,ar.AssetRegisterId
		, sr.ServiceRequestId
		, sr.RequestNo as RequestNo
		, sr.Details
		, sr.[DateTime] as RequestDate
		, null ResponseDateTime 
		, 0 ResponseDuration
		, 0 F1DemeritPoint
		, 1 as F4DemeritPoint
		, 0 F5DemeritPoint
		, 0 F7DemeritPoint
		, null CompletedDateTime
		, a12.FieldValue as TypeofRequest
		, fs.StaffName as RequestorName
		, 0 UserLocationId
		, 0 FmsUserAreaId
		, ar.AssetNo
		, ar.AssetTypeCodeId 
		, ar.PurchaseCostRM
		, ar.WarrantyEndDate
		, ar.AssetStatus
		, ar.AssetDescription
		, a.FieldValue as AssetClassification
		, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
		  order by ProcessStatusId desc),0)) AS AssetProcessStatus
		, fua.UserAreaName
	
		,Case when ar.AssetClassification = 2324 --or ar.AssetClassification='Building'-- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = ar.AssetRegisterId 
			
				  )
				When ar.AssetClassification = 2297 --or ar.AssetClassification='System'-- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = ar.AssetRegisterId 
					
		  ) END as 'CountOfServingArea'
		, '' MaintenanceType
		, wg.WorkGroupDescription
		--,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo  
		,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo			
		 from SrServiceRequestMst  sr (NOLOCK)
		join EngAssetRegisterMst Ar (NOLOCK) on Ar.AssetRegisterId = sr.AssetRegisterId
		inner join asissyslovmst a (NOLOCK) on ar.AssetClassification = a.LovId
		join srServiceRequestFemsBemsTxn srd (NOLOCK) on sr.ServiceRequestId = srd.ServiceRequestId
		INNER JOIN dbo.AsisSysLovMst AS A12 (NOLOCK) ON srd.TypeOfRequest=A12.LovId and a12.IsDeleted=0
		left join EngMaintenanceWorkOrderTxn  emw (NOLOCK) on emw.ServiceRequestId = sr.ServiceRequestId and Emw.isdeleted= 0  and Emw.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and emw.ServiceId = @SERVICEID 
		left join FmsStaffMst fs (NOLOCK) on fs.StaffMasterId = sr.FmsStaffMstId --and fs.IsDeleted = 0
		--LEFT JOIN EngAssetTypeCodeMstDet eatc on ar.AssetTypeCodeId = eatc.AssetTypeCodeId
		LEFT JOIN GmWorkGroupDetailsMst AS wg (NOLOCK) on ar.WorkGroupId = wg.WorkGroupId and wg.IsDeleted = 0
		LEFT JOIN EngUserLocationMst eul (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId
		LEFT JOIN FmsUserLocationMst ful (NOLOCK) ON eul.UserLocationId = ful.UserLocationId
		LEFT JOIN FmsUserAreaMst fua (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId	
		where  month(sr.[DateTime])=@month and year(sr.[DateTime]) = @year
		--convert(varchar(6),DateTime,112)   = convert(varchar(6),@StartDate,112)
		and ar.[Authorization]=4799 
		and ar.AssetStatus=127	
		and sr.IsDeleted = 0
		and srd.IsDeleted = 0
		and srd.TypeOfRequest = 973		
		and ar.IsDeleted = 0
		and sr.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and ar.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and ar.ServiceId = @SERVICEID
		and sr.Service = @SERVICEID
		AND (ar.AssetClassification in (2325,2326) or  ar.WarrantyEndDate is not null)
		AND sr.[Status] not in  (2315,5887)
		and emw.WorkOrderId is null
	
		-----------------------------------------------------------------Equipement and System------------------------------------------------------------------------------------------------
		--INSERT INTO #ImpactedWorkGroupA
		select e.WorkOrderId
				,ar.AssetRegisterId
				, sr.ServiceRequestId -- must
				, sr.RequestNo
				, sr.Details
				, e.MaintenanceWorkDateTime as RequestDate
				,  eass.ResponseDateTime  
				, DATEDIFF(MINUTE,e.MaintenanceWorkDateTime,eass.ResponseDateTime) as ResponseDuration
				, 0 F1DemeritPoint
				, count(*) as F4DemeritPoint		
				, 0 F5DemeritPoint
				, 0 F7DemeritPoint
				, ISNULL(wc.EndDateTime,@LastDate) as CompletedDateTime
				, a12.FieldValue as TypeofRequest
				, fs.StaffName as RequestorName
				, 0 UserLocationId
				, 0 FmsUserAreaId
				, ar.AssetNo
				, ar.AssetTypeCodeId 
				, ar.PurchaseCostRM
				, ar.WarrantyEndDate
				, ar.AssetStatus
				, eatc.AssetTypeDescription as AssetDescription
				, a.FieldValue as AssetClassification 
				, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
			order by ProcessStatusId desc),0)) AS AssetProcessStatus
				, fua.UserAreaName
			
					,Case when ar.AssetClassification = 2324 --or ar.AssetClassification='Building'-- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = ar.AssetRegisterId 
			
				  )
				When ar.AssetClassification = 2297 --or ar.AssetClassification='System'-- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = ar.AssetRegisterId 
				
		  ) END as 'CountOfServingArea'
			, alt.FieldValue as MaintenanceType
			, wg.WorkGroupDescription
			--,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
			,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
			 INTO #ImpactedWorkGroupA
			FROM	dbo.EngMaintenanceWorkOrderTxn as e  (NOLOCK)				
			INNER JOIN dbo.AsisSysLovMst AS A1 (NOLOCK) ON E.Priority=A1.LovId and a1.isdeleted=0
			inner join AsisSysLovMst alt (NOLOCK) on e.[Type] = alt.LovId and alt.IsDeleted = 0
			INNER JOIN dbo.EngAssetRegisterMst AS ar  (NOLOCK) ON ar.AssetRegisterId=e.AssetRegisterId 	
			inner join asissyslovmst a (NOLOCK) on ar.AssetClassification = a.LovId			
			and ar.IsDeleted=0 and ar.[Authorization]=4799 and ar.AssetStatus=127	
			left Join SrServiceRequestMst  sr (NOLOCK) on e.ServiceRequestId = sr.ServiceRequestId and sr.IsDeleted = 0
			join srServiceRequestFemsBemsTxn srd  (NOLOCK) on sr.ServiceRequestId = srd.ServiceRequestId
			INNER JOIN dbo.AsisSysLovMst AS A12  (NOLOCK) ON srd.TypeOfRequest=A12.LovId and a12.IsDeleted=0
			left join EngMwoCompletionInfoTxn wc (NOLOCK) on e.WorkOrderId = wc.WorkOrderId and wc.IsDeleted = 0
			left join FmsStaffMst fs (NOLOCK) on fs.StaffMasterId = sr.FmsStaffMstId --and fs.IsDeleted = 0
			LEFT JOIN EngAssetTypeCodeMstDet eatc (NOLOCK) on ar.AssetTypeCodeId = eatc.AssetTypeCodeId					
			LEFT JOIN GmWorkGroupDetailsMst AS wg (NOLOCK) on ar.WorkGroupId = wg.WorkGroupId and wg.IsDeleted = 0							
			INNER  JOIN EngMwoAssesmentTxn Eass  (NOLOCK) ON Eass.WorkOrderId = E.WorkOrderId and eass.IsDeleted = 0
			LEFT JOIN EngUserLocationMst eul  (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId
			LEFT JOIN FmsUserLocationMst ful  (NOLOCK) ON eul.UserLocationId = ful.UserLocationId
			LEFT JOIN FmsUserAreaMst fua  (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId	
			--outer apply (	select PWG.workgroupid   from FmsPositionWorkGroupMst  PWG
			--join FmsStaffPositionMstDet FSP on  PWG.Position = FSP.CurrentPosition
			--where FSP.service=@serviceID and PWG.service=@serviceID and FSP.hospitalid in (select HospitalId from #GetGMHospitalMstAndGroup) 
			--and   FSP.staffmasterid=CompanyStaffMasterId and FSP.isdeleted = 0  and  PWG.isdeleted=0 --and ar.workgroupid = PWG.workgroupid 
			--and  Eass.ResponseDateTime between Fsp.effectivedate and isnull(FSP.enddate,getdate())
			--		) w
		WHERE	E.ServiceId=@SERVICEID AND E.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)   AND E.IsDeleted = 0
		and e.WorkOrderStatus not in  (2315,5887)
		AND  MONTH( E.MaintenanceWorkDateTime) = @MONTH AND YEAR( E.MaintenanceWorkDateTime) = @YEAR
		--and convert(varchar(6),E.MaintenanceWorkDateTime,112) = convert(varchar(6),@StartDate,112)
		--AND ((MONTH(Eass.ResponseDateTime)=@MONTH AND YEAR(Eass.ResponseDateTime) = @YEAR))
		AND e.MaintenanceWorkDateTime<=@LastDate
		AND E.MaintenanceWorkCategory=(SELECT LovId FROM AsisSysLovMst  WHERE LovKey='MaintenanceWorkCategoryValue' AND FieldValue='UnScheduled')
		AND ((E.Priority = 676  AND DATEDIFF(MINUTE, E.MaintenanceWorkDateTime, ISNULL(eass.RespONseDateTime,@LastDate))  <=15)
		OR (E.Priority = 675  AND DATEDIFF(MINUTE, E.MaintenanceWorkDateTime, ISNULL(eass.RespONseDateTime,@LastDate))  <=120))
		----AND not exists (SELECT 1 FROM #tmpSnfAssets ta  where ta.AssetRegisterId =  e.AssetRegisterId )		
		--AND e.AssetRegisterId NOT IN (SELECT distinct AssetRegisterId FROM #tmpSnfAssets)		
		AND  e.Type in (2856,2857,2858,2859)	
		--and not exists (select workorderid from #tmpWorkOrderF4 union select workorderid from #tmpWorkOrderF4D1 union select workorderid from #tmpWorkOrderF4E2)										
		--and ar.workgroupid != w.workgroupid 
		AND ar.WorkGroupId NOT IN
								( SELECT M.WorkGroupId FROM
								EngMaintenanceWorkOrderTxn as H  
								INNER  JOIN EngMwoAssesmentTxn J  (NOLOCK) ON J.WorkOrderId = H.WorkOrderId and J.IsDeleted = 0
								JOIN FmsStaffMst K (NOLOCK) on K.StaffMasterId = J.CompanyStaffMasterId
								JOIN FmsStaffPositionMstDet L (NOLOCK) ON L.StaffMasterId = K.staffmasterid
								JOIN FmsPositionWorkGroupMst M (NOLOCK) on M.Position = L.CurrentPosition
								where H.WorkOrderId in (e.workorderid)
								and J.Isdeleted=0
								and K.Isdeleted=0
								and L.Isdeleted=0
								and M.Isdeleted=0
								and convert(date, J.ResponseDateTime) between L.effectivedate and isnull(L.enddate,getdate())
								)
		and ar.AssetClassification not   in  (2326 ,2324,2325)
		GROUP BY e.WorkOrderId, ar.AssetRegisterId,sr.ServiceRequestId, sr.RequestNo, sr.Details, sr.[DateTime]
		, eass.ResponseDateTime, eass.ResponseDuration, ar.AssetNo, ar.AssetTypeCodeId 
		, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus, ar.AssetClassification, wc.EndDateTime,a12.FieldValue,ar.WorkGroupId,eatc.AssetTypeDescription, fua.UserAreaName
		, a.FieldValue, fs.StaffName,alt.FieldValue, wg.WorkGroupDescription, e.MaintenanceWorkDateTime,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId


	
------------------------------------------------------Land-/location-/building---------------------------------------------------------------------------------------------------------

--union
--INSERT INTO #ImpactedWorkGroupB
			select e.WorkOrderId
				,ar.AssetRegisterId
				, sr.ServiceRequestId -- must
				, sr.RequestNo
				, sr.Details
				, e.MaintenanceWorkDateTime as RequestDate
				,  eass.ResponseDateTime  
				, DATEDIFF(MINUTE,e.MaintenanceWorkDateTime,eass.ResponseDateTime) as ResponseDuration
				, 0 F1DemeritPoint
				, count(*) as F4DemeritPoint		
				, 0 F5DemeritPoint
				, 0 F7DemeritPoint
				, ISNULL(wc.EndDateTime,@LastDate) as CompletedDateTime
				, a12.FieldValue as TypeofRequest
				, fs.StaffName as RequestorName
				, 0 UserLocationId
				, 0 FmsUserAreaId
				, ar.AssetNo
				, ar.AssetTypeCodeId 
				, ar.PurchaseCostRM
				, ar.WarrantyEndDate
				, ar.AssetStatus
				, eatc.AssetTypeDescription as AssetDescription
				, a.FieldValue as AssetClassification 
				, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
			order by ProcessStatusId desc),0)) AS AssetProcessStatus
				, fua.UserAreaName
			
					,Case when ar.AssetClassification = 2324 --or ar.AssetClassification='Building'-- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = ar.AssetRegisterId 
			
				  )
				When ar.AssetClassification = 2297 --or ar.AssetClassification='System'-- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = ar.AssetRegisterId 
				
		  ) END as 'CountOfServingArea'
				, alt.FieldValue as MaintenanceType
				, wg.WorkGroupDescription
				--,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
				,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
			 INTO #ImpactedWorkGroupB
		FROM	dbo.EngMaintenanceWorkOrderTxn as e  (NOLOCK)				
				INNER JOIN dbo.AsisSysLovMst AS A1 (NOLOCK) ON E.Priority=A1.LovId and a1.isdeleted=0
				inner join AsisSysLovMst alt (NOLOCK) on e.[Type] = alt.LovId and alt.IsDeleted = 0
				INNER JOIN dbo.EngAssetRegisterMst AS ar (NOLOCK) ON ar.AssetRegisterId=e.AssetRegisterId 	
				inner join asissyslovmst a (NOLOCK) on ar.AssetClassification = a.LovId			
				and ar.IsDeleted=0 and ar.[Authorization]=4799 and ar.AssetStatus=127	
				left Join SrServiceRequestMst  sr (NOLOCK) on e.ServiceRequestId = sr.ServiceRequestId and sr.IsDeleted = 0
				join srServiceRequestFemsBemsTxn srd (NOLOCK) on sr.ServiceRequestId = srd.ServiceRequestId
				INNER JOIN dbo.AsisSysLovMst AS A12 (NOLOCK) ON srd.TypeOfRequest=A12.LovId and a12.IsDeleted=0
				left join EngMwoCompletionInfoTxn wc (NOLOCK) on e.WorkOrderId = wc.WorkOrderId and wc.IsDeleted = 0
				left join FmsStaffMst fs (NOLOCK) on fs.StaffMasterId = sr.FmsStaffMstId --and fs.IsDeleted = 0
				LEFT JOIN EngAssetTypeCodeMstDet eatc (NOLOCK) on ar.AssetTypeCodeId = eatc.AssetTypeCodeId					
				LEFT JOIN GmWorkGroupDetailsMst AS wg (NOLOCK) on ar.WorkGroupId = wg.WorkGroupId and wg.IsDeleted = 0							
				INNER  JOIN EngMwoAssesmentTxn Eass  (NOLOCK) ON Eass.WorkOrderId = E.WorkOrderId and eass.IsDeleted = 0
				LEFT JOIN EngUserLocationMst eul (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId
				LEFT JOIN FmsUserLocationMst ful (NOLOCK) ON eul.UserLocationId = ful.UserLocationId
				LEFT JOIN FmsUserAreaMst fua  (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId	
				--outer apply (	
				--	PWG.workgroupid   from FmsPositionWorkGroupMst  PWG join FmsStaffPositionMstDet FSP on  PWG.Position = FSP.CurrentPosition
				--	where FSP.service=@serviceID and PWG.service=@serviceID and FSP.hospitalid in (select HospitalId from #GetGMHospitalMstAndGroup) 
				--	and   FSP.staffmasterid=CompanyStaffMasterId and FSP.isdeleted = 0  and  PWG.isdeleted=0 --and ar.workgroupid = PWG.workgroupid 
				--	and  Eass.ResponseDateTime between Fsp.effectivedate and isnull(FSP.enddate,getdate())
				--		) w
		WHERE	E.ServiceId=@SERVICEID AND E.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)   AND E.IsDeleted = 0
		and e.WorkOrderStatus not in  (2315,5887)
				AND  MONTH( E.MaintenanceWorkDateTime) = @MONTH AND YEAR( E.MaintenanceWorkDateTime) = @YEAR
				AND e.MaintenanceWorkDateTime<=@LastDate
				AND E.MaintenanceWorkCategory=(SELECT LovId FROM AsisSysLovMst  WHERE LovKey='MaintenanceWorkCategoryValue' AND FieldValue='UnScheduled')
				AND ((E.Priority = 676  AND DATEDIFF(MINUTE, E.MaintenanceWorkDateTime, ISNULL(eass.RespONseDateTime,@LastDate))  <=15)
				OR (E.Priority = 675  AND DATEDIFF(MINUTE, E.MaintenanceWorkDateTime, ISNULL(eass.RespONseDateTime,@LastDate))  <=120))
				AND  e.Type in (2856,2857,2858,2859)	
				--and not exists (select workorderid from #tmpWorkOrderF4 union select workorderid from #tmpWorkOrderF4D1 union select workorderid from #tmpWorkOrderF4E2)											
		--and ar.workgroupid != w.ImpactedWorkGroup 
		AND Eass.ImpactedWorkGroup NOT IN
								( SELECT M.WorkGroupId FROM
								EngMaintenanceWorkOrderTxn as H (NOLOCK) 
								INNER  JOIN EngMwoAssesmentTxn J  (NOLOCK) ON J.WorkOrderId = H.WorkOrderId and J.IsDeleted = 0
								JOIN FmsStaffMst K (NOLOCK) on K.StaffMasterId = J.CompanyStaffMasterId
								JOIN FmsStaffPositionMstDet L (NOLOCK) ON L.StaffMasterId = K.staffmasterid
								JOIN FmsPositionWorkGroupMst M (NOLOCK) on M.Position = L.CurrentPosition
								where H.WorkOrderId in (e.workorderid)
								and J.Isdeleted=0
								and K.Isdeleted=0
								and L.Isdeleted=0
								and M.Isdeleted=0
								and convert(date, J.ResponseDateTime) between L.effectivedate and isnull(L.enddate,getdate())
								)
		--and not exists (select workorderid from #tmpWorkOrderF4 union select workorderid from #tmpWorkOrderF4D1 union select workorderid from #tmpWorkOrderF4E2)		
		and ar.AssetClassification  in  (2326 ,2324,2325)
		GROUP BY e.WorkOrderId, ar.AssetRegisterId,sr.ServiceRequestId, sr.RequestNo, sr.Details, sr.[DateTime]
			, eass.ResponseDateTime, eass.ResponseDuration, ar.AssetNo, ar.AssetTypeCodeId 
			, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus, ar.AssetClassification, wc.EndDateTime,a12.FieldValue,ar.WorkGroupId,eatc.AssetTypeDescription, fua.UserAreaName
			, a.FieldValue, fs.StaffName,alt.FieldValue, wg.WorkGroupDescription, e.MaintenanceWorkDateTime,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId

		--	print @LastDate

		--insert into #tmpWorkOrderF4 select * from #tmpWorkOrderF4AB
		--insert into #tmpWorkOrderF4 select * from #tmpWorkOrderF4ABC


		
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------

		print @LastDate



		--=============================================================================================--
		--								FEMS Indicator - F5											 ----
		--=============================================================================================--
	
		--===========================================--
		--		Temp Tables				 		-------
		--===========================================--

		IF OBJECT_ID('tempdb..#tmpWorkOrderF5F6') IS NOT NULL
			DROP TABLE #tmpWorkOrderF5F6
		IF OBJECT_ID('tempdb..#tmpAssetDetailsF5') IS NOT NULL
			DROP TABLE #tmpAssetDetailsF5
		IF OBJECT_ID('tempdb..#tmpDiffDays') IS NOT NULL
			DROP TABLE #tmpDiffDays
		IF OBJECT_ID('tempdb..#tmpDays') IS NOT NULL
			DROP TABLE #tmpDays
		IF OBJECT_ID('tempdb..#tmpWOPoint') IS NOT NULL
			DROP TABLE #tmpWOPoint
				IF OBJECT_ID('tempdb..#tmpWorkingDays') IS NOT NULL
			DROP TABLE #tmpWorkingDays
			
	----------------------------------------------------------------------
	--===========================================
	-- Days For Selected Month from FMS working Calendar
	--===========================================

	SELECT DISTINCT [Day], IsWorking, [Month] 
	INTO #tmpDays
	FROM FmsWorkingCalenderMstDet  det (NOLOCK) 
	INNER JOIN FmsWorkingCalenderMst mst (NOLOCK) ON mst.CalenderId = det.CalenderId
	INNER JOIN FmsHospitalProfileMst hosp (NOLOCK) ON hosp.[State] = mst.StateId
	WHERE mst.[Year] = @YEAR AND det.[Month] = @month  
	AND hosp.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
	AND det.IsDeleted = 0 AND mst.IsDeleted = 0 AND hosp.IsDeleted = 0
	------------------------------------------------------------------------
	
		SELECT wo.WorkOrderId ,wo.hospitalid,wo.MaintenanceWorkCategory,wo.WorkOrderStatus,WO.Type ,wo.MaintenanceWorkDateTime,wo.ServiceRequestId, ar.UserLocatiONId,ar.FmsUserAreaId, ar.AssetTypeCodeId 
		,ar.PurchaseCostRM,ar.WarrantyEndDate,ar.AssetStatus,ar.AssetClassification,wc.EndDateTime
				INTO #tmpWorkOrderF5F6
					FROM  dbo.EngMaintenanceWorkOrderTxn AS wo (NOLOCK) 
					  INNER JOIN #tmpAssertReg_f5 AS ar (NOLOCK) ON ar.AssetRegisterId = wo.AssetRegisterId
					  LEFT JOIN EngMwoCompletionInfoTxn wc (NOLOCK) ON wo.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted = 0
					  --LEFT JOIN EngUserLocationMst eul  ON ar.EngUserLocationId = eul.EngUserLocationId and eul.isdeleted=0
					  --LEFT JOIN FmsUserLocationMst ful  ON eul.UserLocationId = ful.UserLocationId and ful.IsDeleted = 0
					  --LEFT JOIN FmsUserAreaMst fua  ON ful.FmsUserAreaId = fua.FmsUserAreaId and fua.IsDeleted =0				
				WHERE wo.ServiceId = @serviceID
					  AND wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) 
					 -- AND ar.[Authorization]=4799 AND ar.AssetStatus = 127
					  AND wo.IsDeleted = 0 and wo.WorkOrderStatus not in  (2315,5887) --and wo.MaintenanceWorkCategory = 2357
					  AND (wc.EndDateTime IS NULL OR wc.EndDateTime >= @StartDate
					  -- (MONTH(wc.EndDateTime)=@MONTH AND YEAR(wc.EndDateTime)=@YEAR)
					  )
					  AND wo.MaintenanceWorkDateTime<=@LastDate
					  ----- The asset is exemption approved / Approved upgrading or reimbursable works and work has commenced.
					  --AND  GETDATE() > ar.WarrantyEndDate 
					  ----AND not exists (SELECT 1 FROM #tmpAdvisoryAsset ta where ta.AssetRegisterId = wo.AssetRegisterId  )
					  ----- Variation Status: V2, V4, V5.
					  ----AND not exists (SELECT 1 FROM #tmpSnfAssets ta where ta.AssetRegisterId = wo.AssetRegisterId  )
					  ----AND not exists (SELECT 1 FROM #tmpBerRecommend ta where ta.AssetRegisterId = wo.AssetRegisterId )

					---  AND wo.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpAdvisoryAsset)
					  ----- Variation Status: V2, V4, V5.
					--  AND wo.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpSnfAssets)
					--  AND wo.AssetRegisterId NOT IN (SELECT AssetRegisterId FROM #tmpBerRecommend)

		SELECT  wo.* --,W.MaintenanceWorkDateTime
				INTO #tmpAssetDetailsF5
					 FROM #tmpWorkOrderF5F6 WO
					--LEFT JOIN #tmpWorkOrder As wo ON W.WorkOrderId = WO.WorkOrderId
					 --INNER JOIN EngMaintenanceWorkOrderTxn W ON WO.WorkOrderId = W.WorkOrderId 
						--LEFT JOIN BerApplicationTxn ber  ON ber.AssetRegisterId = wo.AssetRegisterId
						--LEFT JOIN FmsNCREntryTxn AS ncr  ON wo.ServiceRequestId = ncr.ServiceRequestId 
						outer apply (select top 1 n.IndicatorDetId from FmsNCREntryTxn  n
												INNER JOIN SrServiceRequestMst AS sr  (NOLOCK) on n.ServiceRequestId = sr.ServiceRequestId AND sr.[Status] != 2315 
												where  wo.ServiceRequestId = n.ServiceRequestId ) ncr
					 WHERE  
					 WO.MaintenanceWorkCategory=(SELECT LovId 
															 FROM AsisSysLovMst  
															 WHERE LovKey='MaintenanceWorkCategoryValue' AND FieldValue='UnScheduled')
						   AND WO.Type IN (SELECT LovId 
												 FROM AsisSysLovMst  
												 WHERE LovKey='UnScheduledTypeValue' AND (FieldValue='Corrective Maintenance' OR FieldValue='Breakdown Repairs' OR FieldValue='Emergency Breakdown'))							 
						    AND
							 (ncr.IndicatorDetId IS NULL OR ncr.IndicatorDetId != (SELECT IndicatorDetId FROM DedIndicatorMstDet (NOLOCK) WHERE IndicatorNo='F.5' AND IsDeleted=0))

							 --SELECT * FROM #tmpAssetDetailsF5

		-- Current Month work orders
	SELECT --WO.*,
	 DATEDIFF(DAY,wo.MaintenanceWorkDateTime
						,ISNULL(c.EndDateTime,@LastDate)) as DiffDays
						, wo.WorkOrderId
						, wo.MaintenanceWorkDateTime AS StartDateTime
						, case when c.EndDateTime > @LastDate then @LastDate else isnull(c.EndDateTime,@LastDate) end AS EndDateTimE
						,wo.WorkOrderStatus
						,(Select dbo.ufn_GetSeventhWorkingDate(DATEPART(mm, wo.MaintenanceWorkDateTime),DATEPART(yy, wo.MaintenanceWorkDateTime),
						DATEPART(dd, wo.MaintenanceWorkDateTime),wo.HospitalId)AS WorkingDate )AS WorkingDate
				INTO #tmpDiffDays
					FROM #tmpAssetDetailsF5 AS wo (NOLOCK)
						LEFT JOIN EngMwoCompletionInfoTxn c (NOLOCK) ON wo.WorkOrderId = c.WorkOrderId and c.IsDeleted = 0
						--LEFT JOIN EngMwoCompletionInfoTxnDet d  ON c.CompletionInfoId = d.CompletionInfoId and d.IsDeleted = 0
						--LEFT JOIN EngMwoProcessStatusTxnDet P   ON c.CompletionInfoId = P.CompletionInfoId
					WHERE  MONTH( wo.MaintenanceWorkDateTime) = @MONTH AND YEAR( wo.MaintenanceWorkDateTime) = @year
					--AND DATEPART(MONTH,ISNULL(c.EndDateTime,@LastDate)) = @MONTH AND DATEPART(YEAR,ISNULL(c.EndDateTime,@LastDate))= @YEAR		
					And isnull(c.EndDateTime,@LastDate) >= @StartDate
				     	 --AND ISNULL(p.ProvideLoaner,0) = 0--Exemption: Loaner equipment or alternative services are provided
						 -- AND (DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(C.EndDateTime,GETDATE())) > 7) -- /** dIFference between work order date and End date less than 7 working days **/
						 --AND (DATEDIFF(MINUTE, wo.MaintenanceWorkDateTime, ISNULL(P.[Date],GETDATE())) > 7
						--AND	DATEPART(MONTH,wo.MaintenanceWorkDateTime) = @MONTH
						
						--AND DATEPART(YEAR,wo.MaintenanceWorkDateTime)= @YEAR
						
						--AND DATEDIFF(DAY,wo.MaintenanceWorkDateTime,ISNULL(d.EndDateTime,@LastDate)) > 7
		
			INSERT INTO #tmpDiffDays
			SELECT --WO.*,
				DATEDIFF(DAY,wo.MaintenanceWorkDateTime,ISNULL(wc.EndDateTime,@LastDate)) as DiffDays
				, wo.WorkOrderId
				--, DATEADD(month, DATEDIFF(month, 0, wo.MaintenanceWorkDateTime), 0) 
				--, @StartDate AS StartDateTime (commented by pravin)
				, wo.MaintenanceWorkDateTime AS StartDateTime
				, case when wc.EndDateTime > @LastDate then @LastDate else isnull(wc.EndDateTime,@LastDate) end AS EndDateTimE
				,wo.WorkOrderStatus
				,(Select dbo.ufn_GetSeventhWorkingDate(DATEPART(mm, wo.MaintenanceWorkDateTime),DATEPART(yy, wo.MaintenanceWorkDateTime),
				DATEPART(dd, wo.MaintenanceWorkDateTime), wo.HospitalId)AS WorkingDate )AS WorkingDate
			FROM #tmpAssetDetailsF5 wo (NOLOCK)
			LEFT JOIN EngMwoCompletionInfoTxn wc (NOLOCK) ON wo.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted = 0
			WHERE (wc.EndDateTime IS NULL OR  wc.EndDateTime >= @StartDate
			--(MONTH(ISNULL(wc.EndDateTime, @LastDate)) = @MONTH
			--AND YEAR(ISNULL(wc.EndDateTime, @LastDate)) = @YEAR)			
			)
			--AND wo.ServiceId = @SERVICEID
			--AND wo.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
			AND CAST(wo.MaintenanceWorkDateTime AS DATE) < @StartDate
			--AND DATEDIFF(DAY,wo.MaintenanceWorkDateTime,ISNULL(wc.EndDateTime,@LastDate))<=31
			--AND DATEDIFF(DAY,wo.MaintenanceWorkDateTime,ISNULL(wc.EndDateTime,@LastDate))>7
			--AND wo.IsDeleted = 0 

				SELECT *
				INTO #tmpWorkingDays1
				FROM #tmpDiffDays AS tmp WHERE  CAST(tmp.EndDateTime AS DATE) > CAST(tmp.WorkingDate AS DATE) 



				
		/* Loan Provider  Start */


		SELECT DISTINCT t.WorkOrderId, LP.ProcessStatusId,  ProvideLoaner , 0 as AlternativeServiceProvided, lp.ProvisionDateTime LPStartDate,
						case when lp.EndDateTime > @lastdate then @lastdate else isnull(lp.EndDateTime,@lastdate) end  LPEndDate	
		INTO #tmpLP2
		FROM #tmpWorkingDays1 t 
		INNER JOIN EngMwoCompletionInfoTxn wc (NOLOCK) ON t.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
		INNER JOIN EngMwoProcessStatusTxnDet wp (NOLOCK) ON wc.CompletionInfoId = wp.CompletionInfoId AND wp.IsDeleted=0 
		outer apply (select top 1 lp1.ProcessStatusId  , lp1.ProvisionDateTime, lp1.EndDateTime from  EngMwoProcessStatusLpTxnDet lp1 where  wp.ProcessStatusId = lp1.ProcessStatusId  AND lp1.IsDeleted=0   order by lp1.ProcessStatusLpId desc ) lp
		where  wp.AssetProvided = 692 AND wp.ProvideLoaner = 1


		SELECT DISTINCT t.WorkOrderId, alt.ProcessStatusId , 0 as ProvideLoaner,AlternativeServiceProvided , alt.StartDateTime ALTStartDate, 
				case when alt.EndDateTime  > @lastdate then @lastdate else isnull(alt.EndDateTime ,@lastdate) end ALTEndDate
		INTO #tmpALT2
		FROM #tmpWorkingDays1 t 
		INNER JOIN EngMwoCompletionInfoTxn wc (NOLOCK) ON t.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
		INNER JOIN EngMwoProcessStatusTxnDet wp (NOLOCK) ON wc.CompletionInfoId = wp.CompletionInfoId AND wp.IsDeleted=0 
		outer apply (select top 1 alt1.ProcessStatusId,alt1.StartDateTime, alt1.EndDateTime from  EngMwoProcessStatusAspTxnDet alt1 where  wp.ProcessStatusId = alt1.ProcessStatusId  AND alt1.IsDeleted=0   order by alt1.ProcessStatusAspId desc ) alt
		--LEFT JOIN EngMwoProcessStatusAspTxnDet alt ON wp.ProcessStatusId = alt.ProcessStatusId 
		where  wp.AssetProvided = 692 AND wp.AlternativeServiceProvided = 1
	
	
			
		select wo.*,LP.ProcessStatusId as LPProcessStatusId,ALT.ProcessStatusId as ALTProcessStatusId,lp.ProvideLoaner,alt.AlternativeServiceProvided,
				Lp.LPStartDate,Lp.LPEndDate,ALT.ALTStartDate,ALT.ALTEndDate
		into #tmpWorkOrdersF5_LOAN
		from #tmpWorkingDays1 wo 
		left join #tmpLP2 LP  on LP.WorkOrderId = wo.WorkOrderId
		left join #tmpALT2 ALT  on ALT.WorkOrderId = wo.WorkOrderId
		where  ( LP.ProcessStatusId is not null or ALT.ProcessStatusId  is not null)



		select a.workorderid,b.ProcessStatusId ,a.Startdatetime,a.Enddatetime,cast(a.Startdatetime as date) as startdate, cast(a.Enddatetime as date) enddate,b.ProvisionDateTime as LSTARTdate,  --dateadd(HOUR,-5 , a.Enddatetime ) as LENDdate,
				isnull(b.EndDateTime,@LastDate) as  LENDdate,
				1 LoanType , a.WorkingDate
		into #tmpWorkOrdersF5_LOAN_1
		from #tmpWorkOrdersF5_LOAN a
		join EngMwoProcessStatusLpTxnDet b (NOLOCK) on   a.LPProcessStatusId=b.ProcessStatusId  and b.IsDeleted = 0
		union all		
		select 	a.workorderid,b.ProcessStatusId,a.Startdatetime,a.Enddatetime,cast(a.Startdatetime as date) as startdate, cast(a.Enddatetime as date) enddate,b.StartDateTime as LSTARTdate,
				isnull(b.enddatetime,@LastDate) as  LENDdate,
				2 LoanType ,a.WorkingDate
		from #tmpWorkOrdersF5_LOAN a
		join EngMwoProcessStatusAspTxnDet b (NOLOCK) on   a.ALTProcessStatusId=b.ProcessStatusId  and b.IsDeleted = 0

		/* Days for current month  */

		;with CTE_days as 
		(
		select DATEFROMPARTS ( @year,@month,1) as Days 
		union all
		select dateadd(d,1,Days) from CTE_days where Days < EOMONTH(DATEFROMPARTS ( @year,@month,1))
		)	
		select Days into #Temp_Days_f5 from CTE_days


		--update #tmpWorkOrdersF5_LOAN_1 set lstartdate = '2017-10-25 10:00:00.000'  , lenddate='2018-03-31 10:00:00.000'

		
		select   *, case when days between lstartdate and lenddate then 0  else 1 end as isEligible_demerit
		into #loanprovider
		from #tmpWorkOrdersF5_LOAN_1 a
		cross join  #Temp_Days_f5 t
		where t.days between   a.WorkingDate+1 and a.enddate

		/* remove duplicate dates */
		;with CTE as
		(
		select row_number() over (partition  by workorderid,Days order by Days, isEligible_demerit ) as sno,* from #loanprovider
		)
		delete  a from   #loanprovider a join CTE c on  a.workorderid=c.workorderid and a.Days=c.Days
		where c.sno=2

		select workorderid , max( isEligible_demerit )   as isEligible_demerit into  #loanprovider_final  from   #loanprovider a 
		group  by workorderid
		
		

		select *  into #tmpWorkingDays From #tmpWorkingDays1   a
		where not exists (select 1 from #loanprovider_final t where a.workorderid=t.workorderid and isEligible_demerit = 0)

	--select * from #loanprovider_final
	--select * from #tmpWorkingDays1
	--select * from #tmpWorkingDays

	--return
			--select * from #tmpWorkingDays	

	/* Loan Provider  END */
	
			
				--SELECT * FROM #tmpWorkingDays
		--------------------------------------------------

			--===========================================
			-- Provided Loaner & Alternate service
			--===========================================
			--IF OBJECT_ID('tempdb..#tmpLP') IS NOT NULL
			--DROP TABLE #tmpLP	
			--IF OBJECT_ID('tempdb..#tmpALT') IS NOT NULL
			--DROP TABLE #tmpALT	
			IF OBJECT_ID('tempdb..#tmpLPDays') IS NOT NULL
			DROP TABLE #tmpLPDays	
			IF OBJECT_ID('tempdb..#tmpALTDays') IS NOT NULL
			DROP TABLE #tmpALTDays	
			IF OBJECT_ID('tempdb..#tmpmaintenanceParameter') IS NOT NULL
			DROP TABLE #tmpmaintenanceParameter	
			IF OBJECT_ID('tempdb..#tmpNoOutstanding') IS NOT NULL
			DROP TABLE #tmpNoOutstanding

			Declare @NoOfBearkDown int,@NoOfEmergencyBreakdown int,@NoOutstandingBD int ,@NoOutstandingEB int;

			----select * from #tmpDiffDays
			--SELECT --*
			--t.WorkOrderId, lp.ProvisionDateTime StartDate, lp.EndDateTime EndDate 	
			--INTO #tmpLP
			--FROM #tmpDiffDays t 
			--INNER JOIN EngMwoCompletionInfoTxn wc ON t.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
			--INNER JOIN EngMwoProcessStatusTxnDet wp ON wc.CompletionInfoId = wp.CompletionInfoId 
			--AND wp.IsDeleted=0 AND wp.AssetProvided = 692 AND wp.ProvideLoaner = 1
			--LEFT JOIN EngMwoProcessStatusLpTxnDet lp ON wp.ProcessStatusId = lp.ProcessStatusId
			--WHERE lp.ProvisionDateTime <= wc.EndDateTime 
			--AND lp.EndDateTime >= wc.EndDateTime

			--SELECT t.WorkOrderId, alt.StartDateTime StartDate, alt.EndDateTime EndDate
			--INTO #tmpALT
			--FROM #tmpDiffDays t 
			--INNER JOIN EngMwoCompletionInfoTxn wc ON t.WorkOrderId = wc.WorkOrderId AND wc.IsDeleted=0  
			--INNER JOIN EngMwoProcessStatusTxnDet wp ON wc.CompletionInfoId = wp.CompletionInfoId 
			--AND wp.IsDeleted=0 AND wp.AssetProvided = 692 AND wp.AlternativeServiceProvided = 1
			--LEFT JOIN EngMwoProcessStatusAspTxnDet alt ON wp.ProcessStatusId = alt.ProcessStatusId 
			--AND alt.IsDeleted=0 
			--WHERE alt.StartDateTime <= wc.EndDateTime 
			--AND alt.EndDateTime >= wc.EndDateTime 
			
		-- Exemption of loaner provision
		SELECT  
		W.WorkOrderId
		,wo.AssetRegisterId
		, ServiceRequestId
		, RequestNo
		, Details
		, RequestDate
		, ResponseDateTime 
		, ResponseDuration
		, 0 F1DemeritPoint
		, 0 F4DemeritPoint
		, 1 as F5DemeritPoint		
		, 0 F7DemeritPoint
		, wo.ActualCompletionDate as CompletedDateTime
		, wo.TypeofReq TypeofRequest
		, wo.StaffName RequestorName
		, null as UserLocationId
		, null as FmsUserAreaId
		, AssetNo
		, AssetTypeCodeId 
		, PurchaseCostRM
		, WarrantyEndDate
		, AssetStatus
		, AssetDescription
		, a.FieldValue   as AssetClassification 
		, AssetProcessStatus	
		, wo.WorkGroupDescription as WorkGroupDescription
		, UserAreaName
		,wo.TypeofReq
		,wo.MaintenanceType
		
		,Case when wo.AssetClassification = 2324 --or wo.AssetClassification='Building'-- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = wo.AssetRegisterId 
				
				  )
				When wo.AssetClassification = 2297 --or wo.AssetClassification='System'-- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = wo.AssetRegisterId 
					
		  ) END as 'CountOfServingArea'		
		, cast (wo.BuildingNo  as varchar(200)) as BuildingNo
		INTO #tmpWorkOrderF5 
		FROM #tmpWorkingDays W
		LEFT JOIN #tmpWorkOrdersF1 WO ON W.WorkOrderId = WO.WorkOrderId
		inner join asissyslovmst a (NOLOCK) on wo.AssetClassification = a.LovId
		--LEFT JOIN GmWorkGroupDetailsMst AS wg on wo.Workgroup = wg.WorkGroupId and wg.IsDeleted = 0
		--LEFT JOIN EngUserLocationMst eul  ON ar.EngUserLocationId = eul.EngUserLocationId
		--LEFT JOIN FmsUserLocationMst ful  ON eul.UserLocationId = ful.UserLocationId
		--LEFT JOIN FmsUserAreaMst fua  ON ful.FmsUserAreaId = fua.FmsUserAreaId
		--WHERE (W.WorkOrderId NOT IN (SELECT WorkOrderId FROM #tmpLP))
		--AND (W.WorkOrderId NOT IN (SELECT WorkOrderId FROM #tmpALT))
		GROUP BY W.WorkOrderId,  wo.AssetRegisterId,ServiceRequestId, RequestNo, Details
		, RequestDate, ResponseDateTime, ResponseDuration, ActualCompletionDate
		, TypeofReq, StaffName--, UserLocationId, FmsUserAreaId
		, AssetNo, AssetTypeCodeId, PurchaseCostRM, WarrantyEndDate, AssetStatus
		, a.FieldValue ,AssetProcessStatus,AssetClassification		, BuildingNo, AssetDescription 	,WorkGroupDescription,UserAreaName
		,wo.TypeofReq,wo.MaintenanceType	
				
									
		
		--INSERT INTO #tmpWorkOrderF5
		--Select 0 WorkOrderId
		--,ar.AssetRegisterId
		--, sr.ServiceRequestId
		--, n.NCRNo as RequestNo
		--, sr.Details
		--, sr.[DateTime] as RequestDate
		--, fb.ResponseDateTime 
		--, DATEDIFF(MINUTE,sr.[DateTime],fb.ResponseDateTime) as ResponseDuration
		--, 0 F1DemeritPoint
		--, 0 F4DemeritPoint
		--, 1 as F5DemeritPoint		
		--, 0 F7DemeritPoint
		--, fb.CompletedDateTime
		--, lov.FieldValue as TypeofRequest
		--, req.StaffName+'/'+lpos.FieldValue as RequestorName
		--, ful.UserLocationId
		--, fua.FmsUserAreaId
		--, ar.AssetNo
		--, ar.AssetTypeCodeId 
		--, ar.PurchaseCostRM
		--, ar.WarrantyEndDate
		--, ar.AssetStatus
		--, typedec.AssetTypeDescription as AssetDescription
		--, a.FieldValue as AssetClassification  
		--, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
		--	order by ProcessStatusId desc),0)) AS AssetProcessStatus
		--, fua.UserAreaName
		--, wg.WorkGroupDescription
		----,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
		--,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
		
		----select *
		--FROM FmsNCREntryTxn AS n 
		--INNER JOIN SrServiceRequestMst AS sr  on n.ServiceRequestId = sr.ServiceRequestId
		--INNER JOIN EngAssetRegisterMst AS ar  on ar.AssetRegisterId = sr.AssetRegisterId
		--LEFT JOIN GmWorkGroupDetailsMst AS wg on ar.WorkGroupId = wg.WorkGroupId and wg.IsDeleted = 0
		--INNER JOIN DedIndicatorMstDet AS d  on d.IndicatorDetId = n.IndicatorDetId
		--LEFT JOIN SrServiceRequestFemsBemsTxn fb  on sr.ServiceRequestId = fb.ServiceRequestId
		--LEFT JOIN AsisSysLovMst lov  ON fb.TypeOfRequest = lov.LovId AND lov.IsDeleted = 0
		--LEFT JOIN FmsStaffMst req  ON sr.FmsStaffMstId= req.StaffMasterId AND req.IsDeleted = 0 
		--LEFT JOIN FmsStaffPositionMstDet dsg  ON req.StaffMasterId=dsg.StaffMasterId AND dsg.IsDeleted=0
		--LEFT JOIN AsisSysLovMst lpos  ON dsg.CurrentPosition = lpos.LovId AND lpos.IsDeleted = 0	
		--LEFT JOIN EngUserLocationMst eul  ON ar.EngUserLocationId = eul.EngUserLocationId
		--LEFT JOIN FmsUserLocationMst ful  ON eul.UserLocationId = ful.UserLocationId
		--LEFT JOIN FmsUserAreaMst fua  ON ful.FmsUserAreaId = fua.FmsUserAreaId
		--inner join asissyslovmst a on ar.AssetClassification = a.LovId		
		--LEFT Join EngAssetTypeCodeMstDet typedec on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0		
		--WHERE d.IndicatorNo='F.5'
		--AND n.[Service] = @serviceID
		--AND n.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		--AND MONTH(n.NCRDateTime) = @month
		--AND YEAR(n.NCRDateTime) = @year
		--AND sr.[Status] != 2315		
		----AND @LastDate> ar.WarrantyEndDate 
		----and ar.WarrantyEndDate<=@LastDate
		--AND n.IsDeleted = 0 AND sr.IsDeleted = 0 AND ar.IsDeleted = 0 AND d.IsDeleted = 0	
		--GROUP BY sr.ServiceRequestId, ar.AssetRegisterId,n.NCRNo, sr.Details, sr.[DateTime]
		--, fb.ResponseDateTime , sr.[DateTime], fb.CompletedDateTime, lov.FieldValue, req.StaffName
		--, lpos.FieldValue, ful.UserLocationId, fua.FmsUserAreaId, ar.AssetNo, ar.AssetTypeCodeId 
		--, ar.PurchaseCostRM, ar.WarrantyEndDate, ar.AssetStatus, ar.AssetClassification , ar.WorkGroupId,fua.UserAreaName,a.FieldValue
		--,typedec.AssetTypeDescription,wg.WorkGroupDescription,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId
			
			--SELECT * FROM 	#tmpWorkOrder
			--SELECT * FROM 	#tmpWorkOrderF4
			--select * from  #tmpWorkOrderF5
			

	--Select 0 WorkOrderId
	--	,cast ( ar.AssetRegisterId as bigint) as AssetRegisterId
	--	, sr.ServiceRequestId
	--	, n.NCRNo as RequestNo
	--	, sr.Details
	--	, sr.[DateTime] as RequestDate
	--	, fb.ResponseDateTime 
	--	, DATEDIFF(Minute,sr.[DateTime],fb.ResponseDateTime) as ResponseDuration
	--	, 0 F1DemeritPoint
	--	, 0 F4DemeritPoint
	--	, 0 F5DemeritPoint
	--	, COUNT(*) as F7DemeritPoint				
	--	, fb.CompletedDateTime 
	--	, a.fieldvalue as TypeofRequest
	--	, fs.StaffName as RequestorName
	--	, 0 UserLocationId
	--	, 0 FmsUserAreaId
	--	, ar.AssetNo
	--	, ar.AssetTypeCodeId 
	--	, ar.PurchaseCostRM
	--	, ar.WarrantyEndDate
	--	, ar.AssetStatus
	--	, a1.FieldValue AssetClassification  
	--	, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
 --       order by ProcessStatusId desc),0)) AS AssetProcessStatus
	--	,typedec.AssetTypeDescription as AssetDescription
	--	, wg.WorkGroupCode
	--	, wg.WorkGroupDescription
	--	,fua.UserAreaCode
	--	,fua.UserAreaName
	--	--, 'Non Conformance' AS Remarks
	--	--,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
	--	,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
	--	INTO #tmpWorkOrderF7
	--	FROM FmsNCREntryTxn AS n 
	--	INNER JOIN SrServiceRequestMst AS sr  on n.ServiceRequestId = sr.ServiceRequestId	
	--	INNER JOIN FmsStaffMst fs on sr.FmsStaffMstId = fs.StaffMasterId
	--	LEFT JOIN SrServiceRequestFemsBemsTxn fb on sr.ServiceRequestId = fb.ServiceRequestId
	--	LEFT JOIN AsisSysLovMst a ON fb.TypeOfRequest = a.lovid		
	--	INNER JOIN EngAssetRegisterMst AS ar  on ar.AssetRegisterId = sr.AssetRegisterId
	--	LEFT JOIN GmWorkGroupDetailsMst AS wg on ar.WorkGroupId = wg.WorkGroupId	
	--	LEFT JOIN AsisSysLovMst a1 ON ar.AssetClassification  = a1.lovid
	--	INNER JOIN DedIndicatorMstDet AS d  on d.IndicatorDetId = n.IndicatorDetId
	--	LEFT JOIN EngUserLocationMst eul  ON ar.EngUserLocationId = eul.EngUserLocationId
	--	LEFT JOIN FmsUserLocationMst ful  ON eul.UserLocationId = ful.UserLocationId
	--	LEFT JOIN FmsUserAreaMst fua  ON ful.FmsUserAreaId = fua.FmsUserAreaId
	--	LEFT Join EngAssetTypeCodeMstDet typedec on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0	
	--	WHERE d.IndicatorNo='F.7'
	--	AND n.[Service] = @serviceID
	--	AND ar.assetstatus=127
	--	AND  ar.[Authorization]=4799
	--	AND n.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
	--	AND MONTH(n.NCRDateTime) = @MONTH
	--	AND YEAR(n.NCRDateTime) = @year
	--	AND sr.[Status] != 2315
	--	--and ar.WarrantyEndDate<=@LastDate
	--	AND n.IsDeleted = 0 AND sr.IsDeleted = 0 AND ar.IsDeleted = 0 AND d.IsDeleted = 0
	--	group by sr.ServiceRequestId
	--	, ar.AssetRegisterId
	--	, n.NCRNo
	--	, sr.Details
	--	, sr.[DateTime]
	--	, fb.ResponseDateTime
	--	, ar.AssetNo
	--	, ar.AssetTypeCodeId 
	--	, ar.PurchaseCostRM
	--	, ar.WarrantyEndDate
	--	, ar.AssetStatus
	--	, ar.AssetClassification  
	--	, a.fieldvalue
	--	, fs.StaffName
	--	, fb.CompletedDateTime 
	--	, a1.FieldValue 		
	--	, typedec.AssetTypeDescription
	--	, wg.WorkGroupCode
	--	, wg.WorkGroupDescription
	--	, fua.UserAreaCode
	--	, fua.UserAreaName
	--	, ar.WorkGroupId,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId
		-- select * from AsisSysLovMst where LovId=2315
		--INSERT INTO #tmpWorkOrderF7
		SELECT 
		0 WorkOrderId
		,ar.AssetRegisterId
		, sr.ServiceRequestId
		--isnull(sr.RequestNo,NULL) as RequestNo,
		,sr.RequestNo
		, sr.Details
		, sr.[DateTime] as RequestDate
		, fb.ResponseDateTime 
		, DATEDIFF(Minute,sr.[DateTime],fb.ResponseDateTime) as ResponseDuration
		, 0 F1DemeritPoint
		, 0 F4DemeritPoint
		, 0 F5DemeritPoint
		, COUNT(*) as F7DemeritPoint				
		, tc.TandCCompletedDate CompletedDateTime
		, a.FieldValue as TypeofRequest
		, fs.StaffName as RequestorName
		, 0 UserLocationId
		, 0 FmsUserAreaId
		, ar.AssetNo
		, ar.AssetTypeCodeId 
		, ar.PurchaseCostRM
		, ar.WarrantyEndDate
		, ar.AssetStatus		
		, a1.FieldValue AssetClassification  
		, dbo.Fn_DisplayNameofLov(isnull((select top 1 ISNULL(ProcessStatus,'-') from EngAssetRegisterProcessStatusMst  where AssetRegisterId=ar.AssetRegisterId and IsDeleted=0
        order by ProcessStatusId desc),0)) AS AssetProcessStatus
		, typedec.AssetTypeDescription as AssetDescription
		, wg.WorkGroupCode
		, wg.WorkGroupDescription
		, fua.UserAreaCode
		, fua.UserAreaName
		
		,Case when ar.AssetClassification = 2324 --or ar.AssetClassification='Building' -- --Building
			 then  (
					Select  Count(distinct eul.EngUserAreaId)
					from 
					EngAssetRegisterLocationMst eul
					Where eul.AssetRegisterId = ar.AssetRegisterId 
				
				  )
				When ar.AssetClassification = 2297 --or ar.AssetClassification='System'-- --System
				then (
						 Select  Count(distinct se.UserAreaId)
						 from 
						 EngAssetRegisterServingAreaMst se
						Where se.AssetRegisterId = ar.AssetRegisterId 
					
		  ) END as 'CountOfServingArea'
		, 'Service Work (Unscheduled & Others)' AS Remarks
		,CASE WHEN ar.WorkGroupId = @wgId THEN dbo.ufn_GetBuildingName(fua.FmsUserAreaId,eul.UserLocationId) ELSE '' END as BuildingNo 
		--,CASE WHEN ar.WorkGroupId = 3 and ar.AssetClassification = 2324 THEN ar.AssetNo  ELSE '' END as BuildingNo 
		INTO #tmpWorkOrderF7 from SrServiceRequestMst sr (NOLOCK)
		LEFT join EngTestingandCommissioningTxn tc (NOLOCK) on sr.ServiceRequestId = tc.ServiceRequestId and tc.IsDeleted=0	
		and  tc.TestingandCommissioningId in (select min(TestingandCommissioningId) as TestingandCommissioningId from [EngTestingandCommissioningTxn] t (NOLOCK) 
				 where t.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
				 and  t.serviceid=@SERVICEID
				 and t.IsDeleted=0
				 group by ServiceRequestId
				-- having count(TestingandCommissioningId)>1
				 )
		LEFT JOIN EngAssetRegisterMst AS ar  (NOLOCK) on ar.AssetRegisterId = sr.AssetRegisterId
		LEFT JOIN GmWorkGroupDetailsMst AS wg (NOLOCK) on ar.WorkGroupId = wg.WorkGroupId	
		INNER JOIN FmsStaffMst fs (NOLOCK) on sr.FmsStaffMstId = fs.StaffMasterId
		LEFT JOIN SrServiceRequestFemsBemsTxn fb (NOLOCK) on sr.ServiceRequestId = fb.ServiceRequestId
		LEFT JOIN AsisSysLovMst a (NOLOCK) ON fb.TypeOfRequest = a.lovid 
		LEFT JOIN AsisSysLovMst a1 (NOLOCK) ON ar.AssetClassification  = a1.lovid
		LEFT JOIN EngUserLocationMst eul (NOLOCK) ON ar.EngUserLocationId = eul.EngUserLocationId
        LEFT JOIN FmsUserLocationMst ful (NOLOCK) ON eul.UserLocationId = ful.UserLocationId
        LEFT JOIN FmsUserAreaMst fua (NOLOCK) ON ful.FmsUserAreaId = fua.FmsUserAreaId
        LEFT Join EngAssetTypeCodeMstDet typedec (NOLOCK) on ar.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0
		where sr.Service = @SERVICEID and sr.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
		and sr.[status]!=2315  and a.fieldvalue='T&C'
		and MONTH(sr.RequiredDateTime)=@MONTH and YEAR(sr.RequiredDateTime)=@YEAR
	 and (( ((cast(tc.TandCCompletedDate as date)>=cast(@StartDate as date)) or (tc.TandCCompletedDate is null))
		            --and cast(sr.RequiredDateTime as date)<=cast(@LastDate as date)
		          --and (tc.TandCCompletedDate is null or cast(tc.TandCCompletedDate as date)>cast(RequiredDateTime as date))
		               --and (tc.TandCStatus in (2821,2820) or tc.TandCStatus is null)	
		and  (cast(tc.TandCCompletedDate as date)>cast(RequiredDateTime as date) or (tc.TandCCompletedDate is null))
		and isnull(tc.TandCStatus,0)  not in   (2821,5872))or (isnull(tc.TandCStatus,0)  =   2821 and cast(tc.TandCDate as date)>cast(RequiredDateTime as date)))	

			           
		group by sr.ServiceRequestId
		, ar.AssetRegisterId
		, RequestNo
		, sr.Details
		, sr.[DateTime],TandCCompletedDate
		, fb.ResponseDateTime 
		, ar.AssetNo
		, ar.AssetTypeCodeId 
		, ar.PurchaseCostRM
		, ar.WarrantyEndDate
		, ar.AssetStatus
		, ar.AssetClassification  
		, a.fieldvalue
		, fs.StaffName
		, fb.CompletedDateTime 
		, a1.fieldvalue
			,typedec.AssetTypeDescription
				, wg.WorkGroupCode
		, wg.WorkGroupDescription
				,fua.UserAreaCode
		,fua.UserAreaName
		,ar.WorkGroupId,fua.FmsUserAreaId,eul.UserLocationId,ar.AssetRegisterId
		

			--Update t set t.F4DemeritPoint = ISNULL(t4.F4DemeritPoint,0)
			--, t.F5DemeritPoint = ISNULL(t5.F5DemeritPoint,0)
			--, t.F7DemeritPoint = ISNULL(t7.F7DemeritPoint,0)
			----SELECT * 
			--FROM 	#tmpWorkOrder t
			--LEFT JOIN #tmpWorkOrderF4 t4 on t.ServiceRequestId = t4.ServiceRequestId 
			--LEFT JOIN #tmpWorkOrderF5 t5 on t.ServiceRequestId = t5.ServiceRequestId 
			--LEFT JOIN #tmpWorkOrderF7 t7 on t.ServiceRequestId = t7.ServiceRequestId 
			
	
	--from AsisSysLovMst where lovid=@InputMonth	
	--Select DateName( month , DateAdd( month , 12 , 0 ) - 1 )
	--SELECT @StartDate
	--SELECT @LastDate

			------------------------------------------------------------------------------------------------------------------------------------------------------------
			--insert 
			select workorderid into #OmissionforSameIndicatorRepeatedDemrit from #tmpWorkOrderF4 union 
			select workorderid from #tmpWorkOrderF4D1 
			union select workorderid from #tmpWorkOrderF4E2
			
			Declare @A int,@B int
			set @A=(select Count(*) from #ImpactedWorkGroupA)
			set @B=(select Count(*) from #ImpactedWorkGroupB)
			print @A
			print @B


			--select * from #tmpWorkOrderF4
			--select * from #tmpWorkOrderF4D1
			--select * from #tmpWorkOrderF4E2

			----select * from #OmissionforSameIndicatorRepeatedDemrit

			--select * from #ImpactedWorkGroupA
			--select * from #ImpactedWorkGroupB
			--------------------------------------------------------------------------------------------------------------------------------------------------------------\
			SELECT  @HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, RequestNo as ServiceRequestNo
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'))-2) as ServiceRequestDate
			--, FORMAT(RequestDate, 'dd-MMM-yyyy HH:MM') as ServiceRequestDate
			, TypeofRequest as TypeOfServicesRequest, t.MaintenanceType 
			, AssetNo, Details as ServiceRequestDetails, RequestorName as RequestNameDesignation
			, 'No' UnderWarranty, ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus, vs.VariationStatus
			, ResponseDateTime as ResponseDateTime
			--, FORMAT(ResponseDateTime, 'dd-MMM-yyyy HH:MM') ResponseDateTime
			, ResponseDuration,
			 case when ProvideLoaner='Yes' THen ProvisionDate --FORMAT(ProvisionDate, 'dd-MMM-yyyy HH:MM') 
			ELSE cast (Null as datetime ) END ProvisionDate
			, case when ProvideLoaner='Yes' THen  EndDateTime --FORMAT(EndDateTime, 'dd-MMM-yyyy HH:MM') 
			ELSE  null   END EndDateTime
			--, EndDateTime
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'))-2) as ServiceWorkCompletionDate
			--, FORMAT(CompletedDateTime, 'dd-MMM-yyyy HH:MM')  as ServiceWorkCompletionDate
			----, F1DemeritPoint as F1
			----, F4DemeritPoint as F4, F5DemeritPoint as F5, F7DemeritPoint as F7

				 , case when Reason='Technical Support Letter Obsolete' --( case when Reason ='Variation Status V2, V4 or V5' or Reason ='Exemption Approved from Advisory service' or Reason ='Technical Support Letter Obsolete' or Reason ='BER Recommended Assets'
			  then 0  
			   when Reason='BER Recommended Assets'
			   then 0 
			     when Reason='Variation Status V2, V4 or V5'
			   then 0 
			   when Reason='Exemption Approved from Advisory service'
			   then 0 
			  else F1DemeritPoint end F1
			--, F4DemeritPoint as F4
			 , case when Reason='Technical Support Letter Obsolete' --( case when Reason ='Variation Status V2, V4 or V5' or Reason ='Exemption Approved from Advisory service' or Reason ='Technical Support Letter Obsolete' or Reason ='BER Recommended Assets'
			  then 0  
			   when Reason='BER Recommended Assets'
			   then 0 
			     when Reason='Variation Status V2, V4 or V5'
			   then 0 
			   when Reason='Exemption Approved from Advisory service'
			   then 0 
			  else F4DemeritPoint end F4
			
			
			--, F5DemeritPoint as F5

			, case when Reason='Technical Support Letter Obsolete' --( case when Reason ='Variation Status V2, V4 or V5' or Reason ='Exemption Approved from Advisory service' or Reason ='Technical Support Letter Obsolete' or Reason ='BER Recommended Assets'
			  then 0  
			   when Reason='BER Recommended Assets'
			   then 0 
			     when Reason='Variation Status V2, V4 or V5'
			   then 0 
			   when Reason='Exemption Approved from Advisory service'
			   then 0 
			  else F5DemeritPoint end F5
			
			
			--, F7DemeritPoint as F7
			, case when Reason='Technical Support Letter Obsolete' --( case when Reason ='Variation Status V2, V4 or V5' or Reason ='Exemption Approved from Advisory service' or Reason ='Technical Support Letter Obsolete' or Reason ='BER Recommended Assets'
			  then 0  
			   when Reason='BER Recommended Assets'
			   then 0 
			     when Reason='Variation Status V2, V4 or V5'
			   then 0 
			   when Reason='Exemption Approved from Advisory service'
			   then 0 
			  else F7DemeritPoint end F7
			,0 AS F8
			, case when TypeofRequest = 'Non Conformance' THEN 'Non Conformance' else 'Service Work (Unscheduled & Others)' end as Remarks, 'F.1' Indicator
			, AssetDescription, AssetClassification, Workgroup WOWorkgroup, BuildingNo, UserAreaName
			,t.CountOfServingArea
			, ProvideLoaner,ExcludeDemerit ExcludeDemeritforF1,0 as 'SubParameterDetID' ,
			--case when ExcludeDemerit='Yes' then 'Overlapping/Loaner' 
			case when ExcludeDemerit='Yes' and Reason is null then 'Overlapping/Loaner'
				 when ExcludeDemerit='Yes' and Reason is not null then Reason						
			else
			--isnull((select top 1 dtd.Remarks from DeductionTransactionMappingMst dt join DeductionTransactionMappingMstDet dtd on dt.DedTxnMappingId=dtd.DedTxnMappingId
   --         where dt.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and dt.ServiceId=@serviceID and dt.Month=@month and dt.Year=@year 
   --         and dt.IndicatorDetId=2 and dtd.DocumentNo=RequestNo and dt.IsDeleted=0 and dtd.IsDeleted=0 ),'') 
			Reason end 
			as 	Reason 
			--select *

			------------------------------------------------------------------------------------------#tmpWorkOrder--------------------------
			FROM 	#tmpWorkOrder t
			outer apply (select top 1 lv.FieldValue as VariationStatus from VmVariationDetailsTxn v (NOLOCK) join asissyslovmst lv (NOLOCK) on v.VariationStatus = lv.LovId where v.AssetRegisterId = t.AssetRegisterId and v.IsDeleted = 0 )vs
			
			------------------------------------------------------------------------------------------#tmpWorkOrderF4-------------------------
			union
			SELECT @HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, RequestNo as ServiceRequestNo
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'))-2) as ServiceRequestDate
			--, FORMAT(RequestDate, 'dd-MMM-yyyy HH:MM')  as ServiceRequestDate
			, TypeofRequest as TypeOfServicesRequest, t.MaintenanceType
			, AssetNo, Details as ServiceRequestDetails, RequestorName as RequestNameDesignation
			, 'No' UnderWarranty, ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus, vs.VariationStatus
			, ResponseDateTime as ResponseDateTime
			--,FORMAT(ResponseDateTime, 'dd-MMM-yyyy HH:MM')  ResponseDateTime
			, ResponseDuration, cast(null as Datetime) as ProvisionDate, null as EndDateTime
				,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'))-2) as ServiceWorkCompletionDate
			--, FORMAT(CompletedDateTime, 'dd-MMM-yyyy HH:MM')  as ServiceWorkCompletionDate
			, F1DemeritPoint as F1
			, F4DemeritPoint as F4, F5DemeritPoint as F5, F7DemeritPoint as F7
			,0 AS F8
			, case when TypeofRequest = 'Non Conformance' THEN 'Non Conformance' else 'Service Work (Unscheduled & Others)' end as Remarks, 'F.4' Indicator 
			,  AssetDescription, AssetClassification, WorkGroupDescription as WOWorkgroup,  BuildingNo,  UserAreaName
			,t.CountOfServingArea
			, 'No' ProvideLoaner, 'No' ExcludeDemeritforF1,0 as 'SubParameterDetID' ,'' Reason
			FROM #tmpWorkOrderF4 t --WHERE ServiceRequestId NOT IN (SELECT ServiceRequestId FROM 	#tmpWorkOrder)
			outer apply (select top 1 lv.FieldValue as VariationStatus from VmVariationDetailsTxn v (NOLOCK) join asissyslovmst lv (NOLOCK) on 
			v.VariationStatus = lv.LovId where v.AssetRegisterId = t.AssetRegisterId and v.IsDeleted = 0 )vs 


			----------------------------------------------------------------------------------------#tmpWorkOrderF4D1---------------------------
			union 
			SELECT @HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, RequestNo as ServiceRequestNo
		    ,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'))-2) as ServiceRequestDate
			--,FORMAT(RequestDate, 'dd-MMM-yyyy HH:MM')   as ServiceRequestDate
			, TypeofRequest as TypeOfServicesRequest, MaintenanceType
			, AssetNo, Details as ServiceRequestDetails, RequestorName as RequestNameDesignation
			, 'No' UnderWarranty, ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus, vs.VariationStatus
			, ResponseDateTime as ResponseDateTime
			--, FORMAT(ResponseDateTime, 'dd-MMM-yyyy HH:MM')  ResponseDateTime
			, ResponseDuration, cast(null as Datetime) as ProvisionDate, null as EndDateTime
				,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'))-2) as ServiceWorkCompletionDate
			--, FORMAT(CompletedDateTime, 'dd-MMM-yyyy HH:MM')  as ServiceWorkCompletionDate
			, F1DemeritPoint as F1
			, F4DemeritPoint as F4, F5DemeritPoint as F5, F7DemeritPoint as F7
			,0 AS F8
			, case when TypeofRequest = 'Non Conformance' THEN 'Non Conformance' else 'Service Work (Unscheduled & Others)' end as Remarks, 'F.4' Indicator 
			,  AssetDescription,  AssetClassification, WorkGroupDescription as WOWorkgroup,  BuildingNo,  UserAreaName
			,t.CountOfServingArea
			, 'No' ProvideLoaner, 'No' ExcludeDemeritforF1,0 as 'SubParameterDetID' ,'' Reason
			FROM #tmpWorkOrderF4D1 t --WHERE ServiceRequestId NOT IN (SELECT ServiceRequestId FROM 	#tmpWorkOrder)
			outer apply (select top 1 lv.FieldValue as VariationStatus from VmVariationDetailsTxn v (nolock) join asissyslovmst lv (nolock)  on v.VariationStatus = lv.LovId where v.AssetRegisterId = t.AssetRegisterId and v.IsDeleted = 0 )vs
				
				union 
			------------------------------------------------------------------------------------#tmpWorkOrderF4E2-------------------------------
			
			SELECT @HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, 
			RequestNo as ServiceRequestNo
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'))-2) as ServiceRequestDate
			--, FORMAT(RequestDate, 'dd-MMM-yyyy HH:MM') as ServiceRequestDate
			, TypeofRequest as TypeOfServicesRequest, MaintenanceType
			, AssetNo, Details as ServiceRequestDetails, RequestorName as RequestNameDesignation
			, 'No' UnderWarranty, ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus, vs.VariationStatus
			, ResponseDateTime as ResponseDateTime
			--, FORMAT(ResponseDateTime, 'dd-MMM-yyyy HH:MM') ResponseDateTime
			, ResponseDuration, cast(null as Datetime) as ProvisionDate, null as EndDateTime
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'))-2) as ServiceWorkCompletionDate
			--, FORMAT(CompletedDateTime, 'dd-MMM-yyyy HH:MM')  as ServiceWorkCompletionDate
			, F1DemeritPoint as F1
			, F4DemeritPoint as F4, F5DemeritPoint as F5, F7DemeritPoint as F7
			,0 AS F8
			, case when TypeofRequest = 'Non Conformance' THEN 'Non Conformance' else 'Service Work (Unscheduled & Others)' end as Remarks, 'F.4' Indicator 
			,typedec.AssetTypeDescription as AssetDescription, AssetClassification, WorkGroupDescription as  WOWorkgroup, BuildingNo, UserAreaName
			,t.CountOfServingArea
			, 'No' ProvideLoaner, 'No' ExcludeDemeritforF1,0 as 'SubParameterDetID' ,'' Reason
			FROM #tmpWorkOrderF4E2 t --WHERE ServiceRequestId NOT IN (SELECT ServiceRequestId FROM 	#tmpWorkOrder)
			LEFT Join EngAssetTypeCodeMstDet typedec (NOLOCK) on t.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0
			outer apply (select top 1 lv.FieldValue as VariationStatus from VmVariationDetailsTxn v (nolock)  join asissyslovmst lv (nolock)  on v.VariationStatus = lv.LovId where v.AssetRegisterId = t.AssetRegisterId and v.IsDeleted = 0 )vs
			

			
			-----------------------------------------------------------------#ImpactedWorkGroupA-------------------------------------------------------------

			union
			SELECT @HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, RequestNo as ServiceRequestNo
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'))-2) as ServiceRequestDate
			, TypeofRequest as TypeOfServicesRequest, t.MaintenanceType
			, AssetNo, Details as ServiceRequestDetails, RequestorName as RequestNameDesignation
			, 'No' UnderWarranty, ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus, vs.VariationStatus
			, ResponseDateTime as ResponseDateTime
			, ResponseDuration, cast(null as Datetime) as ProvisionDate, null as EndDateTime
		    ,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'))-2) as ServiceWorkCompletionDate
			, F1DemeritPoint as F1
			, F4DemeritPoint as F4, F5DemeritPoint as F5, F7DemeritPoint as F7
			,0 AS F8
			, case when TypeofRequest = 'Non Conformance' THEN 'Non Conformance' else 'Service Work (Unscheduled & Others)' end as Remarks, 'F.4' Indicator 
			,  AssetDescription, AssetClassification, WorkGroupDescription as WOWorkgroup,  BuildingNo,  UserAreaName
			,t.CountOfServingArea
			, 'No' ProvideLoaner, 'No' ExcludeDemeritforF1,0 as 'SubParameterDetID' ,'' Reason
			FROM #ImpactedWorkGroupA t 
			outer apply (select top 1 lv.FieldValue as VariationStatus from VmVariationDetailsTxn v (NOLOCK)  join asissyslovmst lv (NOLOCK) on 
			v.VariationStatus = lv.LovId where v.AssetRegisterId = t.AssetRegisterId and v.IsDeleted = 0 )vs 
				where not exists (select 1 from #OmissionforSameIndicatorRepeatedDemrit a where a.workorderid = t.workorderid)																		
			-----------------------------------------------------##ImpactedWorkGroupB----------------------------------------------------------------------------
			
						
			union
			SELECT @HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, RequestNo as ServiceRequestNo
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'))-2) as ServiceRequestDate
			, TypeofRequest as TypeOfServicesRequest, t.MaintenanceType
			, AssetNo, Details as ServiceRequestDetails, RequestorName as RequestNameDesignation
			, 'No' UnderWarranty, ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus, vs.VariationStatus
			, ResponseDateTime as ResponseDateTime
			, ResponseDuration, cast(null as Datetime) as ProvisionDate, null as EndDateTime
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'))-2) as ServiceWorkCompletionDate
			, F1DemeritPoint as F1
			, F4DemeritPoint as F4, F5DemeritPoint as F5, F7DemeritPoint as F7
			,0 AS F8
			, case when TypeofRequest = 'Non Conformance' THEN 'Non Conformance' else 'Service Work (Unscheduled & Others)' end as Remarks, 'F.4' Indicator 
			,  AssetDescription, AssetClassification, WorkGroupDescription as WOWorkgroup,  BuildingNo,  UserAreaName
			,t.CountOfServingArea
			, 'No' ProvideLoaner, 'No' ExcludeDemeritforF1,0 as 'SubParameterDetID' ,'' Reason
			FROM #ImpactedWorkGroupB t 
			outer apply (select top 1 lv.FieldValue as VariationStatus from VmVariationDetailsTxn v (NOLOCK) join asissyslovmst lv (NOLOCK) on 
			v.VariationStatus = lv.LovId where v.AssetRegisterId = t.AssetRegisterId and v.IsDeleted = 0 )vs 
			where not exists (select 1 from #OmissionforSameIndicatorRepeatedDemrit a where a.workorderid = t.workorderid)		

			union
			--------------------------------------------------------------------------------------------#tmpWorkOrderF5-----------------------
			
			SELECT 
			@HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, RequestNo as ServiceRequestNo
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'))-2) as ServiceRequestDate
			--, FORMAT(RequestDate, 'dd-MMM-yyyy HH:MM') as ServiceRequestDate
			, t.TypeofReq as TypeOfServicesRequest, t.MaintenanceType as  MaintenanceType
			, AssetNo, Details as ServiceRequestDetails, RequestorName as RequestNameDesignation
			, 'No' UnderWarranty, ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus, vs.VariationStatus
			, ResponseDateTime as ResponseDateTime
			--, FORMAT(ResponseDateTime, 'dd-MMM-yyyy HH:MM') as ResponseDateTime
			, ResponseDuration, cast(null as Datetime) as ProvisionDate, null as EndDateTime
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'))-2) as ServiceWorkCompletionDate
			--, FORMAT(CompletedDateTime, 'dd-MMM-yyyy HH:MM') as ServiceWorkCompletionDate
			, F1DemeritPoint as F1
			, F4DemeritPoint as F4, F5DemeritPoint as F5, F7DemeritPoint as F7
			,0 AS F8
			, case when TypeofRequest = 'Non Conformance' THEN 'Non Conformance' else 'Service Work (Unscheduled & Others)' end as Remarks, 'F.5' Indicator 
			, typedec.AssetTypeDescription as AssetDescription, AssetClassification, WorkGroupDescription as WOWorkgroup, BuildingNo,  UserAreaName
			,t.CountOfServingArea
			, '' ProvideLoaner, 'No' ExcludeDemeritforF1,0 as 'SubParameterDetID' ,'' Reason
			FROM #tmpWorkOrderF5 t --WHERE ServiceRequestId NOT IN (SELECT ServiceRequestId FROM 	#tmpWorkOrder)
			LEFT Join EngAssetTypeCodeMstDet typedec (NOLOCK) on t.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0
			outer apply (select top 1 lv.FieldValue as VariationStatus from VmVariationDetailsTxn v (NOLOCK)  join asissyslovmst lv (NOLOCK)  on v.VariationStatus = lv.LovId where v.AssetRegisterId = t.AssetRegisterId and v.IsDeleted = 0 ) vs
			
			union
			----------------------------------------------------------------------------------------------------#tmpWorkOrderF7---------------
			SELECT 
			@HOSPITALNAME AS HOSPITALNAME
			, @STATENAME AS STATENAME
			, @COMPANYNAME AS COMPANYNAME
			, @MONTHYEAR AS MONTHYEAR
			, FORMAT(isnull(@StartDate,'1900/01/01'),'dd-MMM-yyyy') AS FIRSTDATE
			, FORMAT(isnull(@LastDate,'1900/01/01'),'dd-MMM-yyyy') AS LASTDATE
			, RequestNo as ServiceRequestNo
		   ,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), RequestDate , 113),3,1, '-'),7,1,'-'))-2) as ServiceRequestDate
			--, FORMAT(RequestDate, 'dd-MMM-yyyy HH:MM') as ServiceRequestDate
			, TypeofRequest as TypeOfServicesRequest, '' MaintenanceType
			, AssetNo, Details as ServiceRequestDetails, RequestorName as RequestNameDesignation
			, 'No' UnderWarranty, ISNULL(AssetProcessStatus,'-') AS AssetProcessStatus, vs.VariationStatus
			, ResponseDateTime as ResponseDateTime
		--	, FORMAT(ResponseDateTime, 'dd-MMM-yyyy HH:MM') ResponseDateTime
			, ResponseDuration, cast(null as Datetime) as ProvisionDate, null as EndDateTime
			,SUBSTRING(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'),0,LEN(STUFF(STUFF(CONVERT(CHAR(20), CompletedDateTime , 113),3,1, '-'),7,1,'-'))-2) as ServiceWorkCompletionDate, F1DemeritPoint as F1
			, F4DemeritPoint as F4, F5DemeritPoint as F5, F7DemeritPoint as F7
			,0 AS F8
			, case when TypeofRequest = 'Non Conformance' THEN 'Non Conformance'  else 'Testing & Commissioning' end   as Remarks, 'F.7' Indicator 
			,typedec.AssetTypeDescription as AssetDescription, AssetClassification, WorkGroupDescription as WOWorkgroup, BuildingNo, UserAreaName
			,t.CountOfServingArea
			, 'No' ProvideLoaner, 'No' ExcludeDemeritforF1,0 as 'SubParameterDetID' ,'' Reason
			FROM #tmpWorkOrderF7 t --WHERE ServiceRequestId NOT IN (SELECT ServiceRequestId FROM 	#tmpWorkOrder)
			LEFT Join EngAssetTypeCodeMstDet typedec (NOLOCK)  on t.AssetTypeCodeId=typedec.AssetTypeCodeId and typedec.IsDeleted=0
			outer apply (select top 1 lv.FieldValue as  VariationStatus from VmVariationDetailsTxn v (NOLOCK) join asissyslovmst lv (NOLOCK) on v.VariationStatus = lv.LovId where v.AssetRegisterId = t.AssetRegisterId and v.IsDeleted = 0 ) vs
			ORDER BY ServiceRequestDate asc, AssetNo ASC
END TRY
BEGIN CATCH

insert into AsisErrorLog(Spname,ErrorMessage,createddate)
		values(OBJECT_NAME(@@PROCID),'Error_line: '+CONVERT(VARCHAR(10),error_line())+' - '+error_message(),getdate());
	throw;

END CATCH
SET NOCOUNT OFF
END 			









GO

