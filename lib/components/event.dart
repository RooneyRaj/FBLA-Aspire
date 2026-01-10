class Event {
  final String title;
  final String? time; 


  Event(this.title, {this.time});

  @override
  String toString() => title;
}