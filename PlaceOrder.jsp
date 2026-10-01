<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal" %>
<%
    // --- DB Connection ---
    String DB_URL = "jdbc:postgresql://localhost:5432/postgres";
    String DB_USER = "postgres";
    String DB_PASS = "Raina";

    Class.forName("org.postgresql.Driver");

    // --- Session Cart ---
    List<Map<String,Object>> cart = (List<Map<String,Object>>) session.getAttribute("cart");
    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute("cart", cart);
    }

    // --- Add Product from Store ---
    String productIdParam = request.getParameter("productID");
    String quantityParam = request.getParameter("quantity");
    if (productIdParam != null && quantityParam != null) {
        int productID = Integer.parseInt(productIdParam);
        int quantity = Integer.parseInt(quantityParam);

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            String sql = "SELECT Name, Price, ImageURL FROM Products WHERE ProductID = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, productID);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        Map<String,Object> item = new HashMap<>();
                        item.put("productID", productID);
                        item.put("productName", rs.getString("Name"));
                        item.put("price", rs.getBigDecimal("Price"));
                        item.put("imageURL", rs.getString("ImageURL"));
                        item.put("quantity", quantity);
                        cart.add(item);
                    }
                }
            }
        } catch (Exception e) {
            out.println("<p style='color:red'>Error adding product: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }

    // --- Remove item ---
    String deleteIndexStr = request.getParameter("deleteIndex");
    if (deleteIndexStr != null) {
        try {
            int deleteIndex = Integer.parseInt(deleteIndexStr);
            if (deleteIndex >= 0 && deleteIndex < cart.size()) {
                cart.remove(deleteIndex);
            }
        } catch (NumberFormatException e) {}
    }

    // --- Checkout Submission ---
    String customerName = request.getParameter("customerName");
    String customerEmail = request.getParameter("customerEmail");
    boolean orderPlaced = false;
    int newOrderID = 0;

    if (customerName != null && customerEmail != null && !cart.isEmpty()) {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            conn.setAutoCommit(false);

            // Calculate total
            BigDecimal totalAmount = BigDecimal.ZERO;
            for (Map<String,Object> item : cart) {
                Object priceObj = item.get("price");
                BigDecimal price = (priceObj instanceof BigDecimal) ? (BigDecimal) priceObj : new BigDecimal(priceObj.toString());
                Object qtyObj = item.get("quantity");
                int qty = (qtyObj instanceof Integer) ? (Integer) qtyObj : Integer.parseInt(qtyObj.toString());
                totalAmount = totalAmount.add(price.multiply(new BigDecimal(qty)));
            }

            // Insert order
            String orderSQL = "INSERT INTO Orders (CustomerName, CustomerEmail, TotalAmount) VALUES (?, ?, ?)";
            try (PreparedStatement orderStmt = conn.prepareStatement(orderSQL, Statement.RETURN_GENERATED_KEYS)) {
                orderStmt.setString(1, customerName);
                orderStmt.setString(2, customerEmail);
                orderStmt.setBigDecimal(3, totalAmount);
                orderStmt.executeUpdate();
                try (ResultSet rs = orderStmt.getGeneratedKeys()) {
                    if (rs.next()) newOrderID = rs.getInt(1);
                }
            }

            // Insert line items
            String itemSQL = "INSERT INTO OrderLineItems (OrderID, ProductID, Quantity, UnitPrice) VALUES (?, ?, ?, ?)";
            try (PreparedStatement itemStmt = conn.prepareStatement(itemSQL)) {
                for (Map<String,Object> item : cart) {
                    BigDecimal price = (BigDecimal) item.get("price");
                    int qty = (Integer) item.get("quantity");
                    int productID = (Integer) item.get("productID");

                    itemStmt.setInt(1, newOrderID);
                    itemStmt.setInt(2, productID);
                    itemStmt.setInt(3, qty);
                    itemStmt.setBigDecimal(4, price);
                    itemStmt.addBatch();
                }
                itemStmt.executeBatch();
            }

            conn.commit();
            session.removeAttribute("cart");
            orderPlaced = true;
        } catch (Exception e) {
            if (conn != null) conn.rollback();
            out.println("<p style='color:red'>Error placing order: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (conn != null) conn.close();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Shopping Cart & Checkout</title>
    <style>
        body { font-family: Arial; background:#FFF1E6; padding:20px; }
        .cart { background:#EDDCD2; padding:20px; border-radius:8px; }
        .cart-item { display:flex; justify-content:space-between; padding:10px; margin-bottom:10px; background:#f8e1db; border-radius:5px; }
        .delete-button, .checkout-button { padding:5px 10px; border:none; border-radius:5px; cursor:pointer; }
        .delete-button { background:#faa3a0; color:white; }
        .checkout-button { background:#fcb1b1; color:white; margin-top:10px; display:inline-block; }
        .total-price { font-weight:bold; font-size:18px; margin-top:10px; color:#eba68e; }
    </style>
</head>
<body>
    <h1>Shopping Cart</h1>

    <% if (orderPlaced) { %>
        <p style="color:green; font-weight:bold;">
            Order placed successfully! 
            <a href="order-details.jsp?orderID=<%= newOrderID %>">View Order</a>
        </p>
        <!-- Continue shopping button after order placed -->
        <form action="Store.jsp" method="get" style="margin-top:15px;">
            <button type="submit" class="checkout-button" style="background:#A67B5B;">Continue Shopping</button>
        </form>
    <% } else { %>
        <div class="cart">
            <h2>Items in Cart</h2>
            <%
                if (cart.isEmpty()) {
            %>
                <p>Your cart is empty.</p>
                <!-- Button to return to store when cart is empty -->
                <form action="Store.jsp" method="get" style="margin-top:15px;">
                    <button type="submit" class="checkout-button" style="background:#A67B5B;">Continue Shopping</button>
                </form>
            <%
                } else {
                    BigDecimal totalPrice = BigDecimal.ZERO;
                    for (int i = 0; i < cart.size(); i++) {
                        Object obj = cart.get(i);
                        if (!(obj instanceof Map)) continue;
                        Map<String,Object> item = (Map<String,Object>) obj;

                        BigDecimal price = (BigDecimal) item.get("price");
                        int qty = (Integer) item.get("quantity");
                        BigDecimal subtotal = price.multiply(new BigDecimal(qty));
                        totalPrice = totalPrice.add(subtotal);
            %>
                        <div class="cart-item">
                            <span><%= item.get("productName") %> x <%= qty %> - $<%= subtotal %></span>
                            <form method="post">
                                <input type="hidden" name="deleteIndex" value="<%= i %>">
                                <button type="submit" class="delete-button">Delete</button>
                            </form>
                        </div>
            <%
                    } // end for
            %>
                    <p class="total-price">Total: $<%= totalPrice %></p>
                    <h3>Checkout</h3>
                    <form method="post">
                        <label>Name: <input type="text" name="customerName" required></label><br>
                        <label>Email: <input type="email" name="customerEmail" required></label><br>
                        <button type="submit" class="checkout-button">Place Order</button>
                    </form>

                    <!-- Continue shopping button below cart -->
                    <form action="Store.jsp" method="get" style="margin-top:15px;">
                        <button type="submit" class="checkout-button" style="background:#A67B5B;">Continue Shopping</button>
                    </form>
            <%
                }
            %>
        </div>
    <% } %>
</body>