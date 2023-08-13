import 'package:flutter/material.dart';
import 'package:tienda_mascotas/src/constantes/routes.dart';
import '../VariableControler/amount_product_controller.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../providers/producto_provider.dart';
import 'package:get/get.dart';
import '../providers/usuarios_provider.dart';

class TiendaPage extends StatelessWidget {
  const TiendaPage({super.key});


  
  

  @override
  Widget build(BuildContext context) {
    final productProvider = ProductoProvider();
    
    // final users = userProvider.getUsers();
    // print(users);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ) // Peso de fuente opcional
            ),
        backgroundColor: Colors.green[900],
      ),
       

      body: FutureBuilder(
        future: productProvider.getProducts(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Producto>> snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return const Center(
              child: Text('No hay conexion'),
            );
          }
          if (snapshot.hasError) {}
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListaProductos(snapshot: snapshot);
        },
      ),
    );
  }
}

class ListaProductos extends StatelessWidget {
  const ListaProductos({
    super.key,
    required this.snapshot,
  });

  final AsyncSnapshot<List<Producto>> snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        final product = snapshot.data![index];

        return ItemProduct(product: product);
      },
    );
  }
}

class ItemProduct extends StatelessWidget {
 const ItemProduct({
    super.key,
    required this.product,
  });

  final Producto product;
  

  @override
  Widget build(BuildContext context) {
    final cantidad = Get.put<AmountProductController>(AmountProductController(), tag: product.productoId.toString());
    final userProvider = UsuariosProvider();
    final carritoProvider = CarritoService();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MyRoutes.detalleProducto.name,
            arguments: product);
      },
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(product.nombre),
              ),
            ),
            Image.network(
              product.imagenes,
              height: 200,
              fit: BoxFit.fitHeight,
            ),
            ListTile(
              subtitle: Text(product.descripcion),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${product.precio}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (cantidad.currentAmount >0){
                             cantidad.currentAmount -= 1;
                          }
                         
                        },
                      ),
                      Obx(() => Text(cantidad.currentAmount.toString())),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (cantidad.currentAmount < product.stock){
                             cantidad.currentAmount += 1;
                          }
                          
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed:  () async {
                      String? uidUser =  userProvider.obtenerUIDUsuarioActivo();
                 
                      if(uidUser != null){

                        carritoProvider.agregarProductoAlCarrito(uidUser, product.productoId, cantidad.currentAmount);

                      }                      
                      
                    },
                    child: const Text('Añadir al carrito',
                    style: TextStyle(fontSize: 12),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}