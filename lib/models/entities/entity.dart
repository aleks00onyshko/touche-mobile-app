interface class Entity<T> {
  T id;

  Entity(this.id);

  factory Entity.fromJson(Map<String, dynamic> json) => {'id': json['id']} as Entity<T>;

  toJson() => Map<String, Object?>;
}
