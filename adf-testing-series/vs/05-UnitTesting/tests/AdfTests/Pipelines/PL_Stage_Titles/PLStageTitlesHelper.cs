using AdfTesting.Helpers;
using System.Threading.Tasks;

namespace PL_Stage_Titles
{
    public class PLStageTitlesHelper : DatabaseHelper<PLStageTitlesHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("PL_Stage_Titles");
        }

        public int StagedRowCount
        {
            get
            {
                return RowCount("stg.Titles");
            }
        }
    }
}
