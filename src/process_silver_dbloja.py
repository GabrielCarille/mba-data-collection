# -- coding: utf-8 --
"""
Silver (Trusted) para db_loja.
Lê a Bronze (raw), aplica schema/tipos e grava Parquet na Silver (trusted).

- FULL overwrite: categorias_produto, cliente, pedido_cabecalho, pedido_itens
- MERGE (upsert): produto (chave id_produto)
- Leitura Bronze aceita dois layouts:
   1) s3a://data-ingest/bronze/dbloja/data=*/<tabela>_*.parquet
   2) s3a://data-ingest/bronze/db_loja/<tabela>/
- Escrita Silver:
   s3a://data-ingest/datalake/silver/db_loja/<tabela>/
"""

from pyspark.sql import SparkSession
from pyspark.sql.types import (
    StructType, StructField,
    IntegerType, StringType, DoubleType, DateType
)
from pyspark.sql.functions import col, coalesce, to_date, trim

# ---------------- CONFIG ----------------
BUCKET              = "data-ingest"
BRONZE_DBLOJA_1     = f"s3a://{BUCKET}/bronze/dbloja"        # seu ingest gerou aqui
BRONZE_DBLOJA_2     = f"s3a://{BUCKET}/bronze/db_loja"       # fallback compatível
SILVER_BASE         = f"s3a://{BUCKET}/datalake/silver/db_loja"

MINIO_ENDPOINT      = "http://minio:9000"
ACCESS_KEY          = "minioadmin"
SECRET_KEY          = "minioadmin"

# ---------------- SPARK ----------------
spark = (
    SparkSession.builder
    .appName("process_silver_dbloja")
    .config("spark.jars.packages",
            "org.apache.hadoop:hadoop-aws:3.3.4,"
            "com.amazonaws:aws-java-sdk-bundle:1.12.772")
    .getOrCreate()
)

# Hadoop S3A (usar somente valores numéricos – evita NumberFormatException "60s")
hconf = spark.sparkContext._jsc.hadoopConfiguration()
hconf.set("fs.s3a.endpoint", MINIO_ENDPOINT)
hconf.set("fs.s3a.access.key", ACCESS_KEY)
hconf.set("fs.s3a.secret.key", SECRET_KEY)
hconf.set("fs.s3a.path.style.access", "true")
hconf.set("fs.s3a.connection.ssl.enabled", "false")
hconf.set("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")

# timeouts, conexões e upload (todos numéricos)
hconf.set("fs.s3a.connection.establish.timeout", "5000")   # ms
hconf.set("fs.s3a.connection.timeout", "60000")            # ms
hconf.set("fs.s3a.socket.timeout", "60000")                # ms
hconf.set("fs.s3a.attempts.maximum", "10")
hconf.set("fs.s3a.retry.interval", "1000")                 # ms
hconf.set("fs.s3a.connection.maximum", "200")
hconf.set("fs.s3a.threads.max", "256")
hconf.set("fs.s3a.threads.keepalivetime", "60")            # segundos
hconf.set("fs.s3a.multipart.size", "8388608")              # 8MB
hconf.set("fs.s3a.multipart.threshold", "10485760")        # 10MB
hconf.set("fs.s3a.fast.upload", "true")

print("🚀 Iniciando processamento Silver...")

# ---------------- SCHEMAS ----------------
schema_categorias_produto = StructType([
    StructField("id_categoria", IntegerType()),
    StructField("descricao", StringType()),
])

schema_cliente = StructType([
    StructField("id_cliente", IntegerType()),
    StructField("nome", StringType()),
    StructField("cidade", StringType()),
    StructField("uf", StringType()),
])

schema_pedido_cabecalho = StructType([
    StructField("id_pedido", IntegerType()),
    StructField("id_cliente", IntegerType()),
    StructField("data_pedido", StringType()),   # será convertido pra Date
    StructField("status", StringType()),
])

schema_pedido_itens = StructType([
    StructField("id_pedido", IntegerType()),
    StructField("id_produto", IntegerType()),
    StructField("quantidade", IntegerType()),
])

schema_produto = StructType([
    StructField("id_produto", IntegerType()),
    StructField("descricao", StringType()),
    StructField("preco", DoubleType()),
    StructField("id_categoria", IntegerType()),
])

# ---------------- HELPERS ----------------
def read_bronze_table(table_name: str, schema: StructType):
    """
    Lê a Bronze tentando 2 layouts:
      1) bronze/dbloja/data=*/<tabela>_*.parquet (seu ingest atual)
      2) bronze/db_loja/<tabela>/                (fallback)
    """
    path1 = f"{BRONZE_DBLOJA_1}/data=*/{table_name}_*.parquet"
    path2 = f"{BRONZE_DBLOJA_2}/{table_name}/"
    last_err = None

    for path in (path1, path2):
        try:
            df = spark.read.schema(schema).parquet(path)
            return df
        except Exception as e:
            last_err = e
    raise RuntimeError(
        f"Não encontrei Bronze para '{table_name}'. "
        f"Tentado:\n - {path1}\n - {path2}\nErro: {last_err}"
    )

def write_silver(df, table_name: str):
    out = f"{SILVER_BASE}/{table_name}/"
    df.write.mode("overwrite").parquet(out)
    print(f"✅ Silver escrita: {out}")

# ---------------- FULL (overwrite) ----------------
def process_full(table_name: str, schema: StructType):
    print(f"🔄 [FULL] {table_name}")
    df = read_bronze_table(table_name, schema).dropDuplicates()

    # pequenas limpezas por tabela
    if table_name == "cliente":
        df = df.withColumn("uf", trim(col("uf")))  # remove espaços
    if table_name == "pedido_cabecalho":
        # tenta YYYY-MM-DD; ajuste o formato se seu Bronze usar outro
        df = df.withColumn("data_pedido", to_date(col("data_pedido"), "yyyy-MM-dd")) \
               .withColumnRenamed("data_pedido", "data_pedido_date")  # mantém tipado

    write_silver(df, table_name)

# ---------------- MERGE (upsert) PRODUTO ----------------
def process_incremental_produto():
    print("🔄 [MERGE] produto")
    bronze = read_bronze_table("produto", schema_produto).dropDuplicates(["id_produto"])

    silver_path = f"{SILVER_BASE}/produto/"
    try:
        silver = spark.read.parquet(silver_path)
        has_silver = True
        print("📂 Silver existente carregada.")
    except Exception:
        has_silver = False
        print("⚠️ Silver inexistente — carga inicial FULL.")
        write_silver(bronze, "produto")
        return

    # outer join por id_produto; prioriza valores da Bronze com coalesce
    merged = (
        bronze.alias("b")
        .join(silver.alias("s"), on="id_produto", how="outer")
        .select(
            col("id_produto"),
            coalesce(col("b.descricao"),    col("s.descricao")).alias("descricao"),
            coalesce(col("b.preco"),        col("s.preco")).alias("preco"),
            coalesce(col("b.id_categoria"), col("s.id_categoria")).alias("id_categoria"),
        )
        .dropDuplicates(["id_produto"])
    )

    write_silver(merged, "produto")

# ---------------- EXEC ----------------
process_full("categorias_produto", schema_categorias_produto)
process_full("cliente",            schema_cliente)
process_full("pedido_cabecalho",   schema_pedido_cabecalho)
process_full("pedido_itens",       schema_pedido_itens)
process_incremental_produto()

print("\n🏁 Camada Silver processada com sucesso!")
spark.stop()
