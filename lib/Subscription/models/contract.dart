class Contract {

  int id;
  int membershipId;
  String technicalId;
  String name;
  double price;
  String policies;
  DateTime? startDate;
  DateTime? finalDate;

  Contract({
    this.id = 0,
    this.membershipId = 0,
    this.technicalId = '',
    this.name = '',
    this.price = 0,
    this.policies = ''
  });
}