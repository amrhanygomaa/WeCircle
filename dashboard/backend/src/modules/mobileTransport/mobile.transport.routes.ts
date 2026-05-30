import { Router } from "express";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import {
  getDriverDashboard,
  getSupervisorDashboard,
  markDriverBusAttendance,
  markBusAttendance,
  updateSupervisorProfile,
  updateDriverProfile,
  updateDriverLocation
} from "./mobile.transport.controller";

const router = Router();

router.use(requireMobileAuth);

router.get("/driver/dashboard", getDriverDashboard);
router.put("/driver/profile", updateDriverProfile);
router.post("/driver/location", updateDriverLocation);
router.post("/driver/attendance", markDriverBusAttendance);
router.get("/supervisor/dashboard", getSupervisorDashboard);
router.post("/supervisor/attendance", markBusAttendance);
router.put("/supervisor/profile", updateSupervisorProfile);

export default router;
