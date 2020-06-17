CREATE TABLE [test].[ActivityRun] (
    [ActivityRunId]  INT             IDENTITY (1, 1) NOT NULL,
    [LoggedDateTime] DATETIME        DEFAULT (getutcdate()) NOT NULL,
    [ActivityName]   NVARCHAR (1024) NOT NULL,
    [PipelineName]   NVARCHAR (1024) NOT NULL,
    [Context]        NVARCHAR (MAX)  NOT NULL,
    CONSTRAINT [PK__test_ActivityRun] PRIMARY KEY CLUSTERED ([ActivityRunId] ASC)
);

