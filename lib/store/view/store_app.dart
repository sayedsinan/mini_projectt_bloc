import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_project_bloc/store/bloc/store_bloc.dart';
import 'package:mini_project_bloc/store/bloc/store_event.dart';
import 'package:mini_project_bloc/store/bloc/store_state.dart';
import 'package:mini_project_bloc/store/view/cart_screen.dart';

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: BlocProvider(
        create: (context) => StoreBloc(),
        child: const _StoreAppView(title: 'My Store'),
      ),
    );
  }
}

class _StoreAppView extends StatefulWidget {
  const _StoreAppView({required this.title});

  final String title;

  @override
  State<_StoreAppView> createState() => __StoreAppViewState();
}

class __StoreAppViewState extends State<_StoreAppView> {
  void _addToCart(int cartId) {
    context.read<StoreBloc>().add(StoreProductsAddedToCart(cartId));
  }

  void _removeFromCart(int cartId) {
    context.read<StoreBloc>().add(StoreProductsRemovedFromCart(cartId));
  }

  void _viewCart() {
    Navigator.push(
      context,
      PageRouteBuilder(
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: BlocProvider.value(
                value: context.read<StoreBloc>(),
                child: child,
              ),
            );
          },
          pageBuilder: (_, __, ___) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreBloc, StoreState>(
      listenWhen: (previous, current) =>
          previous.cartIds.length != current.cartIds.length,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Text('Shopping cart updated'),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: BlocBuilder<StoreBloc, StoreState>(
            builder: (context, state) {
              if (state.productsStatus == StoreRequest.requestInProgress) {
                return const CircularProgressIndicator();
              }

              if (state.productsStatus == StoreRequest.requestFailure) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Problem loading products'),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        context.read<StoreBloc>().add(StoreProductsRequested());
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                );
              }

              if (state.productsStatus == StoreRequest.unknown) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shop_outlined,
                      size: 60,
                      color: Colors.black26,
                    ),
                    const SizedBox(height: 10),
                    const Text('No products to view'),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        context.read<StoreBloc>().add(StoreProductsRequested());
                      },
                      child: const Text('Load products'),
                    ),
                  ],
                );
              }

              // state.productsStatus == StoreRequest.success
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  final inCart = state.cartIds.contains(product.id);

                  return Card(
                    key: ValueKey(product.id),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Flexible(
                            child: Image.network(product.image),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Text(
                              product.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: inCart
                                ? () => _removeFromCart(product.id)
                                : () => _addToCart(product.id),
                            style: ButtonStyle(
                              padding: const MaterialStatePropertyAll(
                                EdgeInsets.all(18),
                              ),
                              backgroundColor: inCart
                                  ? const MaterialStatePropertyAll<Color>(
                                      Colors.black12)
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: inCart
                                  ? const [
                                      Icon(
                                        Icons.remove_shopping_cart,
                                        color: Colors.black45,
                                      ),
                                      // SizedBox(width: 10),
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(
                                          'Remove from cart',
                                          style: TextStyle(
                                            color: Colors.black45,
                                          ),
                                        ),
                                      )
                                    ]
                                  : const [
                                      Icon(Icons.add_shopping_cart),
                                      SizedBox(width: 10),
                                      Text('Add to cart')
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: FloatingActionButton(
                onPressed: _viewCart,
                tooltip: 'View Cart',
                child: const Icon(Icons.shopping_cart),
              ),
            ),
            BlocBuilder<StoreBloc, StoreState>(
              builder: (context, state) {
                if (state.cartIds.isEmpty) {
                  return Container();
                }

                return Positioned(
                  right: -4,
                  bottom: 40,
                  child: CircleAvatar(
                    backgroundColor: Colors.tealAccent,
                    radius: 12,
                    child: Text(
                      state.cartIds.length.toString(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}