class DoctorProfile {
  final String id;
  final String name;
  final String specialty;
  final String avatar;
  final double rating;
  final int yearsOfExperience;
  final String hospitalName;
  final bool isAvailableNow;
  final double consultationFee;

  const DoctorProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatar,
    required this.rating,
    required this.yearsOfExperience,
    required this.hospitalName,
    required this.isAvailableNow,
    required this.consultationFee,
  });
}
