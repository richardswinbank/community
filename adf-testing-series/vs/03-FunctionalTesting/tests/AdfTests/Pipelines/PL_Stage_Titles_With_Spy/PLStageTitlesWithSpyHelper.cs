using AdfTesting.Helpers;
using System.Threading.Tasks;

namespace PL_Stage_Titles_With_Spy
{
    public class PLStageTitlesWithSpyHelper : DatabaseHelper<PLStageTitlesWithSpyHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("PL_Stage_Titles_With_Spy");
        }

        public PLStageTitlesWithSpyHelper WithSourceTable(string tableName)
        {
            return this
                .WithParameter("_SrcConnectionSecretName", "AdfTestingDbConnectionString")
                .WithParameter("_SrcTableSchema", tableName.Split('.')[0])
                .WithParameter("_SrcTableName", tableName.Split('.')[1])
                ;
        }

        public PLStageTitlesWithSpyHelper WithRunIdStub()
        {
            return this
                .WithParameter("_LogStartSpName", "test.LogPipelineStartStub")
                .WithParameter("_LogEndSpName", "test.LogPipelineEndSpy")
                .WithEmptyTable("test.LogPipelineEndSpyLog");
        }

        public int RunId
        {
            get
            {
                return int.Parse(ColumnData("test.LogPipelineEndSpyLog", "RunId"));
            }
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