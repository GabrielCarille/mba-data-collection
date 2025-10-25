# -*- coding: utf-8 -*-
"""
Script de teste de conexão com o Minio (Object Storage S3 compatível).

Este script utiliza a biblioteca 'minio' para:
1. Estabelecer uma conexão com o servidor Minio em execução no container 'minio'.
2. Verificar se um bucket de teste (ex: 'meu-bucket-teste') existe.
3. Se o bucket não existir, ele será criado.
4. Fazer upload de um pequeno objeto de dados (em memória) para o bucket.
5. Listar os objetos no bucket para confirmar que o upload foi bem-sucedido.
6. Imprimir o status de cada operação.
"""

# 1. Importação da Biblioteca
# Importamos a biblioteca Minio e a classe BytesIO para simular um arquivo em memória.
from minio import Minio
from io import BytesIO

def main():
    """Função principal que executa o teste de conexão e operação do Minio."""

    print("Tentando se conectar ao servidor Minio...")

    # 2. Definição dos Parâmetros de Conexão
    # Estes valores DEVEM ser os mesmos que definimos na seção 'environment'
    # do serviço 'minio' no seu arquivo 'docker-compose.yml'.
    #
    # IMPORTANTE: O 'endpoint' é 'minio:9000'. 'minio' é o nome do serviço
    # no docker-compose.yml e 9000 é a porta padrão da API do Minio.
    # Não use 'localhost' ou '127.0.0.1' aqui!
    # 'secure=False' é usado porque estamos em uma rede interna do Docker sem SSL.
    try:
        minio_client = Minio(
            "minio:9000",
            access_key="minioadmin", 
            secret_key="minioadmin", 
            secure=False
        )
        
        # Ping básico (list_buckets) para verificar a conexão
        minio_client.list_buckets()
        print("Conexão com o Minio estabelecida com sucesso!")

    except Exception as e:
        print(f"\nOcorreu um erro ao conectar ao Minio: {e}")
        print("Verifique se o container 'minio' está em execução e as credenciais estão corretas.")
        return  # Sai do script se não puder conectar

    # 3. Definir nome do bucket e do objeto
    bucket_name = "meu-bucket-teste"
    object_name = "teste.txt"
    
    try:
        # 4. Verificar e Criar o Bucket
        found = minio_client.bucket_exists(bucket_name)
        if not found:
            print(f"Bucket '{bucket_name}' não encontrado. Criando...")
            minio_client.make_bucket(bucket_name)
            print(f"Bucket '{bucket_name}' criado com sucesso.")
        else:
            print(f"Bucket '{bucket_name}' já existe.")

        # 5. Preparar e Fazer Upload de um Objeto
        # Criamos um "arquivo" em memória com conteúdo de texto.
        test_data = b"Ola Minio! Este e um teste de conexao."
        test_data_stream = BytesIO(test_data)
        data_size = len(test_data)

        print(f"\nFazendo upload do objeto '{object_name}' para o bucket '{bucket_name}'...")
        minio_client.put_object(
            bucket_name,
            object_name,
            test_data_stream,
            length=data_size,
            content_type='text/plain'
        )
        print("Upload concluído com sucesso.")

        # 6. Listar Objetos no Bucket para Verificação
        print(f"\n--- Objetos no bucket '{bucket_name}' ---")
        objects = minio_client.list_objects(bucket_name, recursive=True)
        found_object = False
        for obj in objects:
            print(f"- {obj.object_name} (Tamanho: {obj.size} bytes)")
            if obj.object_name == object_name:
                found_object = True
        
        if not found_object:
            raise Exception(f"O objeto '{object_name}' que acabamos de enviar não foi encontrado na listagem!")

        print("\nTeste de conexão e operação do Minio concluído com sucesso!")

    except Exception as e:
        # Se qualquer erro relacionado ao Minio ocorrer no bloco 'try',
        # ele será capturado aqui.
        print(f"\nOcorreu um erro durante as operações do Minio: {e}")

if __name__ == '__main__':
    main()
