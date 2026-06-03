import 'package:livestock/features/milk_sales/domain/entities/milk_sale.dart';
import 'package:livestock/features/milk_sales/domain/repositories/milk_sale_repository.dart';

/// Use case for recording a milk sale
class RecordMilkSale {
  final MilkSaleRepository _repository;

  RecordMilkSale(this._repository);

  /// Execute the use case
  Future<MilkSale> call(MilkSale sale) async {
    // Validate the sale
    if (!sale.isValid) {
      throw ArgumentError('Invalid milk sale: quantity and price must be > 0');
    }

    // Record the sale
    return await _repository.recordSale(sale);
  }
}
