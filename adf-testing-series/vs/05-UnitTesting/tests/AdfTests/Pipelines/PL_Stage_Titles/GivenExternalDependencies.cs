using FluentAssertions;
using NUnit.Framework;
using System.Threading.Tasks;

namespace PL_Stage_Titles
{
    public class GivenExternalDependencies
    {
        private PLStageTitlesHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineIsRun()
        {
            _helper = new PLStageTitlesHelper();
            await _helper.RunPipeline();
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