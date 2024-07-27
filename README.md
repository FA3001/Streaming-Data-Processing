# Streaming Data Processing

## Used Technologies and Services

- Apache Airflow
- Apache Zookeeper
- Apache Kafka
- Apache Hadoop HDFS
- Apache Spark (PySpark)
- Apache Hadoop YARN
- Elasticsearch
- Kibana
- MinIO
- Docker

## Overview

- Take a compressed data source from a URL
- Process the raw data with **PySpark**, and use **HDFS** as file storage, check resources with **Apache Hadoop YARN**.
- Use **data-generator** to simulate streaming data, and send the data to **Apache Kafka**.
- Read the streaming data from Kafka topic using **PySpark (Spark Streaming)**.
- Write the streaming data to **Elasticsearch**, and visualize it using **Kibana**.
- Write the streaming data to **MinIO (AWS Object Storage)**.
- Use **Apache Airflow** to orchestrate the whole data pipeline.

![image](https://github.com/user-attachments/assets/331227bb-536d-4a68-bdc4-1971eb44a758)



## Steps of the Project

- All services used via Docker and Makefile.

- All steps of the data pipeline can be seen via Airflow DAG. They are all explained here as well.

To run all sevices use:
```bash
  make start-all
```



### Download the Data:
We should first download the data via the command:
```bash
  wget -O /<your_local_directory>/sensors.zip https://github.com/dogukannulu/datasets/raw/master/sensors_instrumented_in_an_office_building_dataset.zip
```
This zip file contains a folder named `KETI`. Each folder inside this main folder represents
a room number. Each room contains five `csv` files, and each represents a property belonging to 
these rooms. These properties are:

- CO2
- Humidity
- Light
- Temperature
- PIR (Passive Infrared Sensor Data)

Each csv also includes timestamp column.

### Unzip the Downloaded Data and Remove README.txt:
We should then unzip this data via the following command:

```bash
unzip /<location_of_zip_file>/sensors_instrumented_in_an_office_building_dataset.zip -d /<desired_location_of_unzipped_folder/
```
Then, we have to remove README.txt since algorithm of the Spark script requires only folders under `KETI`, not files:

```bash
rm /<location_of_KETI>/KETI/README.txt
```

### Put data to HDFS:
`KETI` folder is now installed to our local successfully. 
Since PySpark gets the data from HDFS, we should put the local folder to HDFS 
as well using the following command:

```bash
docker exec -it <hdfs_container_id> bash
hdfs dfs -mkdir -p /user/hadoop/keti/
hdfs dfs -put /path/in/container/KETI /user/hadoop/keti/
```
We can browse for the HDFS location we put the data in via `localhost:9000`

### Running the Read-Write PySpark/Pandas Script:
Both `read_and_write_pandas.py` and `read_and_write_spark.py` can be used to modify the initial
data. They both do the same job.

All the methods and operations are described with comments and docstrings in both scripts.

We can check `localhost:8088` to see the resource usage (**YARN**) of the running jobs while Spark script is running.

Written data:

![image](https://github.com/user-attachments/assets/f804526d-10a8-4f38-b361-f51ab5bcf0a1)


**_NOTE:_** With this step, we have our data ready. You can see it as `sensors.csv` in this repo.

### Creating the Kafka Topic:

The script `kafka_admin_client.py` under the folder `kafka_admin_client` can be used to
create a Kafka topic or prints the `already_exists` message if there is already a Kafka topic
with that name.

We can check if topic has been created as follows:

```
kafka-topics.sh --bootstrap-server localhost:9092 --list
```

Streaming data example:

![image](https://github.com/user-attachments/assets/995aa967-98d1-4ae4-ba27-ee7d5a4fd847)

### Writing data to Elasticsearch using Spark Streaming:

We can access to Elasticsearch UI via `localhost:5601`

All the methods and operations are described with comments and docstrings in 
`spark_to_elasticsearch.py`.

Sample Elasticsearch data:

![image](https://github.com/user-attachments/assets/f787dc26-89d0-447b-a311-31a4af7e24df)

We can run this script by running `spark_to_elasticsearch.sh`. This script also runs the 
Spark virtualenv.

Logs of the script:

![image](https://github.com/user-attachments/assets/15a4b2ea-e036-449a-81fc-c54094a7f826)

### Writing data to MinIO using Spark Streaming:

We can access to MinIO UI via `localhost:9001`

All the methods and operations are described with comments and docstrings in 
`spark_to_minio.py`.


We can run this script by running `spark_to_minio.sh`. This script also runs the 
Spark virtualenv.

Sample MinIO data:
![image](https://github.com/user-attachments/assets/d4937d2d-c16b-472b-a2fd-06eee06ba274)

**_NOTE:_** We can also check the running Spark jobs via `localhost:4040`

### Airflow DAG Trigger:

We can trigger the Airflow DAG on `localhost:1502`. Triggering the DAG will do all the above 
explained data pipeline with one click. 

Airflow DAG:

![image](https://github.com/user-attachments/assets/d8f6879b-b0eb-419c-ab58-1421aba43bce)

![image](https://github.com/user-attachments/assets/41208aac-2c2f-45df-b564-2ff8f21fafae)


Running streaming applications on Airflow may create some issues. In that case, we can run
bash scripts instead.


### Create Dashboard on Elasticsearch/Kibana:

We can check the amount of streaming data (and the change of the amount) 
in Elasticsearch by running the following command:

```
GET /_cat/indices?v
```

We can create a new dashboard using the data in office_input index. Here are some sample graphs:

![image](https://github.com/user-attachments/assets/83f3e0f7-ce79-4f12-b485-9c7850d264a9)

![image](https://github.com/user-attachments/assets/cf4ac274-5493-435b-bce1-a2f6b856185b)

![image](https://github.com/user-attachments/assets/3df2c251-c8f9-48d6-bbea-149c59729fe6)

![image](https://github.com/user-attachments/assets/e5b1e4dd-d74c-4ba0-81c5-357e5271368d)


Which contains:
- Percentage of Movement Pie Chart
- Average CO2 per room Line Chart
- Average pir per Room Absolute Value Graph
- Average Light per Movement Status Gauge
- Average pir per Room Bar Chart
- Average Temperature per Movement Bar Chart
- Average Humidity per Hour Area Chart
- Median of CO2 per Movement Status Bar Chart
