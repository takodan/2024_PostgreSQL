import psycopg2
import hidden

secrets = hidden.secrets()

conn = psycopg2.connect(host=secrets['host'],
        port=secrets['port'],
        database=secrets['database'], 
        user=secrets['user'], 
        password=secrets['pass'], 
        connect_timeout=3)

cur = conn.cursor()

sql = 'CREATE TABLE pythonseq (iter INTEGER, val INTEGER);'
print(sql)
cur.execute(sql)

conn.commit()


number = 775360
for i in range(300) :
    print(i+1, number)

    sql = 'INSERT INTO pythonseq (iter, val) VALUES (%s, %s);'
    cur.execute(sql, (i+1, number))

    number = int((number * 22) / 7) % 1000000

conn.commit()