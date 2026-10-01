<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Recipe Detail - Raina's Bake Shop</title>
    <style>
        body{
            background-color: #fffaf7;
            margin: 0;
            padding: 0;
            font-family: Georgia, serif;
        }

        /* Navigation bar - matching your other site exactly */
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


        /* Recipe Content Styling */
        .recipe-container {
            max-width: 1100px;
            margin: 50px auto;
            padding: 20px;
            display: flex;
            gap: 50px;
        }

        .recipe-info-col { flex: 1; }
        .recipe-info-col img { 
            width: 100%; 
            border-radius: 12px; 
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); 
            object-fit: cover;
        }

        .recipe-title { color: #63392b; font-size: 2.2em; margin: 15px 0 5px 0; }
        .recipe-category { color: #8d6e63; font-weight: bold; text-transform: uppercase; letter-spacing: 1px; }
        .recipe-time { color: #A5A58D; font-family: monospace; margin-top: 10px; }
        
        .recipe-content-col { flex: 1.5; }
        h3 { color: #63392b; border-bottom: 1px solid #fedfb0; padding-bottom: 5px; margin-top: 25px; }
        
        .notes-box { 
            margin-top: 30px; 
            padding: 15px; 
            border-left: 4px solid #fedfb0; 
            font-style: italic; 
            background: #fffcf0; 
        }

        .nav-back { 
            display: inline-block; 
            margin-bottom: 20px; 
            text-decoration: none; 
            color: #A5A58D; 
            font-weight: bold; 
        }

        @media (max-width: 768px) { .recipe-container { flex-direction: column; } }
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
        <div class="recipe-container">
        <%
            String recipeId = request.getParameter("id");
            if (recipeId == null) {
                out.println("<h1 class='recipe-title'>No recipe selected.</h1>");
            } else {
                // Database credentials - Update these to your actual settings
                String dbUrl = "jdbc:postgresql://localhost:5432/postgres";
                String dbUser = "postgres";
                String dbPass = "Raina";

                Connection conn = null;
                try {
                    Class.forName("org.postgresql.Driver");
                    conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                    PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM recipe WHERE id = ?");
                    pstmt.setInt(1, Integer.parseInt(recipeId));
                    ResultSet rs = pstmt.executeQuery();

                    if (rs.next()) {
                        int time = rs.getInt("totaltime");
                        String timeDisplay = (time >= 60) ? (time/60 + " hours") : (time + " minutes");
        %>
            <div class="recipe-info-col">
                <a href="Recipes.jsp" class="nav-back">&larr; Back to Recipes</a>
                <img src="<%= rs.getString("photo") %>" alt="Recipe Image">
                <h1 class="recipe-title"><%= rs.getString("name") %></h1>
                <div class="recipe-category"><%= rs.getString("category") %></div>
                <div class="recipe-time">Time: <%= timeDisplay %></div>
            </div>

            <div class="recipe-content-col">
                <h3>Ingredients:</h3>
                <ul>
                    <% 
                        String ingredients = rs.getString("ingredients");
                        if(ingredients != null) {
                            for (String item : ingredients.split("\n")) { 
                                if(!item.trim().isEmpty()) { %> <li><%= item %></li> <% }
                            }
                        }
                    %>
                </ul>

                <h3>Steps:</h3>
                <ol>
                    <% 
                        String steps = rs.getString("steps");
                        if(steps != null) {
                            for (String step : steps.split("\n")) { 
                                if(!step.trim().isEmpty()) { %> <li><%= step %></li> <% }
                            }
                        }
                    %>
                </ol>

                <% if(rs.getString("notes") != null && !rs.getString("notes").isEmpty()) { %>
                    <div class="notes-box">
                        <strong>Notes:</strong><br>
                        <%= rs.getString("notes") %>
                    </div>
                <% } %>
            </div>
        <%
                    } else {
                        out.println("<h1 class='recipe-title'>Recipe not found.</h1>");
                    }
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                } finally {
                    if (conn != null) conn.close();
                }
            }
        %>
        </div>
    </div>

</body>
</html>