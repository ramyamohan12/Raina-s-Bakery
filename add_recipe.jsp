<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin - Manage Recipes</title>
    <style>
        /* ===== BODY & FONTS ===== */
        body {
            font-family: Arial, Georgia, serif;
            background:#f9f3ef;
            padding:20px;
            color:#4a2c2a;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        h1.recipe-title {
            text-align: center;
            color:#A67B5B;
            font-size: 2.2em;
            margin-bottom: 20px;
        }

        /* ===== NAV BAR ===== */
        .navbar {
            width: 100%;
            background: #A67B5B;
            padding: 10px 20px;
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 40px;
            border-radius: 8px;
        }
        .navbar a {
            color: white;
            text-decoration: none;
            font-weight: bold;
            font-size: 1.1em;
        }
        .navbar a:hover {
            text-decoration: underline;
            color: #fff7f0;
        }

        /* ===== FORM CONTAINER ===== */
        .recipe-container {
            max-width: 900px; 
            margin-bottom: 60px;
            width: 100%;
        }

        .recipe-content-col {
            background:#fff;
            padding:20px;
            border-radius:8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 40px;
        }

        label {
            display: block;
            margin-top: 15px;
            margin-bottom: 5px;
            font-weight: bold;
            color: #63392b;
        }

        input[type="text"], select, textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #A5A58D;
            border-radius: 4px;
            font-family: Georgia, serif;
            box-sizing: border-box;
        }

        .submit-btn {
            background-color: #A67B5B;
            color: white;
            border: none;
            padding: 12px 20px;
            font-size: 1.2em;
            cursor: pointer;
            width: 100%;
            border-radius: 5px;
            margin-top: 10px;
            transition: all 0.3s ease;
        }
        .submit-btn:hover {
            background-color: #63392b;
            transform: scale(1.03);
        }

        /* ===== TABLE ===== */
        .recipe-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        .recipe-table th, .recipe-table td {
            padding:8px 12px;
            border:1px solid #ddd;
            text-align:left;
        }
        .recipe-table th {
            background:#A67B5B;
            color:white;
        }
        .recipe-table tr:nth-child(even) {
            background:#f7f3f0;
        }
        .recipe-table input[type="text"] {
            width: 90%;
            padding: 4px;
            border: 1px solid #A5A58D;
            border-radius: 3px;
        }

        /* ===== ACTION BUTTONS ===== */
        .action-link {
            background: none;
            border: none;
            cursor: pointer;
            font-weight: bold;
            color: #A67B5B;
            margin-right: 5px;
        }
        .action-link:hover {
            color: #63392b;
            text-decoration: underline;
        }
    </style>
</head>
<body>

<!-- ===== NAVIGATION ===== -->
<nav class="navbar">
    <a href="add_recipe.jsp">Add Recipe</a>
    <a href="order-item.jsp">Orders</a>
    <a href="products.jsp">Products in Menu</a>
</nav>

<div class="recipe-container">
    <h1 class="recipe-title">Manage Recipes</h1>

    <!-- ================= ADD RECIPE ================= -->
    <div class="recipe-content-col">
        <form action="${pageContext.request.contextPath}/RecipeServlet" method="POST">
            <input type="hidden" name="action" value="add">

            <label>Recipe Name:</label>
            <input type="text" name="recipeName" required>

            <label>Category:</label>
            <select name="category">
                <option value="Cookies">Cookies</option>
                <option value="Cakes">Cakes</option>
            </select>

            <label>Preparation Time:</label>
            <input type="text" name="prepTime">

            <label>Total Time:</label>
            <input type="text" name="totalTime">

            <label>Ingredients:</label>
            <textarea name="ingredients" rows="4"></textarea>

            <label>Instructions:</label>
            <textarea name="steps" rows="6"></textarea>

            <label>Notes:</label>
            <textarea name="notes" rows="2"></textarea>

            <label>Photo URL:</label>
            <input type="text" name="photo">

            <button type="submit" class="submit-btn">Add Recipe</button>
        </form>
    </div>

    <!-- ================= RECIPE TABLE ================= -->
    <table class="recipe-table">
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Category</th>
            <th>Prep</th>
            <th>Total</th>
            <th>Actions</th>
        </tr>

<%
    String DB_URL  = "jdbc:postgresql://localhost:5432/postgres";
    String DB_USER = "postgres";
    String DB_PASS = "Raina";

    try {
        Class.forName("org.postgresql.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String sql = "SELECT * FROM recipe ORDER BY id DESC";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();

        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><input type="text" name="recipeName" form="updateForm<%=rs.getInt("id")%>" value="<%= rs.getString("name") %>"></td>
            <td><input type="text" name="category" form="updateForm<%=rs.getInt("id")%>" value="<%= rs.getString("category") %>"></td>
            <td><input type="text" name="prepTime" form="updateForm<%=rs.getInt("id")%>" value="<%= rs.getInt("preptime") %>"></td>
            <td><input type="text" name="totalTime" form="updateForm<%=rs.getInt("id")%>" value="<%= rs.getInt("totaltime") %>"></td>
            <td>
                <!-- UPDATE FORM -->
                <form id="updateForm<%=rs.getInt("id")%>" action="${pageContext.request.contextPath}/RecipeServlet" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                    <input type="hidden" name="ingredients" value="<%= rs.getString("ingredients") %>">
                    <input type="hidden" name="steps" value="<%= rs.getString("steps") %>">
                    <input type="hidden" name="notes" value="<%= rs.getString("notes") %>">
                    <input type="hidden" name="photo" value="<%= rs.getString("photo") %>">
                </form>
                <button type="submit" form="updateForm<%=rs.getInt("id")%>" class="action-link">Update</button>

                <!-- DELETE FORM -->
                <form action="${pageContext.request.contextPath}/RecipeServlet" method="POST" style="display:inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                    <button type="submit" class="action-link" onclick="return confirm('Delete this recipe?');">Delete</button>
                </form>
            </td>
        </tr>
<%
        }
        conn.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
    </table>
</div>
</body>
</html>