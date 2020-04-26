using AdfTesting.Helpers;
using System.Threading.Tasks;

namespace PL_Stage_Authors
{
    public class PLStageAuthorsHelper : DatabaseHelper
    {
        public async Task RunPipeline()
        {
            await RunPipeline("PL_Stage_Authors");
        }

        public int StagedRowCount
        {
            get
            {
                return RowCount("stg.Authors");
            }
        }
    }
}