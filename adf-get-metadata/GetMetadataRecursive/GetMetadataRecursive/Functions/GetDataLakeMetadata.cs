using Azure.Identity;
using Azure.Storage.Files.DataLake;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace GetMetadataRecursive.Functions
{
    public class GetMetadata
    {
        [FunctionName("GetMetadata")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req)
        {
            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var location = JsonConvert.DeserializeObject<DataLakeLocation>(requestBody);

            var files = await GetFiles(location);

            if (files.Count > 0)
                return new OkObjectResult("{\"files\":" + JsonConvert.SerializeObject(files) + "}");
            return new OkObjectResult("{\"files\":[]}");
        }

        private async Task<List<string>> GetFiles(DataLakeLocation location)
        {
            var client = new DataLakeFileSystemClient(new Uri(location.ContainerUri), new DefaultAzureCredential());
            var paths = new List<string>();
            await GetFiles(client, location.Path, paths);
            return paths;
        }

        private async Task GetFiles(DataLakeFileSystemClient client, string folderPath, List<string> paths)
        {
            var e = client.GetPathsAsync(folderPath).GetAsyncEnumerator();
            while (true)
            {
                if (!await e.MoveNextAsync())
                    break;
                else if (!e.Current.IsDirectory ?? false)
                    paths.Add(e.Current.Name);
                else
                    await GetFiles(client, e.Current.Name, paths);
            }
        }

        private class DataLakeLocation
        {
            public string ContainerUri { get; set; }
            public string Path { get; set; }
        }
    }
}