package com.hotel.servlet.admin;

import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.StaffDetailDAO;
import com.hotel.dao.UserDAO;
import com.hotel.model.StaffDetail;
import com.hotel.model.User;
import com.hotel.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "AdminStaffServlet", urlPatterns = {"/admin/staff"})
public class AdminStaffServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminStaffServlet.class);
    private final StaffDetailDAO staffDetailDAO = new StaffDetailDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AuthService authService = new AuthService();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<StaffDetail> staffList = staffDetailDAO.listAllStaff();
            req.setAttribute("staffList", staffList);
            req.setAttribute("departments", StaffDetail.Department.values());
            req.setAttribute("shifts", StaffDetail.Shift.values());

            req.getRequestDispatcher("/WEB-INF/views/admin/staff.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load staff list", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading staff records.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAdmin = (User) session.getAttribute("currentUser");

        String action = req.getParameter("action");

        try {
            if ("create".equals(action)) {
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String password = req.getParameter("password");
                String employeeCode = req.getParameter("employeeCode");
                String departmentStr = req.getParameter("department");
                String shiftStr = req.getParameter("shift");

                User user = authService.register(email, password, fullName, phone, req.getRemoteAddr());
                userDAO.updateRole(user.getId(), User.Role.STAFF);

                StaffDetail staff = new StaffDetail();
                staff.setUserId(user.getId());
                staff.setEmployeeCode(employeeCode.trim().toUpperCase());
                staff.setDepartment(StaffDetail.Department.valueOf(departmentStr));
                staff.setShift(StaffDetail.Shift.valueOf(shiftStr));
                staff.setHireDate(LocalDate.now());

                staffDetailDAO.saveOrUpdate(staff);

                auditLogDAO.log(currentAdmin.getId(), "STAFF_ACCOUNT_CREATED", "Staff", String.valueOf(user.getId()),
                        "Created staff account for " + fullName + " (" + employeeCode + ")", req.getRemoteAddr());

                resp.sendRedirect(req.getContextPath() + "/admin/staff?created=true");
            }

        } catch (Exception e) {
            logger.error("Failed to process staff action", e);
            req.setAttribute("errorMessage", "Error managing staff: " + e.getMessage());
            doGet(req, resp);
        }
    }
}
