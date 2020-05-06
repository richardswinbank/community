CREATE PROCEDURE [dbo].[LogPipelineStart] (
  @pipelineName NVARCHAR(255)
)
AS

INSERT INTO dbo.PipelineRun (
  PipelineName
) VALUES (
  @pipelineName
);

SELECT SCOPE_IDENTITY() AS RunId;