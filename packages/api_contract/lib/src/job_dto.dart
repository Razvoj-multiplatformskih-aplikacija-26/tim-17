import 'json.dart';

final class JobPostingDto {
  const JobPostingDto({
    required this.id,
    required this.employerId,
    required this.employerName,
    required this.title,
    required this.description,
    required this.city,
    required this.category,
    required this.shift,
    required this.payType,
    required this.hourlyRate,
    required this.requiredWorkers,
    required this.startsAt,
    required this.postedAt,
    required this.hoursPerShift,
    required this.status,
  });

  final String id;
  final String employerId;
  final String employerName;
  final String title;
  final String description;
  final String city;
  final String category;
  final String shift;
  final String payType;
  final int hourlyRate;
  final int requiredWorkers;
  final DateTime startsAt;
  final DateTime postedAt;
  final int hoursPerShift;
  final String status;

  Map<String, Object?> toJson() => {
    'id': id,
    'employerId': employerId,
    'employerName': employerName,
    'title': title,
    'description': description,
    'city': city,
    'category': category,
    'shift': shift,
    'payType': payType,
    'hourlyRate': hourlyRate,
    'requiredWorkers': requiredWorkers,
    'startsAt': instantToJson(startsAt),
    'postedAt': instantToJson(postedAt),
    'hoursPerShift': hoursPerShift,
    'status': status,
  };

  factory JobPostingDto.fromJson(Map<String, Object?> json) => JobPostingDto(
    id: jsonString(json, 'id'),
    employerId: jsonString(json, 'employerId'),
    employerName: jsonString(json, 'employerName'),
    title: jsonString(json, 'title'),
    description: jsonString(json, 'description'),
    city: jsonString(json, 'city'),
    category: jsonString(json, 'category'),
    shift: jsonString(json, 'shift'),
    payType: jsonString(json, 'payType'),
    hourlyRate: jsonInt(json, 'hourlyRate'),
    requiredWorkers: jsonInt(json, 'requiredWorkers'),
    startsAt: jsonInstant(json, 'startsAt'),
    postedAt: jsonInstant(json, 'postedAt'),
    hoursPerShift: jsonInt(json, 'hoursPerShift'),
    status: jsonString(json, 'status'),
  );
}
