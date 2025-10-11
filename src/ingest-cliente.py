from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg

def main():

    """Função principal que executa o teste do Spark."""
    print("Iniciando a sessão Spark com o dataset de produtos...")


    spark = SparkSession.builder.appName("TesteProdutosSpark").getOrCreate()
    print("Sessão Spark iniciada com sucesso!")

    try:
        # 3. Criação de Dados de Exemplo (os mesmos do teste_pandas.py)
        dados = [('Café', 'Bebida', 15.50, 150),
                 ('Açúcar', 'Mercearia', 4.20, 300),
                 ('Leite', 'Laticínio', 5.80, 200),
                 ('Pão', 'Padaria', 7.00, 90),
                 ('Manteiga', 'Laticínio', 12.00, 120),
                 ('Suco', 'Bebida', 9.90, 80)]
        
        colunas = ['Produto', 'Categoria', 'Preco', 'Estoque']

        print("\nCriando DataFrame do Spark...")
        df = spark.createDataFrame(dados, colunas)

        # 5. Inspeção Básica do DataFrame
        print("\n--- Schema do DataFrame (.printSchema()) ---")
        # .printSchema() é o equivalente do Spark ao .info() do Pandas.
        df.printSchema()

        print("\n--- Conteúdo Original do DataFrame (.show()) ---")
        # .show() é o equivalente do Spark a simplesmente imprimir o DataFrame no Pandas.
        df.show()

        # 6. Manipulação de Dados (aqui a sintaxe começa a diferenciar do Pandas)
        
        # Filtrando linhas com base em uma condição
        # Note a sintaxe: df.filter(...). Em Pandas, a sintaxe comum é df[df['Coluna'] == valor].
        # Usar a função `col()` é uma boa prática no Spark para se referir a colunas.
        print("\n--- Filtrando apenas produtos da categoria 'Laticínio' ---")
        laticinios_df = df.filter(col('Categoria') == 'Laticínio')
        laticinios_df.show()

        # Criando uma nova coluna
        # Diferente do Pandas (df['nova_coluna'] = ...), no Spark usamos .withColumn().
        # Esta operação retorna um **novo** DataFrame, pois DataFrames do Spark são imutáveis.
        print("\n--- Adicionando uma nova coluna 'Valor_Total_Estoque' ---")
        df_com_valor = df.withColumn("Valor_Total_Estoque", col("Preco") * col("Estoque"))
        df_com_valor.show()
        
        # 7. Agrupamento e Agregação (Group By)
        # A sintaxe .groupBy() é muito parecida com a do Pandas.
        # A agregação é feita com o método .agg(), onde podemos passar funções como avg() (média).
        # Usamos .alias() para renomear a coluna do resultado para algo mais claro.
        print("\n--- Preço médio por Categoria (.groupBy() e .agg()) ---")
        preco_medio_por_categoria_df = df.groupBy("Categoria").agg(
            avg("Preco").alias("Preco_Medio")
        )
        preco_medio_por_categoria_df.show()

        print("\n\nTeste do Spark com dataset de produtos concluído com sucesso!")

    finally:
        # 8. Encerramento da Sessão
        print("\nEncerrando a sessão Spark.")
        spark.stop()


if __name__ == '__main__':
    main()



