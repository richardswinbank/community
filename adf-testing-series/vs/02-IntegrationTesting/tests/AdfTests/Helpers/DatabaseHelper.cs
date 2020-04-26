using System.Data.SqlClient;

namespace AdfTesting.Helpers
{
    public class DatabaseHelper : DataFactoryHelper
    {
        public int RowCount(string tableName)
        {
            using (var conn = new SqlConnection(GetSetting("AdfTestingDbConnectionString")))
            {
                conn.Open();
                using (var cmd = new SqlCommand($"SELECT COUNT(*) FROM {tableName}", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    return reader.GetInt32(0);
                }
            }
        }
    }
}
