class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String jenisKelamin;
  final int batchId;
  final int trainingId;
  final String? profilePhoto;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.jenisKelamin,
    required this.batchId,
    required this.trainingId,
    this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "jenis_kelamin": jenisKelamin,
      "batch_id": batchId,
      "training_id": trainingId,
      if (profilePhoto != null) "profile_photo": profilePhoto,
    };
  }
}
