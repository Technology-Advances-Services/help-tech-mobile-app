class Job {

  int id;
  int agendaId;
  int chatRoomId;
  String personId;
  String firstName;
  String lastName;
  int phone;
  DateTime? registrationDate;
  DateTime? workDate;
  String address;
  String description;
  double? time;
  double? laborBudget;
  double? materialBudget;
  double? amountFinal;
  String jobState;

  Job({
    this.id = 0,
    this.agendaId = 0,
    this.chatRoomId = 0,
    this.personId = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = 0,
    this.registrationDate,
    this.workDate,
    this.address = '',
    this.description = '',
    this.time = 0,
    this.laborBudget = 0,
    this.materialBudget = 0,
    this.amountFinal = 0,
    this.jobState = '',
  });
}