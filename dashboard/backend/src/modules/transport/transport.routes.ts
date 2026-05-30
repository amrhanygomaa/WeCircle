import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { getIO } from "../../config/websocket";
import { prisma } from "../../config/prisma";
import {
  getBuses,
  upsertBus,
  toggleTrip,
  getRoutes,
  createRoute,
  deleteBus,
  deleteRoute,
  getTransportStudents,
  assignStudentsToBus
} from "./transport.controller";
import {
  getDrivers,
  createDriver,
  updateDriver,
  deleteDriver
} from "./driver.controller";
import {
  getSupervisors,
  createSupervisor,
  updateSupervisor,
  deleteSupervisor
} from "./supervisor.controller";
const router = Router();

// ── Mobile (AppCredential JWT) — before requireAuth ────────────────────────

// Driver: update GPS location → stored on Bus + broadcast via Socket.IO
router.post("/mobile/location", requireMobileAuth, async (req, res) => {
  const schoolId = req.schoolId;
  const driverId = req.driverId;
  if (!driverId) return res.status(403).json({ success: false, message: "Driver context required" });
  const { lat, lng } = req.body;
  if (typeof lat !== "number" || typeof lng !== "number") {
    return res.status(400).json({ success: false, message: "lat and lng (numbers) required" });
  }
  try {
    await prisma.bus.updateMany({
      where: { schoolId: schoolId!, driver: { id: driverId } },
      data: { lastLat: lat, lastLng: lng, locationUpdatedAt: new Date() } as any,
    });
    getIO().to(`school:${schoolId}`).emit("bus:location", { driverId, lat, lng, updatedAt: new Date() });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Parent: get their child's bus info + driver's last known location
router.get("/mobile/bus-status", requireMobileAuth, async (req, res) => {
  const schoolId = req.schoolId;
  const { studentId } = req.query;
  if (!studentId || typeof studentId !== "string") {
    return res.status(400).json({ success: false, message: "studentId required" });
  }
  try {
    const sb = await prisma.studentBus.findFirst({
      where: { studentId, student: { schoolId: schoolId! } },
      include: {
        bus: {
          include: {
            driver: { include: { user: { select: { fullName: true } } } },
            supervisor: { include: { user: { select: { fullName: true } } } },
          },
        },
        route: { select: { name: true } },
      },
    });
    if (!sb?.bus) return res.json({ success: true, data: null });
    const bus = sb.bus as any;
    res.json({
      success: true,
      data: {
        busNumber: bus.number,
        plateNumber: bus.plateNumber,
        status: bus.status,
        driverName: bus.driver?.user?.fullName ?? null,
        supervisorName: bus.supervisor?.user?.fullName ?? null,
        routeName: sb.route?.name ?? null,
        pickupPoint: sb.pickupPoint,
        dropoffPoint: sb.dropoffPoint,
        lastLat: bus.lastLat ?? null,
        lastLng: bus.lastLng ?? null,
        locationUpdatedAt: bus.locationUpdatedAt ?? null,
      },
    });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── Web dashboard ──────────────────────────────────────────────────────────
router.use(requireAuth, tenantScope);

router.get("/buses", getBuses);
router.post("/buses", upsertBus);
router.post("/buses/:id/trip", toggleTrip);
router.post("/buses/:id/students", assignStudentsToBus);

router.get("/students", getTransportStudents);

router.get("/routes", getRoutes);
router.post("/routes", createRoute);
router.delete("/buses/:id", deleteBus);
router.delete("/routes/:id", deleteRoute);

router.get("/drivers", getDrivers);
router.post("/drivers", createDriver);
router.put("/drivers/:id", updateDriver);
router.delete("/drivers/:id", deleteDriver);

router.get("/supervisors", getSupervisors);
router.post("/supervisors", createSupervisor);
router.put("/supervisors/:id", updateSupervisor);
router.delete("/supervisors/:id", deleteSupervisor);

export default router;
