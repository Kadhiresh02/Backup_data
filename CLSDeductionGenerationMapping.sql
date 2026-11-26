USE [ASISPATWeb]
GO

/****** Object:  StoredProcedure [dbo].[CLSDeductionGenerationMapping]    Script Date: 8/12/2026 5:40:48 PM ******/
DROP PROCEDURE [dbo].[CLSDeductionGenerationMapping]
GO

/****** Object:  StoredProcedure [dbo].[CLSDeductionGenerationMapping]    Script Date: 8/12/2026 5:40:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
  

--exec [CLSDeductionGenerationMapping] 167,1,3,2020,6301

CREATE procedure [dbo].[CLSDeductionGenerationMapping]-- 2016,5,3,null,1,20000

@HospitalId int,

@month int,

@serviceID int,

@year int

,@DedGenerationType int= null 



--@groupID int,



--@MonthlyServiceFee float

as 

begin

IF OBJECT_ID('tempdb..#GetGMHospitalMstAndGroup') IS NOT NULL

        DROP TABLE #GetGMHospitalMstAndGroup

 
    create table #GetGMHospitalMstAndGroup (HospitalId int)

    insert into #GetGMHospitalMstAndGroup  

    select * from dbo.FN_GetGMHospitalMstAndGroup(@Year,@Month,@HospitalId,@DedGenerationType)


SET TRANSACTION ISOLATION LEVEL READ COMMITTED

Begin try 


--select b.IndicatorNo,d.SubParameterDetId from DedIndicatorMst a 
--inner join DedIndicatorMstDet b on a.IndicatorId=b.IndicatorId and a.IsDeleted=0 and b.IsDeleted=0
--inner join DedSubParameterMst c on c.IndicatorDetId=b.IndicatorDetId and c.IsDeleted=0
--inner join DedSubParameterMstDet d on c.SubParameterId=d.SubParameterId and d.IsDeleted=0
--where a.ServiceId=3 order by b.IndicatorNo


declare @dedgenerationid int

select @dedgenerationid=dedgenerationid from DedGenerationTxn with (nolock)

where IsDeleted=0 and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

and Service=@serviceID and month=@month and year=@year


print @dedgenerationid


	SET FMTONLY OFF;

	SET NOCOUNT ON;

					Declare @serviceKey nvarchar(20),@DemeritPoints float,@monthSel nvarchar(50)

					,@TransDemeritPoint float,@monthval int,@Date DateTime

					,@CompanyName varchar(500),

					@HospitalName varchar(500),

					@MonthYear varchar(50)

					,@MonthlyServiceFee numeric(15,2),

					@FMSMonthlyServiceFee numeric(15,2)


					select @serviceKey = ServiceKey from AsisService where ServiceID=@serviceID

					--select @monthSel = FieldValue from [dbo].[AsisSysLovMst] where LovId = @month	

					--select @monthval = FieldCode from [dbo].[AsisSysLovMst] where LovId = @month


					set @monthval=@month

					SET @Date = CONVERT(DATETIME,'01/'+@monthSel+'/' +CONVERT(VARCHAR(4),@year)		)

					--Create table #DedCalcMap(SlNo int identity,[Date] datetime,Details varchar(max),ServiceRequestNo nvarchar(500), ServiceRequestDesc  nvarchar(500),C1  int,C2  int,C3  int,C4 int,C5  int,C6  int)

					Create table #DedCalcMap(SlNo int identity,[Date] datetime,ReferenceNo nvarchar(500),DemeritPoints float,Details varchar(max),C1  int,C2  int,C3  int,C4 int,C5  int,C6  int,Screenname varchar(max))

	--CLS Indicator

	if(@serviceKey='CLS')

		begin

			if exists(select b.DedGenerationCLSPopupId from DedGenerationSubParamterTxndet a inner join DedGenerationClsPopupTxn b 

on a.DedGenerationSPDetId=b.DedGenerationSPDetId and a.IsDeleted=0 and b.IsDeleted=0

where a.DedGenerationId=@dedgenerationid )

			begin

			print '1'

			--c.1

				insert into #DedCalcMap([Date],ReferenceNo,C1,Details,Screenname)

				select c.Date,c.DocumentNo,

				isnull(TotalDemerit3,0),'','Joint Inspection details' --+isnull(TotalDemerit2,0),''--+isnull(TotalDemerit3,0)+isnull(TotalDemerit4,0) ,''

				from dedgenerationtxn a with (nolock) 

				inner join DedGenerationSubParamterTxndet b  with (nolock) on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c  with (nolock) on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID  and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId =35

			--c.2

				insert into #DedCalcMap([Date],ReferenceNo,C2,Details,Screenname)

				select c.Date,c.DocumentNo,

				isnull(TotalDemerit1,0)+--isnull(TotalDemerit2,0)+isnull(TotalDemerit3,0)+

				isnull(TotalDemerit2,0) ,'','Daily Cleaning Activity(Exceptions)' 

				from dedgenerationtxn a  with (nolock) 

				inner join DedGenerationSubParamterTxndet b with (nolock)  on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c with (nolock)  on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(1126)

				union all

				select c.Date,c.DocumentNo,

				--isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0)+isnull(TotalDemerit3,0)+

				isnull(TotalDemerit1,0) ,(select top 1 details from SrServiceRequestMst(nolock) where RequestNo=c.DocumentNo),'Service Request' 

				from dedgenerationtxn a with (nolock) 

				inner join DedGenerationSubParamterTxndet b  with (nolock) on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c with (nolock)  on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(1127)

				union all

				select c.Date,c.DocumentNo,

				--isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0)+				isnull(TotalDemerit3,0)+

				isnull(TotalDemerit4,0) ,'','Late Hour Entry' 

				from dedgenerationtxn a  with (nolock)

				inner join DedGenerationSubParamterTxndet b with (nolock)  on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c  with (nolock) on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(1128)

				update #DedCalcMap set Details = 'Daily Cleaning Activity(Exceptions)' where ReferenceNo is not null and ReferenceNo like '%DCAE%'
				update #DedCalcMap set Details = 'Periodic Work Record' where ReferenceNo is not null and ReferenceNo like '%PWR%'
				--update #DedCalcMap set Details = 'Service Request' where ReferenceNo is not null and ReferenceNo like '%SR%'
			--c.3

				insert into #DedCalcMap([Date],ReferenceNo,C3,Details,Screenname)

				select c.Date,c.DocumentNo,

				--isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0)+isnull(TotalDemerit3,0)+

				isnull(TotalDemerit1,0) ,(select top 1 details from SrServiceRequestMst(nolock) where RequestNo=c.DocumentNo),'Service Request' 

				from dedgenerationtxn a with (nolock)

				inner join DedGenerationSubParamterTxndet b with (nolock)  on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c with (nolock)  on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(1129)

				union all

					select c.Date,c.DocumentNo,

				isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0)

				--+isnull(TotalDemerit3,0)+isnull(NCRDemeritPoint,0) 

				,'','Daily Cleaning Activity(Exceptions)' 

				from dedgenerationtxn a  with (nolock)

				inner join DedGenerationSubParamterTxndet b  with (nolock) on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c  with (nolock) on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(2174)

				update #DedCalcMap set Details = 'Daily Cleaning Activity(Exceptions)' where ReferenceNo is not null and ReferenceNo like '%DCAE%'
				update #DedCalcMap set Details = 'Periodic Work Record' where ReferenceNo is not null and ReferenceNo like '%PWR%'
				--update #DedCalcMap set Details = 'Service Request' where ReferenceNo is not null and ReferenceNo like '%SR%'

			--c.4

				insert into #DedCalcMap([Date],ReferenceNo,C4,Details,Screenname)

				select c.Date,c.DocumentNo,

				--isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0)+isnull(TotalDemerit3,0)+

				((isnull(TotalDemerit1,0))) ,(select top 1 details from SrServiceRequestMst(nolock) where RequestNo=c.DocumentNo),'Service Request' 

				from dedgenerationtxn a with (nolock) 

				inner join DedGenerationSubParamterTxndet b with (nolock)  on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c  with (nolock) on b.DedGenerationSPDetId=c.DedGenerationSPDetId

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(1131)

				union all

					select c.Date,c.DocumentNo,

				isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0),'',

				--+

				--isnull(TotalDemerit3,0)+

				--isnull(TotalDemerit4,0) 

				'Daily Cleaning Activity(Exceptions)'

				from dedgenerationtxn a  with (nolock)

				inner join DedGenerationSubParamterTxndet b  with (nolock) on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c  with (nolock) on b.DedGenerationSPDetId=c.DedGenerationSPDetId

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(1130)

			--c.5

				insert into #DedCalcMap([Date],ReferenceNo,C5,Details,Screenname)

				select c.Date,c.DocumentNo,

				--isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0)+isnull(TotalDemerit3,0)+

				isnull(TotalDemerit1,0) ,(select top 1 details from SrServiceRequestMst(nolock) where RequestNo=c.DocumentNo),'Service Request' 

				from dedgenerationtxn a  with (nolock)

				inner join DedGenerationSubParamterTxndet b  with (nolock) on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c  with (nolock) on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(1132)

			--c.6

				insert into #DedCalcMap([Date],ReferenceNo,C6,Details,Screenname)

				select c.Date,c.DocumentNo,

				isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0)+isnull(TotalDemerit3,0)+isnull(TotalDemerit4,0) ,(select top 1 details from SrServiceRequestMst(nolock) where RequestNo=c.DocumentNo),'Daily Cleaning Activity(Exceptions)' 

				from dedgenerationtxn a  with (nolock)

				inner join DedGenerationSubParamterTxndet b  with (nolock) on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c  with (nolock) on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(1133)

				union all

				select c.Date,c.DocumentNo,

				--isnull(TotalDemerit1,0)+isnull(TotalDemerit2,0)+isnull(TotalDemerit3,0)+

				isnull(TotalDemerit1,0) ,(select top 1 details from SrServiceRequestMst(nolock) where RequestNo=c.DocumentNo),'Service Request' 

				from dedgenerationtxn a with (nolock) 

				inner join DedGenerationSubParamterTxndet b with (nolock) on a.DedGenerationId=b.DedGenerationId and a.IsDeleted=0 and b.IsDeleted=0

				inner join DedGenerationClsPopupTxn c  with (nolock) on b.DedGenerationSPDetId=c.DedGenerationSPDetId and c.IsDeleted=0

				where 	a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.Service=@serviceID and c.IsDeleted=0

				and a.Year=@year and a.Month=@month and b.SubParameterDetId in(2183)



			end 

			else

			begin

			--C1

			print '2'

					Declare @C1sp1 Float

					Declare @C1sp2 Float

					print 'C1'



					--Select @C1sp1=sum(case  when [Floor]in (1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068) then 1 else 0 end

					--+case  when WallsDoors in (1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068) then 1 else 0 end

					--+case  when [Ceiling]in (1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068) then 1 else 0 end

					--+case  when [Windows]in (1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068) then 1 else 0 end

					--+case  when Fixtures in (1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068) then 1 else 0 end

					--+case  when FurnituresFitting in (1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068) then 1 else 0 end)

					--from ClsJointInspectionDetailTxndet jid

					--inner join ClsJointInspectionDetailTxn  ji on ji.JIInspectionId=jid.JIInspectionId

					--where jid.IsDeleted=0 and datepart(month,ji.JIDate)=@month and jid.HospitalId=@HospitalId and datepart(YEAR,ji.JIDate)=@year and ji.status=1040

					

					--set @TransDemeritPoint=coalesce(@C1sp1,0)+coalesce(@C1sp2,0)

					

					--sum(case when cljtxdet.Floor=1051 or cljtxdet.Floor=1054 or cljtxdet.Floor=1053 then 0 else 1 end) +

							--sum(case when cljtxdet.WallsDoors=1051 or cljtxdet.WallsDoors=1054 or cljtxdet.WallsDoors=1053 then 0 else 1 end) +

							--sum(case when cljtxdet.Windows=1051 or cljtxdet.Windows=1054 or cljtxdet.Windows=1053  then 0 else 1 end) +

							--sum(case when cljtxdet.Fixtures=1051 or cljtxdet.Fixtures=1054 or cljtxdet.Fixtures=1053 then 0 else 1 end) +

							--sum(case when cljtxdet.FurnituresFitting=1051 or cljtxdet.FurnituresFitting=1054 or cljtxdet.FurnituresFitting=1053 then 0 else 1 end)+

							--sum(case when cljtxdet.Ceiling=1051 or cljtxdet.Ceiling=1054 or cljtxdet.Ceiling=1053 then 0 else 1 end)





					insert into #DedCalcMap([Date],ReferenceNo,C1,Details,Screenname)

					select Date,ReferenceNo,sum(C1) as C1,'' as Details,'Joint Inspection Details' as Screenname from (

					select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when cljtxdet.WallsDoors=1051 or cljtxdet.WallsDoors=1054 or cljtxdet.WallsDoors=1053 then 0 else 1 end) as C1,'' as Details ,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx  with (nolock)

							  join FmsUserAreaMst usrs with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							 join ClsJointInspectionDetailTxnDet cljtxdet  with (nolock) on cljtx.JIInspectionId=cljtxdet.JIInspectionId 

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0 and cljtxdet.IsDeleted=0   

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1040  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

							 group by cljtx.JIDate ,JIDocumentNo

					union all

					select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when cljtxdet.Windows=1051 or cljtxdet.Windows=1054 or cljtxdet.Windows=1053  then 0 else 1 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx  with (nolock)

							  join FmsUserAreaMst usrs  with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							 join ClsJointInspectionDetailTxnDet cljtxdet  with (nolock) on cljtx.JIInspectionId=cljtxdet.JIInspectionId 

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0 and cljtxdet.IsDeleted=0   

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1040  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

							  group by cljtx.JIDate ,JIDocumentNo

					union all

					select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when cljtxdet.Fixtures=1051 or cljtxdet.Fixtures=1054 or cljtxdet.Fixtures=1053 then 0 else 1 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx with (nolock)

							  join FmsUserAreaMst usrs  with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							 join ClsJointInspectionDetailTxnDet cljtxdet  with (nolock) on cljtx.JIInspectionId=cljtxdet.JIInspectionId 

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0 and cljtxdet.IsDeleted=0   

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1040  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

							  group by cljtx.JIDate ,JIDocumentNo

					union all

					select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when cljtxdet.FurnituresFitting=1051 or cljtxdet.FurnituresFitting=1054 or cljtxdet.FurnituresFitting=1053 then 0 else 1 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx with (nolock) 

							  join FmsUserAreaMst usrs with (nolock)on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							 join ClsJointInspectionDetailTxnDet cljtxdet with (nolock)  on cljtx.JIInspectionId=cljtxdet.JIInspectionId 

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0 and cljtxdet.IsDeleted=0   

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1040  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

							  group by cljtx.JIDate ,JIDocumentNo

					union all

					select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when cljtxdet.Ceiling=1051 or cljtxdet.Ceiling=1054 or cljtxdet.Ceiling=1053 then 0 else 1 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx  with (nolock)

							  join FmsUserAreaMst usrs with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							 join ClsJointInspectionDetailTxnDet cljtxdet  with (nolock) on cljtx.JIInspectionId=cljtxdet.JIInspectionId 

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0 and cljtxdet.IsDeleted=0   

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1040  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

							  group by cljtx.JIDate ,JIDocumentNo

							  

							    	union all

					select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when cljtxdet.Floor=1051 or cljtxdet.Floor=1054 or cljtxdet.Floor=1053 then 0 else 1 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx with (nolock) 

							  join FmsUserAreaMst usrs with (nolock)  on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							 join ClsJointInspectionDetailTxnDet cljtxdet  with (nolock) on cljtx.JIInspectionId=cljtxdet.JIInspectionId 

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0 and cljtxdet.IsDeleted=0   

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1040  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

							  group by cljtx.JIDate ,JIDocumentNo
							  
						------------------------NEW IMPLEMENTATION FOR OPEN AND NOT DONE-------------------------------	  
							 union all 
							  
							  select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when c.Walls=1  then 1 else 0 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx with (nolock) 

							  join FmsUserAreaMst usrs  with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							  join ClsUserAreaDetailsMst a  with (nolock) on usrs.FmsUserAreaId =a.FmsUserAreaId
							  join ClsUserLocationDetailsMst b with (nolock) on a.ClsUserAreaId=b.ClsUserAreaId
							  join ClsUserLocationJIElementMst c  with (nolock) on c.ClsUserLocationId=b.ClsUserLocationId

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0  

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1039  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
							  and b.isdeleted=0 and b.Status=413

							  group by cljtx.JIDate ,JIDocumentNo


							   union all 
							  
							  select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when c.Floor=1  then 1 else 0 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx  with (nolock) 

							  join FmsUserAreaMst usrs  with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							  join ClsUserAreaDetailsMst a  with (nolock) on usrs.FmsUserAreaId =a.FmsUserAreaId
							  join ClsUserLocationDetailsMst b  with (nolock) on a.ClsUserAreaId=b.ClsUserAreaId
							  join ClsUserLocationJIElementMst c  with (nolock) on c.ClsUserLocationId=b.ClsUserLocationId

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0  

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1039  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
							  and b.isdeleted=0 and b.Status=413

							  group by cljtx.JIDate ,JIDocumentNo


							   union all 
							  
							  select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when c.WindowsDoors=1  then 1 else 0 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx  with (nolock)

							  join FmsUserAreaMst usrs  with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							  join ClsUserAreaDetailsMst a  with (nolock) on usrs.FmsUserAreaId =a.FmsUserAreaId
							  join ClsUserLocationDetailsMst b  with (nolock) on a.ClsUserAreaId=b.ClsUserAreaId
							  join ClsUserLocationJIElementMst c with (nolock)  on c.ClsUserLocationId=b.ClsUserLocationId

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0  

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1039  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
							  and b.isdeleted=0 and b.Status=413

							  group by cljtx.JIDate ,JIDocumentNo


							   union all 
							  
							  select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when c.FurnitureFixtureEquipment=1  then 1 else 0 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx  with (nolock)

							  join FmsUserAreaMst usrs  with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							  join ClsUserAreaDetailsMst a  with (nolock) on usrs.FmsUserAreaId =a.FmsUserAreaId
							  join ClsUserLocationDetailsMst b with (nolock) on a.ClsUserAreaId=b.ClsUserAreaId
							  join ClsUserLocationJIElementMst c  with (nolock) on c.ClsUserLocationId=b.ClsUserLocationId

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0  

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1039  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
							  and b.isdeleted=0 and b.Status=413

							  group by cljtx.JIDate ,JIDocumentNo


							   union all 
							  
							  select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when c.ReceptaclesContainers=1  then 1 else 0 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx with (nolock)

							  join FmsUserAreaMst usrs  with (nolock) on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							  join ClsUserAreaDetailsMst a with (nolock) on usrs.FmsUserAreaId =a.FmsUserAreaId
							  join ClsUserLocationDetailsMst b  with (nolock) on a.ClsUserAreaId=b.ClsUserAreaId
							  join ClsUserLocationJIElementMst c with (nolock) on c.ClsUserLocationId=b.ClsUserLocationId

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0  

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1039  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
							  and b.isdeleted=0 and b.Status=413

							  group by cljtx.JIDate ,JIDocumentNo



							   union all 
							  
							  select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case when c.Ceiling=1  then 1 else 0 end) as C1,'' as Details,'' as Screenname

					from 

							  ClsJointInspectionDetailTxn cljtx  with (nolock)

							  join FmsUserAreaMst usrs  with (nolock)on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

							  join ClsUserAreaDetailsMst a  with (nolock)on usrs.FmsUserAreaId =a.FmsUserAreaId
							  join ClsUserLocationDetailsMst b with (nolock)  on a.ClsUserAreaId=b.ClsUserAreaId
							  join ClsUserLocationJIElementMst c with (nolock)  on c.ClsUserLocationId=b.ClsUserLocationId

							 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0  

							 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1039  and cljtx.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)
							  and b.isdeleted=0 and b.Status=413

							  group by cljtx.JIDate ,JIDocumentNo
							  
							  
							  )a
							  ---------------------------------------------------------------------------------------------------
					--union all

					--select cljtx.JIDate as Date,JIDocumentNo as ReferenceNo,sum(case  when FurnituresFitting in (1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068) then 1 else 0 end) as C1,'' as Details

					--from 

					--		  ClsJointInspectionDetailTxn cljtx 

					--		  join FmsUserAreaMst usrs on cljtx.FmsUserAreaId=usrs.FmsUserAreaId

					--		 join ClsJointInspectionDetailTxnDet cljtxdet on cljtx.JIInspectionId=cljtxdet.JIInspectionId 

					--		 where cljtx.IsDeleted=0  and cljtx.IsDeleted=0 and cljtxdet.IsDeleted=0   

					--		 and cljtx.Year=@Year and cljtx.Month=@Month and cljtx.Status=1040  and cljtx.HospitalId=@HospitalId) a

					group by a.Date,a.ReferenceNo



					--insert into #DedCalcMap([Date],ReferenceNo,C1,Details)

					--select  NCRDateTime as Date,NCRNo as ReferenceNo,Count('1') as C1,'' as Details

					----coalesce(sum(datediff(dd,ncr.Createddate,case when NCRStatus=802 then ncr.modifieddate else  EOMONTH ( dateadd(mm,0,ncr.Createddate) ) end )+1),0) 

					--from FmsNCREntryTxn ncr

					--inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId and ded.IndicatorNo='C.1' and ded.IsDeleted=0

					--inner join fmsuserlocationmst FULM on ncr.userlocationID=FULM.UserLocationId and ncr.[Service]=3 --and NCRStatus=800 					

					--where ncr.IsDeleted=0  and ncr.HospitalId=@HospitalId  

					--and datepart(month,ncr.NCRDateTime)=@month  and datepart(YEAR,ncr.NCRDateTime)=@year

					--group by NCRNo,NCRDateTime order by NCRDateTime

					--group by FULM.FmsUserAreaId



			--C2

			print 'C2'

					Declare @C2sp1 Float

					Declare @C2sp2 Float

					Declare @C2sp3 Float

					Declare @C2sp4 Float

					set @TransDemeritPoint = '';


					select ServiceRequestId into #OmitNCR from SrServiceRequestLlsClsTxn  with (nolock)
					where  Category = 2675 and Elements = 2705 and NonConformance = 2725

					insert into #OmitNCR
					select ServiceRequestId  from SrServiceRequestLlsClsTxn  with (nolock)
					where  Category = 2675 and Elements = 2705 and NonConformance = 2726

-------------------------------------------- Old Query -------------------------------------------

--										insert into #DedCalcMap([Date],ReferenceNo,C2,Details,Screenname)

--					select [DateTime],RequestNo, sum(datediff(dd,a.CreatedDate,a.modifieddate)+1), Details, 'Service Request' from (

--					select  [DateTime],RequestNo, sr.userlocationID,src.NonConformance,
--				 case when @month = datepart(mm,sr.datetime) then min(convert(date,sr.DateTime))
--when @month > datepart(mm,sr.datetime) then CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end as createddate,
--				    max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime 
--when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and (@month = month(getdate()))) then getdate()
--when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
--when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
--when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
--when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then src.CompletedDateTime 
--when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month = month(getdate())) then src.CompletedDateTime   end ))modifieddate
--                              ,Details,'Service Request' as Screenname

--					from SrServiceRequestMst  SR 

--					inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2725,2726,2729,4664

--																																		,4665,4666,4667,4668,4669

--																																		,4670,4671,4672)  and src.TypeOfRequest=2317

--					inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

--					where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  
--					and src.ServiceRequestId not in (select ServiceRequestId from #OmitNCR)

--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

--					and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

--					or (((datepart(month,Sr.[DateTime]) < @month  and( datepart(YEAR,SR.[DateTime])=@year or datepart(YEAR,SR.[DateTime]) <@year)
--							) )  and sr.Status not in (2314,2313) and
--					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
--					or (((datepart(month,Sr.[DateTime]) < @month  and( datepart(YEAR,SR.[DateTime])=@year or datepart(YEAR,SR.[DateTime]) <@year)
--							))  and sr.Status  in (2314,2313) and
--					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)
--                              group by sr.userlocationID,src.NonConformance,[DateTime],RequestNo,Details--,convert(date,sr.CreatedDate)

--					)a 

--					group by [DateTime],RequestNo,Details,Screenname



--					union all

--					select T.Date,T.DocumentNo,TotalException,'','Daily Cleaning Activity(Exceptions)'  from ClsDcaCleansingDoneTxnDet  TD

--					inner join ClsDailyCleaningActivityExceptionsTxn T on T.CleaningActivityId=TD.CleaningActivityId and IsCleansingDone=0

--					where t.IsDeleted=0 and TD.Isdeleted = 0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year

--					union all

--					select T.Date,T.DocumentNo,TotalException,'','Daily Cleaning Activity(Exceptions)' from ClsDcaCleansingDoneTxnDet TD 

--					inner join ClsDailyCleaningActivityExceptionsTxn T on T.CleaningActivityId=TD.CleaningActivityId and IsCleansingDone=1

--					where t.IsDeleted=0 and TD.Isdeleted = 0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year

--					union all

--					select T.Date,T.DocumentNo,1,'','Periodic Record'  from ClsPeriodicWorkRecordTxndet TD 

--							inner join ClsPeriodicWorkRecordTxn T on T.PeriodicWorkId=TD.PeriodicWorkId and (td.NotCarriedOut=1 or td.NotToSchedule=1)

--							where t.IsDeleted=0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year and td.isdeleted=0



--					union all

--					select EntryDate,f.UserAreaCode,DemeritPoint,'','Late Hour Entry'  from ClsLateHourEntryTxn a inner join ClsLateHourEntryTxndet  b

--					inner join ClsUserAreaDetailsMst c on b.ClsUserAreaId=c.ClsUserAreaId

--					inner join FmsUserAreaMst f on c.FmsUserAreaId=f.FmsUserAreaId

--							on a.LateEntryId=b.LateEntryId
--														cross apply (select distinct  c.ClsUserAreaId as ClsUserLocationId  from ClsUserAreaDetailsMst c 
--							inner join ClsUserLocationDetailsMst d on  b.ClsUserAreaId=c.ClsUserAreaId and c.IsDeleted=0 and c.Status=413 and  c.ClsUserAreaId=d.ClsUserAreaId and d.Status=413 and d.IsDeleted=0
--							 ) c1


--							where a.IsDeleted=0 and datepart(month,a.EntryDate)=@month and a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)    and datepart(YEAR,a.EntryDate)=@year

--							union all			

--					select b.DateTime,b.RequestNo,c.val3,Details,'Service Request' 	from ( select distinct SR.DateTime,Sr.RequestNo,FULM.FmsUserAreaId,Details	from SrServiceRequestMst  SR 

--					inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723) and src.TypeOfRequest=2317

					

--					inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

--					where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  

--					and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

--				or (((datepart(month,Sr.[DateTime]) < @month  and( datepart(YEAR,SR.[DateTime])=@year or datepart(YEAR,SR.[DateTime]) <@year)
--							) )  and sr.Status not in (2314,2313) and
--					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
--					or (((datepart(month,Sr.[DateTime]) < @month  and( datepart(YEAR,SR.[DateTime])=@year or datepart(YEAR,SR.[DateTime]) <@year)
--							))  and sr.Status  in (2314,2313) and
--					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)

--					)b inner join (

					
--					select  f.RequestNo,e.FmsUserAreaId,coalesce(val1*val,0)val3 from (

					

--					select a.FmsUserAreaId,count(*)val1 from ClsUserLocationDetailsMst a

--					where a.[Status]=413 and a.isdeleted=0  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

--					group by a.FmsUserAreaId

--					) e inner join (

			
--					select RequestNo,

--					FULM.FmsUserAreaId,

--					(datediff(dd,case when @month = datepart(mm,sr.datetime) then min(convert(date,sr.DateTime))
--when @month > datepart(mm,sr.datetime) then CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
--					max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime 
--when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and (@month = month(getdate()))) then getdate()
--when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
--when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
--when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
--when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then src.CompletedDateTime 
--when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month = month(getdate())) then src.CompletedDateTime   end )))+1) Val

--					from SrServiceRequestMst  SR 

--					inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

--					inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId  and FULM.[Status]=413  and FULM.isdeleted=0

--					where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) 

--					and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year
--					or (((datepart(month,Sr.[DateTime]) < @month  and( datepart(YEAR,SR.[DateTime])=@year or datepart(YEAR,SR.[DateTime]) <@year)
--							))  and sr.Status not in (2314,2313) and
--					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
--					or (((datepart(month,Sr.[DateTime]) < @month  and( datepart(YEAR,SR.[DateTime])=@year or datepart(YEAR,SR.[DateTime]) <@year)
--							))  and sr.Status  in (2314,2313) and
--					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
--					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)

--					group by FULM.FmsUserAreaId,src.NonConformance,[DateTime],RequestNo


--					)f on e.FmsUserAreaId=f.FmsUserAreaId

					

--					)c on b.FmsUserAreaId=c.FmsUserAreaId and b.requestno=c.RequestNo
------------------------------------------------------------- New Query (17-03-2022) --------------------------------------
					insert into #DedCalcMap([Date],ReferenceNo,C2,Details,Screenname)

					select [DateTime],RequestNo, sum(datediff(dd,a.CreatedDate,a.modifieddate)+1), Details, 'Service Request' from (

					select  [DateTime],RequestNo, sr.userlocationID,src.NonConformance,
					--min(convert(date,sr.DateTime))CreatedDate,max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime when sr.Status not in (2314,2313) and datepart(mm,getdate())>datepart(mm,sr.datetime


     --                  ) then  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) when sr.Status not in (2314,2313) and datepart(mm,getdate())=datepart(mm,sr.datetime) then  getdate() end ))modifieddate
	             case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end as createddate,
					max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then src.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then src.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month) end ))modifieddate
                              ,Details,'Service Request' as Screenname

					from SrServiceRequestMst  SR  with (nolock)

					inner join SrServiceRequestLlsClsTxn src with (nolock)  on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2725,2726,2729,4664

																																		,4665,4666,4667,4668,4669

																																		,4670,4671,4672)  and src.TypeOfRequest=2317

					inner join fmsuserlocationmst FULM with (nolock)  on sr.userlocationID=FULM.UserLocationId 

					where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  
					and src.ServiceRequestId not in (select ServiceRequestId from #OmitNCR)

					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

					and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) )  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and src.ServiceRequestId not in (select ServiceRequestId from #OmitNCR))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year and src.ServiceRequestId not in (select ServiceRequestId from #OmitNCR))

					--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)

					group by sr.userlocationID,src.NonConformance,[DateTime],RequestNo,Details--,convert(date,sr.CreatedDate)

					)a --and NCRStatus=800 )

					group by [DateTime],RequestNo,Details,Screenname



					union all

					select T.Date,T.DocumentNo,TotalException,'','Daily Cleaning Activity(Exceptions)'  from ClsDcaCleansingDoneTxnDet  TD with (nolock) 

					inner join ClsDailyCleaningActivityExceptionsTxn T with (nolock)  on T.CleaningActivityId=TD.CleaningActivityId and IsCleansingDone=0

					where t.IsDeleted=0 and TD.Isdeleted = 0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year

					union all

					select T.Date,T.DocumentNo,TotalException,'','Daily Cleaning Activity(Exceptions)' from ClsDcaCleansingDoneTxnDet TD  with (nolock)

					inner join ClsDailyCleaningActivityExceptionsTxn T  with (nolock) on T.CleaningActivityId=TD.CleaningActivityId and IsCleansingDone=1

					where t.IsDeleted=0 and TD.Isdeleted = 0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year

					union all

					select T.Date,T.DocumentNo,1,'','Periodic Record'  from ClsPeriodicWorkRecordTxndet TD  with (nolock)

							inner join ClsPeriodicWorkRecordTxn T with (nolock) on T.PeriodicWorkId=TD.PeriodicWorkId and (td.NotCarriedOut=1 or td.NotToSchedule=1)

							where t.IsDeleted=0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year and td.isdeleted=0



					union all

					select EntryDate,f.UserAreaCode,DemeritPoint,'','Late Hour Entry'  from ClsLateHourEntryTxn a with (nolock)  inner join ClsLateHourEntryTxndet  b with (nolock) 

					inner join ClsUserAreaDetailsMst c with (nolock) on b.ClsUserAreaId=c.ClsUserAreaId

					inner join FmsUserAreaMst f  with (nolock) on c.FmsUserAreaId=f.FmsUserAreaId

							on a.LateEntryId=b.LateEntryId
														cross apply (select distinct  c.ClsUserAreaId as ClsUserLocationId  from ClsUserAreaDetailsMst c with (nolock)  
							inner join ClsUserLocationDetailsMst d with (nolock)  on  b.ClsUserAreaId=c.ClsUserAreaId and c.IsDeleted=0 and c.Status=413 and  c.ClsUserAreaId=d.ClsUserAreaId and d.Status=413 and d.IsDeleted=0
							 ) c1


							where a.IsDeleted=0 and datepart(month,a.EntryDate)=@month and a.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)    and datepart(YEAR,a.EntryDate)=@year

							union all

							

					select b.DateTime,b.RequestNo,c.val3,Details,'Service Request' 	from ( select distinct SR.DateTime,Sr.RequestNo,FULM.FmsUserAreaId,Details	from SrServiceRequestMst  SR  with (nolock)

					inner join SrServiceRequestLlsClsTxn src with (nolock)  on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723) and src.TypeOfRequest=2317

					

					inner join fmsuserlocationmst FULM with (nolock)  on sr.userlocationID=FULM.UserLocationId 

					where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  

					and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

				or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) )  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)

					)b inner join (

					
					select  f.RequestNo,e.FmsUserAreaId,coalesce(val1*val,0)val3 from (

					

					select a.FmsUserAreaId,count(*)val1 from ClsUserLocationDetailsMst a with (nolock)

					where a.[Status]=413 and a.isdeleted=0  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

					group by a.FmsUserAreaId

					) e inner join (

					--select a.FmsUserAreaId,sum(val)val2 from(

					select RequestNo,

					FULM.FmsUserAreaId,

					(datediff(dd,case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
						max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then src.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then src.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month)  end )))+1) Val

					from SrServiceRequestMst  SR  with (nolock)

					inner join SrServiceRequestLlsClsTxn src  with (nolock) on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

					inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId  and FULM.[Status]=413  and FULM.isdeleted=0

					where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) 

					and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)

					group by FULM.FmsUserAreaId,src.NonConformance,[DateTime],RequestNo

					--)a group by a.FmsUserAreaId

					)f on e.FmsUserAreaId=f.FmsUserAreaId

					

					)c on b.FmsUserAreaId=c.FmsUserAreaId and b.requestno=c.RequestNo







		

			--C3

			print 'C3'

					Declare @C3sp1 Float

			

					set @TransDemeritPoint = '';



					insert into #DedCalcMap([Date],ReferenceNo,C3,Details,Screenname)

					

					select T.Date,T.DocumentNo,sum(td.NotCarriedOut),'','Periodic Record'  from ClsPeriodicWorkRecordTxndet TD  with (nolock)

							inner join ClsPeriodicWorkRecordTxn T with (nolock)  on T.PeriodicWorkId=TD.PeriodicWorkId and td.NotCarriedOut=1 --or td.NotToSchedule=1)

							where t.IsDeleted=0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year

							and td.isdeleted=0

group by T.Date,T.DocumentNo

union all

					select T.Date,T.DocumentNo,sum(td.NotToSchedule),'','Periodic Record'  from ClsPeriodicWorkRecordTxndet TD  with (nolock)

							inner join ClsPeriodicWorkRecordTxn T  with (nolock) on T.PeriodicWorkId=TD.PeriodicWorkId and td.NotToSchedule=1 --or td.NotToSchedule=1)

							where t.IsDeleted=0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and datepart(YEAR,t.Date)=@year

							and td.isdeleted=0

		group by 		T.Date,T.DocumentNo

					union all

	--				select [DateTime],RequestNo, sum(datediff(dd,a.CreatedDate,a.modifieddate)+1), Details,Screenname  from (

	--				select  [DateTime],RequestNo, sr.userlocationID,src.NonConformance,min(convert(date,sr.DateTime))CreatedDate,max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime when sr.Status!=2314 and datepart(mm,getdate())>datepart(mm,sr.datetime)


 --then  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) when sr.Status!=2314 and datepart(mm,getdate())=datepart(mm,sr.datetime) then  getdate() end ))modifieddate,Details,'Service Request' as Screenname 

	--				from SrServiceRequestMst  SR 

	--						inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2725,2727,2726,2729,4664

	--																									,4665,4666,4667,4668,4669

	--																									,4670,4671,4672)  and src.TypeOfRequest=2317

	--						inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

	--						where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  ) -- and Sr.[Status]=2311  

	--						and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  

	--						and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

	--						--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)

	--						group by sr.userlocationID,src.NonConformance,[DateTime],RequestNo,Details --,Screenname--,convert(date,sr.CreatedDate)

	--				)a --and NCRStatus=800 )

	--				group by [DateTime],RequestNo,Details,Screenname


		select SR.DateTime as Date, SR.RequestNo as ReferenceNo,
		(datediff(dd,case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
					max(convert(date,case when sr.Status in (2314,2313) then SRLC.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then SRLC.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then SRLC.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month)  end )))+1) DemeritPoints

				, Details,'Service Request' 

						from SrServiceRequestMst  SR with (nolock)	 				

							inner join SrServiceRequestLlsClsTxn SRLC  with (nolock) on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2725,2727,4664

																										,4665,4666,4667,4668,4669

																										,4670,4671,4672)   and srlc.TypeOfRequest=2317-- and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM with (nolock) on sr.userlocationID=FULM.UserLocationId
							 inner join  FmsNCREntryTxn NCR with (nolock)  on  NCR.ServiceRequestId=sr.ServiceRequestId
							where SR.IsDeleted=0 and sr.[service]=3 and SR.Status != 2315--and Sr.[Status]=2311  
							and srlc.ServiceRequestId not in (select ServiceRequestId from #OmitNCR)
							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)   --and sr.[Status]!=2315 

							--and NonConformance in (2725,2726) and [Elements] in(2705)

							and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

							or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(srlc.CompletedDateTime)=@Month and year(srlc.CompletedDateTime)=@year)

				group by SR.DateTime,SR.RequestNo,Details

					union all

					select T.Date,T.DocumentNo,TotalException,'','Daily Cleaning Activity(Exceptions)'  from ClsDcaCleansingDoneTxnDet  TD with (nolock)

					inner join ClsDailyCleaningActivityExceptionsTxn T  with (nolock) on T.CleaningActivityId=TD.CleaningActivityId and IsCleansingDone=0

							where t.IsDeleted=0 and TD.Isdeleted = 0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year

					union all

					select T.Date,T.DocumentNo,TotalException,'','Daily Cleaning Activity(Exceptions)'  from ClsDcaCleansingDoneTxnDet TD with (nolock)  

					inner join ClsDailyCleaningActivityExceptionsTxn T with (nolock)  on T.CleaningActivityId=TD.CleaningActivityId and IsCleansingDone=1

							where t.IsDeleted=0 and TD.Isdeleted = 0 and datepart(month,t.Date)=@month  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and datepart(YEAR,t.Date)=@year

					union all

					--select b.DateTime,b.RequestNo,c.val3,'Service Request'	from (select SR.DateTime,Sr.RequestNo,FULM.FmsUserAreaId	from SrServiceRequestMst  SR 

					--inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723) and src.TypeOfRequest=2317

					--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

					--where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

					--and SR.HospitalId=@HospitalId  

					--and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

					----and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)	

					

					--)b inner join (

					

		

					--										select e.FmsUserAreaId,coalesce(val1*val2,0)val3 from (select a.FmsUserAreaId,count(*)val1 from ClsUserLocationDetailsMst a

					--where a.[Status]=413  and HospitalId=@HOSPITALID

					--group by a.FmsUserAreaId) e inner join (select a.FmsUserAreaId,sum(val)val2 from(

					--select 

					--FULM.FmsUserAreaId,

					--(datediff(dd,min(convert(date,sr.DateTime)),max(convert(date,case when sr.Status=2314 then src.CompletedDateTime else  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) end )))+1) Val

					--from SrServiceRequestMst  SR 

					--inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

					--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId  and FULM.[Status]=413 

					--where SR.IsDeleted=0 and sr.[service]=3 -- and Sr.[Status]=2311  

					--and SR.HospitalId=@HOSPITALID  

					--and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

					--group by FULM.FmsUserAreaId,src.NonConformance,[DateTime],RequestNo)a group by a.FmsUserAreaId)f on e.FmsUserAreaId=f.FmsUserAreaId

					--)c on b.FmsUserAreaId=c.FmsUserAreaId

					

					select b.DateTime,b.RequestNo,c.val3,Details,'Service Request' 	from ( select distinct SR.DateTime,Sr.RequestNo,FULM.FmsUserAreaId,Details	from SrServiceRequestMst  SR  with (nolock)

					inner join SrServiceRequestLlsClsTxn src with (nolock) on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723) and src.TypeOfRequest=2317

					inner join fmsuserlocationmst FULM with (nolock) on sr.userlocationID=FULM.UserLocationId 

					where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) 

					and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)

					)b inner join (

					
					select  f.RequestNo,e.FmsUserAreaId,coalesce(sum(val1*val ),0)val3 from (

					

					select a.FmsUserAreaId,count(*)val1 from ClsUserLocationDetailsMst a with (nolock) 

					where a.[Status]=413  and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and a.isdeleted=0

					group by a.FmsUserAreaId

					) e inner join (

					--select a.FmsUserAreaId,sum(val)val2 from(

					select RequestNo,

					FULM.FmsUserAreaId,

					(datediff(dd,case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
					max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then src.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then src.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month)  end )))+1) Val

					from SrServiceRequestMst  SR with (nolock) 

					inner join SrServiceRequestLlsClsTxn src with (nolock)  on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

					inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId  and FULM.[Status]=413 

					where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  

					and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)

						

					group by FULM.FmsUserAreaId,src.NonConformance,[DateTime],RequestNo

					--)a group by a.FmsUserAreaId

					)f on e.FmsUserAreaId=f.FmsUserAreaId
					group by f.requestno,e.fmsuserareaid

					

					)c on b.FmsUserAreaId=c.FmsUserAreaId and b.requestno=c.RequestNo

					



--exec [CLSDeductionGenerationMapping] 36,3,3,2020,6301

										
			--c4

			print 'C4'

					Declare @C4sp1 Float

					Declare @C4sp2 Float

				
					set @TransDemeritPoint = '';

					
--exec [CLSDeductionGenerationMapping] 57,3,3,2020,6301

					insert into #DedCalcMap([Date],ReferenceNo,Details,C4,Screenname)

					select  [DateTime],RequestNo,Details,
					--sum(datediff(dd,SR.DateTime,case when sr.Status in (2314,2313) then srlc.CompletedDateTime 
					--when sr.Status not in (2314,2313) and datepart(mm,getdate())>datepart(mm,sr.datetime) then  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) when sr.Status not in (2314,2313) and datepart(mm,getdate())=datepart(mm,sr.datetime) then  getdate() end )+1
					--		)
					(datediff(dd,case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
					max(convert(date,case when sr.Status in (2314,2313) then SRLC.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then SRLC.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then SRLC.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month)  end )))+1)
							 ,'Service Request' 

						from SrServiceRequestMst  SR  with (nolock)

							inner join SrServiceRequestLlsClsTxn SRLC  with (nolock) on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2722) and srlc.TypeOfRequest=2317  and [Elements] not  in(2691,2678)

							inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]!=2314  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and SR.Status != 2315 -- and sr.[Status]!=2315

							and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year --and datediff(dd,sr.DateTime,srlc.CompletedDateTime)>=0 --and datediff(MINUTE,sr.CreatedDate,sr.ModifiedDate) >15

							or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) )  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(srlc.CompletedDateTime)=@Month and year(srlc.CompletedDateTime)=@year)
							--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3) --and NCRStatus=800 )

							group by [DateTime],RequestNo,Details

							UNION   --exec [CLSDeductionGenerationMapping] 36,3,3,2020

					select  [DateTime],RequestNo,Details,coalesce(
					--(datediff(dd,SR.DateTime,case when sr.Status in (2314,2313) then srlc.CompletedDateTime
					--when sr.Status not in (2314,2313) and datepart(mm,getdate())>datepart(mm,sr.datetime) then  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) when sr.Status not in (2314,2313) and datepart(mm,getdate())=datepart(mm,sr.datetime) then  getdate() end )+1)
					(datediff(dd,case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
					max(convert(date,case when sr.Status in (2314,2313) then SRLC.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then SRLC.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then SRLC.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month)  end )))+1)	,0) 
							,'Service Request' 

					from SrServiceRequestMst  SR  with (nolock)

							inner join SrServiceRequestLlsClsTxn SRLC  with (nolock)on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2722)  and srlc.TypeOfRequest=2317 --and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2314  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and SR.Status != 2315-- and sr.[Status]!=2315

							and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year --and datediff(dd,sr.DateTime,srlc.CompletedDateTime)>=0 --and datediff(MINUTE,sr.CreatedDate,srlc.CompletedDateTime) >15

							or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) )  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(srlc.CompletedDateTime)=@Month and year(srlc.CompletedDateTime)=@year)
							--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3) --and NCRStatus=800 )

						group by [DateTime],RequestNo,Details

							UNION

							select  [DateTime],RequestNo,Details,
							--sum(datediff(dd,SR.DateTime,case when sr.Status in (2314,2313)then srlc.CompletedDateTime 
							--when sr.Status not in (2314,2313) and datepart(mm,getdate())>datepart(mm,sr.datetime) then  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) when sr.Status not in (2314,2313) and datepart(mm,getdate())=datepart(mm,sr.datetime) then  getdate() end )+1
							(datediff(dd,case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
					max(convert(date,case when sr.Status in (2314,2313) then SRLC.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then SRLC.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then SRLC.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month)  end )))+1)*2 , 'Service Request' 

							from SrServiceRequestMst  SR  with (nolock)

							inner join SrServiceRequestLlsClsTxn SRLC with (nolock)  on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2724)   and srlc.TypeOfRequest=2317 and [Elements] not in(2696)--and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]!=2314  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and SR.Status != 2315-- and sr.[Status]!=2315

							and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year --and datediff(dd,sr.DateTime,srlc.CompletedDateTime)>=0 --and datediff(MINUTE,sr.CreatedDate,sr.ModifiedDate) >15

							or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) )  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(srlc.CompletedDateTime)=@Month and year(srlc.CompletedDateTime)=@year)
							--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3) --and NCRStatus=800 )

							group by [DateTime],RequestNo,Details

							UNION

					select  [DateTime],RequestNo,Details,coalesce(
					--sum(datediff(dd,SR.DateTime,case when sr.Status in (2314,2313) then srlc.CompletedDateTime 
					--when sr.Status not in (2314,2313) and datepart(mm,getdate())>datepart(mm,sr.datetime) then  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) when sr.Status not in (2314,2313) and datepart(mm,getdate())=datepart(mm,sr.datetime) then  getdate() end )+1
							(datediff(dd,case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
						max(convert(date,case when sr.Status in (2314,2313) then SRLC.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then SRLC.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then SRLC.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month)  end )))+1),0)*2 ,'Service Request' 

					from SrServiceRequestMst  SR  with (nolock)

							inner join SrServiceRequestLlsClsTxn SRLC with (nolock) on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2724)  and srlc.TypeOfRequest=2317--and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM with (nolock)  on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2314  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and SR.Status != 2315 -- and sr.[Status]!=2315

							and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year-- and datediff(dd,sr.DateTime,srlc.CompletedDateTime)>=0 --and datediff(MINUTE,sr.CreatedDate,srlc.CompletedDateTime) >15

							or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) or   datepart(month,Srlc.CompletedDatetime)=@month)  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
						or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							)  )  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(srlc.CompletedDateTime)=@Month and year(srlc.CompletedDateTime)=@year)
							--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3) --and NCRStatus=800 )

group by [DateTime],RequestNo,Details

							UNION

					--		select  e.[DateTime],e.RequestNo,'Service Request',coalesce(HandPaperTowelHolder,0)+coalesce(JumboRollToiletRollHolder,0)+coalesce(HandSoapLiquidSoapDispenser,0)+coalesce(DeodrantParaBlock,0)

					--		+coalesce(FootPumpNonContactTypeDispenser,0)+coalesce(HandDryers,0)+coalesce(AutoTimeDeoderizerAirFreshenerDispenser,0) 

					--		from ClsUserAreaDispenserMst a inner join ClsUserAreaDetailsMst b on a.ClsUserAreaId=b.ClsUserAreaId

					--		inner join  (

					--select SR.DateTime,Sr.RequestNo,FULM.FmsUserAreaId	from SrServiceRequestMst  SR 

					--inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

					--		inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

					--		where SR.IsDeleted=0 and sr.[service]=3 -- and Sr.[Status]=2311  

					--		and SR.HospitalId=@HospitalId  

					--		and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

					--		--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)	

					--		)e on e.FmsUserAreaId=b.FmsUserAreaId

					--and [Status]=413 

					------group by e.FmsUserAreaId,DateTime,RequestNo

					--		UNION

					--select  [DateTime],RequestNo,'Service Request',coalesce(HandPaperTowelHolder,0)+coalesce(JumboRollToiletRollHolder,0)+coalesce(HandSoapLiquidSoapDispenser,0)+coalesce(DeodrantParaBlock,0)

					--		+coalesce(FootPumpNonContactTypeDispenser,0)+coalesce(HandDryers,0)+coalesce(AutoTimeDeoderizerAirFreshenerDispenser,0) from ClsUserAreaDispenserMst a inner join ClsUserAreaDetailsMst b on a.ClsUserAreaId=b.ClsUserAreaId

					--		inner join  (

					--select SR.DateTime,Sr.RequestNo,FULM.FmsUserAreaId	from SrServiceRequestMst  SR 

					--inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

					--		inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

					--		where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2314  

					--		and SR.HospitalId=@HospitalId  -- and sr.[Status]!=2315

					--		and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year and datediff(dd,sr.DateTime,sr.ModifiedDate)>=0 and datediff(MINUTE,sr.CreatedDate,sr.ModifiedDate) >15

					--		--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3) 

					--		)e on e.FmsUserAreaId=b.FmsUserAreaId

					--and [Status]=413 

					--select b.DateTime,b.RequestNo,'Service Request',c.val3	from (select SR.DateTime,Sr.RequestNo,FULM.FmsUserAreaId	

					--from SrServiceRequestMst  SR 

					--inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723) and src.TypeOfRequest=2317

					--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

					--where SR.IsDeleted=0 and sr.[service]=3 -- and Sr.[Status]=2311  

					--and SR.HospitalId=@HospitalId  

					--and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

					----and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)	

					

					--)b inner join (



					--										select e.FmsUserAreaId,

					--										coalesce((val1*val2),0)val3 from (select 

					--		FULM.FmsUserAreaId,

					--		(datediff(dd,min(convert(date,sr.DateTime)),max(convert(date,case when sr.Status=2314 then src.CompletedDateTime else  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) end )))+1) Val1

					--		from SrServiceRequestMst  SR 

					--		inner join SrServiceRequestLlsClsTxn src on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

					--		inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId  and FULM.[Status]=413 

					--		where SR.IsDeleted=0 and sr.[service]=3 -- and Sr.[Status]=2311  

					--		and SR.HospitalId=@HOSPITALID  

					--		and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

					--		group by FULM.FmsUserAreaId,src.NonConformance,[DateTime],RequestNo) e inner join 

					--(select b.FmsUserAreaId,coalesce(sum(coalesce(HandPaperTowelHolder,0)+coalesce(JumboRollToiletRollHolder,0)+coalesce(HandSoapLiquidSoapDispenser,0)+coalesce(DeodrantParaBlock,0)

					--		+coalesce(FootPumpNonContactTypeDispenser,0)+coalesce(HandDryers,0)+coalesce(AutoTimeDeoderizerAirFreshenerDispenser,0)) ,0) val2

					--		from ClsUserAreaDispenserMst a 

					--		inner join ClsUserAreaDetailsMst b on a.ClsUserAreaId=b.ClsUserAreaId

					--		where b.FmsUserAreaId in(select FULM.FmsUserAreaId from SrServiceRequestMst  SR 

					--		inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2723)  and srlc.TypeOfRequest=2317 --and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

					--		inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId

					--		where SR.IsDeleted=0 and sr.[service]=3 --and Sr.[Status]!=2314  

					--		and SR.HospitalId=@HospitalId  -- and sr.[Status]!=2315

					--		and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year and datediff(dd,sr.DateTime,srlc.CompletedDateTime)>=0 --and datediff(MINUTE,sr.CreatedDate,sr.ModifiedDate) >15

					--		--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)

					--		)group by b.FmsUserAreaId)f on e.FmsUserAreaId=f.FmsUserAreaId 

					--		)c on b.FmsUserAreaId=c.FmsUserAreaId
					

select b.DateTime,b.RequestNo,Details,c.val3,'Service Request' 	from (select SR.DateTime,Sr.RequestNo,Details,FULM.FmsUserAreaId	

from SrServiceRequestMst  SR  with (nolock)

inner join SrServiceRequestLlsClsTxn src  with (nolock) on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723) and src.TypeOfRequest=2317

inner join fmsuserlocationmst FULM  with (nolock)on sr.userlocationID=FULM.UserLocationId 

where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) 

and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) )  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)

--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)	

					

)b inner join (


--exec [CLSDeductionGenerationMapping] 57,3,3,2020,6301

select RequestNo,e.FmsUserAreaId,coalesce((val1*val2),0)val3 from (

select RequestNo,

FULM.FmsUserAreaId,

--(datediff(dd,min(convert(date,sr.DateTime)),max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime 
--when sr.Status not in (2314,2313) and datepart(mm,getdate())>datepart(mm,sr.datetime) then  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) when sr.Status not in (2314,2313) and datepart(mm,getdate())=datepart(mm,sr.datetime) then  getdate() end )))+1
						
					(datediff(dd,case when @month = datepart(mm,sr.datetime) and @year = datepart(yyyy,sr.datetime) then min(convert(date,sr.DateTime))
else CONVERT(VARCHAR(20),@Year) + '-'+ CONVERT(VARCHAR(20),@month) +'-01' end,
					max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime 
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime)  and (@month = month(getdate()))) then getdate()
when sr.Status not in (2314,2313) and ((@month=datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate()))) then EOMONTH(convert(date,sr.DateTime))
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month < month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)	
when sr.Status not in (2314,2313) and (@month>datepart(mm,sr.datetime)) and @year = datepart(yyyy,sr.datetime) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and ( @year > datepart(yyyy,sr.datetime)) and (@month = month(getdate())) then convert(date,getdate())
when sr.Status not in (2314,2313) and  ( @year > datepart(yyyy,sr.datetime)) and  (@month != month(getdate())) then dbo.ufn_GetEnddatebyMonthYear(@Year,@month)
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime)) and (@month < month(getdate())) then src.CompletedDateTime 
when sr.Status  in (2314,2313) and (@month>datepart(mm,sr.datetime))  and (@month = month(getdate())) then src.CompletedDateTime 
else dbo.ufn_GetEnddatebyMonthYear(@Year,@month)  end )))+1)	 Val1

from SrServiceRequestMst  SR  with (nolock)

inner join SrServiceRequestLlsClsTxn src with (nolock) on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId  and FULM.[Status]=413 

where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )-- and Sr.[Status]=2311  

and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) 

and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							))  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(src.CompletedDateTime)=@Month and year(src.CompletedDateTime)=@year)

group by FULM.FmsUserAreaId,src.NonConformance,[DateTime],RequestNo

) e inner join (

select b.FmsUserAreaId,coalesce(sum(coalesce(HandPaperTowelHolder,0)+coalesce(JumboRollToiletRollHolder,0)+coalesce(HandSoapLiquidSoapDispenser,0)+coalesce(DeodrantParaBlock,0)

+coalesce(FootPumpNonContactTypeDispenser,0)+coalesce(HandDryers,0)+coalesce(AutoTimeDeoderizerAirFreshenerDispenser,0)) ,0) val2

from ClsUserAreaDispenserMst a  with (nolock)

inner join ClsUserAreaDetailsMst b with (nolock) on a.ClsUserAreaId=b.ClsUserAreaId

where b.FmsUserAreaId in(select FULM.FmsUserAreaId from SrServiceRequestMst  SR  with (nolock)

inner join SrServiceRequestLlsClsTxn SRLC  with (nolock) on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2723)  and srlc.TypeOfRequest=2317 --and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId

where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status] not in (2315  )--and Sr.[Status]!=2314  

and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  -- and sr.[Status]!=2315

and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year-- and datediff(dd,sr.DateTime,srlc.CompletedDateTime)>=0 --and datediff(MINUTE,sr.CreatedDate,sr.ModifiedDate) >15

or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) )  and sr.Status not in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup))
					or ((((datepart(month,Sr.[DateTime]) < @month  and datepart(YEAR,SR.[DateTime])=@year) or (datepart(YEAR,SR.[DateTime]) <@year)
							) )  and sr.Status  in (2314,2313) and
					SR.IsDeleted=0 and sr.[service]=3  and Sr.[Status] not in (2315 )
					and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)and month(srlc.CompletedDateTime)=@Month and year(srlc.CompletedDateTime)=@year)
--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)

)group by b.FmsUserAreaId

)f on e.FmsUserAreaId=f.FmsUserAreaId 

)c on b.FmsUserAreaId=c.FmsUserAreaId and b.RequestNo=c.requestno

							-----------------


							UNION

							

							
					--select NCRDateTime,NCRNo,'Non Conformance Entry',coalesce(sum(datediff(dd,ncr.NCRDateTime,case when NCRStatus=802 then ncr.modifieddate else  EOMONTH ( dateadd(mm,0,ncr.NCRDateTime) ) end)+1),0) from FmsNCREntryTxn ncr 

					--		inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId and ded.IndicatorNo='C.4' and ded.IsDeleted=0 

					--		inner join SrServiceRequestMst  SR on sr.ServiceRequestId=ncr.ServiceRequestId and ncr.[Service]=3 --and NCRStatus=800 

					--		inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId --and NonConformance in (2722,2724)  and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

					--		inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

					--		where SR.IsDeleted=0 and sr.[service]=3 --and Sr.[Status]=2311  

					--		and SR.HospitalId=@HospitalId   --and sr.[Status]!=2315

					--		and datepart(month,ncr.NCRDateTime)=@month  and datepart(YEAR,ncr.NCRDateTime)=@year

					--		group by NCRDateTime,NCRNo

					--		union

							select b.Date,b.DocumentNo,'',(coalesce(HandPaperTowelShortageConsumable	,0)	+

								coalesce(JumboRollHolderShortageConsumable	,0)	+	

								coalesce(HandSoapShortageConsumable		,0)	+	

								coalesce(DeodrantShortageConsumable		,0)	+	

								coalesce(FootPumpShortageConsumable		,0)	+	

								coalesce(HandDryersShortageConsumable		,0)	+	

								coalesce(AutoTimeDeodorizerShortageConsumable	,0)	+			

								coalesce(HandPaperTowelDispenserQty		  ,0)	+

								coalesce(JumboRollHolderDispenserQty		,0)	+  

								coalesce(HandSoapDispenserQty				,0)	+  

								coalesce(DeodrantDispenserQty			,0)	+	  

								coalesce(FootPumpDispenserQty			,0)	+	  

								coalesce(HandDryersDispenserQty			,0)	+  

								coalesce(AutoTimeDeodorizerDispenserQty	  ,0)),'Daily Cleaning Activity (Exceptions)' 

							from ClsDcaConsumablesTxnDet  a with (nolock)

							inner join ClsDailyCleaningActivityExceptionsTxn b  with (nolock) on a.CleaningActivityId=b.CleaningActivityId

							where a.IsDeleted=0 and datepart(month,b.Date)=@month

							and datepart(YEAR,b.Date)=@year

							and (HandPaperTowelShortageConsumable >0 or JumboRollHolderShortageConsumable >0 or HandSoapShortageConsumable >0 

							or DeodrantShortageConsumable >0 or FootPumpShortageConsumable >0 or HandDryersShortageConsumable >0 

							or AutoTimeDeodorizerShortageConsumable >0) and b.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and a.IsDeleted=0 and b.IsDeleted=0



					--insert into #DedCalcMap([Date],ServiceRequestNo,details,C4)

					--select  [DateTime],RequestNo,SR.Details,1 from SrServiceRequestMst  SR 

					--inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2722,2724)  and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

					--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId

					--where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2311  and SR.HospitalId=@HospitalId  -- and sr.[Status]!=2315

					--and datepart(month,Sr.CreatedDate)=@month  and datepart(YEAR,SR.CreatedDate)=@year

					--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId 

					--and ded.IndicatorNo='C.4' and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3 and NCRStatus=800 )

					--UNION

					--select  [DateTime],RequestNo,SR.Details,1 from SrServiceRequestMst  SR 

					--inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2722,2724)  and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

					--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId

					--where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2314  and SR.HospitalId=@HospitalId  -- and sr.[Status]!=2315

					--and datepart(month,Sr.CreatedDate)=@month  and datepart(YEAR,SR.CreatedDate)=@year and datediff(dd,sr.CreatedDate,sr.ModifiedDate)>=0 and datediff(MINUTE,sr.CreatedDate,sr.ModifiedDate) >15

					--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded 

					--on DED.IndicatorDetId=ncr.IndicatorDetId and ded.IndicatorNo='C.4' and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3 and NCRStatus=800 )

					--UNION			

					--select NCRDateTime,NCRNo,NCR.NCRDetails,1 from FmsNCREntryTxn ncr 

					--inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId and ded.IndicatorNo='C.4' and ded.IsDeleted=0 

					--inner join SrServiceRequestMst  SR on sr.ServiceRequestId=ncr.ServiceRequestId and ncr.[Service]=3 and NCRStatus=800 

					--inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2722,2724)  and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

					--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

					--where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2311  and SR.HospitalId=@HospitalId   --and sr.[Status]!=2315

					--and datepart(month,ncr.NCRDateTime)=@month  and datepart(YEAR,ncr.NCRDateTime)=@year


			--C5

				print 'C5'

				Declare @C5sp1 Float



				set @TransDemeritPoint = '';



				insert into #DedCalcMap([Date],ReferenceNo,Details,C5,Screenname)

				select [DateTime],RequestNo,DEtails,1 ,'Service Request' 

				from SrServiceRequestMst  SR with (nolock)

							inner join SrServiceRequestLlsClsTxn SRLC with (nolock)  on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (4673,4674)  

							and srlc.TypeOfRequest=2317--and NonConformance in (2722,2724)  and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM with (nolock) on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and SR.Status != 2315--and Sr.[Status]=2311  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  and Category in (3301,3302,3303) and TypeOfRequest = 2317

							and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year



				--set @TransDemeritPoint=coalesce(@C5sp1,0)



				--insert into #DedCalcMap([Date],ServiceRequestNo,details,C5)

				--select [DateTime],RequestNo,SR.Details,1 from SrServiceRequestMst  SR 

				--inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId --and NonConformance in (2722,2724)  and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

				--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId

				--where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2311  and SR.HospitalId=@HospitalId    and Category in (3301,3302,3303)

				--and datepart(month,Sr.CreatedDate)=@month  and datepart(YEAR,SR.CreatedDate)=@year

				--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId

				-- and ded.IndicatorNo='C.5' and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3 and NCRStatus=800 )

				--UNION

				--select NCRDateTime,NCRNo,NCR.NCRDetails,1 from FmsNCREntryTxn ncr 

				--inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId and ded.IndicatorNo='C.5' and ded.IsDeleted=0 

				--inner join SrServiceRequestMst  SR on sr.ServiceRequestId=ncr.ServiceRequestId and ncr.[Service]=3 and NCRStatus=800  

				--inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId

				--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

				--where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2311  and SR.HospitalId=@HospitalId   --and sr.[Status]!=2315 

				--and Category in (3301,3302,3303)

				--and datepart(month,ncr.NCRDateTime)=@month  and datepart(YEAR,ncr.NCRDateTime)=@year

			
			--C6

				print 'C6'

						Declare @C6sp1 Float

						Declare @C6sp2 Float



				set @TransDemeritPoint = '';



				insert into #DedCalcMap([Date],ReferenceNo,Details,C6,Screenname)

				select t.Date as Date,t.DocumentNo as ReferenceNo,td.remarks as Details, sum(TotalException) as DemeritPoints,'Daily Cleaning Activity(Exceptions)' as Screenname--,td.Remarks as Details 

				from ClsDcaWasteCollectionTxnDet TD with (nolock)

				inner join ClsDailyCleaningActivityExceptionsTxn T  with (nolock) on T.CleaningActivityId=TD.CleaningActivityId 	and IsWasteCollected in (0,1)

				where td.IsDeleted=0 and datepart(month,t.Date)=@monthval and HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)

				and datepart(YEAR,t.Date)=@year

				group by t.Date,t.DocumentNo,td.Remarks

				

				--insert into #DedCalcMap([Date],ReferenceNo,C6,Details)

				--select t.Date as Date,t.DocumentNo as ReferenceNo, sum(TotalException) as C6,td.Remarks as Details 

				--from ClsDcaWasteCollectionTxnDet TD 

				--inner join ClsDailyCleaningActivityExceptionsTxn T on T.CleaningActivityId=TD.CleaningActivityId and IsWasteCollected=1			

				--where td.IsDeleted=0 and datepart(month,t.Date)=@monthval and HospitalId=@HospitalId

				--and datepart(YEAR,t.Date)=@year 

				--group by t.Date,t.DocumentNo,td.Remarks



				insert into #DedCalcMap([Date],ReferenceNo,C6,Details,Screenname)

				select SR.DateTime as Date, SR.RequestNo as ReferenceNo,coalesce(sum(case when sr.ServiceRequestId is not null then 1 else 0 end),0) DemeritPoints

				, Details,'Service Request' 

						from SrServiceRequestMst  SR with (nolock)					

							inner join SrServiceRequestLlsClsTxn SRLC  with (nolock) on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2728)  and srlc.TypeOfRequest=2317-- and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM  with (nolock)on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and SR.Status != 2315--and Sr.[Status]=2311  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)   --and sr.[Status]!=2315 

							--and NonConformance in (2725,2726) and [Elements] in(2705)

							and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

								
				group by SR.DateTime,SR.RequestNo,Details

				-----------------------------------------------------

							insert into #DedCalcMap([Date],ReferenceNo,C6,Details,Screenname)

				select SR.DateTime as Date, SR.RequestNo as ReferenceNo,coalesce(sum(case when sr.ServiceRequestId is not null then 1 else 0 end),0)*2 DemeritPoints

				, Details,'Service Request' 

						from SrServiceRequestMst  SR with (nolock)					

							inner join SrServiceRequestLlsClsTxn SRLC  with (nolock)on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in ( 6317)  and srlc.TypeOfRequest=2317-- and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and SR.Status != 2315--and Sr.[Status]=2311  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)   --and sr.[Status]!=2315 

							--and NonConformance in (2725,2726) and [Elements] in(2705)

							and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

								

				group by SR.DateTime,SR.RequestNo,Details
							---------------------------------------------------



				insert into #DedCalcMap([Date],ReferenceNo,C6,Details,Screenname)

				select SR.DateTime as Date,SR.RequestNo as ReferenceNo,coalesce(sum(case when sr.ServiceRequestId is not null then 1 else 0 end),0)*2  DemeritPoints

				, Details,'Service Request' 

							from SrServiceRequestMst  SR  with (nolock)					

							inner join SrServiceRequestLlsClsTxn SRLC with (nolock)  on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2724)  and [Elements] in(2705) and srlc.TypeOfRequest=2317--,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and SR.Status != 2315--and Sr.[Status]=2311  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)   --and sr.[Status]!=2315 

							--and NonConformance in (2725,2726) and [Elements] in(2705)

							and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year


								

				group by SR.DateTime,SR.RequestNo ,Details



				insert into #DedCalcMap([Date],ReferenceNo,C6,Details,Screenname)

				select SR.DateTime as Date,SR.RequestNo as ReferenceNo,coalesce(sum(case when sr.ServiceRequestId is not null then 1 else 0 end),0)  DemeritPoints

				, Details,'Service Request' 

				from SrServiceRequestMst  SR with (nolock)					

							inner join SrServiceRequestLlsClsTxn SRLC  with (nolock) on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2725,2726)  
							and [Elements] in(2705) 
							and srlc.TypeOfRequest=2317--,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and SR.Status != 2315--and Sr.[Status]=2311  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)   --and sr.[Status]!=2315 

							--and NonConformance in (2725,2726) and [Elements] in(2705)

							and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

								

				group by SR.DateTime,SR.RequestNo,Details



				insert into #DedCalcMap([Date],ReferenceNo,C6,Details,Screenname)

				select b.DateTime as Date,b.RequestNo as ReferenceNo,coalesce(sum(val2),0) DemeritPoints

				, details,'Service Request' 

							from 

							(select 

							FULM.FmsUserAreaId,sr.DateTime,sr.RequestNo,

							(datediff(dd,min(convert(date,sr.DateTime)),max(convert(date,case when sr.Status in (2314,2313) then src.CompletedDateTime else  EOMONTH ( dateadd(mm,0,convert(date,sr.DateTime)) ) end )))+1) Val1,Details,'' Screenname

							from SrServiceRequestMst  SR  with (nolock)

							inner join SrServiceRequestLlsClsTxn src with (nolock)  on sr.ServiceRequestId=src.ServiceRequestId and src.NonConformance in(2723)  and src.TypeOfRequest=2317

							inner join fmsuserlocationmst FULM with (nolock)  on sr.userlocationID=FULM.UserLocationId  and FULM.[Status]=413 

							where SR.IsDeleted=0 and sr.[service]=3 and SR.Status != 2315-- and Sr.[Status]=2311  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) 

							and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

							

							group by FULM.FmsUserAreaId,src.NonConformance,[DateTime],RequestNo,Details) b inner join (select b.FmsUserAreaId,sum(coalesce(Bin660L,0)+coalesce(Bin240L,0)

							+coalesce(WastepaperbasketBin,0)+coalesce(PedalBin,0)+coalesce(BedsideBin,0)+coalesce(FlipFlopBin,0)+coalesce(FoodBin,0)) val2

							from ClsUserLocationReceptaclesMst a with (nolock) 

							inner join ClsUserLocationDetailsMst cl  with (nolock)on a.ClsUserLocationId=cl.ClsUserLocationId

							inner join ClsUserAreaDetailsMst b  with (nolock) on cl.ClsUserAreaId=b.ClsUserAreaId

							where b.FmsUserAreaId in(select FULM.FmsUserAreaId from SrServiceRequestMst  SR  with (nolock)

							inner join SrServiceRequestLlsClsTxn SRLC with (nolock) on sr.ServiceRequestId=SRLC.ServiceRequestId and NonConformance in (2723)  and srlc.TypeOfRequest=2317 --and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

							inner join fmsuserlocationmst FULM  with (nolock) on sr.userlocationID=FULM.UserLocationId

							where SR.IsDeleted=0 and sr.[service]=3 and SR.Status != 2315--and Sr.[Status]!=2314  

							and SR.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)  -- and sr.[Status]!=2315

							and datepart(month,Sr.DateTime)=@month  and datepart(YEAR,SR.DateTime)=@year
							
								-- and datediff(dd,sr.DateTime,srlc.CompletedDateTime)>=0 --and datediff(MINUTE,sr.CreatedDate,sr.ModifiedDate) >15

							--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId  and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3)

							)group by b.FmsUserAreaId)c on b.FmsUserAreaId=c.FmsUserAreaId

							group by b.DateTime,b.RequestNo,Details

				--group by fulm.FmsUserAreaId



				--insert into #DedCalcMap([Date],ServiceRequestNo,details,C6)

				--select [DateTime],RequestNo,SR.Details,1 from SrServiceRequestMst  SR 					

				--inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId --and NonConformance in (2722,2724)  and [Elements] in(2687,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698)

				--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId

				--where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2311  and SR.HospitalId=@HospitalId   --and sr.[Status]!=2315 

				--and NonConformance in (2725,2726) and [Elements] in(2705)

				--and datepart(month,Sr.[DateTime])=@month  and datepart(YEAR,SR.[DateTime])=@year

				--and sr.ServiceRequestId not in(select ServiceRequestId from FmsNCREntryTxn ncr inner join DedIndicatorMstDet Ded 

				--on DED.IndicatorDetId=ncr.IndicatorDetId and ded.IndicatorNo='C.6' and ded.IsDeleted=0 where ncr.IsDeleted=0 and [Service]=3 and NCRStatus=800 )

				--UNION

				--select NCRDateTime,NCRNo,NCR.NCRDetails,1 from FmsNCREntryTxn ncr 

				--inner join DedIndicatorMstDet Ded on DED.IndicatorDetId=ncr.IndicatorDetId and ded.IndicatorNo='C.6' and ded.IsDeleted=0

				--inner join SrServiceRequestMst  SR on sr.ServiceRequestId=ncr.ServiceRequestId and ncr.[Service]=3 and NCRStatus=800  

				--inner join SrServiceRequestLlsClsTxn SRLC on sr.ServiceRequestId=SRLC.ServiceRequestId

				--inner join fmsuserlocationmst FULM on sr.userlocationID=FULM.UserLocationId 

				--where SR.IsDeleted=0 and sr.[service]=3 and Sr.[Status]=2311  and SR.HospitalId=@HospitalId   --and sr.[Status]!=2315 

				--and NonConformance in (2725,2726) and [Elements] in(2705)

				--and datepart(month,ncr.NCRDateTime)=@month  and datepart(YEAR,ncr.NCRDateTime)=@year

				

				

		end



		--update #DedCalcMap set CompletionDate=null , ServiceRequestDate=cast(ServiceRequestDate as Date)

		delete from #DedCalcMap where C1=0 and C2=0 and C3=0 and C4=0  and  C5=0 and C6=0 



		select @HospitalName = HospitalName

		FROM GMHospitalMst  with (nolock)

		where HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)



		select @CompanyName = c.CompanyName

		from GmCompanyMst c with (nolock)

		INNER JOIN GMHospitalMst p ON c.CompanyId = p.CompanyId

		where p.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup)



		select @MonthYear = CONVERT(varchar(3), DateName( month , DateAdd( month , @month , 0 ) - 1 ))+' / '+CONVERT(varchar(10), @year) 



		select @MonthlyServiceFee=isnull(finm.CLSpercent,0) from FinMonthlyFeeTxn fin with (nolock)

		inner join FinMonthlyFeeTxnDet finm  with (nolock) on fin.MonthlyFeeId = finm.MonthlyFeeId

		where fin.Year = @year and finm.Month =@month

		and fin.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and fin.IsDeleted=0 and finm.IsDeleted=0



		select @FMSMonthlyServiceFee=isnull((finm.CLSMSF*2.5)/100,0) from FinMonthlyFeeTxn fin with (nolock)

		inner join FinMonthlyFeeTxnDet finm  with (nolock) on fin.MonthlyFeeId = finm.MonthlyFeeId

		where fin.Year = @year and finm.Month =@month

		and fin.HospitalId in (select HospitalId from #GetGMHospitalMstAndGroup) and fin.IsDeleted=0 and finm.IsDeleted=0



		--select * from (

		--Select @HospitalName as HospitalName,@CompanyName as CompanyName,@MonthYear as MonthYear,  row_number() over(order by date) as  SlNo,@MonthlyServiceFee as MonthlyServiceFee, 

		--@FMSMonthlyServiceFee FMSMonthlyServiceFee,format(Date,'dd/MMM/yyyy') as Date,ReferenceNo

		--,sum(isnull(C1,0)+isnull(C2,0)+isnull(C3,0)+isnull(C4,0)+isnull(C5,0)+isnull(C6,0)) as DemeritPoints ,

		--C1 , C2,C3 ,C4 ,C5 , C6,

		--Details	

		--from #DedCalcMap a

	

		--group by a.SlNo,Date , ReferenceNo , DemeritPoints, C1 , C2,C3 ,C4 ,C5 , C6,Details) b where cast(demeritpoints as int)>0

		--order by date

	
		if exists(select 1 from #DedCalcMap)

		begin 



				select HospitalName,CompanyName,MonthYear, row_number() over(order by date) as  SlNo, MonthlyServiceFee

				,FMSMonthlyServiceFee,Date,ReferenceNo,DemeritPoints,

				C1 , C2,C3 ,C4 ,C5 , C6 , Details,Screenname from

				(

				select HospitalName,CompanyName,MonthYear,  MonthlyServiceFee

				,FMSMonthlyServiceFee,Date,ReferenceNo,sum(DemeritPoints) as DemeritPoints,

				sum(C1) as C1 , sum(C2) as C2,sum(C3) as C3 ,sum(C4) as C4 ,sum(C5) as C5 , sum(C6) as C6,

				--max(Details)	as Details,
				 Details,
				 Screenname
					
				 from (

				Select @HospitalName as HospitalName,@CompanyName as CompanyName,@MonthYear as MonthYear,@MonthlyServiceFee as MonthlyServiceFee, @FMSMonthlyServiceFee FMSMonthlyServiceFee,format(Date,'dd/MMM/yyyy') as Date,ReferenceNo

				,sum(isnull(C1,0)+isnull(C2,0)+isnull(C3,0)+isnull(C4,0)+isnull(C5,0)+isnull(C6,0)) as DemeritPoints ,

				sum(C1)C1 ,sum(c2) C2,sum(c3)C3 ,sum(c4)C4 ,sum(c5)C5 ,sum(c6) C6,

				Details,Screenname	

				from #DedCalcMap a

				group by Date , ReferenceNo , DemeritPoints,Details,Screenname) b where cast(demeritpoints as int)>0

				group by HospitalName,CompanyName,MonthYear,  MonthlyServiceFee

				,FMSMonthlyServiceFee,Date,ReferenceNo,Details,Screenname

				) a1

				order by date

		end

		else

		begin

				Select @HospitalName as HospitalName,@CompanyName as CompanyName,@MonthYear as MonthYear,row_number() over(order by (select null)) as  SlNo,@MonthlyServiceFee as MonthlyServiceFee, @FMSMonthlyServiceFee FMSMonthlyServiceFee,'' as Date,'' ReferenceNo




				,0 as DemeritPoints,0 C1,0 C2,0 C3,0 C4,0 C5,0C6,''Details,'' Screenname

		end

		drop table #DedCalcMap

END

End try 

Begin catch

			declare @error varchar(max)

			set @error=error_message()

			print @error

End catch

end










GO

