using NUnit.Framework;
using System.Threading.Tasks;

namespace PL_Stage_Authors
{
    public class Given23Rows
    {
        private PLStageAuthorsHelper _helper;

        [SetUp]
        public async Task WhenPipelineIsRun()
        {
            _helper = new PLStageAuthorsHelper();
            await _helper.RunPipeline();
        }

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            Assert.AreEqual("Succeeded", _helper.PipelineOutcome);
        }
    }
}