# Database Architecture, Scale, and NoSQL with Elasticsearch
## Module 1 Scaling Database
1. Database Normalization: Don't replicate data until you fully understand database normalization
2. ACID or BASE
3. ACID
    1. Atomicity
    2. Consistency
    3. Isolation
    4. Durability
    5. Most SQL database is ACID
4. BASE
    1. Basically
    2. Available
    3. Soft state
    4. Eventual consistency: document may temporarily differ until the changes are propagated and synchronized
    5. NoSQL like MongoDB and Apache Cassandra is BASE

5. Simply put, ACID ensures strong consistency by guaranteeing that all users read the same data. On the other hand, BASE databases operate on multiple distributed replicas, which may have different data at intermediate points but eventually achieve consistency.
6.  https://aws.amazon.com/compare/the-difference-between-acid-and-base-database/
7. Vertical Scaling: improve or add more hardware, it's good , but never enough.
8. Master/Read Only Replicas 
    1. It consists of a master database and multiple replica databases.
    2. Data modifications are executed on the master and recorded in a transaction log.
    3. The replicas are updated based on this transaction log.
    4. sort of BASE-like
9. Multi-Master
    1. similar to Master/Read Only Replicas but with more master database
    2. need to put a lot of resources into coordination.
10. Multiple Store Type
    1. Using different databases to store different types of data.



## Module 2 Cloud Scale Applications
1. First Generation Cloud Application Example: Google
    1. Scatter-Gather pattern
    2. server scalability
    3. replication of data
    4. people kind of like handling things in their own corners on servers
2. Second Generation Cloud Application Example: Facebook and Twitter
    1. challenge: Privacy settings have made the relationships between files very complex
    2. eventual consistency
3. BASE Solutions
    1. basic principles
        1. distribute (via fast network)
        2. no central locks
        3. lots of fast but small memory CPU
        4. lots of disks
        5. indexes follow data shards
        6. documents (not tables)
4. NoSQL Database
    1. CouchDB
    2. MongoDB
    3. Cassandra (Apache Cassandra)
    4. ElasticSearch
        1. initially full text search Apache Lucene
        2. Evolved into JSON database
    5. AWS DynamoDB
    6. Google BigTable
    7. Azure Table Storage
5. SQL react to BASE
    1. Rapid advancements in hardware have reduced the costs of vertical scaling.
    2. add JSON like columns
    3. Being BASE-like in ACID RDBMS
        1. accept replicate
        2. use GUID
        3. column is only for indexing
        4. don't use foreign keys
        5. design schema/indexes to enable reading a single row on query
        6. Don;t use ALTER, JOINS, aggregation



## Module 3 Elasticsearch
1. ELK stack
    1. Elasticsearch: distributed NoSQL database
    2. Logstash: ingests streams of active data 
    3. Kibana: visualization
2. Python Elasticsearch
    1. `pip install elasticsearch`
3. all the demos and assignments are in the "4_Assignment"



## Module 4 Course Wrap Up
1. Course end
