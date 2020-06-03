using AdfTesting.Helpers;
using System.Threading.Tasks;

namespace PL_Stage_Titles_With_Warning
{
    public class PLStageTitlesWithWarningHelper : DatabaseHelper<PLStageTitlesWithWarningHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("PL_Stage_Titles_With_Warning");
        }

        public PLStageTitlesWithWarningHelper WithSourceTable(string tableName)
        {
            return this
                .WithParameter("_SrcConnectionSecretName", "AdfTestingDbConnectionString")
                .WithParameter("_SrcTableSchema", tableName.Split('.')[0])
                .WithParameter("_SrcTableName", tableName.Split('.')[1]);
        }

        public PLStageTitlesWithWarningHelper WithRowCountWarningThreshold(int threshold)
        {
            return this
                .WithParameter("_RowCountWarningThreshold", threshold);
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