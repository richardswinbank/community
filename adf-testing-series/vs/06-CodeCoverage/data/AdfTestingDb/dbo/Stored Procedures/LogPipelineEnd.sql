CREATE PROCEDURE dbo.LogPipelineEnd (
  @runId INT
, @rowsCopied INT
, @message NVARCHAR(255) = NULL
)
AS

UPDATE pr
SET RowsCopied = @rowsCopied
  , RunEnd = GETUTCDATE()
  , [Message] = @message
FROM dbo.PipelineRun pr
WHERE pr.RunId = @runId;
