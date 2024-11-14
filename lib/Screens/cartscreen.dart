import 'package:e_commerce/Models/cart.dart';
import 'package:e_commerce/Provider/provider.dart';
import 'package:e_commerce/Screens/payment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get totalPrice => context.read<CartProvider>().items.fold(
        0,
        (sum, item) =>
            sum + (double.parse(item.product.price.substring(1)) * item.quantity),
      );

  void _increaseQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      setState(() {
        item.quantity--;
      });
    }
  }

  void _removeItem(CartItem item) {
    setState(() {
      context.read<CartProvider>().removeItem(item);
    });
  }

  // For dropdown selection
  String? _selectedDeliveryOption = "Standard Shipping"; // Example option
  String? _selectedDiscountCode = "No Discount"; // Example option
  bool _isDeliveryOptionVisible = false; // To toggle the visibility of the delivery options
  double _deliveryCost = 0.0; // To store the cost of the selected delivery option

  // Calculate the updated total price after considering discounts and delivery cost
  double get updatedTotalPrice {
    double discount = 0.0;
    if (_selectedDiscountCode == "10% Off") {
      discount = 0.10 * totalPrice;
    } else if (_selectedDiscountCode == "20% Off") {
      discount = 0.20 * totalPrice;
    } else if (_selectedDiscountCode == "Free Shipping") {
      _deliveryCost = 0.0;
    }
    return totalPrice + _deliveryCost - discount; // Adjusting for discount
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkouts", style: TextStyle(fontFamily: 'poppinsbold', fontSize: 18)),
         actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const CartScreen()));
            },
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    if (cartProvider.items.isNotEmpty) {
                      return Positioned(
                        right: -3,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // constraints: const BoxConstraints(
                          //   minWidth: 16,
                          //   minHeight: 16,
                          // ),
                          child: Text(
                            '${cartProvider.items.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
         ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Delivery to", style: TextStyle(fontFamily: 'poppinssemibold', fontSize: 12)),
                Text("Karachi, Sindh, Pakistan", style: TextStyle(fontFamily: 'poppinssemibold', fontSize: 12)),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            // Cart Items List
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final cartItem = cartProvider.items[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(cartItem.product.imageurl,
                          width: size.width * 0.1, height: size.height * 0.2),
                      title: Text(cartItem.product.name, overflow: TextOverflow.ellipsis,
                        maxLines: 1, style: const TextStyle(fontFamily: 'poppinssemibold', fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cartItem.product.price, style: const TextStyle(fontFamily: 'poppinslight', fontSize: 12)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _increaseQuantity(cartItem),
                          ),
                          Text(cartItem.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _decreaseQuantity(cartItem),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeItem(cartItem),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Order Summary
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Order Summary", style: TextStyle(fontFamily: 'poppinsmedium')),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isDeliveryOptionVisible = !_isDeliveryOptionVisible;
                          });
                        },
                        icon: const Icon(Icons.arrow_drop_up_outlined, color: Colors.black),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total price (${cartProvider.items.length} items)", style: const TextStyle(fontFamily: 'poppinssemibold', fontSize: 12)),
                      Text("\$${updatedTotalPrice.toStringAsFixed(2)}", style: const TextStyle(fontFamily: 'poppinssemibold', fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Delivery Option (${_selectedDeliveryOption})", style: const TextStyle(fontFamily: 'poppinssemibold', fontSize: 12)),
                      Text("\$${_deliveryCost.toStringAsFixed(2)}", style: const TextStyle(fontFamily: 'poppinssemibold', fontSize: 12)),
                    ],
                  ),
                   SizedBox(height: size.height*0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontFamily: 'poppinssemibold', fontSize: 12)),
                      Text("\$${(updatedTotalPrice + _deliveryCost).toStringAsFixed(2)}", style: const TextStyle(fontFamily: 'poppinssemibold', fontSize: 12)),
                    ],
                  ),
                   SizedBox(height:size.height*0.01),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: Colors.purple
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(totalPrice: updatedTotalPrice + _deliveryCost),
                        ),
                      );
                    },
                    child: const Text("Select payment method", style: TextStyle(fontFamily: 'poppinssemibold', fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ),
            // Delivery Options Popup
            _isDeliveryOptionVisible
                ? Container(
                    height: size.height * 0.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16.0)),
                      border: Border.all(width: 1)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 20.0, bottom: 20),
                                child: Text("Select The Delivery", style: TextStyle(fontFamily: 'poppinssemibold', fontSize: 16)),
                              ),
                            ],
                          ),
                          ListTile(
                            title: const Text("Standard", style: TextStyle(fontFamily: 'poppinsmedium')),
                            trailing: const Text("\$8.00", style: TextStyle(fontFamily: 'poppinssemibold')),
                            subtitle: const Text("1 - 3 days delivery", style: TextStyle(fontFamily: 'poppinssemibold')),
                            onTap: () {
                              setState(() {
                                _selectedDeliveryOption = "Standard Shipping";
                                _deliveryCost = 8.00;
                              });
                            },
                            tileColor: _selectedDeliveryOption == "Standard Shipping" ? Colors.green[100] : null,
                          ),
                          ListTile(
                            title: const Text("Express", style: TextStyle(fontFamily: 'poppinsmedium')),
                            trailing: const Text("\$15.00", style: TextStyle(fontFamily: 'poppinssemibold')),
                            subtitle: const Text("1 - 2 days delivery", style: TextStyle(fontFamily: 'poppinssemibold')),
                            onTap: () {
                              setState(() {
                                _selectedDeliveryOption = "Express Shipping";
                                _deliveryCost = 15.0;
                              });
                            },
                            tileColor: _selectedDeliveryOption == "Express Shipping" ? Colors.green[100] : null,
                          ),
                          ListTile(
                            title: const Text("Same Day Delivery", style: TextStyle(fontFamily: 'poppinsmedium')),
                            trailing: const Text("\$20.00", style: TextStyle(fontFamily: 'poppinssemibold')),
                            onTap: () {
                              setState(() {
                                _selectedDeliveryOption = "Same Day Delivery";
                                _deliveryCost = 20.0;
                              });
                            },
                            tileColor: _selectedDeliveryOption == "Same Day Delivery" ? Colors.green[100] : null,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
