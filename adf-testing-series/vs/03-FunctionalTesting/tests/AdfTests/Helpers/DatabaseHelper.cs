using System.Data.SqlClient;

namespace AdfTesting.Helpers
{
    public class DatabaseHelper<T> : DataFactoryHelper<T> where T : DatabaseHelper<T>
    {
        public int RowCount(string tableName)
        {
            using (var _conn = new SqlConnection(GetSetting("AdfTestingDbConnectionString")))
            {
                _conn.Open();
                using (var cmd = new SqlCommand($"SELECT COUNT(*) FROM {tableName}", _conn))
                using (var reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    return reader.GetInt32(0);
                }
            }
        }

        public T WithEmptyTable(string tableName)
        {
            using (var _conn = new SqlConnection(GetSetting("AdfTestingDbConnectionString")))
            {
                _conn.Open();
                using (var cmd = new SqlCommand($"TRUNCATE TABLE {tableName}", _conn))
                    cmd.ExecuteNonQuery();
            }
            return (T)this;
        }

        public string ColumnData(string tableName, string columnName, char separator = ',')
        {
            using (var _conn = new SqlConnection(GetSetting("AdfTestingDbConnectionString")))
            {
                _conn.Open();
                using (var cmd = new SqlCommand($"SELECT STRING_AGG([{columnName}],'{separator}') FROM {tableName}", _conn))
                using (var reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    return reader.GetString(0);
                }
            }           
        }
    }
}
