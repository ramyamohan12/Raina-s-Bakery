<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Raina's Desserts - Store</title>
    <style>
        body { background-color: #fffaf7; margin: 0; padding: 0; font-family: Georgia, serif; color: #63392b; }
        .navbar { display: flex; padding: 20px 0; position: sticky; top: 0; gap: 40px; z-index: 1000; justify-content: center; border-bottom: 1px dashed #A5A58D; background-color: #fffaf7; }
        .nav-links a { color:#A5A58D; text-decoration: none; font-family: 'Brush Script MT'; font-size: 1.6em; font-weight: bold; }
        .nav-links a:hover { color: #fedfb0; transform: scale(1.1) rotate(-2deg); }
        .container { max-width: 1100px; margin: 0 auto; padding: 20px; }
        h1 { color: #A5A58D; font-family: 'Brush Script MT', cursive; font-size: 3.5em; text-align: center; margin-top: 40px; }
        .intro-text { text-align: center; color: #8d6e63; font-size: 1.1em; max-width: 800px; margin: 0 auto 40px auto; line-height: 1.6; }
        .product { max-width: 1000px; margin: 20px auto; padding: 20px; background: #fff; border-radius: 10px; box-shadow: 2px 2px 10px rgba(0,0,0,0.05); border: 1px solid #efebe9; }
        .product-container { display: flex; align-items: center; gap: 30px; }
        .product-image { width: 250px; height: auto; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        .product-details { flex: 1; text-align: left; }
        .product-details h2 { color: #63392b; margin-top: 0; }
        .product-details h4 { color: #8d6e63; font-weight: normal; margin-bottom: 15px; }
        .product-details p { font-size: 1.2em; font-weight: bold; color: #63392b; }
        .button { background-color: #A67B5B; color: #fff; padding: 10px 25px; font-size: 16px; border: none; border-radius: 25px; cursor: pointer; transition: all 0.3s ease; font-family: Georgia, serif; }
        .button:hover { background-color: #63392b; transform: translateY(-2px); }
        select { padding: 8px; border: 1px solid #A5A58D; border-radius: 5px; background-color: white; color: #63392b; margin: 0 10px; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="Store.jsp">Menu</a>
        <a href="AboutMe.jsp">About Me</a>
        <a href="Recipes.jsp">Recipes</a>
        <a href="PlaceOrder.jsp">View Cart &#x1F6D2;</a>
        
    </nav>

    <div class="container">
        <h1>Raina's Desserts</h1>
        <p class="intro-text">
            Hi, I'm <b>Raina Gopalan</b>, a self-taught teen baker with a passion for spreading joy through sweet treats!  
            Everything I offer is homemade and baked with love &#x2661;
        </p>

        <%
            // DB connection
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

        <div class="product">
            <div class="product-container">
                <img src="<%= imageURL %>" alt="<%= name %>" class="product-image">
                <div class="product-details">
                    <h2><%= name %></h2>
                    <h4><%= description %></h4>
                    <p>$<%= price %></p>
                    <form action="PlaceOrder.jsp" method="post">
                            <input type="hidden" name="productID" value="<%= productID %>">
                
                            <input type="number" name="quantity" value="1" min="1" style="width:50px;">
                        <button type="submit" class="button">Add to Cart</button>
                    </form>
                </div>
            </div>
        </div>

        <%
                }
                rs.close();
                stmt.close();
                conn.close();
            } catch(Exception e) {
                out.println("<p style='color:red;'>Error loading products: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</body>
</html>