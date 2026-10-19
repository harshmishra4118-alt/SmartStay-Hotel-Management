<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Forward directly to the public home servlet
    response.sendRedirect(request.getContextPath() + "/home");
%>
