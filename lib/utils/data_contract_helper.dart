Map<String, dynamic> removeDataContracFromMap(Map<String, dynamic> data) {
  const dataContractFields = ['created_at', 'id', 'owner_id'];
  data.removeWhere((key, value) => dataContractFields.contains(key));
  return data;
}
