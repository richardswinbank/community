using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace GetMetadata.DevConsole
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var request = new DefaultHttpContext().Request;
            request.Method = HttpMethods.Post;
            request.Body = new MemoryStream(Encoding.ASCII.GetBytes("{\"storageAccount\":\"myStorageAccount\",\"container\":\"myContainer\",\"folderPath\":\"Path/To/Root\"}"));
            var response = await GetMetadata.Run(request, null);

            var okResponse = (OkObjectResult)response;
            Console.WriteLine(okResponse.Value.ToString());
        }
    }
}
