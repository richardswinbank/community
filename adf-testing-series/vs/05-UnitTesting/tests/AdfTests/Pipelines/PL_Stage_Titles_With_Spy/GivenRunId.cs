using FluentAssertions;
using NUnit.Framework;
using System.Threading.Tasks;

namespace PL_Stage_Titles_With_Spy.FunctionalTests
{
    public class GivenRunId
    {
        private PLStageTitlesWithSpyHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineIsRun()
        {
            _helper = new PLStageTitlesWithSpyHelper()
                .WithSourceTable("test.TenTitleStub")
                .WithRunIdStub();
            await _helper.RunPipeline();
        }

        [Test]
        public void ThenRunIdIsPassedCorrectly()
        {
            _helper.RunId.Should().Be(-17483);
        }

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}