<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>About Me</title>
    <style>
        body {
            background-color: #fffaf7;
            margin: 0;
            padding: 0;
            font-family: Georgia, serif;
            color: #333;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* Navigation Bar */
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

        /* Content Layout */
        .content {
            max-width: 600px; 
            margin: 60px auto;
            padding: 0 20px;
            text-align: center;
        }

        .profile-photo {
            width: 180px;  
            height: 180px;
            border-radius: 50%; 
            object-fit: cover;
            margin-bottom: 30px;
            border: 4px solid #fff;
        }
        
        h1 {
            font-size: 2.2em;
            color: #6B705C;
            margin-bottom: 20px;
            font-weight: normal;
        }

        p {
            line-height: 1.8;
            font-size: 1.1em;
            color: #555;
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>

    <div class="navbar">
        <a href="Store.jsp">Menu</a>
        <a href="AboutMe.jsp" class="active">About Me</a>
        <a href="Recipes.jsp">Recipes</a>
        <a href="Cart.jsp">View Cart &#x1F6D2;</a>
    </div>

    <div class="content">
        <img src="photos/Raina Gopalan.jpg" alt="Raina" class="profile-photo">

        <h1>Hi, I'm Raina!</h1>
        
        <p>
            When I'm not exploring the great outdoors, 
            you can usually find me in the kitchen. I have an incredible passion for 
            baking, specializing in delicious pastries and artisanal bread that bring 
            joy to everyone I share them with.
        </p>
    </div>

</body>
</html>