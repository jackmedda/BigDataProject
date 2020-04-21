from pyspark import SparkConf, SparkContext

conf = (SparkConf() \
        .set('spark.yarn.dist.files','/home/ubuntu/spark/python/lib/pyspark.zip,/home/ubuntu/spark/python/lib/py4j-0.10.7-src.zip') \
        .setExecutorEnv('PYTHONPATH','pyspark.zip:py4j-0.10.7-src.zip'))
sc = SparkContext(conf = conf)

rdd = sc.textFile("hdfs://namenode:9000/sample.txt")

# split textfile into characters
split_chars = rdd.flatMap(list)

chars_count = split_chars.map(lambda c: (c,1)).reduceByKey(lambda c1,c2: c1+c2)

for x in chars_count.collect():
        print(x)