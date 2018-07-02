SELECT start_time, end_time, execution_id,status, package_name,
CASE  WHEN [status] = 1 THEN 'created'
    WHEN [status] = 2 THEN 'running'
    WHEN [status] = 3 THEN 'canceled'
    WHEN [status] = 4 THEN 'failed'
    WHEN [status] = 5 THEN 'pending'
    WHEN [status] = 6 THEN 'ended unexpectedly'
    WHEN [status] = 7 THEN 'succeeded'
    WHEN [status] = 8 THEN 'stopping'
    WHEN [status] = 9 THEN 'completed'
END AS [status_text]
,DATEDIFF(ss,start_time,end_time)DurationInSeconds
FROM  catalog.executions e
where folder_name = 'Dev_InvMgt' and project_name in('MainframeDownloads','Food DataSet Creation','Report Datasets') or project_name like 'SOT%'
order by start_time desc

select top 100 * from catalog.executions