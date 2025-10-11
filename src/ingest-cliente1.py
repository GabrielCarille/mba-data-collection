#!/usr/bin/env python3
# -- coding: utf-8 --
# ingest_cliente.py
#
# Inicializa o Spark, lê dados do PostgreSQL em um DataFrame,
# exibe o conteúdo e encerra a sessão Spark.

import sys
from pyspark.sql import SparkSession

DB_HOST = "db"
DB_PORT = "5432"
DB_NAME = "mydb"
DB_USER = "myuser"
DB_PASS = "mypassword"

def main():
    # Inicializa SparkSession com o driver JDBC do PostgreSQL
    spark = (
        SparkSession.builder
        .appName("IngestCliente")
        .master("local[*]")
        .config("spark.jars.packages", "org.postgresql:postgresql:42.7.3")
        .getOrCreate()
    )

    jdbc_url = f"jdbc:postgresql://{DB_HOST}:{DB_PORT}/{DB_NAME}"
    props = {
        "driver": "org.postgresql.Driver",
        "user": DB_USER,
        "password": DB_PASS,
    }

    try:
        # Lê os dados da tabela clientes em um DataFrame
        df_clientes = spark.read.jdbc(
            url=jdbc_url,
            table="(SELECT id, nome, email, telefone, data_cadastro, is_date FROM db_loja.clientes) t",
            properties=props
        )

        # Exibe o conteúdo do DataFrame
        print("✅ Dados lidos do banco de dados:")
        df_clientes.show(truncate=False)

    except Exception as e:
        print(f"❌ Erro ao ler dados do PostgreSQL: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        # Fecha a conexão (SparkSession)
        spark.stop()
        print("🔒 Conexão encerrada.")

if __name__ == "__main__":
    main()