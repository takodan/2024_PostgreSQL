import psycopg2
import hidden
import requests

secrets = hidden.secrets()

conn = psycopg2.connect(host=secrets['host'],
        port=secrets['port'],
        database=secrets['database'], 
        user=secrets['user'], 
        password=secrets['pass'], 
        connect_timeout=3)

cur = conn.cursor()

sql = 'CREATE TABLE IF NOT EXISTS pokeapi (id INTEGER, body JSONB);'
print(sql)
cur.execute(sql)

for i in range(1, 101):
    url = f"https://pokeapi.co/api/v2/pokemon/{i}"
    response = requests.get(url)

    if response.status_code != 200:
        print("something went wrong")
        break
    text = response.text
    sql = 'INSERT INTO pokeapi (id, body) VALUES (%s, %s);'
    cur.execute(sql, (i, text))

    if i % 5 == 0:
        conn.commit()

conn.commit()
