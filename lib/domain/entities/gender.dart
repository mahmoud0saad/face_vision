enum Gender {
  male,
  female;

  String get label => switch (this) {
        Gender.male => 'Male',
        Gender.female => 'Female',
      };
}
