enum EyeState {
  open,
  closed,
  unknown;

  String get label => switch (this) {
        EyeState.open => 'Open',
        EyeState.closed => 'Closed',
        EyeState.unknown => '?',
      };

  static EyeState fromLabel(String value) => switch (value.toLowerCase()) {
        'open' => EyeState.open,
        'closed' => EyeState.closed,
        _ => EyeState.unknown,
      };
}
