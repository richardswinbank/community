CREATE PROCEDURE test.RecordActivity (
  @activityName NVARCHAR(1024)
, @pipelineName NVARCHAR(1024)
) AS

INSERT INTO test.PipelineActivity (
  ActivityName
, PipelineName
) VALUES (
  @activityName
, @pipelineName
)