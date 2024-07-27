################################################################################
# Run the task
################################################################################

# All
start-all:  start-airflow start-hdfs start-spark start-kafka start-general

stop-all: stop-airflow stop-hdfs stop-spark stop-kafka  stop-general

# Airflow
start-airflow:
	docker build -t airflow:0.1 ./infra/airflow
	docker-compose -f ./infra/airflow/airflow-compose.yml up -d
stop-airflow:
	docker-compose -f ./infra/airflow/airflow-compose.yml down

# HDFS
start-hdfs:
	docker-compose -f ./infra/hdfs/hdfs-compose.yml up -d
stop-hdfs:
	docker-compose -f ./infra/hdfs/hdfs-compose.yml down

# Spark
start-spark:
	docker-compose -f ./infra/spark/spark-compose.yml up -d
stop-spark:
	docker-compose -f ./infra/spark/spark-compose.yml down

# Kafka
start-kafka:
	docker-compose -f ./infra/kafka/kafka-compose.yml up -d
stop-kafka:
	docker-compose -f ./infra/kafka/kafka-compose.yml down

# Kafka
start-general:
	docker-compose -f /workspaces/Streaming-spark-kafka-elasticsearch-kibana-minio-docker/docker-compose.yaml up -d
stop-general:
	docker-compose -f /workspaces/Streaming-spark-kafka-elasticsearch-kibana-minio-docker/docker-compose.yaml down

# Network
# start-network:
# 	docker network create -d bridge kafka-network
# stop-network:
# 	docker network rm kafka-network

################################################################################
# Test the task
################################################################################

# test:
# 	python -m unittest discover -s tests
