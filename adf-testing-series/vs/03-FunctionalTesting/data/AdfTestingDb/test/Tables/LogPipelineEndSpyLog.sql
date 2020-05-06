CREATE TABLE [test].[LogPipelineEndSpyLog] (
    [RunId] INT NULL
);

GO

CREATE CLUSTERED INDEX CL__test_LogPipelineEndSpyLog
ON [test].[LogPipelineEndSpyLog] (
  RunId
)
;
