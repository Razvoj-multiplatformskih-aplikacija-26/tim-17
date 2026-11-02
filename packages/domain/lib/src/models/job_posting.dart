import 'package:meta/meta.dart';

import '../identifiers.dart';

enum JobStatus { open, closed }

enum WorkShift { morning, afternoon, night, weekend, flexible }

enum PayType { daily, hourly, perTask }

enum JobCategory { hospitality, retail, warehouse, promotion, office, delivery, events, it }

@immutable
final class JobPosting {
  const JobPosting({
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
    this.hoursPerShift = 8,
    this.status = JobStatus.open,
  });

  final JobPostingId id;
  final EmployerId employerId;
  final String employerName;
  final String title;
  final String description;
  final String city;
  final JobCategory category;
  final WorkShift shift;
  final PayType payType;
  final double hourlyRate;
  final int requiredWorkers;
  final DateTime startsAt;
  final DateTime postedAt;
  final int hoursPerShift;
  final JobStatus status;

  bool get isOpen => status == JobStatus.open;

  double get dailyPay => hourlyRate * hoursPerShift;

  JobPosting copyWith({JobStatus? status, int? requiredWorkers}) {
    return JobPosting(
      id: id,
      employerId: employerId,
      employerName: employerName,
      title: title,
      description: description,
      city: city,
      category: category,
      shift: shift,
      payType: payType,
      hourlyRate: hourlyRate,
      requiredWorkers: requiredWorkers ?? this.requiredWorkers,
      startsAt: startsAt,
      postedAt: postedAt,
      hoursPerShift: hoursPerShift,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is JobPosting &&
      other.id == id &&
      other.employerId == employerId &&
      other.employerName == employerName &&
      other.title == title &&
      other.description == description &&
      other.city == city &&
      other.category == category &&
      other.shift == shift &&
      other.payType == payType &&
      other.hourlyRate == hourlyRate &&
      other.requiredWorkers == requiredWorkers &&
      other.startsAt == startsAt &&
      other.postedAt == postedAt &&
      other.hoursPerShift == hoursPerShift &&
      other.status == status;

  @override
  int get hashCode => Object.hash(
    id,
    employerId,
    employerName,
    title,
    description,
    city,
    category,
    shift,
    payType,
    hourlyRate,
    requiredWorkers,
    startsAt,
    postedAt,
    hoursPerShift,
    status,
  );

  @override
  String toString() => 'JobPosting($id, $title, $city, $status)';
}
