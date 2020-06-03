using FluentAssertions;
using NUnit.Framework;
using System.Threading.Tasks;

namespace PL_Stage_Titles_With_Warning.UnitTests
{
    public class Given100Rows
    {
        private PLStageTitlesWithWarningHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineIsRun()
        {
            _helper = new PLStageTitlesWithWarningHelper()
                .WithSourceTable("test.HundredTitleStub")
                .WithRowCountWarningThreshold(50);
            await _helper.RunPipeline();
        }

        [Test]
        public async Task Then5ActivitiesAreRun()
        {
            var count = await _helper.GetActivityRunCount();
            count.Should().Be(5);
        }

        [Test]
        public async Task Then100RowsAreCopied()
        {
            var rowsCopied = await _helper.GetActivityOutput("Copy src_Titles to stg_Titles", "$.rowsCopied");
            int.Parse(rowsCopied).Should().Be(100);
        }

        [Test]
        public async Task ThenLogWithWarningNotRun()
        {
            var count = await _helper.GetActivityRunCount("Log pipeline end with warning");
            count.Should().Be(0);
        }

        [Test]
        public async Task ThenLogWithoutWarningRunOnce()
        {
            var count = await _helper.GetActivityRunCount("Log pipeline end without warning");
            count.Should().Be(1);
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