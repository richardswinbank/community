using GetMetadataRecursive;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Azure.WebJobs.Hosting;

[assembly: WebJobsStartup(typeof(FunctionAppStartup))]
namespace GetMetadataRecursive
{
    public class FunctionAppStartup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
        }
    }
}
