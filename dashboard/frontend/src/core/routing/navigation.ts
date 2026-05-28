import { ROUTES } from "./routes";
import { 
  Home, Users, GraduationCap, UserCheck, BookOpen, 
  Calendar, Check, ClipboardList, Megaphone, Bus, Archive, Video,
  CreditCard, TrendingUp, ShieldCheck, FileText, Settings, Bell, MessageSquare
} from "lucide-react";

export const NAVIGATION_MAP = [
  { label: "Dashboard", href: ROUTES.DASHBOARD.HOME, icon: Home },
  { label: "Students", href: ROUTES.DASHBOARD.STUDENTS, icon: Users },
  { label: "Teachers", href: ROUTES.DASHBOARD.TEACHERS, icon: GraduationCap },
  { label: "Parents", href: ROUTES.DASHBOARD.PARENTS, icon: UserCheck },
  { label: "Drivers", href: ROUTES.DASHBOARD.DRIVERS, icon: Bus },
  { label: "Classes", href: ROUTES.DASHBOARD.CLASSES, icon: Archive },
  { label: "Subjects", href: ROUTES.DASHBOARD.SUBJECTS, icon: BookOpen },
  { label: "Attendance", href: ROUTES.DASHBOARD.ATTENDANCE, icon: ClipboardList },
  { label: "Transport", href: ROUTES.DASHBOARD.TRANSPORT, icon: Bus },
  { label: "Payments", href: ROUTES.DASHBOARD.PAYMENTS, icon: CreditCard },
  { label: "Reports", href: ROUTES.DASHBOARD.REPORTS, icon: FileText },
  { label: "Announcements", href: ROUTES.DASHBOARD.ANNOUNCEMENTS, icon: Megaphone },
  { label: "Notifications", href: ROUTES.DASHBOARD.NOTIFICATIONS, icon: Bell },
  { label: "Settings", href: ROUTES.DASHBOARD.SETTINGS, icon: Settings },
];
