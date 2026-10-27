import 'package:flutter/material.dart';

// Izbor filtera na ekranu poslova. Kad stignu oglasi, smena, način isplate i
// kategorija prelaze u domenski paket, a stanje filtera u Bloc.

const serbianCities = [
  'Beograd',
  'Novi Sad',
  'Niš',
  'Kragujevac',
  'Subotica',
  'Zrenjanin',
  'Pančevo',
  'Čačak',
  'Kraljevo',
  'Novi Pazar',
  'Leskovac',
  'Smederevo',
];

enum WorkShift {
  morning('Prva smena', Icons.wb_sunny_outlined),
  afternoon('Druga smena', Icons.wb_twilight_rounded),
  night('Noćna smena', Icons.nightlight_outlined),
  weekend('Vikend', Icons.weekend_outlined),
  flexible('Fleksibilno', Icons.schedule_rounded);

  const WorkShift(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum PayType {
  daily('Dnevnica', Icons.payments_outlined),
  hourly('Po satu', Icons.timer_outlined),
  perTask('Po zadatku', Icons.task_alt_rounded);

  const PayType(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum JobCategory {
  hospitality('Ugostiteljstvo', Icons.local_cafe_outlined),
  retail('Prodaja', Icons.storefront_outlined),
  warehouse('Magacin', Icons.inventory_2_outlined),
  promotion('Promocije', Icons.campaign_outlined),
  office('Administracija', Icons.desk_outlined),
  delivery('Dostava', Icons.delivery_dining_outlined),
  events('Događaji', Icons.celebration_outlined),
  it('IT', Icons.code_rounded);

  const JobCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum JobSort {
  newest('Najnovije', Icons.fiber_new_outlined),
  payHighest('Najveća satnica', Icons.trending_up_rounded),
  payLowest('Najmanja satnica', Icons.trending_down_rounded),
  dailyHighest('Najveća dnevnica', Icons.payments_outlined),
  hoursShortest('Najkraće radno vreme', Icons.hourglass_bottom_rounded),
  hoursLongest('Najduže radno vreme', Icons.hourglass_top_rounded),
  startSoonest('Najskoriji početak', Icons.event_available_outlined);

  const JobSort(this.label, this.icon);

  final String label;
  final IconData icon;
}

@immutable
final class JobFilters {
  const JobFilters({
    this.query = '',
    this.cities = const {},
    this.shifts = const {},
    this.payTypes = const {},
    this.categories = const {},
    this.minHourlyPay = 0,
    this.sort = JobSort.newest,
  });

  static const maxHourlyPay = 1500;
  static const hourlyPayStep = 50;

  final String query;
  final Set<String> cities;
  final Set<WorkShift> shifts;
  final Set<PayType> payTypes;
  final Set<JobCategory> categories;
  final int minHourlyPay;
  final JobSort sort;

  int get activeCount =>
      cities.length + shifts.length + payTypes.length + categories.length + (minHourlyPay > 0 ? 1 : 0);

  bool get hasActiveFilters => activeCount > 0;

  bool get isNarrowed => hasActiveFilters || query.trim().isNotEmpty;

  JobFilters copyWith({
    String? query,
    Set<String>? cities,
    Set<WorkShift>? shifts,
    Set<PayType>? payTypes,
    Set<JobCategory>? categories,
    int? minHourlyPay,
    JobSort? sort,
  }) {
    return JobFilters(
      query: query ?? this.query,
      cities: cities ?? this.cities,
      shifts: shifts ?? this.shifts,
      payTypes: payTypes ?? this.payTypes,
      categories: categories ?? this.categories,
      minHourlyPay: minHourlyPay ?? this.minHourlyPay,
      sort: sort ?? this.sort,
    );
  }

  JobFilters cleared() => JobFilters(query: query, sort: sort);
}
