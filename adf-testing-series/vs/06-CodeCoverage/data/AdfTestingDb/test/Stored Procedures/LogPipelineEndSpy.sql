CREATE PROCEDURE [test].[LogPipelineEndSpy] (
  @runId INT
, @rowsCopied INT
)
AS
 
INSERT INTO [test].[LogPipelineEndSpyLog] (
  RunId
) VALUES (
  @runId
);