using FluentAssertions;
using NUnit.Framework;
using System.Threading.Tasks;

namespace PL_Stage_Titles_With_Stub.FunctionalTests
{
    public class Given10Rows
    {
        private PLStageTitlesWithStubHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineIsRun()
        {
            _helper = new PLStageTitlesWithStubHelper()
                .WithSourceTable("test.TenTitleStub");
            await _helper.RunPipeline();
        }

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void Then10RowsAreStaged()
        {
            _helper.StagedRowCount.Should().Be(10);
        }

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}