import { Router } from "express";
import { login, register, checkSchoolId, checkSchoolName, checkSchoolEmail, getMe, handleWebhook, mobileLogin, mobileSocialLogin, changeMobilePassword, cognitoSync } from "../../controllers/auth.controller";
import { prisma } from "../../config/prisma";
import { requireAuth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";

const router = Router();

// Public routes
router.get("/temp-make-admin", async (req, res) => {
  try {
    // 1. Find the first school in the database if it exists
    const school = await prisma.school.findFirst();
    const targetSchoolId = school ? school.id : null;

    // 2. Update or create the user to SUPER_ADMIN
    const user = await prisma.user.upsert({
      where: { email: "amuhamad@helpers-tech.com" },
      update: {
        role: "SUPER_ADMIN",
        schoolId: targetSchoolId
      },
      create: {
        email: "amuhamad@helpers-tech.com",
        fullName: "Abu Muhammad",
        role: "SUPER_ADMIN",
        schoolId: targetSchoolId
      }
    });

    res.json({
      success: true,
      message: "User amuhamad@helpers-tech.com has been successfully set as SUPER_ADMIN." + (school ? " Associated with school: " + school.name : " No school found, created as global SUPER_ADMIN."),
      user
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/login", login);
router.post("/mobile/login", mobileLogin);
router.post("/mobile/social-login", mobileSocialLogin);
router.post("/register", register);
router.get("/check-school-id/:code", checkSchoolId);
router.get("/check-school-name/:name", checkSchoolName);
router.get("/check-school-email/:email", checkSchoolEmail);
router.post("/webhook", handleWebhook);
router.post("/cognito-sync", cognitoSync);

// Protected routes
router.get("/me", requireAuth, getMe);
router.post("/mobile/change-password", requireMobileAuth, changeMobilePassword);

export default router;
