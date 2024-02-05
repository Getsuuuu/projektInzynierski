import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class EditCategory extends StatefulWidget {
  @override
  _EditCategoryState createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edytuj kategorie'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Podaj nazwę kategorii'),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _addCategory(_categoryController.text);
                    _categoryController.clear();
                    setState(() {});
                  },
                  child: Text('Dodaj kategorię'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          FutureBuilder<List<ParseObject>>(
            future: _fetchCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Brak dostępnych kategori.');
              } else {
                List<ParseObject> categories = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        title: Text(category.get<String>('Kategoria') ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _deleteCategory(category);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(String categoryName) async {
    final categoryObject = ParseObject('Kategorie')..set('Kategoria', categoryName);
    await categoryObject.save();
  }

  Future<List<ParseObject>> _fetchCategories() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Kategorie'));
    final response = await query.query();

    if (response.success && response.results != null) {
      final List<dynamic> results = response.results!;
      final List<ParseObject> categories = results.cast<ParseObject>();
      return categories;
    } else {
      throw Exception('Error załadowywania kategorii: ${response.error}');
    }
  }

  Future<void> _deleteCategory(ParseObject category) async {
    await category.delete();
  }
}
