using FluentAssertions;
using NUnit.Framework;
using System.Threading.Tasks;

namespace PL_Stage_Titles_With_Stub.FunctionalTests
{
    public class Given100Rows
    {
        private PLStageTitlesWithStubHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineIsRun()
        {
            _helper = new PLStageTitlesWithStubHelper()
                .WithSourceTable("test.HundredTitleStub");
            await _helper.RunPipeline();
        }

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void Then100RowsAreStaged()
        {
            _helper.StagedRowCount.Should().Be(100);
        }

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}