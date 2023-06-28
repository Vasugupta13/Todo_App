import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo_app/screen/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.amberAccent,
        title: const Center(
          child: Text(
            'Todo List',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.transparent)],
                fontSize: 25),
          ),
        ),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,color: Colors.black,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text('No Todo Item',style: Theme.of(context).textTheme.headlineMedium,),
            ),
            child: ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;
                  return Card(
                    color: Colors.amber[50],
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.shade400,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),textColor: Colors.black,
                      title: Text(item['title'],style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize:18,
                      ),),
                      subtitle: Text(item['description'], style: const TextStyle(
                        color: Colors.black45
                      ),),
                      trailing:PopupMenuButton(
                        onSelected: (value){
                          if (value== 'edit'){
                            //open edit page
                            navigateToEditPage(item);
                          }else if (value == 'delete'){
                            //open delete page
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context){
                          return[
                            const PopupMenuItem(value: 'edit',child: Text('Edit'),),
                            const PopupMenuItem(value: 'delete',child: Text('Delete'),),
                          ];
                        },
                      ) ,
                    ),
                  );
                }),
          ),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.black,),),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text(
          'Add Todo',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.amberAccent,
        elevation: 1,
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddPage(todo: item),
    );
   await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage()async {
    final route = MaterialPageRoute(
      builder: (context) => const AddPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();

  }

  Future<void>deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if(response.statusCode==200){
      //remove the item
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      showSuccessMessage('Deleted Successfully');
    }else{
      //Show error
      showErrorMessage('Unable to Delete');
    }
  }

  Future<void> fetchTodo() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(
      uri,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });

    } else {
      //error
    }
    setState(() {
      isLoading = false;
    });
  }
  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
      backgroundColor: Colors.green[300],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
      backgroundColor: Colors.red[400],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
