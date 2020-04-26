CREATE PROCEDURE dbo.LogPipelineEnd (
  @runId INT
, @rowsCopied INT
)
AS

UPDATE pr
SET RowsCopied = @rowsCopied
  , RunEnd = GETUTCDATE()
FROM dbo.PipelineRun pr
WHERE pr.RunId = @runId