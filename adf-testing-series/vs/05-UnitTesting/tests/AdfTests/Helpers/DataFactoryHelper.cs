using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace AdfTesting.Helpers
{
    public class DataFactoryHelper<T> : SettingsHelper<T> where T : DataFactoryHelper<T>
    {
        private readonly string _adfName;
        private readonly string _rgName;
        private DataFactoryManagementClient _adfClient;

        private async Task InitialiseClient()
        {
            if (_adfClient != null)
                return;

            var context = new AuthenticationContext("https://login.windows.net/" + GetSetting("AZURE_TENANT_ID"));
            var cc = new ClientCredential(GetSetting("AZURE_CLIENT_ID"), GetSetting("AZURE_CLIENT_SECRET"));
            var authResult = await context.AcquireTokenAsync("https://management.azure.com/", cc);

            var cred = new TokenCredentials(authResult.AccessToken);
            _adfClient = new DataFactoryManagementClient(cred) { SubscriptionId = GetSetting("AZURE_SUBSCRIPTION_ID") };
        }

        public async Task<string> TriggerPipeline(string pipelineName, IDictionary<string, object> parameters)
        {
            await InitialiseClient();
            var response = await _adfClient.Pipelines.CreateRunWithHttpMessagesAsync(_rgName, _adfName, pipelineName, parameters: parameters);
            return response.Body.RunId;
        }

        public async Task<List<ActivityRun>> GetActivityRuns(string pipelineRunId)
        {
            await InitialiseClient();
            var activityRuns = new List<ActivityRun>();
            
            var filter = new RunFilterParameters(DateTime.MinValue, DateTime.UtcNow);
            ActivityRunsQueryResponse arqr;
            do
            {
                arqr = await _adfClient.ActivityRuns.QueryByPipelineRunAsync(_rgName, _adfName, pipelineRunId, filter);
                activityRuns.AddRange(arqr.Value);
                filter.ContinuationToken = arqr.ContinuationToken;

            } while (arqr.ContinuationToken != null);

            return activityRuns;
        }

        public virtual void TearDown()
        {
            _adfClient?.Dispose();
        }

        public async Task<string> GetRunStatus(string pipelineRunId)
        {
            await InitialiseClient();
            var run = await _adfClient.PipelineRuns.GetAsync(_rgName, _adfName, pipelineRunId);
            return run.Status;
        }

        public async Task<bool> IsInProgress(string pipelineRunId)
        {
            await InitialiseClient();
            var status = await GetRunStatus(pipelineRunId);
            return status == "Queued" || status == "InProgress" || status == "Canceling";
        }

        public DataFactoryHelper()
        {
            _adfName = GetSetting("DataFactoryName");
            _rgName = GetSetting("DataFactoryResourceGroup");
        }
    }
}
