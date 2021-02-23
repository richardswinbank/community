using Azure.Identity;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace GetMetadata
{
    public static class GetMetadata
    {
        [FunctionName("GetMetadata")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string storageAccount = data.storageAccount;
            string container = data.container;
            string folderPath = data.folderPath;  // with no leading slash

            var uri = $"https://{storageAccount}.blob.core.windows.net/";
            var serviceClient = new BlobServiceClient(new Uri(uri), new DefaultAzureCredential());
            var containerClient = serviceClient.GetBlobContainerClient(container);

            var files = new List<BlobFilePath>();
            await GetFiles(containerClient, folderPath, files);

            return new OkObjectResult("{\"childItems\":" + JsonConvert.SerializeObject(files) + "}");
        }

        private static async Task GetFiles(BlobContainerClient client, string path, List<BlobFilePath> files)
        {
            var pages = client.GetBlobsByHierarchyAsync(prefix: path, delimiter: "/").AsPages(default);
            await foreach (var page in pages)
            {
                foreach (var item in page.Values)
                {
                    if (item.IsPrefix)
                        await GetFiles(client, item.Prefix, files);
                    else
                        files.Add(new BlobFilePath(item.Blob.Name));
                }
            }
        }
    }

    public class BlobFilePath
    {
        private string _path;

        public string name { get { return Path.GetFileName(_path); } }
        public string folderName { get { return Path.GetDirectoryName(_path).Replace('\\', '/'); } }
        public string type { get { return "File"; } }

        public BlobFilePath(string path)
        {
            _path = path;
        }
    }
}
