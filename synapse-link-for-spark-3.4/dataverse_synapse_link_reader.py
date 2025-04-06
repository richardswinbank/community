#!/usr/bin/env python
# coding: utf-8

# ## dataverse_synapse_link_reader
# 
# Set `spark.sql.ansi.enabled` true to flush out any type cast failures later.
# 

# In[17]:


spark.conf.set("spark.sql.ansi.enabled", "true")
from pyspark.sql import DataFrame, Row, Column
import pyspark.sql.functions as F


# #### _get_type_map()
# Returns a dataframe mapping CDM type names to PySpark type names. This list is taken from the [CdmDataFormat enum](https://learn.microsoft.com/en-us/common-data-model/1.0om/api-reference/cdm/dataformat?wt.mc_id=DP-MVP-5004052) documentation.

# In[18]:


def _get_type_map() -> DataFrame:

    return spark.createDataFrame([
          ("int16", "int")
        , ("int32", "int")
        , ("int64", "long")
        , ("float", "float")
        , ("double", "double")
        , ("guid", "string")
        , ("string", "string")
        , ("char", "string")
        , ("byte", "binary")
        , ("binary", "binary")
        , ("time", "timestamp")
        , ("date", "timestamp")
        , ("dateTime", "timestamp")
        , ("dateTimeOffset", "timestamp")
        , ("boolean", "boolean")
        , ("decimal", "decimal")
        , ("json", "string")
        ], schema="cdm_type string, pyspark_type string")


# #### _get_model()
# Returns a dataframe containing the list of tables and columns contained in `model.json`.
# 

# In[19]:


def _get_model(model_path:str) -> DataFrame:
    
    df_model = spark.read.json(model_path)

    df_entities = (
        df_model
        .withColumn("e", F.explode("entities"))
        .withColumn("entity_name", F.col("e.name"))
        .withColumn("description", F.col("e.description"))
        .withColumn("entity_type", F.col("e.$type"))
        .withColumn("attributes", F.col("e.attributes"))
        .withColumn("annotations", F.col("e.annotations"))
        .withColumn("partitions", F.col("e.partitions"))
        .select("entity_name", "description", "entity_type", "attributes", "annotations", "partitions")
    )

    # parse basic attribute properties
    df_attributes = (
        df_entities
        .select("*", F.posexplode("attributes").alias("attr_offset", "a"))
        .withColumn("attribute_name", F.col("a.name"))
        .withColumn("cdm_type", F.col("a.dataType"))
        .withColumn("max_length", F.col("a.maxLength"))
        .withColumn("ts", F.col("a.cdm:traits"))
    )

    # parse numeric precision & scale
    df_attributes = (
        df_attributes
        .withColumn("t", F.filter(F.col("ts"), lambda t : t.traitReference == "is.dataFormat.numeric.shaped"))
        .withColumn("t", F.when(F.size("t") > 0, F.col("t")[0]))
        .withColumn("as", F.col("t.arguments"))
        .withColumn("p", F.filter(F.col("as"), lambda a : a["name"] == "precision"))
        .withColumn("p", F.when(F.size("p") > 0, F.col("p")[0]))
        .withColumn("precision", F.col("p.value"))
        .withColumn("s", F.filter(F.col("as"), lambda a : a["name"] == "scale"))
        .withColumn("s", F.when(F.size("s") > 0, F.col("s")[0]))
        .withColumn("scale", F.col("s.value"))
        .select("entity_name", "attribute_name", "attr_offset", "cdm_type", "max_length", "precision", "scale")
    )

    return ( 
        df_attributes
        .join(_get_type_map(), ["cdm_type"], how="left")
        .withColumn(
            "pyspark_type", 
            F.when(
                F.col("precision").isNotNull(), 
                F.concat(F.col("pyspark_type"), F.lit("("), F.col("precision"), F.lit(","), F.col("scale"), F.lit(")"))
            ).otherwise(F.col("pyspark_type")))
        .select("entity_name", "attribute_name", "attr_offset", "pyspark_type")
    )


# #### _get_columns()
# Returns an array of PySpark `Row` objects containing attribute metadata for a specified entity.

# In[20]:


def _get_columns(entity_name:str, model_path:str) -> [Row]:
    return (
        _get_model(model_path=model_path)
        .where(f"entity_name == '{entity_name}'")
        .orderBy("attr_offset")
        .select("attribute_name", "pyspark_type")
        .collect()
    )


# #### _to_iso_timestamp()
# Transforms a string column in date format `M/d/yyyy H:mm:ss tt` to a string column in date format `yyyy-MM-dd'T'HH:mm:ss'Z'`.
# 
# [Required](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/export-data-lake-faq#what-date-and-time-formats-can-be-expected-in-exported-dataverse-tables?wt.mc_id=DP-MVP-5004052) for `SinkCreatedOn` and `SinkModifiedOn`.
# 
# 

# In[ ]:


def _to_iso_timestamp(c:Column) -> Column:
  return F.date_format(F.to_timestamp(c, "M/d/y h:m:s a"), "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")


# #### load_dataverse_entity()
# Returns a dataframe containing data from a specified entity in a given [Azure Synapse Link for Dataverse](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/azure-synapse-link-synapsehttps://learn.microsoft.com/en-us/power-apps/maker/data-platform/azure-synapse-link-synapse?wt.mc_id=DP-MVP-5004052) storage location.

# In[26]:


def load_dataverse_entity(entity_name:str, storage_root:str):

    cols = _get_columns(entity_name=entity_name, model_path=f"{storage_root}/model.json")
    schema = ", ".join([ f"{c.attribute_name} string" for c in cols])

    # read CSV columns as strings
    df = (
        spark.read.options(mode='FAILFAST', multiLine=True, escape='"')
        .csv(f"{storage_root}/{entity_name}/*.csv", schema=schema)
        .withColumn("SinkCreatedOn", _to_iso_timestamp(F.col("SinkCreatedOn")))
        .withColumn("SinkModifiedOn", _to_iso_timestamp(F.col("SinkModifiedOn")))
    )

    # cast strings to declared types (makes failures fatal with spark.sql.ansi.enabled=true)
    for c in cols:
        df = df.withColumn(c.attribute_name, F.col(c.attribute_name).cast(c.pyspark_type))
    
    return df

