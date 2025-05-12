class Complaint {

  int typeComplaintId;
  int jobId;
  String sender;
  DateTime? registrationDate;
  String description;

  Complaint({
    this.typeComplaintId = 0,
    this.jobId = 0,
    this.sender = '',
    this.registrationDate,
    this.description = ''
  });
}