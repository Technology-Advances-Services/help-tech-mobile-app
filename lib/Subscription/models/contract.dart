class Contract {

  int id;
  int membershipId;
  String personId;
  String name;
  double price;
  String policies;
  DateTime? startDate;
  DateTime? finalDate;

  Contract({
    this.id = 0,
    this.membershipId = 0,
    this.personId = '',
    this.name = '',
    this.price = 0,
    this.policies = '',
    this.startDate,
    this.finalDate
  });
}