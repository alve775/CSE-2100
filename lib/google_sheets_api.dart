import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
    {
    "type": "service_account",
    "project_id": "flutter-project-390201",
    "private_key_id": "efae70d1a9363f0d29db1139a7b07d5877f78121",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCkEuvpnd7xildC\nvuB+51KYUA7mXbLStSTTUSG49fm2DGuLNJs/i6wtvW3NanrsRHuSJHurgqawIQBl\nDzsvnMQg2ki8tixwarf+ypWqdfMnOoZUjM2/JKVH8R8yvEGaiBfkZDVU6VMLGJsy\neoDEEdMozs6Rg3+dsBY0dg4I5jNEdVesg88ber4iTwxKew+/jKmOH1o40hZ7qfSl\nGr9JCfHI8EO8zEWOmSKb5Su2rqZJyaZF4NmcScOwhXIydiA2d9k7vHrmIjwTlL9U\nBaN7cLOlVirPSO2es+5Eed9rQV7S1W0jcp4o0hUzLa+uYP7IgHEEFuJhZnIDh7QD\nFAOBCdzjAgMBAAECggEAChd72TezocmvilRxPHz/8IxkDjlPKXSo2jKQT28Zt9/V\nsY8/yU3O/lU7broQ631e2GNUE/2KQSUWgCDKtCgBTEAA31KZMyTtQke1ovF0TkJk\nRskOUqZvYBhtodJAer/KMGsVeK6NRA50ZUtxph2ujkECJaMf81QEWZ+1R0jZeGli\nCyoJBqsQSFEQVngZElmlDQEeiTTwrXzHwk3UE8WaLtzzReEYcjIfFkrxl7WLtW4T\nFXuF6Ohe5AefiPgqoxP2jXeaEU8AO4VYhgRhIZaE9D80Rf0h/t2ixN11kIqN4TFv\nUPTOx6L/HBcBKQ8kBavHn/p/2xq7XpAmz4D0j+wjSQKBgQDU+trmIGUbtMFt/O45\nBgsCbdctqpg6wh9KK7JsdUvGLw8pp/Gi21iYPymsONd9C5Ny/Y11NH4W100iPh5r\nu5jOwf9V2BOzjtUrhV0bW0lH5xv/46ra3dNVQcpPSkC79s6uLQn57OctOq9v5UUC\nfMsp1eqpW2VzE+FCWkR/sgMqlQKBgQDFNyXx5AaF00VODwfh7+Mco0mp9nnBJr77\nD3Btpx4BqAh31G8IW5NF8CHQ/n+e7K5zlJ+j4srcxX/6DeRF1XVzbTfO0SX/LnfP\ni4lnS0xI1CCavtGUPva4u4rkRth49dqjoRwhoj4uVPQKTtZwdqboD54aT5J2T+Ua\nOyXBGfwDlwKBgQC9KZEClAM5eHHUnrF3NEbTAXv8s2hBx+jCl80BR6zleSaeeOvF\nGcy2bGM288Vw6rcrisf5MYZMAy4fG80pIpW2DdgbBq9464OqA+mOQqXzlvDnde5q\nNltdffGSOwED8VHgoWAa+q7ZHSZ0281PSEeqALVLdkHE1ANeS45LXHAzgQKBgGyi\nCCDKPl2RFuf8l5b5EN1BhN4+iqq+sQySYJfGKl03NhLrzY2JBALOV5JL3fio3x+D\nirw3vQ8HK4uOA2QERQIj803VH10FN7H3ZuSjMY4caylSWxeR502y4LsF21Al/R2N\nLXXJbP8QhKz46F5ivWWu1KQhmMfbEpP0aMOJkKxZAoGBAI8ADkUUoD2TAKagHQSS\nIzEhVJHJkS8HPMHhe29eNzhdJ7s5TS/DBTKRYsxNg9AJ30eFzV4CQSoVN1+A6y25\n7IB02bW3PDA72PDMzNfh+KXZTY11yyNZmTAUiH7rwtTd2OLLDuOup8W5qtJMOXHZ\nyyjt+wcFVaNuq64HQZgVitVy\n-----END PRIVATE KEY-----\n",
    "client_email": "flutter-project@flutter-project-390201.iam.gserviceaccount.com",
    "client_id": "100410981029205349611",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-project%40flutter-project-390201.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  }
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '15s1xhm4mx0_zKIEm6CptCWsPX6dvv_7JXtRdN5Vu4xI';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;
  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
        .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
      await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
      await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
      await _worksheet!.values.value(column: 3, row: i + 1);
//date
      final String transactionDate =
          await _worksheet!.values.value(column: 4, row: i+1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
          transactionDate,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome, String date) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
      date,
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
      date,
    ]);
  }

  // CALCULATE THE TOTAL INCOME
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
