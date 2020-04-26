using Microsoft.Azure.Management.DataFactory;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using System.Threading;
using System.Threading.Tasks;

namespace AdfTesting.Helpers
{
    public class DataFactoryHelper : SettingsHelper
    {
        public string PipelineOutcome { get; private set; }

        public async Task RunPipeline(string pipelineName)
        {
            PipelineOutcome = "Unknown";

            // authenticate against Azure
            var context = new AuthenticationContext("https://login.windows.net/" + GetSetting("AZURE_TENANT_ID"));
            var cc = new ClientCredential(GetSetting("AZURE_CLIENT_ID"), GetSetting("AZURE_CLIENT_SECRET"));
            var authResult = await context.AcquireTokenAsync("https://management.azure.com/", cc);

            // prepare ADF client
            var cred = new TokenCredentials(authResult.AccessToken);
            using (var adfClient = new DataFactoryManagementClient(cred) { SubscriptionId = GetSetting("AZURE_SUBSCRIPTION_ID") })
            {
                var adfName = GetSetting("DataFactoryName");
                var rgName = GetSetting("DataFactoryResourceGroup");

                // run pipeline
                var response = await adfClient.Pipelines.CreateRunWithHttpMessagesAsync(rgName, adfName, pipelineName);
                string runId = response.Body.RunId;

                // wait for pipeline to finish
                var run = await adfClient.PipelineRuns.GetAsync(rgName, adfName, runId);
                while (run.Status == "Queued" || run.Status == "InProgress" || run.Status == "Canceling")
                {
                    Thread.Sleep(2000);
                    run = await adfClient.PipelineRuns.GetAsync(rgName, adfName, runId);
                }
                PipelineOutcome = run.Status;
            }
        }

        public DataFactoryHelper()
        {
            PipelineOutcome = "Unknown";
        }
    }
}
