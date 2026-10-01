<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal" %>
<%
    // DB info
    String DB_URL = "jdbc:postgresql://localhost:5432/postgres";
    String DB_USER = "postgres";
    String DB_PASS = "Raina";

    Class.forName("org.postgresql.Driver");
    Connection conn = null;
    PreparedStatement orderStmt = null;
    PreparedStatement itemStmt = null;
    ResultSet rs = null;

    try {
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        conn.setAutoCommit(false); // transactional insert

        // Get cart from session
        List<Map<String, Object>> cart = (List<Map<String,Object>>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            out.println("<p>Your cart is empty.</p>");
            return;
        }

        // Get customer info from form (simple example)
        String customerName = request.getParameter("customerName");
        String customerEmail = request.getParameter("customerEmail");
        if (customerName == null || customerEmail == null) {
            out.println("<p>Please provide name and email.</p>");
            return;
        }

        // Calculate total
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (Map<String,Object> item : cart) {
            Object priceObj = item.get("price");
            BigDecimal price = (priceObj instanceof BigDecimal) ? (BigDecimal) priceObj : new BigDecimal(priceObj.toString());
            Object qtyObj = item.get("quantity");
            int qty = (qtyObj instanceof Integer) ? (Integer) qtyObj : Integer.parseInt(qtyObj.toString());
            totalAmount = totalAmount.add(price.multiply(new BigDecimal(qty)));
        }

        // Insert into Orders
        String orderSQL = "INSERT INTO Orders (CustomerName, CustomerEmail, TotalAmount) VALUES (?, ?, ?) RETURNING OrderID";
        orderStmt = conn.prepareStatement(orderSQL);
        orderStmt.setString(1, customerName);
        orderStmt.setString(2, customerEmail);
        orderStmt.setBigDecimal(3, totalAmount);
        rs = orderStmt.executeQuery();

        int orderID = 0;
        if (rs.next()) {
            orderID = rs.getInt("OrderID");
        }

        // Insert line items
        String itemSQL = "INSERT INTO OrderLineItems (OrderID, ProductID, Quantity, UnitPrice) VALUES (?, ?, ?, ?)";
        itemStmt = conn.prepareStatement(itemSQL);
        for (Map<String,Object> item : cart) {
            Object priceObj = item.get("price");
            BigDecimal price = (priceObj instanceof BigDecimal) ? (BigDecimal) priceObj : new BigDecimal(priceObj.toString());
            Object qtyObj = item.get("quantity");
            int qty = (qtyObj instanceof Integer) ? (Integer) qtyObj : Integer.parseInt(qtyObj.toString());
            int productID = (Integer) item.get("productID");

            itemStmt.setInt(1, orderID);
            itemStmt.setInt(2, productID);
            itemStmt.setInt(3, qty);
            itemStmt.setBigDecimal(4, price);
            itemStmt.addBatch();
        }
        itemStmt.executeBatch();

        conn.commit();

        // Clear cart
        session.removeAttribute("cart");

        // Redirect to admin order details
        response.sendRedirect("order-details.jsp?orderID=" + orderID);

    } catch (Exception e) {
        if (conn != null) conn.rollback();
        out.println("<p style='color:red'>Error placing order: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (orderStmt != null) orderStmt.close();
        if (itemStmt != null) itemStmt.close();
        if (conn != null) conn.close();
    }
%>