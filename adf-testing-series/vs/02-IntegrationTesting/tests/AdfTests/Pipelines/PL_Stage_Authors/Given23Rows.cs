using FluentAssertions;
using NUnit.Framework;
using System.Threading.Tasks;

namespace PL_Stage_Authors
{
    public class Given23Rows
    {
        private PLStageAuthorsHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineIsRun()
        {
            _helper = new PLStageAuthorsHelper();
            await _helper.RunPipeline();
        }

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.PipelineOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void Then23RowsAreStaged()
        {
            _helper.StagedRowCount.Should().Be(32);
        }
    }
}