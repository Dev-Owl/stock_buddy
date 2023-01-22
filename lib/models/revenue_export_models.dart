class RevenueExport {
  final String accountNumber;
  final DateTime exportDate;
  final List<RevenueItem> items;

  RevenueExport(this.accountNumber, this.exportDate, this.items);
}

class RevenueItem {
  final DateTime bookingDate;
  final String client;
  final String bookingText;
  final String referenceText; //aka Verwendungszweck
  final double saldo;
  final double amount;
  final String currency;

  RevenueItem(this.bookingDate, this.client, this.bookingText,
      this.referenceText, this.saldo, this.amount, this.currency);
}
