import psycopg2

HOST = "localhost"
DB_NAME = "e_library1"
USER = "postgres"
PASSWORD = "sayedee624432"
PORT = 5432

def create_connection():
    try:
        conn = psycopg2.connect(
            host=HOST,
            database=DB_NAME,
            user=USER,
            password=PASSWORD,
            port=PORT
        )
        return conn
    except (psycopg2.Error) as error:
        print("Error while connecting to PostgreSQL", error)
        return psycopg2.connect(
            host=HOST,
            database=DB_NAME,
            user=USER,
            password=PASSWORD,
            port=PORT
        )

conn = create_connection()
cur = conn.cursor()
Error = psycopg2.Error