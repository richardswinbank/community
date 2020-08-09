# Parameterising the Execute Pipeline activity

The `.json` files in this folder are ADF pipeline definitions that appear in my blog post on [Parameterising the Execute Pipeline activity](https://richardswinbank.net/adf/parameterising_the_execute_pipeline_activity).

- `Execute Pipeline.json` is the final implementation including trigger, wait for completion and fail on error.
- `Wait for completion.json` is a partial implementation including trigger and wait for completion.
- `Fire and forget.json` is the initial implementation including trigger only.

The three other pipelines are for testing purposes:
- `TestWait.json` takes a `WaitTime` parameter and waits for the specified number of seconds before completing successfully
- `TestFail.json` takes no parameters and fails immediately, every time
- `Test parameterised pipeline execution.json` executes the `TestWait` and `TestFail` pipelines in parallel, using the `Execute Pipeline` ADF pipeline.
