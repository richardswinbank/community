WITH src AS (
  SELECT * FROM (VALUES 
    ('T00001')
  , ('T00002')
  , ('T00003')
  , ('T00004')
  , ('T00005')
  , ('T00006')
  , ('T00007')
  , ('T00008')
  , ('T00009')
  , ('T00010')
  ) t ([title_id])
)
MERGE INTO [test].[TenTitleStub] tgt
  USING src
  ON src.[title_id] = tgt.[title_id]
WHEN NOT MATCHED BY TARGET THEN 
  INSERT (
    [title_id]
  ) VALUES (
    src.[title_id]
  )
WHEN NOT MATCHED BY SOURCE THEN
  DELETE;
