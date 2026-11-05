import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

extension JobPostingMapping on JobPosting {
  JobPostingDto toDto() => JobPostingDto(
    id: id.value,
    employerId: employerId.value,
    employerName: employerName,
    title: title,
    description: description,
    city: city,
    category: category.name,
    shift: shift.name,
    payType: payType.name,
    hourlyRate: hourlyRate,
    requiredWorkers: requiredWorkers,
    startsAt: startsAt,
    postedAt: postedAt,
    hoursPerShift: hoursPerShift,
    status: status.name,
  );
}

extension JobPostingDtoMapping on JobPostingDto {
  JobPosting toDomain() => JobPosting(
    id: JobPostingId(id),
    employerId: EmployerId(employerId),
    employerName: employerName,
    title: title,
    description: description,
    city: city,
    category: _byName(JobCategory.values, category, 'category'),
    shift: _byName(WorkShift.values, shift, 'shift'),
    payType: _byName(PayType.values, payType, 'payType'),
    hourlyRate: hourlyRate,
    requiredWorkers: requiredWorkers,
    startsAt: startsAt,
    postedAt: postedAt,
    hoursPerShift: hoursPerShift,
    status: _byName(JobStatus.values, status, 'status'),
  );
}

T _byName<T extends Enum>(List<T> values, String name, String field) =>
    values.where((value) => value.name == name).firstOrNull ?? (throw FormatException('Unknown $field "$name"', name));
