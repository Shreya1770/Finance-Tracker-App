class BudgetModel {
  final String id;
  final String category;
  final double limit;
  final String month;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
  });
  Map<String,dynamic> toMap(){
    return{
      'category':category,
      'limit':limit,
      'month':month,
    };
  }
  factory BudgetModel.fromMap(
    String id,
    Map<String,dynamic> map,
  ){
    return BudgetModel(
      id: id,
      category: map['category']??'',
       limit: (map['limit']??0).toDoube(),
        month: map['month']??'',
        );
  }
}