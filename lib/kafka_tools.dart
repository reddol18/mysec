import 'package:kafkabr/kafka.dart';

class KafkaTools {
  late var session;
  late var group;
  late var topics;
  late var consumer;
  late var producer;
  late String topic;
  KafkaTools(String ip, int port, String cgroup, String topic, int startIndex, int lastIndex) {
    var host = new ContactPoint('127.0.0.1', 9092);
    session = new KafkaSession([host]);
    producer = new Producer(session, 1, 1000);
    group = new ConsumerGroup(session, cgroup);
    this.topic = topic;
    topics = {
      topic: [startIndex, lastIndex] // list of partitions to consume from.
    };
    consumer = new Consumer(session, group, topics, 100, 1);
  }

  Future<void> send(String message) async {
    var result = await producer.produce([
      new ProduceEnvelope(topic, 0, [new Message(message.codeUnits)]),
    ]);
    print(result);
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
