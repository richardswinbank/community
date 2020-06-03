using AdfTesting.Helpers;
using System.Threading.Tasks;

namespace PL_Stage_Titles_With_Stub
{
    public class PLStageTitlesWithStubHelper : DatabaseHelper<PLStageTitlesWithStubHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("PL_Stage_Titles_With_Stub");
        }

        public PLStageTitlesWithStubHelper WithSourceTable(string tableName)
        {
            return this
                .WithParameter("_SrcConnectionSecretName", "AdfTestingDbConnectionString")
                .WithParameter("_SrcTableSchema", tableName.Split('.')[0])
                .WithParameter("_SrcTableName", tableName.Split('.')[1]);
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