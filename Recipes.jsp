<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Raina's Bake Shop</title>
    <style>
        body{
            background-color: #fffaf7;
            margin: 0;
            padding: 0;
            font-family: Georgia, serif;
        }

        .navbar{
            display: flex;
            padding: 20px 0;
            position: sticky;
            top: 0;
            gap: 40px;
            z-index: 1000;
            justify-content: center;
            border-bottom: 1px dashed #A5A58D;
            background-color: #fffaf7;

        }

        .nav-links{
            display: flex;
            list-style: none;
            gap: 20px;
        }

        .nav-links a{
            color:#A5A58D;
            text-decoration: none;
            transition: all 0.3s ease;
            font-family: 'Brush Script MT';
            font-size: 1.6em;
            font-weight: bold;
        }



        .nav-links a:hover {
            color: #fedfb0;
            transform: scale(1.1) rotate(-2deg);
        }

        .container{
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .category-section{
            max-width: 1100px;
            margin: 40px auto;
        }

        .category-title{
            color:#63392b;
            font-size: 2.2em;
            margin-bottom: 5px
        }
        
        .divider{
            border: none;
            border-top: 1px solid #fedfb0;
            margin-bottom: 30px;
        }

        .recipe-grid{
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            justify-content: flex-start;
            width: 100%;
        }

        .recipe-card-small{
            width: calc(25% - 15px);
            margin-bottom: 30px;
        }

        .recipe-card-small img{
            width: 100%;
            height: 200px;
            display: block;
            object-fit: cover;
            border-radius: 12px;
        }

        .recipe-name{
            margin-top: 12px;
            font-weight: bold;
            color: #63392b;
            font-size: 1.1em;
        }

        .recipe-name a {
            text-decoration: none;
            color: inherit;
            transition: color 0.2s ease;
        }

        .recipe-name a:hover {
            color: #A5A58D;
        }

        .recipe-time{
            color: #a1887f;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="Store.jsp">Menu</a>
        <a href="AboutMe.jsp">About Me</a>
        <a href="Recipes.jsp" class="active"> Recipes</a>
        <a href="Cart.jsp"> View Cart &#x1F6D2;</a>
    </nav>

    <div class="container">
    <%
        // DATABASE CONNECTION SETTINGS
        String dbUrl = "jdbc:postgresql://localhost:5432/postgres";
        String dbUser = "postgres";
        String dbPass = "Raina";

        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 1. Get all unique categories to create the headers (Breads, Cakes, etc.)
            Statement categoryStmt = conn.createStatement();
            ResultSet categoryRs = categoryStmt.executeQuery("SELECT DISTINCT category FROM recipe ORDER BY category");

            while (categoryRs.next()) {
                String currentCategory = categoryRs.getString("category");
    %>
                <div class="category-section">
                    <h2 class="category-title"><%= currentCategory %></h2>
                    <hr class="divider">
                    <div class="recipe-grid">
                        <%
                            // 2. For each category, get the recipes that belong to it
                            PreparedStatement recipeStmt = conn.prepareStatement("SELECT id, name, totaltime, photo FROM recipe WHERE category = ?");
                            recipeStmt.setString(1, currentCategory);
                            ResultSet recipeRs = recipeStmt.executeQuery();

                            while (recipeRs.next()) {
                                int id = recipeRs.getInt("id");
                                String name = recipeRs.getString("name");
                                int time = recipeRs.getInt("totaltime");
                                String photo = recipeRs.getString("photo");
                                
                                // Format time display
                                String timeDisplay = (time >= 60) ? (time/60 + " hours") : (time + " minutes");
                        %>
                                <div class="recipe-card-small">
                                    <img src="<%= photo %>" alt="<%= name %>">
                                    <div class="recipe-name">
                                        <a href="RecipeDetail.jsp?id=<%= id %>"><%= name %></a>
                                    </div>
                                    <div class="recipe-time"><%= timeDisplay %></div>
                                </div>
                        <%
                            }
                        %>
                    </div>
                </div>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Database Connection Error: " + e.getMessage() + "</p>");
        } finally {
            if (conn != null) conn.close();
        }
    %>
    </div>
</body>
</html>