import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import { createServer } from "http";
import { env } from "./config/env";
import { errorHandler } from "./core/http/middlewares/errorHandler";
import { initWebSocket } from "./config/websocket";
import { startOverdueChecker } from "./cron/checkOverdueInvoices";
import routes from "./routes";

const app = express();
const httpServer = createServer(app);

// Initialize WebSocket with school-based room isolation
initWebSocket(httpServer);

app.use(helmet());
app.use(cors({ origin: env.allowedOrigins, credentials: true }));
app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ limit: "1mb", extended: true }));
app.use(morgan("dev"));

app.use("/api", routes);

app.get("/", (_req, res) => {
  res.json({ 
    message: "WeCircle API is running", 
    version: "2.0.0",
    docs: "/api/health",
    features: ["multi-tenant", "websocket", "real-time"]
  });
});

// Global error handler — must be last middleware
app.use(errorHandler);

httpServer.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`Server running on http://localhost:${env.port}`);
  console.log(`WebSocket ready on ws://localhost:${env.port}`);
  // Single-instance overdue-invoice checker (hourly). Disable via DISABLE_INPROCESS_CRON=true
  // when an external scheduler (EventBridge → /api/internal/cron/check-overdue) takes over.
  if (env.inProcessCron) startOverdueChecker();
});
