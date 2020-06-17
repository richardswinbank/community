CREATE VIEW test.CoverageReport 
AS

WITH cte AS (
  SELECT
    COALESCE(a.PipelineName, '<unknown>') AS PipelineName
  , COALESCE(a.ActivityName, '<unknown>') AS ActivityName
  , IIF(ar.ActivityRunId IS NULL, 0, 1) AS Runs
  , ar.LoggedDateTime
  , ar.Context
  FROM [test].[PipelineActivity] a
    FULL OUTER JOIN test.ActivityRun ar 
      ON ar.PipelineName = a.PipelineName
      AND ar.ActivityName = a.ActivityName
)
SELECT 
  PipelineName
, ActivityName
, SUM(Runs) AS ActivityRuns
, MAX(LoggedDateTime) AS LastRunDateTime
FROM cte
GROUP BY
  PipelineName
, ActivityName