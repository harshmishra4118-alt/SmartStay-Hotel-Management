package com.hotel.servlet.admin;

import com.hotel.model.Feedback;
import com.hotel.model.User;
import com.hotel.service.FeedbackService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminFeedbackServlet", urlPatterns = {"/admin/feedback"})
public class AdminFeedbackServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminFeedbackServlet.class);
    private final FeedbackService feedbackService = new FeedbackService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String approvedStr = req.getParameter("approved");
        Boolean approved = null;
        if ("true".equals(approvedStr)) approved = true;
        if ("false".equals(approvedStr)) approved = false;

        try {
            List<Feedback> feedbacks = feedbackService.listAllFeedback(approved, 0, 50);
            req.setAttribute("feedbacks", feedbacks);
            req.setAttribute("selectedApproved", approvedStr);

            req.getRequestDispatcher("/WEB-INF/views/admin/feedback.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load feedback", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading feedback.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAdmin = (User) session.getAttribute("currentUser");

        String action = req.getParameter("action");
        String idStr = req.getParameter("feedbackId");

        try {
            Long feedbackId = Long.parseLong(idStr.trim());
            if ("toggleApproval".equals(action)) {
                boolean approved = Boolean.parseBoolean(req.getParameter("approved"));
                feedbackService.setApproval(feedbackId, approved, currentAdmin.getId(), req.getRemoteAddr());
            } else if ("reply".equals(action)) {
                String reply = req.getParameter("reply");
                feedbackService.addAdminReply(feedbackId, reply, currentAdmin.getId(), req.getRemoteAddr());
            }

            resp.sendRedirect(req.getContextPath() + "/admin/feedback?success=true");

        } catch (Exception e) {
            logger.error("Error moderating feedback", e);
            req.setAttribute("errorMessage", "Error modifying feedback: " + e.getMessage());
            doGet(req, resp);
        }
    }
}
