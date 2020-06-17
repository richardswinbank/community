CREATE PROCEDURE test.RecordActivityRun (
  @activityName NVARCHAR(1024)
, @pipelineName NVARCHAR(1024)
, @context NVARCHAR(MAX)
) AS

INSERT INTO test.ActivityRun (
  ActivityName
, PipelineName
, Context
) VALUES (
  @activityName
, @pipelineName
, @context
)