import 'package:kafkabr/kafka.dart';

class kafka_tools {
  late var session;
  late var group;
  late var topics;
  late var consumer;
  late var producer;
  kafka_tools(String ip, int port, String cgroup, String topic, String startIndex, String lastIndex) {
    var host = new ContactPoint('127.0.0.1', 9092);
    session = new KafkaSession([host]);
    producer = new Producer(session, 1, 1000);
    group = new ConsumerGroup(session, 'consumerGroupName');
    topics = {
      'topicName': [0, 1] // list of partitions to consume from.
    };
    consumer = new Consumer(session, group, topics, 100, 1);
  }

  void send(String message) async {
    var result = await producer.produce([
      new ProduceEnvelope('topicName', 0, [new Message('msgForPartition0'.codeUnits)]),
      new ProduceEnvelope('topicName', 1, [new Message('msgForPartition1'.codeUnits)])
    ]);
  }

  void receive() async {
    await for (BatchEnvelope batch in consumer.batchConsume(20)) {
      batch.items.forEach((MessageEnvelope envelope) {
        // use envelope as usual
      });
      batch.commit('metadata'); // use batch control methods instead of individual messages.
    }
  }

  void close() {
    session.close();
  }
}
