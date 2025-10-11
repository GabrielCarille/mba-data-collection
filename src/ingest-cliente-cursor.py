from pyspark.sql import SparkSession
import psycopg2

def main():

    print("Inicializando a sessão Spark com o dataset de produtos...")

    spark = SparkSession.builder.appName("TesteProductosSpark").getOrCreate()
    print("Sessão Spark iniciada com sucesso!")

    # Parâmetros da conexão
    conn_params = {
        "host": "db",
        "database": "mydb",
        "user": "myuser",
        "password": "mypassword"
    }

    conn = None
    try:
        print("Conectando ao banco PostgreSQL...")
        conn = psycopg2.connect(**conn_params)
        cur = conn.cursor()

        print("Conexão estabelecida! Executando SELECT...")
        cur.execute("""
            SELECT id, nome, email, telefone, data_cadastro, is_date 
            FROM db_loja.clientes
        """)

        # Busca os resultados
        rows = cur.fetchall()

        # Cabeçalhos das colunas
        col_names = [desc[0] for desc in cur.description]
        print(f"\nColunas: {col_names}")

        # Printar os dados
        print("\nDados retornados:")
        for row in rows:
            print(row)

        print(f"\nTotal de registros retornados: {len(rows)}")

    except Exception as e:
        print(f"Erro: {e}")

    finally:
        print("\nEncerrando a sessão Spark...")
        spark.stop()
        if conn is not None:
            conn.close()
            print("Conexão com o banco de dados foi fechada.")

if __name__ == "__main__":
    main()