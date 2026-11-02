import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

export 'package:domain/domain.dart' show JobCategory, JobFilters, JobSort, PayType, WorkShift;

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

extension WorkShiftLabel on WorkShift {
  String get label => switch (this) {
    WorkShift.morning => 'Prva smena',
    WorkShift.afternoon => 'Druga smena',
    WorkShift.night => 'Noćna smena',
    WorkShift.weekend => 'Vikend',
    WorkShift.flexible => 'Fleksibilno',
  };

  IconData get icon => switch (this) {
    WorkShift.morning => Icons.wb_sunny_outlined,
    WorkShift.afternoon => Icons.wb_twilight_rounded,
    WorkShift.night => Icons.nightlight_outlined,
    WorkShift.weekend => Icons.weekend_outlined,
    WorkShift.flexible => Icons.schedule_rounded,
  };
}

extension PayTypeLabel on PayType {
  String get label => switch (this) {
    PayType.daily => 'Dnevnica',
    PayType.hourly => 'Po satu',
    PayType.perTask => 'Po zadatku',
  };

  IconData get icon => switch (this) {
    PayType.daily => Icons.payments_outlined,
    PayType.hourly => Icons.timer_outlined,
    PayType.perTask => Icons.task_alt_rounded,
  };
}

extension JobCategoryLabel on JobCategory {
  String get label => switch (this) {
    JobCategory.hospitality => 'Ugostiteljstvo',
    JobCategory.retail => 'Prodaja',
    JobCategory.warehouse => 'Magacin',
    JobCategory.promotion => 'Promocije',
    JobCategory.office => 'Administracija',
    JobCategory.delivery => 'Dostava',
    JobCategory.events => 'Događaji',
    JobCategory.it => 'IT',
  };

  IconData get icon => switch (this) {
    JobCategory.hospitality => Icons.local_cafe_outlined,
    JobCategory.retail => Icons.storefront_outlined,
    JobCategory.warehouse => Icons.inventory_2_outlined,
    JobCategory.promotion => Icons.campaign_outlined,
    JobCategory.office => Icons.desk_outlined,
    JobCategory.delivery => Icons.delivery_dining_outlined,
    JobCategory.events => Icons.celebration_outlined,
    JobCategory.it => Icons.code_rounded,
  };
}

extension JobSortLabel on JobSort {
  String get label => switch (this) {
    JobSort.newest => 'Najnovije',
    JobSort.payHighest => 'Najveća satnica',
    JobSort.payLowest => 'Najmanja satnica',
    JobSort.dailyHighest => 'Najveća dnevnica',
    JobSort.hoursShortest => 'Najkraće radno vreme',
    JobSort.hoursLongest => 'Najduže radno vreme',
    JobSort.startSoonest => 'Najskoriji početak',
  };

  IconData get icon => switch (this) {
    JobSort.newest => Icons.fiber_new_outlined,
    JobSort.payHighest => Icons.trending_up_rounded,
    JobSort.payLowest => Icons.trending_down_rounded,
    JobSort.dailyHighest => Icons.payments_outlined,
    JobSort.hoursShortest => Icons.hourglass_bottom_rounded,
    JobSort.hoursLongest => Icons.hourglass_top_rounded,
    JobSort.startSoonest => Icons.event_available_outlined,
  };
}
