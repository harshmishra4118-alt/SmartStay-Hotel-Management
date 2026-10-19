<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="AuraStay Luxury Suites & Resort - Experience timeless elegance and smart hospitality in prime destinations.">
    <title>${pageTitle != null ? pageTitle : 'AuraStay Luxury Suites & Resort'}</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    
    <!-- AuraStay Master Luxury Theme -->
    <link href="${pageContext.request.contextPath}/assets/css/hotel-theme.css" rel="stylesheet">

    <script>
        window.AURA_CONTEXT_PATH = '${pageContext.request.contextPath}';
    </script>
</head>
<body class="d-flex flex-column min-vh-100">
