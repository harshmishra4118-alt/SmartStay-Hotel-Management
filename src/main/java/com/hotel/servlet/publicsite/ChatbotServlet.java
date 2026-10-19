package com.hotel.servlet.publicsite;

import com.google.gson.Gson;
import com.hotel.service.FaqChatbotService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "ChatbotServlet", urlPatterns = {"/api/chatbot"})
public class ChatbotServlet extends HttpServlet {

    private final FaqChatbotService chatbotService = new FaqChatbotService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        String query = req.getParameter("query");
        FaqChatbotService.ChatResponse chatResponse = chatbotService.processQuery(query);

        String json = gson.toJson(chatResponse);
        resp.getWriter().write(json);
    }
}
