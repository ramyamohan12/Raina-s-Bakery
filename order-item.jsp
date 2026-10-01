<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal" %>
<%
    // --- DB Connection ---
    String DB_URL = "jdbc:postgresql://localhost:5432/postgres";
    String DB_USER = "postgres";
    String DB_PASS = "Raina";

    Class.forName("org.postgresql.Driver");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin: Order Item</title>
<style>
    body { font-family: Arial; background:#f9f3ef; padding:20px; color:#4a2c2a; margin:0; }
    h1 { text-align:center; color:#A67B5B; }

    /* Navbar styles */
    .navbar {
        display: flex;
        justify-content: center;
        gap: 30px;
        background: #fff1e6;
        padding: 15px 0;
        position: sticky;
        top: 0;
        z-index: 1000;
        border-bottom: 2px solid #A67B5B;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
    .navbar a {
        text-decoration: none;
        color: #63392b;
        font-weight: bold;
        font-size: 1.1em;
        padding: 5px 10px;
        transition: all 0.3s ease;
    }
    .navbar a:hover {
        color: #A67B5B;
        background: #f7e4d9;
        border-radius: 5px;
        transform: scale(1.05);
    }

    /* Order section */
    .order { 
        background:#fff; 
        padding:15px 20px; 
        margin-bottom:30px; 
        border-radius:8px; 
        box-shadow: 0 2px 8px rgba(0,0,0,0.1); 
    }
    .order h2 { margin-top:0; color:#63392b; }
    table { width:100%; border-collapse: collapse; margin-top:10px; }
    th, td { padding:8px 12px; border:1px solid #ddd; text-align:left; }
    th { background:#A67B5B; color:white; }
    tr:nth-child(even) { background:#f7f3f0; }
</style>
</head>
<body>
    <nav class="navbar">
        <a href="add_recipe.jsp">Add Recipe</a>
        <a href="order-item.jsp">Orders</a>
        <a href="products.jsp"> Products in Menu</a>
    </nav>
    <h1>All Orders</h1>

<%
    try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
        // Get all orders
        String orderSQL = "SELECT * FROM Orders ORDER BY OrderDate DESC";
        try (PreparedStatement orderStmt = conn.prepareStatement(orderSQL);
             ResultSet orderRs = orderStmt.executeQuery()) {

            while(orderRs.next()) {
                int orderID = orderRs.getInt("OrderID");
                String customerName = orderRs.getString("CustomerName");
                String customerEmail = orderRs.getString("CustomerEmail");
                Timestamp orderDate = orderRs.getTimestamp("OrderDate");
                BigDecimal totalAmount = orderRs.getBigDecimal("TotalAmount");
%>
    <div class="order">
        <h2>Order #<%= orderID %> - <%= customerName %> (<%= customerEmail %>)</h2>
        <p><strong>Date:</strong> <%= orderDate %> | <strong>Total:</strong> $<%= totalAmount %></p>

        <table>
            <tr>
                <th>Product Name</th>
                <th>Quantity</th>
                <th>Unit Price</th>
                <th>Line Total</th>
            </tr>
<%
                // Get line items for this order
                String itemSQL = "SELECT oli.Quantity, oli.UnitPrice, p.Name " +
                                 "FROM OrderLineItems oli " +
                                 "JOIN Products p ON oli.ProductID = p.ProductID " +
                                 "WHERE oli.OrderID = ?";
                try (PreparedStatement itemStmt = conn.prepareStatement(itemSQL)) {
                    itemStmt.setInt(1, orderID);
                    try (ResultSet itemRs = itemStmt.executeQuery()) {
                        while(itemRs.next()) {
                            String productName = itemRs.getString("Name");
                            int qty = itemRs.getInt("Quantity");
                            BigDecimal unitPrice = itemRs.getBigDecimal("UnitPrice");
                            BigDecimal lineTotal = unitPrice.multiply(new BigDecimal(qty));
%>
            <tr>
                <td><%= productName %></td>
                <td><%= qty %></td>
                <td>$<%= unitPrice %></td>
                <td>$<%= lineTotal %></td>
            </tr>
<%
                        } // end line items
                    }
                }
%>
        </table>
    </div>
<%
            } // end orders
        }
    } catch(Exception e) {
        out.println("<p style='color:red'>Error loading orders: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
%>

</body>
</html>