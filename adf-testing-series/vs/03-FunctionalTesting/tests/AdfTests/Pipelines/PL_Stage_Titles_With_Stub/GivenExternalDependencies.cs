using FluentAssertions;
using NUnit.Framework;
using System.Threading.Tasks;

namespace PL_Stage_Titles_With_Stub.IntegrationTests
{
    public class GivenExternalDependencies
    {
        private PLStageTitlesWithStubHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineIsRun()
        {
            _helper = new PLStageTitlesWithStubHelper();
            await _helper.RunPipeline();
        }

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.PipelineOutcome.Should().Be("Succeeded");
        }
    }
}