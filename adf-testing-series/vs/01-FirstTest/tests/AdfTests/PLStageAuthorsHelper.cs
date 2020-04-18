using Microsoft.Azure.Management.DataFactory;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace PL_Stage_Authors
{
    public class PLStageAuthorsHelper
    {
        public string PipelineOutcome { get; private set; }

        public async Task RunPipeline()
        {
            PipelineOutcome = "Unknown";

            // authenticate against Azure
            var context = new AuthenticationContext("https://login.windows.net/" + Environment.GetEnvironmentVariable("AZURE_TENANT_ID"));
            var cc = new ClientCredential(Environment.GetEnvironmentVariable("AZURE_CLIENT_ID"), Environment.GetEnvironmentVariable("AZURE_CLIENT_SECRET"));
            var authResult = await context.AcquireTokenAsync("https://management.azure.com/", cc);

            // prepare ADF client
            var cred = new TokenCredentials(authResult.AccessToken);
            using (var adfClient = new DataFactoryManagementClient(cred) { SubscriptionId = Environment.GetEnvironmentVariable("AZURE_SUBSCRIPTION_ID") })
            {
                var adfName = "firefive-adftest95-adf";  // name of data factory
                var rgName = "firefive-adftest95-rg";    // name of resource group that contains the data factory

                // run pipeline
                var response = await adfClient.Pipelines.CreateRunWithHttpMessagesAsync(rgName, adfName, "PL_Stage_Authors");
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

        public PLStageAuthorsHelper()
        {
            PipelineOutcome = "Unknown";
        }
    }
}