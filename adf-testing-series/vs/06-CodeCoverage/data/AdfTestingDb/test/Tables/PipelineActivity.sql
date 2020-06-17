CREATE TABLE [test].[PipelineActivity] (
    [PipelineActivityId] INT             IDENTITY (1, 1) NOT NULL,
    [LoggedDateTime]     DATETIME        DEFAULT (getutcdate()) NOT NULL,
    [ActivityName]       NVARCHAR (1024) NOT NULL,
    [PipelineName]       NVARCHAR (1024) NOT NULL,
    CONSTRAINT [PK__test_PipelineActivity] PRIMARY KEY CLUSTERED ([PipelineActivityId] ASC)
);

