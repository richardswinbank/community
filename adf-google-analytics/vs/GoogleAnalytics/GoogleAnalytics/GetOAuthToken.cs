using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Google.Apis.Auth.OAuth2;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using System;
using System.Threading.Tasks;

namespace GoogleAnalytics
{
    public class GetOAuthToken
    {
        [FunctionName("GetOAuthToken")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req)
        {
            var kvClient = new SecretClient(new Uri(Environment.GetEnvironmentVariable("KEY_VAULT_URL")), new ManagedIdentityCredential());
            string keyJson = kvClient.GetSecret("GoogleServiceAccountKeyJson").Value.Value;

            var cred = GoogleCredential.FromJson(keyJson).CreateScoped(new string[] { "https://www.googleapis.com/auth/analytics.readonly" });
            var token = await cred.UnderlyingCredential.GetAccessTokenForRequestAsync();

            return new OkObjectResult("{\"token\":\"" + token + "\"}");
        }
    }
}
