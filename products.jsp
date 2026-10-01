<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin - Manage Products</title>
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
    <h1>Admin Panel - Manage Products</h1>

    <!-- ADD NEW PRODUCT FORM -->
    <div class="add-form">
        <form action="ProductServlet" method="post">
            <input type="hidden" name="action" value="add">
            <input type="text" name="name" placeholder="Product Name" required>
            <input type="text" name="description" placeholder="Description" required>
            <input type="text" name="price" placeholder="Price" required>
            <input type="text" name="imageURL" placeholder="Image URL" required>
            <button type="submit" class="button">Add Product</button>
        </form>
    </div>

    <!-- PRODUCTS TABLE -->
    <table>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Description</th>
            <th>Price</th>
            <th>Image URL</th>
            <th>Actions</th>
        </tr>

        <%
            String dbURL = "jdbc:postgresql://localhost:5432/postgres";
            String dbUser = "postgres";
            String dbPass = "Raina";

            try {
                Class.forName("org.postgresql.Driver");
                Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM Products ORDER BY ProductID");

                while(rs.next()) {
                    int productID = rs.getInt("ProductID");
                    String name = rs.getString("Name");
                    String description = rs.getString("Description");
                    java.math.BigDecimal price = rs.getBigDecimal("Price");
                    String imageURL = rs.getString("ImageURL");
        %>
        <tr>
            <td><%= productID %></td>
            <td><%= name %></td>
            <td><%= description %></td>
            <td>$<%= price %></td>
            <td><%= imageURL %></td>
            <td>
                <!-- EDIT FORM -->
                <form action="ProductServlet" method="post">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="productID" value="<%= productID %>">
                    <input type="text" name="name" value="<%= name %>" required>
                    <input type="text" name="description" value="<%= description %>" required>
                    <input type="text" name="price" value="<%= price %>" required>
                    <input type="text" name="imageURL" value="<%= imageURL %>" required>
                    <button type="submit" class="button">Update</button>
                </form>

                <!-- DELETE FORM -->
                <form action="ProductServlet" method="post" onsubmit="return confirm('Are you sure?');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="productID" value="<%= productID %>">
                    <button type="submit" class="button">Delete</button>
                </form>
            </td>
        </tr>
        <%
                }
                rs.close();
                stmt.close();
                conn.close();
            } catch(Exception e) {
                out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
            }
        %>
    </table>

    <p style="text-align:center; margin-top:20px;">
        <a href="Store.jsp" class="button">View Store</a>
    </p>
</body>
</html>